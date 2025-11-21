# BattleOne Infrastructure

This repository contains Terraform configuration to deploy the BattleOne infrastructure on DigitalOcean, including PostgreSQL, Redis, Kratos identity management, and comprehensive Better Stack monitoring.

🚀 **Production-ready infrastructure with automated deployment, security hardening, and enterprise-grade monitoring!**

## 📚 Documentation

### Setup Guides
- **[DigitalOcean Setup](./docs/DIGITALOCEAN_SETUP.md)** - Complete DigitalOcean account and resource configuration
- **[GitHub Setup](./docs/GITHUB_SETUP.md)** - GitHub repository, secrets, and Actions configuration  
- **[Better Stack Monitoring](./docs/BETTERSTACK_SETUP.md)** - Modern log management and uptime monitoring

### Reference
- **[Project State](./docs/claude-state.md)** - Development session state and progress tracking

## 🏗️ Architecture

- **Platform**: DigitalOcean Droplet + Spaces + VPC
- **Region**: Toronto (tor1) - configurable
- **Services**: PostgreSQL, Redis, Kratos, Better Stack Native Collector
- **State Storage**: DigitalOcean Spaces (S3-compatible)
- **Deployment**: GitHub Actions + Terraform
- **Monitoring**: Better Stack (modern observability platform)

## 🚀 Quick Start

### 1. Prerequisites
- DigitalOcean account with payment method
- GitHub repository with this code
- Better Stack account (generous free tier)

### 2. Setup (15 minutes)
1. **[Configure DigitalOcean](./docs/DIGITALOCEAN_SETUP.md)** - API keys, Spaces, SSH keys
2. **[Configure GitHub](./docs/GITHUB_SETUP.md)** - Repository secrets, Actions
3. **[Configure Better Stack](./docs/BETTERSTACK_SETUP.md)** - Modern monitoring setup

### 3. Deploy
- Push to main branch OR manually trigger GitHub Actions
- Infrastructure deploys automatically in ~5 minutes
- Monitor progress in GitHub Actions tab

### 4. Access
- **SSH**: `ssh root@DROPLET_IP`
- **Monitoring**: [Better Stack Dashboard](https://betterstack.com/logs)
- **Services**: All internal-only (secure by design)

## 🏗️ Infrastructure Components

### Core Services
- **PostgreSQL 15**: Primary database with persistent storage
- **Redis 7**: Cache and session storage with authentication  
- **Kratos v1.0.0**: Identity and user management system
- **Better Stack Native Collector**: eBPF-based observability with automatic instrumentation

### Infrastructure  
- **DigitalOcean Droplet**: s-2vcpu-4gb (scalable)
- **Block Storage**: 20GB persistent SSD volume
- **VPC**: Private network (10.50.0.0/24) 
- **Firewall**: SSH (22), HTTP (80), HTTPS (443) - All services internal-only
- **Monitoring**: Host + container + application metrics

## 💰 Cost Breakdown

| Component | Monthly Cost | Notes |
|-----------|--------------|--------|
| **Droplet** (s-2vcpu-4gb) | $24.00 | Scalable compute |
| **Block Storage** (20GB) | $2.00 | Persistent data |
| **Spaces** (Terraform state) | $0.50 | Object storage |
| **Better Stack Monitoring** | $0.00 | Generous free tier |
| **Total** | **~$26.50** | Production-ready infrastructure |

*New DigitalOcean accounts get $200 free credit (60 days)*

## 🔐 Security Features

- **🔒 Internal Services**: PostgreSQL, Redis, Kratos only accessible within VPC
- **🛡️ Firewall Protection**: Minimal external ports (SSH, HTTP, HTTPS only)
- **🔑 SSH Key Authentication**: No password authentication  
- **📊 Monitoring**: Real-time security and performance monitoring
- **🗂️ Encrypted Storage**: All data encrypted at rest
- **🔄 Automated Updates**: Infrastructure as Code with version control

## ⚙️ Deployment Options

### Automatic (Recommended)
- **Push to main branch** → Automatically deploys infrastructure
- **Manual trigger** → GitHub Actions → "Deploy BattleOne Infrastructure"

### Manual Commands  
```bash
# Deploy infrastructure
gh workflow run "Deploy BattleOne Infrastructure" --field action=apply

# Preview changes only  
gh workflow run "Deploy BattleOne Infrastructure" --field action=plan

# Destroy all resources (SEPARATE WORKFLOW)
gh workflow run "Destroy BattleOne Infrastructure" --field confirmation=DESTROY
```

## 🌐 Service Access

After deployment, access your infrastructure:

### External Access
- **SSH**: `ssh root@DROPLET_IP` 
- **Monitoring**: [Datadog Dashboard](https://app.datadoghq.com/infrastructure)

### Internal Services (VPC only)
All database and API services are secure and only accessible from within the VPC:
- **PostgreSQL**: `postgresql://battleone_user:PASSWORD@10.50.0.2:5432/battleone`
- **Redis**: `redis://:PASSWORD@10.50.0.2:6379`  
- **Kratos Public**: `http://10.50.0.2:4433`
- **Kratos Admin**: `http://10.50.0.2:4434`

For admin access, use SSH tunneling as documented in the setup guides.

## 🧪 Local Development

For local Terraform development and testing:

### Prerequisites
- Terraform >= 1.6
- DigitalOcean CLI (`doctl`)
- Valid DigitalOcean account with API access

### Quick Setup
```bash
# Install doctl and authenticate
curl -sL https://github.com/digitalocean/doctl/releases/download/v1.94.0/doctl-1.94.0-linux-amd64.tar.gz | tar -xzv
sudo mv doctl /usr/local/bin
doctl auth init

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Initialize and plan
terraform init
terraform plan
```

**⚠️ Note**: For production deployment, use GitHub Actions as documented in the setup guides.

## 📁 Project Structure

```
battleone-infrastructure/
├── 📋 README.md                # This file
├── 📋 terraform.tfvars.example # Example configuration
├── 🏗️  main.tf                # Main Terraform configuration  
├── 🔧 variables.tf            # Input variables
├── 📤 outputs.tf              # Output values
├── ☁️  cloud-init.yml         # Server initialization
├── 🐳 docker-compose.yml      # Service orchestration
├── 📊 datadog/                # Monitoring configuration
│   ├── datadog.yaml          # Agent configuration
│   └── conf.d/               # Service integrations
├── 🔐 kratos/                 # Identity management
│   ├── kratos.yml            # Kratos configuration
│   └── identity.schema.json  # User schema
├── 🗃️  postgres/              # Database setup
│   └── init-datadog-user.sql # Monitoring user
├── 📚 docs/                   # Complete documentation
│   ├── DIGITALOCEAN_SETUP.md # DO account setup
│   ├── GITHUB_SETUP.md       # GitHub Actions setup  
│   ├── DATADOG_SETUP.md      # Free monitoring setup
│   └── claude-state.md       # Project status
└── ⚙️  .github/workflows/     # CI/CD automation
    └── terraform-deploy.yml  # Deployment pipeline
```

## 🩺 Health & Monitoring

### Automated Health Checks
The deployment includes comprehensive monitoring:
- ✅ **Host metrics**: CPU, memory, disk, network via Datadog
- ✅ **Container health**: All Docker services monitored
- ✅ **Database connectivity**: PostgreSQL connection and performance
- ✅ **Cache performance**: Redis metrics and memory usage  
- ✅ **API endpoints**: Kratos health monitoring
- ✅ **Log aggregation**: Centralized logging from all services

### Manual Service Checks
```bash
# SSH to server and check status
ssh root@DROPLET_IP
cd /opt/battleone
docker-compose ps
docker-compose logs [service_name]

# Check individual services
docker-compose logs postgres
docker-compose logs redis  
docker-compose logs kratos
docker-compose logs better-stack-collector
```

### Monitoring Dashboard
Access your **free** Better Stack dashboard at [betterstack.com/logs](https://betterstack.com/logs)

## 🚨 Troubleshooting

Common issues and solutions:

### Deployment Failures
1. **Check GitHub Actions logs** in repository Actions tab
2. **Verify secrets** - ensure all 8 required secrets are set
3. **Check DigitalOcean billing** - payment method required

### Service Issues
```bash
# Reset all services
ssh root@DROPLET_IP
cd /opt/battleone
docker-compose restart

# Check specific service logs
docker-compose logs -f [service_name]

# Verify network connectivity
ping 10.50.0.2
```

### Need Help?
1. **📋 Documentation**: Check the comprehensive guides in `docs/`
2. **🐙 GitHub Issues**: Review Actions logs and error messages  
3. **☁️ DigitalOcean**: Verify account status and resource limits
4. **📊 Better Stack**: Monitor service health and performance metrics

For detailed troubleshooting, see the setup guides in the `docs/` folder.