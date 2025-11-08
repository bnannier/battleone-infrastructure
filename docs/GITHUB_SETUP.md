# GitHub Setup Guide for BattleOne Infrastructure

## 🎯 Overview
This guide covers the complete GitHub repository setup for automated deployment of your BattleOne infrastructure using GitHub Actions. The setup includes DigitalOcean integration, secret management, and continuous deployment.

## 🚀 Quick Setup Checklist

### ✅ **Prerequisites**
- [ ] GitHub account with repository created
- [ ] DigitalOcean account with payment method
- [ ] Datadog account (free tier)
- [ ] SSH key pair for server access

### ✅ **Required Secrets (8 total)**
- [ ] `DO_USER_ACCESS_TOKEN` - DigitalOcean API access
- [ ] `DO_SPACES_ACCESS_KEY` - DigitalOcean Spaces access key  
- [ ] `DO_SPACES_SECRET_KEY` - DigitalOcean Spaces secret key
- [ ] `DO_SSH_PRIVATE_KEY` - SSH private key for server access
- [ ] `DO_SSH_PUBLIC_KEY` - SSH public key (used for both deployment and your laptop access)
- [ ] `POSTGRES_PASSWORD` - Database password
- [ ] `REDIS_PASSWORD` - Cache password  
- [ ] `DATADOG_API_KEY` - Monitoring API key

## 🔧 Detailed Setup Instructions

### 1. Repository Setup

#### **Create Repository**
1. **Go to GitHub** and create a new repository
2. **Repository name**: `battleone-infrastructure` (or your preferred name)
3. **Visibility**: Private (recommended for infrastructure)
4. **Initialize**: Don't add README, .gitignore, or license (we'll push existing code)

#### **Clone and Push Existing Code**
```bash
git remote add origin https://github.com/yourusername/battleone-infrastructure.git
git branch -M main
git push -u origin main
```

### 2. DigitalOcean Setup

#### **2.1 API Token**
1. **Log into DigitalOcean** → [API](https://cloud.digitalocean.com/account/api/tokens)
2. **Generate New Token**:
   - **Name**: `battleone-infrastructure-token`
   - **Scopes**: Full Access (Read & Write)
   - **Expiration**: No Expiry (or set to your preference)
3. **Copy the token** (starts with `dop_v1_...`)
4. **Save as GitHub Secret**: `DO_USER_ACCESS_TOKEN`

#### **2.2 Spaces Access Keys**
1. **Go to** [Spaces Keys](https://cloud.digitalocean.com/account/api/spaces)
2. **Generate New Key**:
   - **Name**: `battleone-terraform-state-key`  
3. **Copy both values**:
   - **Access Key** (like `DO801ADJ22JY...`) → Save as `DO_SPACES_ACCESS_KEY`
   - **Secret Key** (like `IjdU3WVc...`) → Save as `DO_SPACES_SECRET_KEY`

#### **2.3 SSH Key Pair**
Generate SSH keys for server access:
```bash
# Generate new key pair
ssh-keygen -t ed25519 -C "battleone-infrastructure" -f ~/.ssh/battleone_key

# Copy public key content
cat ~/.ssh/battleone_key.pub

# Copy private key content  
cat ~/.ssh/battleone_key
```

Save the keys:
- **Public key content** → `DO_SSH_PUBLIC_KEY` (will be used for both deployment and your laptop access)
- **Private key content** → `DO_SSH_PRIVATE_KEY`

### 3. Database & Security Setup

#### **3.1 Database Passwords**
Generate secure passwords for your databases:
```bash
# Generate PostgreSQL password
openssl rand -base64 32

# Generate Redis password  
openssl rand -base64 32
```

Save as:
- **PostgreSQL password** → `POSTGRES_PASSWORD`
- **Redis password** → `REDIS_PASSWORD`

#### **3.2 Optional Database Configuration**
These have defaults but can be customized:
- **`POSTGRES_DB`** (default: `battleone`)
- **`POSTGRES_USER`** (default: `battleone_user`)

### 4. Datadog Setup

#### **4.1 Free Account Setup**
1. **Sign up** for free at [datadoghq.com/free](https://datadoghq.com/free)
2. **No credit card required** for free tier
3. **Choose region**: US (`datadoghq.com`) or EU (`datadoghq.eu`)

#### **4.2 API Key**
1. **Go to** [Organization Settings → API Keys](https://app.datadoghq.com/organization-settings/api-keys)
2. **Create New Key**:
   - **Name**: `battleone-infrastructure`
3. **Copy the API key** → Save as `DATADOG_API_KEY`

#### **4.3 Optional: EU Region**
If using EU region, also add:
- **`DATADOG_SITE`** → `datadoghq.eu`

### 5. Adding Secrets to GitHub

#### **Step-by-Step for Each Secret**
1. **Go to your repository** on GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. **Click "New repository secret"**
4. **Add each secret**:

| Secret Name | Description | Example Source |
|-------------|-------------|----------------|
| `DO_USER_ACCESS_TOKEN` | DigitalOcean API token | `dop_v1_abc123...` |
| `DO_SPACES_ACCESS_KEY` | Spaces access key | `DO801ADJ22JY...` |
| `DO_SPACES_SECRET_KEY` | Spaces secret key | `IjdU3WVc...` |
| `DO_SSH_PRIVATE_KEY` | Private SSH key | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `DO_SSH_PUBLIC_KEY` | Public SSH key | `ssh-ed25519 AAAAC3...` |
| `POSTGRES_PASSWORD` | Database password | Generated with `openssl rand -base64 32` |
| `REDIS_PASSWORD` | Cache password | Generated with `openssl rand -base64 32` |
| `DATADOG_API_KEY` | Monitoring API key | From Datadog dashboard |

#### **Security Best Practices**
- ✅ **Never commit secrets** to code
- ✅ **Use strong, unique passwords** for databases
- ✅ **Rotate keys periodically** (every 90 days recommended)
- ✅ **Use separate keys per environment** if you have dev/staging
- ✅ **Monitor secret usage** in GitHub Actions logs

## 🔄 GitHub Actions Workflow

### **Automatic Triggers**
The workflow automatically runs when you push changes to:
- `*.tf` (Terraform files)
- `terraform.tfvars`
- `docker-compose.yml`
- `kratos/**` (Kratos configuration)
- `cloud-init.yml`
- `.github/workflows/terraform-deploy.yml`

### **Manual Triggers**
You can also run the workflow manually:

#### **Via GitHub Web Interface**
1. **Go to** Actions tab in your repository
2. **Select** "Deploy BattleOne Infrastructure"
3. **Click** "Run workflow"
4. **Choose options**:
   - **Action**: `apply`, `destroy`, or `plan`
   - **Auto-approve**: Skip manual approval

#### **Via GitHub CLI**
```bash
# Apply infrastructure changes
gh workflow run "Deploy BattleOne Infrastructure" --field action=apply

# Plan only (no changes)
gh workflow run "Deploy BattleOne Infrastructure" --field action=plan

# Destroy infrastructure
gh workflow run "Deploy BattleOne Infrastructure" --field action=destroy

# Auto-approve (skip manual confirmation)
gh workflow run "Deploy BattleOne Infrastructure" --field action=apply --field auto_approve=true
```

### **Workflow Steps**
1. **Validation**: Check all required secrets are present
2. **Terraform Setup**: Install and configure Terraform
3. **Format Check**: Validate Terraform code formatting
4. **Init**: Initialize Terraform with DigitalOcean Spaces backend
5. **Validate**: Check Terraform configuration syntax
6. **Plan**: Generate deployment plan
7. **Manual Approval**: Wait for approval (unless auto-approved)
8. **Apply**: Deploy infrastructure changes
9. **Health Check**: Verify services are running
10. **Output**: Display infrastructure information

## 🔍 Verification & Testing

### **Check Secret Configuration**
Verify all secrets are properly set:
```bash
gh secret list
```

Should show 8 secrets (all the ones listed above).

### **Test Workflow**
Run a plan to test configuration without making changes:
```bash
gh workflow run "Deploy BattleOne Infrastructure" --field action=plan
```

### **Monitor Deployment**
Watch workflow execution in real-time:
```bash
gh run watch
```

## 🚨 Troubleshooting

### **Common Issues**

#### **Secret Validation Failed**
```
❌ DO_USER_ACCESS_TOKEN secret is missing
```
**Solution**: Check that all 8 required secrets are added with exact names

#### **Terraform Backend Error**
```
Error: Failed to configure the backend "s3"
```
**Solution**: Verify `DO_SPACES_ACCESS_KEY` and `DO_SPACES_SECRET_KEY` are correct

#### **SSH Connection Failed**
```
Permission denied (publickey)
```
**Solution**: 
- Verify `DO_SSH_PRIVATE_KEY` includes full key with headers
- Ensure `DO_SSH_PUBLIC_KEY` matches the private key

#### **Resource Already Exists**
```
Error: droplet with name battleone-xyz already exists
```
**Solution**: 
- Previous deployment may have failed to clean up
- Either destroy existing resources or change resource names

### **Debug Commands**

#### **Check Workflow Logs**
```bash
# List recent runs
gh run list --limit 5

# View specific run logs
gh run view RUN_ID --log

# Watch current run
gh run watch
```

#### **Check Repository Settings**
```bash
# Verify secrets
gh secret list

# Check repository info
gh repo view
```

#### **Validate Terraform Locally**
```bash
# Format check
terraform fmt -check

# Validate syntax
terraform validate

# Plan deployment
terraform plan
```

### **Getting Help**

#### **GitHub Actions Issues**
1. Check the Actions tab in your repository
2. Review failed step logs for specific error messages
3. Verify all secrets are properly configured

#### **DigitalOcean Issues**
1. Verify API token has correct permissions
2. Check DigitalOcean billing is up to date
3. Ensure region (tor1) supports your requested resources

#### **Infrastructure Issues**
1. SSH to droplet and check service status
2. Review Docker container logs
3. Check DigitalOcean dashboard for resource status

## 🎯 Next Steps

After successful GitHub setup:

1. **📊 [Monitor with Datadog](./DATADOG_SETUP.md)** - Set up comprehensive monitoring
2. **🔧 Configure your BFF** - Connect your application to the deployed services  
3. **🚨 Set up alerts** - Configure notifications for infrastructure issues
4. **📈 Scale resources** - Upgrade droplet size as your application grows

## 🔒 Security Considerations

### **Secret Management**
- Secrets are encrypted at rest in GitHub
- Only accessible to repository collaborators with appropriate permissions
- Not visible in workflow logs (marked as `***`)
- Can be rotated without changing workflow code

### **Infrastructure Access**
- SSH access restricted to your public key only
- Database services only accessible internally
- Firewall configured with minimal required ports
- All services run with non-root users where possible

### **Monitoring & Auditing**  
- All deployments logged in GitHub Actions
- Infrastructure changes tracked in Terraform state
- Datadog monitors all services and alerts on issues
- SSH access and service logs available for audit

Your GitHub repository is now fully configured for automated, secure, and monitored deployment of your BattleOne infrastructure! 🚀