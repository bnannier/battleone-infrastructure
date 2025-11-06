# BattleOne Infrastructure - Terraform Configuration
# Deploys PostgreSQL, Redis, and Kratos to DigitalOcean

terraform {
  required_version = ">= 1.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.digitalocean_token
}

# Create SSH key for droplet access
resource "digitalocean_ssh_key" "battleone_key" {
  name       = "battleone-infrastructure-key-${random_id.key_suffix.hex}"
  public_key = var.ssh_public_key
}

# Generate random suffix for unique resource names
resource "random_id" "key_suffix" {
  byte_length = 4
}

# Create a new VPC for our infrastructure
resource "digitalocean_vpc" "battleone_vpc" {
  name     = "battleone-network-${random_id.key_suffix.hex}"
  region   = var.region
  ip_range = "10.124.0.0/24"
}

# Create a firewall for our droplet
resource "digitalocean_firewall" "battleone_firewall" {
  name = "battleone-infrastructure-firewall-${random_id.key_suffix.hex}"

  droplet_ids = [digitalocean_droplet.battleone_infrastructure.id]

  # SSH access
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Kratos public API (health checks)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "4433"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow all outbound traffic
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Create a volume for persistent data
resource "digitalocean_volume" "battleone_data" {
  region                  = var.region
  name                    = "battleone-data-volume-${random_id.key_suffix.hex}"
  size                    = 20
  initial_filesystem_type = "ext4"
  description             = "Volume for BattleOne database and Redis data"
}

# Create the main infrastructure droplet
resource "digitalocean_droplet" "battleone_infrastructure" {
  image    = "docker-20-04" # Ubuntu 20.04 with Docker pre-installed
  name     = "battleone-infrastructure-${random_id.key_suffix.hex}"
  region   = var.region
  size     = var.droplet_size
  vpc_uuid = digitalocean_vpc.battleone_vpc.id

  ssh_keys = [digitalocean_ssh_key.battleone_key.id]

  # User data script to prepare the droplet
  user_data = templatefile("${path.module}/scripts/cloud-init.yml", {
    postgres_password = var.postgres_password
    redis_password    = var.redis_password
    postgres_db       = var.postgres_db
    postgres_user     = var.postgres_user
    kratos_log_level  = var.kratos_log_level
  })

  # Wait for droplet to be ready
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "echo 'Droplet initialization complete'"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
      host        = self.ipv4_address
    }
  }

  # Attach the volume
  volume_ids = [digitalocean_volume.battleone_data.id]
}

# Mount and format the volume
resource "null_resource" "mount_volume" {
  depends_on = [digitalocean_droplet.battleone_infrastructure]

  provisioner "remote-exec" {
    inline = [
      # Create mount point
      "mkdir -p /mnt/battleone-data",

      # Mount the volume (it should be at /dev/sda)
      "mount -o defaults /dev/sda /mnt/battleone-data",

      # Add to fstab for persistent mounting
      "echo '/dev/sda /mnt/battleone-data ext4 defaults 0 0' >> /etc/fstab",

      # Create directories for data
      "mkdir -p /mnt/battleone-data/postgres",
      "mkdir -p /mnt/battleone-data/redis",
      "mkdir -p /mnt/battleone-data/kratos",

      # Set proper permissions
      "chown -R 999:999 /mnt/battleone-data/postgres", # postgres user in container
      "chown -R 999:999 /mnt/battleone-data/redis",    # redis user in container
      "chmod 755 /mnt/battleone-data/kratos"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
      host        = digitalocean_droplet.battleone_infrastructure.ipv4_address
    }
  }
}

# Deploy the infrastructure using Docker Compose
resource "null_resource" "deploy_infrastructure" {
  depends_on = [null_resource.mount_volume]

  # Upload configuration files
  provisioner "file" {
    source      = "${path.module}/docker-compose.infrastructure.yml"
    destination = "/opt/battleone/docker-compose.infrastructure.yml"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
      host        = digitalocean_droplet.battleone_infrastructure.ipv4_address
    }
  }

  provisioner "file" {
    source      = "${path.module}/ory/"
    destination = "/opt/battleone/ory/"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
      host        = digitalocean_droplet.battleone_infrastructure.ipv4_address
    }
  }

  # Deploy the infrastructure
  provisioner "remote-exec" {
    inline = [
      "cd /opt/battleone",

      # Set environment variables
      "export POSTGRES_PASSWORD='${var.postgres_password}'",
      "export REDIS_PASSWORD='${var.redis_password}'",
      "export POSTGRES_DB='${var.postgres_db}'",
      "export POSTGRES_USER='${var.postgres_user}'",
      "export KRATOS_LOG_LEVEL='${var.kratos_log_level}'",

      # Deploy with Docker Compose
      "docker compose -f docker-compose.infrastructure.yml down || true",
      "docker compose -f docker-compose.infrastructure.yml pull",
      "docker compose -f docker-compose.infrastructure.yml up -d",

      # Wait for services to be ready
      "sleep 30",

      # Verify services are running
      "docker compose -f docker-compose.infrastructure.yml ps",

      # Test service health
      "docker exec battleone-postgres pg_isready -U ${var.postgres_user} -d ${var.postgres_db}",
      "docker exec battleone-redis redis-cli ping",
      "curl -f http://localhost:4433/health/ready"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
      host        = digitalocean_droplet.battleone_infrastructure.ipv4_address
    }
  }

  # Trigger redeployment when infrastructure files change
  triggers = {
    docker_compose_hash = filemd5("${path.module}/docker-compose.infrastructure.yml")
    kratos_config_hash  = filemd5("${path.module}/ory/kratos.yml")
  }
}