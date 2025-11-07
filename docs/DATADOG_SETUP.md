# Datadog Monitoring Setup for BattleOne Infrastructure

## 🎯 Overview
This setup provides comprehensive monitoring for your BattleOne infrastructure including:
- **Host Metrics**: CPU, Memory, Disk, Network on the DigitalOcean droplet
- **Container Metrics**: Docker container resource usage for all services
- **Database Monitoring**: PostgreSQL performance metrics and query analytics
- **Cache Monitoring**: Redis performance and memory usage metrics
- **Application Health**: Kratos API endpoint monitoring
- **Log Aggregation**: Centralized logging from all services

## 🔧 Prerequisites

### 1. Datadog Free Tier Setup
Datadog offers a generous free tier that's perfect for your BattleOne infrastructure:

#### **Free Tier Benefits:**
- ✅ **5 hosts** monitoring (you only need 1)
- ✅ **1-day metric retention** (perfect for real-time monitoring)
- ✅ **Unlimited custom metrics** (first 100 are free, then pay-as-you-go)
- ✅ **Log ingestion**: 150MB/month free
- ✅ **All integrations** (PostgreSQL, Redis, HTTP checks, etc.)
- ✅ **Dashboards & alerts** (unlimited)
- ✅ **Mobile app** access

#### **Account Setup Steps:**
1. **Sign up** for free at [datadoghq.com](https://datadoghq.com/free)
   - Use your email (no credit card required initially)
   - Select "Free" plan during signup
   - Choose your region (US: `datadoghq.com`, EU: `datadoghq.eu`)

2. **Get your API key**:
   - Go to **Organization Settings** → **API Keys** (or [direct link](https://app.datadoghq.com/organization-settings/api-keys))
   - Click **"New Key"**
   - Name it: `battleone-infrastructure`
   - Copy the generated key (starts with letters/numbers like `abc123def456...`)

3. **Note your site**: Usually `datadoghq.com` for US accounts

#### **Free Tier Limits vs Your Usage:**
| Resource | Free Tier Limit | Your Usage | Status |
|----------|----------------|------------|--------|
| **Hosts** | 5 hosts | 1 droplet | ✅ Well within limit |
| **Metrics** | 100 custom + unlimited standard | ~50 total | ✅ Well within limit |
| **Logs** | 150MB/month | ~10-20MB/month | ✅ Well within limit |
| **Retention** | 1 day | Real-time monitoring | ✅ Perfect for alerts |

**Result**: Your entire BattleOne infrastructure will run **completely free** on Datadog! 🎉

### 2. GitHub Secrets Configuration
Add your Datadog API key to GitHub repository secrets:

#### **Step-by-step:**
1. **Go to your repository**: `https://github.com/yourusername/battleone-infrastructure`
2. **Navigate to Settings** → **Secrets and variables** → **Actions**
3. **Click "New repository secret"**
4. **Add the API key**:
   - **Name**: `DATADOG_API_KEY`
   - **Secret**: Paste your API key from step 1 above
   - Click **"Add secret"**

5. **Optional - Add site** (only if you're in EU):
   - **Name**: `DATADOG_SITE` 
   - **Secret**: `datadoghq.eu` (for EU accounts)
   - Most users can skip this (defaults to `datadoghq.com`)

#### **Security Note:**
Your API key will be encrypted and only accessible to GitHub Actions. It's never exposed in logs or visible to unauthorized users.

## 📊 What Gets Monitored

### Infrastructure Metrics
- **Host**: CPU usage, memory usage, disk I/O, network traffic
- **Docker**: Container resource usage, container status, image info
- **Process**: Running processes and their resource consumption

### Service-Specific Metrics

#### PostgreSQL Database
- Connection count and activity
- Query performance metrics
- Database size and growth
- Index usage statistics
- Lock monitoring
- Custom query: Active connection count

#### Redis Cache
- Memory usage and eviction rates
- Command statistics
- Hit/miss ratios
- Persistence status
- Connected clients

#### Kratos Identity Management
- Health endpoint monitoring (public and admin APIs)
- HTTP response times and status codes
- Service availability

### Log Collection
- **PostgreSQL**: Database logs, slow queries, errors
- **Redis**: Redis server logs, command logs
- **Kratos**: Application logs, request logs, error logs
- **Docker**: Container stdout/stderr logs

## 🏷️ Tagging Strategy
All metrics are tagged with:
- `environment:production`
- `service:battleone`
- `version:1.0.0`
- `infrastructure:digitalocean`
- Service-specific tags like `service:battleone-postgres`

## 🚀 Quick Start (5 minutes to monitoring!)

### **Option 1: Automatic Deployment**
1. ✅ **Sign up** for Datadog free account at [datadoghq.com/free](https://datadoghq.com/free)
2. ✅ **Copy your API key** from [Organization Settings](https://app.datadoghq.com/organization-settings/api-keys) 
3. ✅ **Add to GitHub**: Repository Settings → Secrets → New secret
   - Name: `DATADOG_API_KEY`
   - Value: Your API key
4. ✅ **Deploy**: Push any change to main branch or manually trigger workflow
5. ✅ **Monitor**: Check [Datadog Infrastructure](https://app.datadoghq.com/infrastructure) in 2-3 minutes

### **Option 2: Test Without Deployment**
If you want to test the monitoring setup first:
```bash
# Skip deployment, just validate configuration
gh workflow run "Deploy BattleOne Infrastructure" --field action=plan
```

### **Immediate Results**
Once deployed, you'll see in Datadog within 2-3 minutes:
- 📊 **Host metrics**: CPU, memory, disk usage
- 🐳 **Container status**: All 5 containers (postgres, redis, kratos, etc.)
- 📋 **Service health**: PostgreSQL connections, Redis memory, Kratos API
- 📝 **Live logs**: Real-time logs from all services

## 📈 Datadog Dashboard Setup

### Recommended Dashboards
1. **Infrastructure Overview** - Host metrics, Docker containers
2. **Database Performance** - PostgreSQL metrics and queries  
3. **Cache Performance** - Redis metrics and memory usage
4. **Application Health** - Kratos endpoint monitoring
5. **Log Analytics** - Centralized log analysis

### Key Metrics to Monitor
- **Host CPU > 80%** - Scale up instance
- **Memory Usage > 85%** - Check for memory leaks
- **Disk Usage > 90%** - Increase storage
- **PostgreSQL Connections** - Monitor connection pooling
- **Redis Memory Usage** - Monitor cache efficiency
- **Kratos Response Time** - API performance

## 🚨 Alerting Setup

### Critical Alerts
- Host down or unreachable
- High CPU usage (>90% for 5 minutes)
- High memory usage (>95% for 5 minutes)
- Disk space low (<10% free)
- Database connection failures
- Redis server down
- Kratos API not responding

### Warning Alerts  
- Medium CPU usage (>70% for 10 minutes)
- Medium memory usage (>80% for 10 minutes)
- Slow database queries (>1s execution time)
- High Redis memory usage (>80%)

## 🔍 Troubleshooting

### Agent Not Reporting
1. Check `DATADOG_API_KEY` secret is set correctly
2. Verify agent container is running: `docker-compose ps datadog-agent`
3. Check agent logs: `docker-compose logs datadog-agent`

### Missing Database Metrics
1. Verify PostgreSQL datadog user was created successfully
2. Check postgres integration config in agent logs
3. Ensure network connectivity between agent and postgres containers

### Missing Application Metrics
1. Verify Kratos health endpoints are accessible
2. Check HTTP check configuration in agent logs
3. Ensure proper service discovery labels are set

## 💰 Cost: Completely FREE! 

### **Free Tier Coverage**
Your BattleOne infrastructure is **100% covered** by Datadog's free tier:

#### **What's Free Forever:**
- ✅ **Host monitoring**: 1 droplet (5 allowed)
- ✅ **Standard metrics**: All PostgreSQL, Redis, Docker metrics
- ✅ **Custom metrics**: Your ~10 custom metrics (100 allowed)  
- ✅ **Log collection**: ~20MB/month (150MB allowed)
- ✅ **Dashboards**: Unlimited dashboards and visualizations
- ✅ **Alerting**: Unlimited alerts via email/Slack
- ✅ **Integrations**: All database and application integrations

#### **Usage Monitoring:**
Monitor your usage to stay within free limits:
1. **Go to** [Usage & Billing](https://app.datadoghq.com/billing/usage)
2. **Check monthly usage**:
   - **Hosts**: Should show 1/5 used
   - **Custom Metrics**: Should show <20/100 used  
   - **Log Ingestion**: Should show <50MB/150MB used

#### **Staying Free Tips:**
- **Log retention**: 1 day is perfect for real-time alerts
- **Metric retention**: 1 day covers all operational needs
- **Custom metrics**: Our setup uses minimal custom metrics
- **No credit card needed**: Until you exceed free limits
- **Monitor usage**: Check billing page monthly to stay aware
- **Clean old tags**: Remove unused tags to avoid metric explosion

#### **What Happens If You Exceed Limits?**
- **Hosts**: Datadog will email you and ask for payment info
- **Logs**: Log ingestion stops until next month or you upgrade  
- **Custom metrics**: Standard pricing applies to excess metrics
- **No service interruption**: Your monitoring continues working
- **Downgrade option**: You can always reduce usage to return to free tier

#### **If You Ever Need More:**
- **Pro plan**: $15/host/month (only if you exceed limits)
- **More retention**: 15 months history vs 1 day
- **More logs**: 150GB vs 150MB per month
- **Advanced features**: APM, synthetic monitoring, etc.

**Bottom line**: Start completely free, upgrade only if/when you need more! 🎯

## 📚 Next Steps
1. Set up custom dashboards for your specific use cases
2. Configure alert notifications (email, Slack, PagerDuty)
3. Explore APM (Application Performance Monitoring) for your BFF
4. Set up synthetic monitoring for external health checks