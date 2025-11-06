# DigitalOcean API Key Documentation

## Current API Token
**Token**: Stored securely in GitHub repository secrets as `DIGITALOCEAN_ACCESS_TOKEN`

## Usage
This token is used for:
- Terraform deployments via `DIGITALOCEAN_ACCESS_TOKEN` environment variable
- Manual `doctl` commands for infrastructure management
- GitHub Actions workflows (stored as repository secret)

## Security Notes
- This token has full access to your DigitalOcean account
- Keep this token secure and never commit it to version control
- Rotate this token regularly for security
- Consider using limited scope tokens for specific operations

## Configuration Locations
1. **Terraform**: `terraform.tfvars` file
2. **GitHub Secrets**: `DIGITALOCEAN_ACCESS_TOKEN` repository secret
3. **Local doctl**: Can be set via `doctl auth init` or environment variable

## Permissions
This token has the following permissions:
- Read/Write access to Droplets
- Read/Write access to VPCs
- Read/Write access to Volumes
- Read/Write access to Firewalls
- Read/Write access to SSH Keys
- Read/Write access to all DigitalOcean resources

## Token Management
- **Created**: 2025-11-06
- **Scope**: Full account access
- **Status**: Active
- **Expiry**: No expiration (should be rotated manually)

## Emergency Revocation
If this token is compromised:
1. Go to DigitalOcean Control Panel > API > Personal Access Tokens
2. Find and delete this token
3. Generate a new token
4. Update all configuration files and GitHub secrets