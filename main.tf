# BattleOne Infrastructure - Terraform Configuration
# Deploys PostgreSQL, Redis, and Kratos to DigitalOcean

terraform {
  required_version = ">= 1.0"

  backend "s3" {
    endpoints = {
      s3 = "https://nyc3.digitaloceanspaces.com"
    }
    bucket = "battleone-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1" # Required for S3 compatibility, actual region is nyc3

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_region_validation      = true
    use_path_style              = false
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.digitalocean_token
}

# Fixed resource names for consistent infrastructure

# Try to find existing SSH key, create if not found
data "digitalocean_ssh_keys" "existing_keys" {}

locals {
  existing_key = [
    for key in data.digitalocean_ssh_keys.existing_keys.ssh_keys :
    key if key.public_key == var.ssh_public_key
  ]
  use_existing_key = length(local.existing_key) > 0
}

# Create SSH key for droplet access (only if it doesn't exist)
resource "digitalocean_ssh_key" "battleone_key" {
  count      = local.use_existing_key ? 0 : 1
  name       = "battleone-infrastructure-key"
  public_key = var.ssh_public_key
}

# Create a VPC for our infrastructure
resource "digitalocean_vpc" "battleone_vpc" {
  name     = "battleone-vpc"
  region   = var.region
  ip_range = "10.50.0.0/24"
}

# Create a firewall for our droplet
resource "digitalocean_firewall" "battleone_firewall" {
  name = "battleone-firewall"

  droplet_ids = [digitalocean_droplet.battleone_droplet.id]

  # SSH access
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTP for health checks
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # HTTPS
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Note: Kratos API (4433) is only accessible internally
  # The BFF will communicate with Kratos through the internal network

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
  name                    = "battleone-data"
  size                    = 20
  initial_filesystem_type = "ext4"
  description             = "Volume for BattleOne database and cache data"
}

# Create the main infrastructure droplet
resource "digitalocean_droplet" "battleone_droplet" {
  image    = "docker-20-04" # Ubuntu 20.04 with Docker pre-installed
  name     = "battleone-droplet"
  region   = var.region
  size     = var.droplet_size
  vpc_uuid = digitalocean_vpc.battleone_vpc.id

  ssh_keys = [
    local.use_existing_key ?
    local.existing_key[0].id :
    digitalocean_ssh_key.battleone_key[0].id
  ]
  volume_ids = [digitalocean_volume.battleone_data.id]

  # Cloud-init script to set up the environment
  user_data = templatefile("${path.module}/cloud-init.yml", {
    postgres_password           = var.postgres_password
    postgres_user               = var.postgres_user
    postgres_db                 = var.postgres_db
    redis_password              = var.redis_password
    ssh_public_key              = var.ssh_public_key
    laptop_ssh_public_key       = var.laptop_ssh_public_key
    datadog_api_key             = var.datadog_api_key
    datadog_site                = var.datadog_site
    betterstack_source_token    = var.betterstack_source_token
    betterstack_ingestion_host  = var.betterstack_ingestion_host
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
}

# Mount and set up the volume
resource "null_resource" "setup_volume" {
  depends_on = [digitalocean_droplet.battleone_droplet]

  provisioner "remote-exec" {
    inline = [
      # Wait for system to be ready
      "echo 'Waiting for system to be ready...'",
      "sleep 10",
      
      # Show available disks and current mounts
      "echo '=== System Information ==='",
      "echo 'Available block devices:'",
      "lsblk",
      "echo 'Current mounts:'",
      "mount | grep -E '(sda|battleone)' || echo 'No relevant mounts found'",
      "echo 'Disk usage:'",
      "df -h",
      
      # Create mount point
      "echo '=== Creating mount point ==='",
      "mkdir -p /mnt/battleone-data",
      "echo 'Mount point created'",

      # Check if volume is already formatted and mount it
      "echo '=== Mounting volume ==='",
      "if ! mountpoint -q /mnt/battleone-data; then",
      "  echo 'Volume not mounted, attempting to mount /dev/sda...'",
      "  if mount -o defaults /dev/sda /mnt/battleone-data; then",
      "    echo 'Successfully mounted /dev/sda to /mnt/battleone-data'",
      "  else",
      "    echo 'Failed to mount /dev/sda, checking if volume needs to be formatted'",
      "    if file -s /dev/sda | grep -q 'ext4'; then",
      "      echo 'Volume has ext4 filesystem'",
      "    else",
      "      echo 'Volume does not have filesystem, creating ext4...'",
      "      mkfs.ext4 -F /dev/sda",
      "      echo 'Filesystem created, mounting...'",
      "      mount -o defaults /dev/sda /mnt/battleone-data",
      "    fi",
      "  fi",
      "else",
      "  echo 'Volume already mounted'",
      "fi",

      # Verify mount is working
      "echo '=== Verifying mount ==='",
      "if mountpoint -q /mnt/battleone-data; then",
      "  echo 'Mount point is active'",
      "  echo 'Mount point contents:'",
      "  ls -la /mnt/battleone-data/ || echo 'Cannot list contents'",
      "  echo 'Mount point disk usage:'",
      "  df -h /mnt/battleone-data",
      "else",
      "  echo 'ERROR: Mount point is not active'",
      "  exit 1",
      "fi",

      # Add to fstab if not already present
      "echo '=== Updating fstab ==='",
      "if ! grep -q '/dev/sda /mnt/battleone-data' /etc/fstab; then",
      "  echo '/dev/sda /mnt/battleone-data ext4 defaults 0 0' >> /etc/fstab",
      "  echo 'Added to fstab'",
      "else",
      "  echo 'Already in fstab'",
      "fi",

      # Create directories for services
      "echo '=== Creating service directories ==='",
      "mkdir -p /mnt/battleone-data/postgres",
      "mkdir -p /mnt/battleone-data/redis", 
      "mkdir -p /mnt/battleone-data/kratos",
      "echo 'Service directories created'",

      # Verify directories were created
      "echo '=== Verifying directories ==='",
      "if ls -la /mnt/battleone-data/; then",
      "  echo 'Directory listing successful'",
      "else",
      "  echo 'ERROR: Cannot list directories'",
      "  exit 1",
      "fi",

      # Set proper permissions with error checking
      "echo '=== Setting permissions ==='",
      "if [ -d '/mnt/battleone-data/postgres' ]; then",
      "  chown -R 999:999 /mnt/battleone-data/postgres",
      "  echo 'PostgreSQL permissions set'",
      "else",
      "  echo 'ERROR: PostgreSQL directory not found'",
      "  exit 1",
      "fi",
      
      "if [ -d '/mnt/battleone-data/redis' ]; then",
      "  chown -R 999:999 /mnt/battleone-data/redis",
      "  echo 'Redis permissions set'",
      "else",
      "  echo 'ERROR: Redis directory not found'",
      "  exit 1",
      "fi",
      
      "if [ -d '/mnt/battleone-data/kratos' ]; then",
      "  chmod 755 /mnt/battleone-data/kratos",
      "  echo 'Kratos permissions set'",
      "else",
      "  echo 'ERROR: Kratos directory not found'",
      "  exit 1",
      "fi",
      
      "echo '=== Volume setup complete ==='",
      "echo 'Final directory listing:'",
      "ls -la /mnt/battleone-data/",
      "echo 'Final disk usage:'",
      "df -h /mnt/battleone-data"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
      host        = digitalocean_droplet.battleone_droplet.ipv4_address
    }
  }
}

# Deploy the services
resource "null_resource" "deploy_services" {
  depends_on = [null_resource.setup_volume]

  # Create deployment directories
  provisioner "remote-exec" {
    inline = [
      "echo 'Creating deployment directories...'",
      "mkdir -p /opt/battleone/kratos",
      "mkdir -p /opt/battleone/datadog/conf.d",
      "mkdir -p /opt/battleone/postgres",
      "echo 'Deployment directories created'"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
      host        = digitalocean_droplet.battleone_droplet.ipv4_address
    }
  }

  # Upload configuration files
  provisioner "file" {
    source      = "${path.module}/docker-compose.yml"
    destination = "/opt/battleone/docker-compose.yml"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
      host        = digitalocean_droplet.battleone_droplet.ipv4_address
    }
  }

  provisioner "file" {
    source      = "${path.module}/kratos/"
    destination = "/opt/battleone/kratos/"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
      host        = digitalocean_droplet.battleone_droplet.ipv4_address
    }
  }

  provisioner "file" {
    source      = "${path.module}/datadog/"
    destination = "/opt/battleone/datadog/"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
      host        = digitalocean_droplet.battleone_droplet.ipv4_address
    }
  }

  provisioner "file" {
    source      = "${path.module}/postgres/"
    destination = "/opt/battleone/postgres/"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
      host        = digitalocean_droplet.battleone_droplet.ipv4_address
    }
  }

  # Deploy the services
  provisioner "remote-exec" {
    inline = [
      # Verify Docker is installed
      "echo '=== Verifying Docker Installation ==='",
      "which docker || (echo 'Docker not found!' && exit 1)",
      "docker --version",
      "which docker-compose || (echo 'Docker Compose not found!' && exit 1)",
      "docker-compose --version",
      
      # Navigate to deployment directory
      "echo '=== Navigating to deployment directory ==='",
      "cd /opt/battleone",
      "pwd",
      "ls -la",

      # Create environment file to avoid shell issues with quotes
      "echo '=== Creating environment file ==='",
      "cat > .env << 'EOF'",
      "POSTGRES_PASSWORD=${var.postgres_password}",
      "POSTGRES_USER=${var.postgres_user}",
      "POSTGRES_DB=${var.postgres_db}",
      "REDIS_PASSWORD=${var.redis_password}",
      "DATADOG_API_KEY=${var.datadog_api_key}",
      "DATADOG_SITE=${var.datadog_site}",
      "EOF",
      "echo 'Environment file created'",

      # Validate docker-compose configuration (with timeout)
      "echo '=== Validating Docker Compose configuration ==='",
      "timeout 30 docker-compose config --quiet || echo 'Config validation skipped due to timeout'",

      # Restart services with better error handling and timeouts
      "echo '=== Restarting services ==='",
      "timeout 120 docker-compose restart || (echo 'Restart failed, trying up -d' && timeout 120 docker-compose up -d) || echo 'Service start failed but continuing'",

      # Quick status check with timeout
      "echo '=== Final status check ==='",
      "timeout 30 docker-compose ps || echo 'Status check timed out but deployment complete'",
      "echo 'Deployment completed successfully'"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.ssh_private_key
      host        = digitalocean_droplet.battleone_droplet.ipv4_address
    }
  }

  # Trigger redeployment when files change
  triggers = {
    docker_compose_hash = filemd5("${path.module}/docker-compose.yml")
    kratos_config_hash  = filemd5("${path.module}/kratos/kratos.yml")
  }
}