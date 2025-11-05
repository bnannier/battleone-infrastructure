# Quick GitHub Secrets Setup

Use these GitHub CLI commands to quickly set up all required secrets:

## Prerequisites
```bash
# Install GitHub CLI (if not already installed)
brew install gh  # macOS

# Authenticate with GitHub
gh auth login
```

## Set Required Secrets

```bash
# SSH Configuration
gh secret set DO_SSH_PRIVATE_KEY --body "$(cat ~/.ssh/id_ed25519)"  # Your SSH private key
gh secret set DO_DROPLET_IP --body "167.99.184.98"                  # Your droplet IP
gh secret set DO_USERNAME --body "root"                             # SSH username

# Database Passwords (generate secure ones)
gh secret set POSTGRES_PASSWORD --body "$(openssl rand -base64 32)"
gh secret set REDIS_PASSWORD --body "$(openssl rand -base64 32)"
```

## Set Optional Secrets (with defaults)

```bash
# Database Configuration (optional - uses defaults if not set)
gh secret set POSTGRES_DB --body "battleone"
gh secret set POSTGRES_USER --body "battleone_user"
gh secret set KRATOS_LOG_LEVEL --body "warn"
```

## Verify Secrets

```bash
# List all secrets
gh secret list

# Should show:
# DO_SSH_PRIVATE_KEY
# DO_DROPLET_IP  
# DO_USERNAME
# POSTGRES_PASSWORD
# REDIS_PASSWORD
# POSTGRES_DB
# POSTGRES_USER
# KRATOS_LOG_LEVEL
```

## Manual Secret Entry (for sensitive values)

For sensitive values like SSH keys, you might want to enter them manually:

```bash
# This will prompt for the value securely
gh secret set DO_SSH_PRIVATE_KEY
# Paste your private key when prompted

gh secret set POSTGRES_PASSWORD
# Enter a secure password when prompted
```

## Generate Secure Passwords

```bash
# Generate strong passwords
echo "PostgreSQL Password: $(openssl rand -base64 32)"
echo "Redis Password: $(openssl rand -base64 32)"

# Use these generated passwords with:
gh secret set POSTGRES_PASSWORD --body "YOUR_GENERATED_PASSWORD"
gh secret set REDIS_PASSWORD --body "YOUR_GENERATED_PASSWORD"
```

## Next Steps

After setting up secrets:

1. **Trigger deployment**: 
   ```bash
   # Go to GitHub Actions and run the workflow
   # Or push a change to trigger automatic deployment
   ```

2. **Monitor deployment**:
   ```bash
   # View workflow runs
   gh run list --workflow="deploy-infrastructure.yml"
   
   # View specific run logs
   gh run view --log
   ```

3. **Verify deployment**:
   ```bash
   # SSH to droplet and check services
   ssh root@167.99.184.98
   docker ps | grep battleone
   curl http://localhost:4433/health/ready
   ```