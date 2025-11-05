# Environment Variables Configuration

This document contains all environment variables and their configured values for the BattleOne Infrastructure deployment.

## 🔐 Current Configuration

### SSH Connection Variables
| Variable | Value | Purpose |
|----------|-------|---------|
| `DO_DROPLET_IP` | `167.99.184.98` | DigitalOcean droplet IP address |
| `DO_USERNAME` | `root` | SSH username for droplet access |
| `DO_SSH_PRIVATE_KEY` | *[See: private_public/private_key.txt]* | SSH private key for authentication |

### Database Configuration
| Variable | Value | Purpose |
|----------|-------|---------|
| `POSTGRES_DB` | `battleone` | PostgreSQL database name |
| `POSTGRES_USER` | `battleone_user` | PostgreSQL username |
| `POSTGRES_PASSWORD` | `Q0124lWwMhTu3pejo+mqvXy7bm6DxBNoilxr+0JM+Lg=` | PostgreSQL secure password |

### Cache Configuration
| Variable | Value | Purpose |
|----------|-------|---------|
| `REDIS_PASSWORD` | `J3tPwtIzHzh5YO5NKamJ/XwCLWuehFR3lavbaFv0KEw=` | Redis secure password |

### Kratos Configuration
| Variable | Value | Purpose |
|----------|-------|---------|
| `KRATOS_LOG_LEVEL` | `warn` | Ory Kratos logging level |

## 🔗 Infrastructure Service Endpoints

After deployment, these services will be available:

### Internal Network (from BFF containers)
- **PostgreSQL**: `postgres:5432`
- **Redis**: `redis:6379` 
- **Kratos Public API**: `kratos:4433`
- **Kratos Admin API**: `kratos:4434`

### External Access (from droplet host)
- **PostgreSQL**: `localhost:5432` (or `127.0.0.1:5432`)
- **Redis**: `localhost:6379` (or `127.0.0.1:6379`)
- **Kratos Public API**: `localhost:4433` (or `127.0.0.1:4433`)
- **Kratos Admin API**: `localhost:4434` (or `127.0.0.1:4434`)

### Public Health Check
- **Kratos Health**: `http://167.99.184.98:4433/health/ready`

## 🛠️ Connection Strings

### PostgreSQL Connection String
```
postgres://battleone_user:Q0124lWwMhTu3pejo+mqvXy7bm6DxBNoilxr+0JM+Lg=@postgres:5432/battleone
```

### Redis Connection String
```
redis://:J3tPwtIzHzh5YO5NKamJ/XwCLWuehFR3lavbaFv0KEw=@redis:6379/0
```

### SSH Public Key
| Variable | Value | Purpose |
|----------|-------|---------|
| `DO_SSH_PUBLIC_KEY` | *[See: private_public/public_key.txt]* | SSH public key (add to droplet's authorized_keys) |

## 🔒 Security Notes

### Password Security
- **PostgreSQL Password**: 32-character base64 encoded, 256-bit entropy
- **Redis Password**: 32-character base64 encoded, 256-bit entropy
- **SSH Key**: Ed25519 encryption (most secure SSH key type)

### Access Control
- All services bind to `127.0.0.1` (localhost only) except for internal Docker network
- SSH access requires private key authentication
- Database services not exposed to public internet
- Only Kratos health endpoint accessible for monitoring

### Network Security
- Services communicate over internal Docker network `battleone-network`
- No direct external access to databases
- BFF applications connect using service names (DNS resolution)

## 📋 Environment Variable Usage

### In GitHub Actions
```yaml
env:
  POSTGRES_PASSWORD: ${{ secrets.POSTGRES_PASSWORD }}
  REDIS_PASSWORD: ${{ secrets.REDIS_PASSWORD }}
  # ... other secrets
```

### In Docker Compose
```yaml
environment:
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
  REDIS_PASSWORD: ${REDIS_PASSWORD}
  # ... other variables
```

### In BFF Application
```yaml
environment:
  POSTGRES_HOST: postgres
  POSTGRES_PORT: 5432
  POSTGRES_DB: battleone
  POSTGRES_USER: battleone_user
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
  
  REDIS_HOST: redis
  REDIS_PORT: 6379
  REDIS_PASSWORD: ${REDIS_PASSWORD}
  
  KRATOS_PUBLIC_URL: http://kratos:4433
  KRATOS_ADMIN_URL: http://kratos:4434
```

## 🔄 Password Rotation

### To Rotate Passwords
1. Generate new secure passwords:
   ```bash
   NEW_POSTGRES_PWD=$(openssl rand -base64 32)
   NEW_REDIS_PWD=$(openssl rand -base64 32)
   ```

2. Update GitHub secrets:
   ```bash
   echo "$NEW_POSTGRES_PWD" | gh secret set POSTGRES_PASSWORD
   echo "$NEW_REDIS_PWD" | gh secret set REDIS_PASSWORD
   ```

3. Redeploy infrastructure:
   ```bash
   gh workflow run deploy-infrastructure.yml -f force_redeploy=true
   ```

### SSH Key Rotation
1. Generate new key pair:
   ```bash
   ssh-keygen -t ed25519 -C "battleone-infrastructure-new"
   ```

2. Add public key to droplet:
   ```bash
   ssh-copy-id -i ~/.ssh/new_key root@167.99.184.98
   ```

3. Update GitHub secret:
   ```bash
   gh secret set DO_SSH_PRIVATE_KEY --body "$(cat ~/.ssh/new_key)"
   ```

## 🚨 Emergency Access

### If SSH Key is Lost
- Access droplet via DigitalOcean console
- Add new SSH key to `/root/.ssh/authorized_keys`
- Update GitHub secret with new key

### If Database Password is Lost
- SSH to droplet: `ssh root@167.99.184.98`
- Reset PostgreSQL password:
  ```bash
  docker exec -it battleone-postgres psql -U postgres -c "ALTER USER battleone_user PASSWORD 'new_password';"
  ```
- Update GitHub secret and redeploy

## 📊 Monitoring Commands

### Check Service Status
```bash
ssh root@167.99.184.98
cd /opt/battleone/infrastructure
docker compose -f docker-compose.infrastructure.yml ps
```

### Test Connectivity
```bash
# PostgreSQL
docker exec battleone-postgres pg_isready -U battleone_user -d battleone

# Redis  
docker exec battleone-redis redis-cli ping

# Kratos
curl http://localhost:4433/health/ready
```

### View Logs
```bash
docker compose -f docker-compose.infrastructure.yml logs postgres
docker compose -f docker-compose.infrastructure.yml logs redis
docker compose -f docker-compose.infrastructure.yml logs kratos
```

---

**Last Updated**: 2025-11-05  
**Configuration Set By**: GitHub CLI automation  
**Next Review**: 2025-12-05 (monthly password rotation recommended)