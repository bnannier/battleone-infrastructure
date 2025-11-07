# BattleOne Infrastructure

This repository contains Terraform configuration to deploy the BattleOne infrastructure on DigitalOcean, including PostgreSQL, Redis, and Kratos identity management.

## Architecture

- **Platform**: DigitalOcean
- **Region**: Toronto (tor1)
- **Services**: PostgreSQL, Redis, Kratos (Ory Identity)
- **State Storage**: DigitalOcean Spaces
- **Deployment**: GitHub Actions

## Infrastructure Components

### Core Services
- **PostgreSQL 15**: Primary database with persistent storage
- **Redis 7**: Cache and session storage with authentication
- **Kratos v1.0.0**: Identity and user management system

### Infrastructure
- **DigitalOcean Droplet**: s-2vcpu-4gb in Toronto region
- **Volume**: 20GB persistent storage for data
- **VPC**: Private network (10.10.0.0/24)
- **Firewall**: SSH (22), HTTP (80), HTTPS (443), Kratos (4433)

## Prerequisites

### Required GitHub Secrets

Set these secrets in your GitHub repository (Settings → Secrets and variables → Actions):

```bash
# DigitalOcean Configuration
DIGITALOCEAN_ACCESS_TOKEN=dop_v1_your_digitalocean_token_here

# DigitalOcean Spaces (for Terraform state)
SPACES_ACCESS_KEY=DO801XXXXXXXXXXXXX
SPACES_SECRET_KEY=your_spaces_secret_key_here

# SSH Keys (generate with: ssh-keygen -t rsa -b 4096)
DO_SSH_PRIVATE_KEY=-----BEGIN OPENSSH PRIVATE KEY-----
# Your private key content here
-----END OPENSSH PRIVATE KEY-----

DO_SSH_PUBLIC_KEY=ssh-rsa AAAAB3NzaC1yc2EAAA... your-email@domain.com

# Database Passwords
POSTGRES_PASSWORD=your-secure-postgres-password
REDIS_PASSWORD=your-secure-redis-password

# Optional (with defaults)
POSTGRES_DB=battleone
POSTGRES_USER=battleone_user
```

### SSH Key Generation

Generate SSH keys for server access:

```bash
ssh-keygen -t rsa -b 4096 -C "battleone-infrastructure"
```

- Copy the **private key** content to `DO_SSH_PRIVATE_KEY` secret
- Copy the **public key** content to `DO_SSH_PUBLIC_KEY` secret

## Deployment

### Automatic Deployment

The infrastructure automatically deploys when:

1. **Push to main branch** - Automatically applies changes
2. **Manual trigger** - Use GitHub Actions workflow dispatch

### Manual Deployment Options

Go to **Actions** → **Deploy BattleOne Infrastructure** → **Run workflow**

Choose from:
- **apply**: Deploy/update infrastructure
- **plan**: Preview changes
- **destroy**: Remove all infrastructure

## Terraform State

- **Backend**: DigitalOcean Spaces
- **Bucket**: `battleone-terraform-state`
- **Region**: Toronto (tor1)
- **Key**: `terraform.tfstate`

## Service Access

After deployment, you'll receive:

### Public Access
- **Kratos API**: `http://DROPLET_IP:4433`
- **SSH**: `ssh root@DROPLET_IP`

### Internal Services
- **PostgreSQL**: `postgresql://battleone_user:PASSWORD@localhost:5432/battleone`
- **Redis**: `redis://:PASSWORD@localhost:6379`
- **Kratos Admin**: `http://localhost:4434`

## Local Development

### Prerequisites
- Terraform >= 1.6
- DigitalOcean CLI (doctl)

### Setup Environment

```bash
# Set Spaces credentials for Terraform state
export AWS_ACCESS_KEY_ID=DO801ADJ22JYLHKHJK9V
export AWS_SECRET_ACCESS_KEY=IjdU3WVcForYivTkuiLqrjvr9W22mGudBHVwfYHJS5k

# Copy and customize variables
cp terraform.tfvars.example terraform.tfvars
```

### Deploy Locally

```bash
terraform init
terraform plan
terraform apply
```

## File Structure

```
.
├── main.tf                     # Main Terraform configuration
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
├── terraform.tfvars.example    # Example configuration
├── cloud-init.yml             # Droplet initialization script
├── docker-compose.yml         # Services configuration
├── kratos/
│   ├── kratos.yml             # Kratos configuration
│   └── identity.schema.json   # Identity schema
└── .github/workflows/
    └── terraform-deploy.yml   # GitHub Actions deployment
```

## Health Monitoring

The deployment includes health checks for:

- ✅ Kratos API endpoint
- ✅ PostgreSQL connectivity
- ✅ Redis connectivity
- ✅ Docker container status

## Security Notes

- SSH access is restricted by firewall rules
- Database passwords are managed via GitHub secrets
- Kratos uses secure session management
- All data persisted on encrypted volumes

## Troubleshooting

### Check Service Status

```bash
ssh root@DROPLET_IP
cd /opt/battleone
docker-compose ps
docker-compose logs
```

### Verify Health

```bash
curl http://DROPLET_IP:4433/health/ready
```

### Reset Services

```bash
ssh root@DROPLET_IP
cd /opt/battleone
docker-compose restart
```

## Support

For issues or questions about the infrastructure deployment, check:

1. GitHub Actions logs for deployment errors
2. Service logs via SSH access
3. Terraform state in DigitalOcean Spaces