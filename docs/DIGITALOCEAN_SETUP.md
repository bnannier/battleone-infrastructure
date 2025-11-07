# DigitalOcean Setup Guide for BattleOne Infrastructure

## 🎯 Overview
This guide covers the complete DigitalOcean account setup and configuration required for deploying your BattleOne infrastructure. We'll set up API access, Spaces for Terraform state storage, SSH keys, and configure billing.

## 🚀 Quick Setup Checklist

### ✅ **Account Prerequisites**
- [ ] DigitalOcean account created
- [ ] Payment method added (required for Droplets)
- [ ] Account email verified
- [ ] Two-factor authentication enabled (recommended)

### ✅ **Required Components**
- [ ] API Token with full access
- [ ] Spaces bucket for Terraform state
- [ ] Spaces access keys 
- [ ] SSH key uploaded
- [ ] Project created (optional but recommended)

## 🔧 Detailed Setup Instructions

### 1. Account Setup

#### **1.1 Create Account**
1. **Sign up** at [digitalocean.com](https://cloud.digitalocean.com/registrations/new)
2. **Verify email** address
3. **Add payment method**:
   - Credit card required for Droplets
   - $200 free credit available for new accounts (60 days)
   - Billing starts when free credit expires

#### **1.2 Security Setup (Recommended)**
1. **Enable 2FA**: Account → Settings → Security → Two-Factor Authentication
2. **Add recovery codes**: Save backup codes in secure location
3. **Review login activity**: Monitor for unauthorized access

### 2. API Access Configuration

#### **2.1 Generate API Token**
1. **Navigate to** [API Tokens](https://cloud.digitalocean.com/account/api/tokens)
2. **Generate New Token**:
   - **Name**: `battleone-infrastructure-token`
   - **Scopes**: **Full Access** (Read & Write)
   - **Expiration**: No Expiry (or set to your security preference)
3. **Copy the token immediately** (starts with `dop_v1_...`)
   - ⚠️ **Important**: Token is only shown once!
   - Store securely - this goes in GitHub secrets as `DIGITALOCEAN_ACCESS_TOKEN`

#### **2.2 Token Security Best Practices**
- ✅ **Use descriptive names** for easy identification
- ✅ **Set expiration dates** for enhanced security (90 days recommended)
- ✅ **Rotate tokens regularly** 
- ✅ **Delete unused tokens**
- ✅ **Monitor token usage** in account activity

### 3. Spaces Setup (Terraform State Storage)

#### **3.1 Create Spaces Bucket**
DigitalOcean Spaces provides S3-compatible object storage for Terraform state:

1. **Go to** [Spaces](https://cloud.digitalocean.com/spaces)
2. **Create Space**:
   - **Name**: `battleone-terraform-state`
   - **Region**: `NYC3` (recommended for reliability)
   - **File listing**: Restrict (security best practice)
   - **CDN**: Not required for Terraform state
3. **Note the endpoint**: `nyc3.digitaloceanspaces.com`

#### **3.2 Generate Spaces Keys**
1. **Go to** [Spaces Access Keys](https://cloud.digitalocean.com/account/api/spaces)
2. **Generate New Key**:
   - **Name**: `battleone-terraform-state-key`
3. **Copy both values**:
   - **Access Key ID** (like `DO801ADJ22JY...`) → Save as `SPACES_ACCESS_KEY`
   - **Secret Access Key** (like `IjdU3WVc...`) → Save as `SPACES_SECRET_KEY`

#### **3.3 Spaces Configuration Details**

| Setting | Value | Purpose |
|---------|-------|---------|
| **Bucket Name** | `battleone-terraform-state` | Stores infrastructure state |
| **Region** | `NYC3` | Reliable, fast region |
| **Endpoint** | `nyc3.digitaloceanspaces.com` | S3-compatible API |
| **File Listing** | Restricted | Security - hide state files |
| **CDN** | Disabled | Not needed for state storage |

### 4. SSH Key Management

#### **4.1 Generate SSH Key Pair**
Create a dedicated key pair for your infrastructure:

```bash
# Generate Ed25519 key (recommended)
ssh-keygen -t ed25519 -C "battleone-infrastructure" -f ~/.ssh/battleone_key

# Alternative: RSA key (if Ed25519 not supported)
ssh-keygen -t rsa -b 4096 -C "battleone-infrastructure" -f ~/.ssh/battleone_rsa
```

#### **4.2 Add SSH Key to DigitalOcean**
1. **Go to** [SSH Keys](https://cloud.digitalocean.com/account/security)
2. **Add SSH Key**:
   - **SSH Key Content**: Paste public key content (`cat ~/.ssh/battleone_key.pub`)
   - **Name**: `battleone-infrastructure-key`
3. **Note the Key ID** (will be auto-detected in Terraform)

#### **4.3 SSH Key Security**
- ✅ **Use unique keys** per project/environment
- ✅ **Protect private keys** with passphrases
- ✅ **Store keys securely** (encrypted backups)
- ✅ **Rotate keys regularly** (annually recommended)
- ✅ **Remove unused keys** from DigitalOcean

### 5. Region and Resource Planning

#### **5.1 Choose Region**
Recommended regions for BattleOne infrastructure:

| Region Code | Location | Benefits |
|-------------|----------|----------|
| **tor1** | Toronto, Canada | Low latency for North America |
| **nyc1/nyc3** | New York, USA | High performance, many features |
| **sfo3** | San Francisco, USA | West coast coverage |
| **lon1** | London, UK | European coverage |
| **fra1** | Frankfurt, Germany | EU compliance |

**Default**: `tor1` (Toronto) - Good balance of performance and features

#### **5.2 Droplet Size Planning**

| Size | vCPUs | RAM | Disk | Price/Month | Use Case |
|------|-------|-----|------|-------------|----------|
| **s-1vcpu-2gb** | 1 | 2GB | 50GB | $12 | Development/Testing |
| **s-2vcpu-4gb** | 2 | 4GB | 80GB | $24 | **Recommended Production** |
| **s-4vcpu-8gb** | 4 | 8GB | 160GB | $48 | High traffic |

**Default**: `s-2vcpu-4gb` - Perfect for PostgreSQL + Redis + Kratos

#### **5.3 Additional Storage**
- **Volume Size**: 20GB (configured automatically)
- **Volume Type**: SSD (high performance)
- **Purpose**: Persistent database and cache storage
- **Cost**: ~$2/month for 20GB

### 6. Project Organization (Optional)

#### **6.1 Create Project**
Organize your resources for better management:

1. **Go to** [Projects](https://cloud.digitalocean.com/projects)
2. **Create Project**:
   - **Name**: `BattleOne Infrastructure`
   - **Description**: `Production infrastructure for BattleOne application`
   - **Purpose**: `Web Application`
   - **Environment**: `Production`

#### **6.2 Project Benefits**
- ✅ **Resource grouping** - All related resources in one place
- ✅ **Team collaboration** - Share project access
- ✅ **Billing organization** - Separate cost tracking
- ✅ **Access control** - Project-level permissions

### 7. Network and Security

#### **7.1 VPC Configuration**
Virtual Private Cloud for network isolation:
- **VPC Name**: `battleone-vpc-{random}` (auto-generated)
- **IP Range**: `10.50.0.0/24` 
- **Region**: Same as your droplet region
- **Purpose**: Isolated network for your services

#### **7.2 Firewall Rules**
Automatic security configuration:

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | TCP | 0.0.0.0/0 | SSH access |
| 80 | TCP | 0.0.0.0/0 | HTTP (future use) |
| 443 | TCP | 0.0.0.0/0 | HTTPS (future use) |
| 5432 | TCP | Internal | PostgreSQL (internal only) |
| 6379 | TCP | Internal | Redis (internal only) |
| 4433 | TCP | Internal | Kratos API (internal only) |

### 8. Cost Management

#### **8.1 Monthly Cost Breakdown**
Estimated costs for BattleOne infrastructure:

| Component | Size | Monthly Cost |
|-----------|------|--------------|
| **Droplet** | s-2vcpu-4gb | $24.00 |
| **Volume** | 20GB SSD | $2.00 |
| **Spaces** | 250GB, 1TB transfer | $0.50 |
| **Bandwidth** | First 1TB free | $0.00 |
| **Backups** | Optional | $4.80 |
| **Total** | | **~$26.50/month** |

#### **8.2 Cost Optimization**
- ✅ **Start small**: Begin with s-2vcpu-4gb, scale up as needed
- ✅ **Monitor usage**: Use DigitalOcean monitoring dashboard
- ✅ **Delete unused resources**: Remove test droplets promptly
- ✅ **Use Spaces efficiently**: Clean up old Terraform states
- ✅ **Consider reserved instances**: Savings for long-term usage

#### **8.3 Free Credits**
- **New accounts**: $200 credit (60 days)
- **GitHub Students**: $50 credit
- **Promotional offers**: Various credits available
- **Referral program**: Earn credits for referrals

### 9. Monitoring and Limits

#### **9.1 Account Limits**
Default limits for new accounts:

| Resource | Default Limit | Increase Method |
|----------|---------------|-----------------|
| **Droplets** | 5 | Contact support |
| **Volumes** | 5 | Contact support |
| **Spaces** | 5 | Contact support |
| **Load Balancers** | 1 | Contact support |
| **Floating IPs** | 3 | Contact support |

#### **9.2 Resource Monitoring**
Monitor your usage:
1. **Dashboard**: [cloud.digitalocean.com](https://cloud.digitalocean.com)
2. **Billing**: Track costs and usage
3. **Monitoring**: CPU, memory, disk, network graphs
4. **Alerts**: Set up notifications for resource limits

### 10. Backup and Recovery

#### **10.1 Automated Backups**
Enable backups for data protection:
- **Droplet Backups**: $4.80/month (20% of droplet cost)
- **Volume Snapshots**: $0.05/GB/month  
- **Frequency**: Daily backups, 4-week retention
- **Recovery**: Point-in-time restore capability

#### **10.2 Manual Snapshots**
Create snapshots before major changes:
```bash
# Create droplet snapshot
doctl compute droplet-action snapshot DROPLET_ID --snapshot-name "pre-deployment-backup"

# Create volume snapshot  
doctl compute volume-action snapshot VOLUME_ID --snapshot-name "data-backup-$(date +%Y%m%d)"
```

## ✅ Verification Checklist

Before proceeding to infrastructure deployment:

### **Account Setup**
- [ ] DigitalOcean account verified and payment method added
- [ ] Two-factor authentication enabled
- [ ] Free credits applied (if available)

### **API Configuration**  
- [ ] API token generated with full access
- [ ] Token saved securely for GitHub secrets
- [ ] Token expiration set (if desired)

### **Storage Setup**
- [ ] Spaces bucket created (`battleone-terraform-state`)
- [ ] Spaces access keys generated
- [ ] Keys saved for GitHub secrets

### **Security Setup**
- [ ] SSH key pair generated
- [ ] Public key added to DigitalOcean
- [ ] Private key saved securely
- [ ] Key permissions verified

### **Planning Complete**
- [ ] Region selected (default: tor1)
- [ ] Droplet size chosen (default: s-2vcpu-4gb)
- [ ] Cost estimate reviewed (~$26.50/month)

## 🔍 Testing and Validation

### **Test API Access**
Verify your API token works:
```bash
# Install doctl CLI
curl -sL https://github.com/digitalocean/doctl/releases/download/v1.94.0/doctl-1.94.0-linux-amd64.tar.gz | tar -xzv
sudo mv doctl /usr/local/bin

# Configure doctl
doctl auth init

# Test API access
doctl account get
```

### **Test Spaces Access**
Verify Spaces configuration:
```bash
# Using AWS CLI (S3 compatible)
aws configure set aws_access_key_id YOUR_SPACES_ACCESS_KEY
aws configure set aws_secret_access_key YOUR_SPACES_SECRET_KEY
aws configure set default.region nyc3

# Test access
aws s3 ls --endpoint-url https://nyc3.digitaloceanspaces.com
```

### **Verify SSH Key**
Check SSH key is properly added:
```bash
doctl compute ssh-key list
```

## 🚨 Troubleshooting

### **Common Issues**

#### **Payment Method Required**
```
Error: A payment method is required to create Droplets
```
**Solution**: Add valid credit card to [billing settings](https://cloud.digitalocean.com/account/billing)

#### **API Token Invalid**
```
Error: Unable to authenticate you
```
**Solution**: 
- Regenerate API token with full access
- Verify token is copied completely (starts with `dop_v1_`)
- Check token hasn't expired

#### **Spaces Access Denied**
```
Error: Access Denied to Spaces bucket
```
**Solution**:
- Verify Spaces keys are correct
- Ensure bucket name matches exactly
- Check region endpoint (`nyc3.digitaloceanspaces.com`)

#### **SSH Key Not Found**
```
Error: SSH key not found
```
**Solution**:
- Verify SSH key is added to DigitalOcean
- Check public key format is correct
- Ensure key name matches

### **Getting Help**

#### **DigitalOcean Support**
- **Community**: [digitalocean.com/community](https://www.digitalocean.com/community/)
- **Documentation**: [docs.digitalocean.com](https://docs.digitalocean.com/)  
- **Tutorials**: Comprehensive guides for common tasks
- **Support Tickets**: Available for billing and technical issues

#### **Account Issues**
- **Billing**: Contact support for payment issues
- **Limits**: Request limit increases through support
- **Security**: Report unauthorized access immediately

## 🎯 Next Steps

After completing DigitalOcean setup:

1. **🔧 [GitHub Setup](./GITHUB_SETUP.md)** - Configure GitHub Actions with your DO credentials
2. **🚀 Deploy Infrastructure** - Run Terraform to create your infrastructure  
3. **📊 [Setup Monitoring](./DATADOG_SETUP.md)** - Add Datadog for comprehensive monitoring
4. **🔒 Security Review** - Verify firewall rules and access controls

Your DigitalOcean account is now ready for automated BattleOne infrastructure deployment! 🎯

## 💡 Pro Tips

### **Cost Optimization**
- Monitor usage with DigitalOcean's native monitoring
- Set up billing alerts for budget management
- Use snapshots for backup instead of continuous backups if budget is tight
- Consider smaller droplet sizes for development environments

### **Security Best Practices**
- Rotate API tokens quarterly
- Use unique SSH keys per environment
- Enable audit logging for compliance
- Regular security reviews of access and permissions

### **Performance Optimization**
- Choose regions close to your users
- Monitor droplet performance and scale up when needed
- Use Spaces CDN if serving static content
- Consider load balancers for high availability

Your DigitalOcean foundation is solid and ready for production deployment! 🚀