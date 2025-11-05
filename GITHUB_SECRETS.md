# GitHub Secrets Configuration for Infrastructure Deployment

This document lists all the required GitHub secrets that need to be configured in the `battleone-infrastructure` repository for automated deployment to DigitalOcean.

## 🔑 Required GitHub Secrets

Navigate to your GitHub repository: `Settings` → `Secrets and variables` → `Actions` → `New repository secret`

### SSH Connection Secrets

| Secret Name | Description | Example Value | Required |
|-------------|-------------|---------------|----------|
| `DO_SSH_PRIVATE_KEY` | Private SSH key for droplet access | `-----BEGIN OPENSSH PRIVATE KEY-----\n...` | ✅ |
| `DO_DROPLET_IP` | DigitalOcean droplet IP address | `167.99.184.98` | ✅ |
| `DO_USERNAME` | SSH username for droplet | `root` | ✅ |

### Database Configuration Secrets

| Secret Name | Description | Example Value | Required |
|-------------|-------------|---------------|----------|
| `POSTGRES_PASSWORD` | PostgreSQL database password | `your_secure_postgres_password` | ✅ |
| `REDIS_PASSWORD` | Redis cache password | `your_secure_redis_password` | ✅ |
| `POSTGRES_DB` | PostgreSQL database name | `battleone` | ⚠️ Optional* |
| `POSTGRES_USER` | PostgreSQL username | `battleone_user` | ⚠️ Optional* |

*Optional secrets will use default values if not provided

### Kratos Configuration Secrets

| Secret Name | Description | Example Value | Required |
|-------------|-------------|---------------|----------|
| `KRATOS_LOG_LEVEL` | Kratos logging level | `warn` | ⚠️ Optional* |

*Optional - defaults to `warn` if not provided

## 🛠️ How to Set Up Each Secret

### 1. SSH Private Key (`DO_SSH_PRIVATE_KEY`)

```bash
# Generate SSH key pair (if you don't have one)
ssh-keygen -t ed25519 -C "battleone-infrastructure-deploy"

# Copy the PRIVATE key content (including headers)
cat ~/.ssh/id_ed25519
```

**Important**: 
- Copy the **entire** private key including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`
- Add the corresponding public key to your DigitalOcean droplet's `~/.ssh/authorized_keys`

### 2. Droplet IP (`DO_DROPLET_IP`)

```bash
# Find your droplet IP in DigitalOcean dashboard or via CLI
doctl compute droplet list
```

### 3. SSH Username (`DO_USERNAME`)

- Usually `root` for DigitalOcean droplets
- Or your custom user if you've created one

### 4. Database Passwords

Generate secure passwords:

```bash
# Generate secure password (PostgreSQL)
openssl rand -base64 32

# Generate secure password (Redis)  
openssl rand -base64 32
```

## 🔒 Security Best Practices

### Password Requirements
- **Minimum 16 characters**
- **Mix of letters, numbers, symbols**
- **No dictionary words**
- **Unique per service**

### SSH Key Security
- Use Ed25519 keys (preferred) or RSA 4096-bit minimum
- Protect private keys with strong passphrases
- Rotate keys regularly
- Never share private keys

### Secret Management
- Use unique passwords for each environment (dev/staging/prod)
- Rotate secrets regularly
- Monitor secret usage in GitHub Actions logs
- Remove unused secrets

## 📋 Quick Setup Checklist

```bash
# 1. Generate secure passwords
POSTGRES_PASSWORD=$(openssl rand -base64 32)
REDIS_PASSWORD=$(openssl rand -base64 32)

echo "PostgreSQL Password: $POSTGRES_PASSWORD"
echo "Redis Password: $REDIS_PASSWORD"

# 2. Verify SSH key works
ssh -i ~/.ssh/your_key root@YOUR_DROPLET_IP "echo 'SSH test successful'"

# 3. Test GitHub Actions workflow
# Push a change or manually trigger the workflow
```

## 🚀 GitHub Actions Setup

### Repository Settings
1. Go to `https://github.com/YOUR_USERNAME/battleone-infrastructure`
2. Click `Settings` → `Secrets and variables` → `Actions`
3. Add each secret from the table above

### Manual Workflow Trigger
- Go to `Actions` tab in your repository
- Select `Deploy Infrastructure to DigitalOcean`
- Click `Run workflow`
- Optionally enable `force_redeploy` to redeploy existing infrastructure

### Automatic Triggers
The workflow automatically runs when you:
- Push changes to `main` branch
- Modify infrastructure files (`docker-compose.infrastructure.yml`, `deploy-infrastructure.sh`, `ory/**`)

## 🔍 Troubleshooting

### Common Issues

**SSH Connection Failed**
```
❌ SSH connection failed to X.X.X.X
```
- Verify `DO_DROPLET_IP` is correct
- Check `DO_SSH_PRIVATE_KEY` includes full key with headers
- Ensure public key is in droplet's `~/.ssh/authorized_keys`
- Test SSH manually: `ssh root@YOUR_IP`

**Secret Missing**
```
❌ POSTGRES_PASSWORD secret is missing
```
- Go to repository Settings → Secrets → Actions
- Add the missing secret with exact name (case-sensitive)

**Docker Permission Denied**
```
permission denied while trying to connect to the Docker daemon
```
- User needs to be in `docker` group: `usermod -aG docker $USER`
- Or use `root` user for deployment

**Health Check Failed**
```
❌ PostgreSQL health check failed
```
- Check deployment logs for specific errors
- Verify passwords are set correctly
- Check droplet resources (CPU/memory)

## 📊 Monitoring

### View Deployment Status
- GitHub Actions: `https://github.com/YOUR_USERNAME/battleone-infrastructure/actions`
- Check workflow runs for success/failure status
- Review logs for detailed deployment information

### Infrastructure Health
After deployment, verify services:
```bash
# SSH to droplet
ssh root@YOUR_DROPLET_IP

# Check service status
cd /opt/battleone/infrastructure
docker compose -f docker-compose.infrastructure.yml ps

# Check health endpoints
curl http://localhost:4433/health/ready  # Kratos
docker exec battleone-postgres pg_isready  # PostgreSQL
docker exec battleone-redis redis-cli ping  # Redis
```

## 🔗 Related Documentation

- [Main Deployment Guide](../battleone-bff/DEPLOYMENT.md)
- [Infrastructure README](./README.md)
- [BFF Repository](https://github.com/bnannier/battleone-bff)