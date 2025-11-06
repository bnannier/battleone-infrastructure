# BattleOne Infrastructure

Modern infrastructure deployment for BattleOne using Terraform and DigitalOcean.

This repository deploys a complete infrastructure stack including PostgreSQL, Redis, and Ory Kratos that needs to be deployed before the BFF application.

## Components

### 1. PostgreSQL Database
- **Image**: `postgres:15-alpine`
- **Port**: `127.0.0.1:5432:5432`
- **Container**: `battleone-postgres`
- **Purpose**: Primary database for user data, sessions, and application state

### 2. Redis Cache
- **Image**: `redis:7-alpine`  
- **Port**: `127.0.0.1:6379:6379`
- **Container**: `battleone-redis`
- **Purpose**: Session storage, caching, and rate limiting

### 3. Ory Kratos Identity Management
- **Image**: `oryd/kratos:v1.0.0`
- **Ports**: 
  - Public API: `127.0.0.1:4433:4433`
  - Admin API: `127.0.0.1:4434:4434`
- **Container**: `battleone-kratos`
- **Purpose**: User authentication, registration, and identity management
- **Migrations**: Kratos handles its own table creation automatically

## Files Structure

```
battleone-infrastructure/
├── README.md                           # This file
├── GITHUB_SECRETS.md                   # GitHub Actions setup guide
├── docker-compose.infrastructure.yml   # Infrastructure services
├── deploy-infrastructure.sh            # Infrastructure deployment script
├── .github/workflows/
│   └── deploy-infrastructure.yml       # GitHub Actions workflow
└── ory/                                # Kratos configuration
    ├── kratos.yml                      # Main Kratos config
    ├── identity.schema.json            # User identity schema
    └── email-templates/                # Email templates
```

## Deployment Order

1. **First**: Deploy infrastructure using this folder
2. **Second**: Deploy BFF application from the main project

## 🚀 Quick Start with Terraform

### Prerequisites

1. **DigitalOcean Account** with API access
2. **GitHub Repository** with Actions enabled
3. **SSH Key Pair** for droplet access

### 1. Set Up GitHub Secrets

Run this script to configure all required secrets:

```bash
# Required secrets for Terraform deployment
gh secret set DIGITALOCEAN_ACCESS_TOKEN --body "your_digitalocean_api_token"
gh secret set DO_SSH_PRIVATE_KEY --body "$(cat private_public/private_key.txt)"
gh secret set DO_SSH_PUBLIC_KEY --body "$(cat private_public/public_key.txt)"

# Database configuration
gh secret set POSTGRES_PASSWORD --body "$(openssl rand -base64 32)"
gh secret set REDIS_PASSWORD --body "$(openssl rand -base64 32)"

# Optional configuration (uses defaults if not set)
gh secret set POSTGRES_DB --body "battleone"
gh secret set POSTGRES_USER --body "battleone_user"
gh secret set KRATOS_LOG_LEVEL --body "warn"
```

### 2. Deploy Infrastructure

**Automatic Deployment** (on push to main):
```bash
git push origin main
```

**Manual Deployment**:
1. Go to GitHub Actions tab
2. Select "Deploy Infrastructure with Terraform"
3. Click "Run workflow"
4. Choose action: `apply`, `plan`, or `destroy`

### 3. Verify Deployment

After successful deployment, check the health endpoint:
```bash
curl http://YOUR_DROPLET_IP:4433/health/ready
```

## 🛠️ Local Development

### Terraform Commands

```bash
# Initialize Terraform
terraform init

# Plan infrastructure changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

### Environment Configuration

Create `terraform.tfvars` (copy from `terraform.tfvars.example`):
```hcl
digitalocean_token = "your_api_token"
ssh_private_key    = "your_private_key"
ssh_public_key     = "your_public_key"
postgres_password  = "secure_password"
redis_password     = "secure_password"
```

## 📁 Project Structure

```
├── main.tf                           # Core Terraform configuration
├── variables.tf                      # Input variables
├── outputs.tf                        # Output values
├── terraform.tfvars.example          # Example variables file
├── docker-compose.infrastructure.yml # Container definitions
├── scripts/
│   └── cloud-init.yml               # Droplet initialization
├── ory/
│   └── kratos.yml                   # Kratos configuration
├── private_public/
│   ├── private_key.txt              # SSH private key
│   └── public_key.txt               # SSH public key
└── .github/workflows/
    └── terraform-deploy.yml         # CI/CD workflow
```

## 🔧 Infrastructure Resources

### DigitalOcean Resources Created

| Resource | Purpose | Configuration |
|----------|---------|---------------|
| **Droplet** | Virtual machine | 2 vCPU, 2GB RAM, Ubuntu + Docker |
| **Volume** | Persistent storage | 20GB for database data |
| **VPC** | Private networking | 10.10.0.0/24 range |
| **Firewall** | Security rules | SSH (22), Kratos health (4433) |
| **SSH Key** | Authentication | Ed25519 key for secure access |

### Docker Services

| Service | Image | Purpose | Port | Data Volume |
|---------|-------|---------|------|-------------|
| **postgres** | postgres:15-alpine | Database | 5432 | /mnt/battleone-data/postgres |
| **redis** | redis:7-alpine | Cache | 6379 | /mnt/battleone-data/redis |
| **kratos** | oryd/kratos:v1.0.0 | Auth | 4433/4434 | Configuration only |

## Infrastructure Deployment

### 🚀 Option 1: Terraform (Recommended)

**Prerequisites**: 
- DigitalOcean droplet with SSH access
- GitHub secrets configured (see [GITHUB_SECRETS.md](./GITHUB_SECRETS.md))

**Deploy via GitHub Actions**:
1. **Configure secrets**: Follow [GITHUB_SECRETS.md](./GITHUB_SECRETS.md) to set up required secrets
2. **Trigger deployment**:
   - **Automatic**: Push changes to `main` branch
   - **Manual**: Go to Actions → "Deploy Infrastructure to DigitalOcean" → "Run workflow"

**Required GitHub Secrets**:
- `DO_SSH_PRIVATE_KEY` - SSH private key for droplet access
- `DO_DROPLET_IP` - Droplet IP address (e.g., `167.99.184.98`)
- `DO_USERNAME` - SSH username (usually `root`)
- `POSTGRES_PASSWORD` - Secure PostgreSQL password
- `REDIS_PASSWORD` - Secure Redis password

📖 **[Complete setup guide →](./GITHUB_SECRETS.md)**

### 🛠️ Option 2: Manual Deployment

**Prerequisites**:
- Docker and Docker Compose installed on the droplet
- Required environment variables set

**Required Environment Variables**:
```bash
export POSTGRES_PASSWORD="your_postgres_password"
export REDIS_PASSWORD="your_redis_password" 
export POSTGRES_DB="battleone"
export POSTGRES_USER="battleone_user"
export KRATOS_LOG_LEVEL="warn"
```

**Deploy Infrastructure**:
```bash
# Clone and copy to droplet
git clone https://github.com/bnannier/battleone-infrastructure.git
scp -r battleone-infrastructure/ user@droplet:/opt/battleone/infrastructure/

# SSH to droplet and deploy
ssh user@droplet
cd /opt/battleone/infrastructure
chmod +x deploy-infrastructure.sh
./deploy-infrastructure.sh
```

### 🔧 Option 3: Direct Docker Compose
```bash
# Start infrastructure services directly
docker compose -f docker-compose.infrastructure.yml up -d

# Check status
docker compose -f docker-compose.infrastructure.yml ps

# View logs
docker compose -f docker-compose.infrastructure.yml logs -f
```

## Network

The infrastructure creates a Docker network called `battleone-network` that the BFF application will connect to. This allows the BFF containers to communicate with the infrastructure services using service names:

- `postgres` - PostgreSQL database
- `redis` - Redis cache  
- `kratos` - Kratos identity service

## Health Checks

All services include health checks:
- **PostgreSQL**: `pg_isready` command
- **Redis**: `redis-cli ping` command  
- **Kratos**: HTTP health endpoint `/health/ready`

## Resource Limits

Conservative resource limits are set:
- **PostgreSQL**: 256MB RAM, 0.4 CPU
- **Redis**: 128MB RAM, 0.2 CPU
- **Kratos**: 256MB RAM, 0.3 CPU

## Data Persistence

Persistent volumes are created for:
- `postgres_data` - PostgreSQL data
- `redis_data` - Redis data

## Management Commands

```bash
# Check status
docker compose -f docker-compose.infrastructure.yml ps

# View logs
docker compose -f docker-compose.infrastructure.yml logs -f [service_name]

# Stop services
docker compose -f docker-compose.infrastructure.yml down

# Restart a service
docker compose -f docker-compose.infrastructure.yml restart [service_name]

# Backup database
docker exec battleone-postgres pg_dump -U battleone_user battleone > backup.sql

# Access PostgreSQL
docker exec -it battleone-postgres psql -U battleone_user -d battleone

# Access Redis
docker exec -it battleone-redis redis-cli
```

## Troubleshooting

### Check Infrastructure Status
```bash
cd /opt/battleone/infrastructure
docker compose -f docker-compose.infrastructure.yml ps
```

### View Service Logs
```bash
docker compose -f docker-compose.infrastructure.yml logs postgres
docker compose -f docker-compose.infrastructure.yml logs redis  
docker compose -f docker-compose.infrastructure.yml logs kratos
```

### Test Connectivity
```bash
# Test PostgreSQL
docker exec battleone-postgres pg_isready -U battleone_user -d battleone

# Test Redis
docker exec battleone-redis redis-cli ping

# Test Kratos
curl http://localhost:4433/health/ready
```

## Security Notes

- PostgreSQL and Redis are bound to `127.0.0.1` (localhost only)
- Kratos public/admin APIs are bound to `127.0.0.1` 
- All services communicate over the internal Docker network
- Strong passwords should be used for all database connections# Trigger Terraform deployment with real API token
