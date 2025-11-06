# BattleOne Infrastructure Setup

## Quick Start

1. **Set GitHub Secrets** (in repository settings):

```
DIGITALOCEAN_ACCESS_TOKEN = [Your DigitalOcean API token]
SPACES_ACCESS_KEY = DO00KYUY4XUP2EFCL6XQ
SPACES_SECRET_KEY = Qvo+720hVyW420kiyYb8y9d/vMuwbrSR/zFv6PLPWGY
DO_SSH_PRIVATE_KEY = [SSH private key content]
DO_SSH_PUBLIC_KEY = [SSH public key content]
POSTGRES_PASSWORD = [Database password]
REDIS_PASSWORD = [Cache password]
POSTGRES_DB = battleone
POSTGRES_USER = battleone_user
KRATOS_LOG_LEVEL = warning
```

2. **Deploy**: Push to main branch or run workflow manually

## What Gets Deployed

- **PostgreSQL 15**: Database on port 5432
- **Redis 7**: Cache on port 6379  
- **Ory Kratos**: Identity management on ports 4433/4434
- **DigitalOcean Droplet**: 2 CPU, 2GB RAM in NYC1
- **20GB Volume**: Persistent data storage
- **VPC Network**: 10.200.0.0/24 private network
- **Firewall**: SSH (22) and Kratos health (4433) access

## Architecture

Infrastructure runs on DigitalOcean droplet with Docker containers. All services bind to localhost for security. BFF application connects via service names (`postgres`, `redis`, `kratos`).

## Migration Status

✅ **COMPLETE** - Successfully migrated from manual SSH deployment to Infrastructure as Code with Terraform. All ~2,500 lines of infrastructure code moved to dedicated repository with professional CI/CD workflow.

## Connection Strings

- **PostgreSQL**: `postgres://battleone_user:[password]@postgres:5432/battleone`
- **Redis**: `redis://:[password]@redis:6379/0`  
- **Kratos Public**: `http://kratos:4433`
- **Kratos Admin**: `http://kratos:4434`