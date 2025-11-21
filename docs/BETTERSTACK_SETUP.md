# Better Stack Setup Guide

This guide walks you through setting up Better Stack monitoring for your BattleOne infrastructure.

## 🎯 Overview

Better Stack provides modern log management and uptime monitoring with:
- **SQL-compatible log queries** - Query up to 1 billion log lines per second
- **Unified platform** - Logs, metrics, and uptime monitoring in one place
- **Generous free tier** - 3 GB logs for 3 days + 10 monitors
- **Beautiful interface** - Modern, intuitive dashboard design

## 📋 Prerequisites

- BattleOne infrastructure repository
- DigitalOcean account configured
- GitHub repository with required secrets

## 🚀 Quick Setup

### 1. Create Better Stack Account

1. Visit [betterstack.com](https://betterstack.com) and sign up for free
2. Verify your email address
3. Log into your Better Stack dashboard

### 2. Create Log Source

1. In Better Stack dashboard, navigate to **Sources**
2. Click **"Add Source"**
3. Select **"Docker"** as the source type
4. Give it a name: `battleone-infrastructure`
5. Copy the **Source Token** (starts with `bttr_`)
6. Note the **Ingestion Host** (usually `in.logs.betterstack.com`)

### 3. Add GitHub Secrets

Add these secrets to your GitHub repository:

1. Go to your repository → **Settings** → **Secrets and variables** → **Actions**
2. Click **"New repository secret"**
3. Add the following secrets:

```
Name: BETTERSTACK_SOURCE_TOKEN
Value: bttr_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Name: BETTERSTACK_INGESTION_HOST  
Value: in.logs.betterstack.com
```

## ✅ Verify Setup

### 1. Deploy Infrastructure

```bash
# Trigger deployment
gh workflow run "Deploy BattleOne Infrastructure" --field action=apply
```

### 2. Check Monitoring

1. Wait ~5 minutes for deployment to complete
2. Visit [Better Stack Logs](https://betterstack.com/logs)
3. You should see logs from:
   - `battleone-postgres`
   - `battleone-redis` 
   - `battleone-kratos`
   - `battleone-monitoring`

### 3. Test Log Queries

Try these SQL queries in Better Stack:

```sql
-- View all logs from the last hour
SELECT * FROM logs 
WHERE dt > NOW() - INTERVAL 1 HOUR
ORDER BY dt DESC LIMIT 100

-- PostgreSQL connection logs
SELECT * FROM logs 
WHERE tags.service = 'battleone-postgres'
AND message LIKE '%connection%'
ORDER BY dt DESC

-- Kratos authentication events
SELECT * FROM logs 
WHERE tags.service = 'battleone-kratos'
AND message LIKE '%login%'
ORDER BY dt DESC
```

## 📊 Dashboard Features

### Key Metrics Available

- **Host Metrics**: CPU, memory, disk usage from Better Stack collector
- **Container Logs**: Real-time logs from all Docker services
- **Service Health**: Automatic service discovery and monitoring
- **Custom Tags**: Environment, service, hostname automatically tagged

### Log Structure

Each log entry includes:
```json
{
  "message": "Log message content",
  "dt": "2024-01-15T10:30:00Z",
  "tags": {
    "service": "battleone-postgres",
    "environment": "production", 
    "hostname": "battleone-droplet",
    "project": "battleone"
  },
  "container_name": "battleone-postgres"
}
```

## 🔧 Advanced Configuration

### Custom Dashboards

1. Go to **Dashboards** in Better Stack
2. Click **"Create Dashboard"**
3. Add widgets for:
   - Service health overview
   - Error rate trends
   - Database connection metrics
   - Authentication events

### Alerting

Set up alerts for:
- High error rates
- Service downtime
- Database connection failures
- Memory/CPU thresholds

### Log Retention

- **Free tier**: 3 days retention for 3 GB
- **Paid plans**: Extended retention available
- Configure in **Sources** → **Settings** → **Retention**

## 🎁 Free Tier Limits

Better Stack free tier includes:
- **3 GB** log ingestion per month
- **3 days** log retention
- **10** uptime monitors
- **10** status page checks
- Full dashboard and alerting features

## 🔄 Migration from Datadog

If migrating from Datadog:

1. **Parallel monitoring** - Both systems can run simultaneously during transition
2. **Data export** - Export dashboards and alert configurations
3. **Gradual migration** - Move services one by one
4. **Cost comparison** - Monitor usage to optimize costs

## 🚨 Troubleshooting

### No Logs Appearing

1. **Check secrets** - Verify `BETTERSTACK_SOURCE_TOKEN` in GitHub
2. **Check deployment** - Review GitHub Actions logs for errors
3. **Check Better Stack collector** - SSH to droplet and check container logs:
   ```bash
   ssh root@DROPLET_IP
   cd /opt/battleone
   docker-compose logs better-stack-collector
   ```

### High Log Volume

1. **Monitor usage** - Check Better Stack → **Sources** → **Usage**
2. **Filter logs** - Configure Better Stack collector to exclude noisy logs
3. **Upgrade plan** - Consider paid plan for higher limits

### Query Performance

1. **Use indexes** - Better Stack automatically indexes common fields
2. **Limit time ranges** - Use specific time windows in queries
3. **Use service filters** - Filter by `tags.service` for better performance

## 📞 Support

- **Better Stack Docs**: [docs.betterstack.com](https://docs.betterstack.com)
- **Community**: [Better Stack Community](https://betterstack.com/community)
- **Support**: [hello@betterstack.com](mailto:hello@betterstack.com)

## 📈 Next Steps

1. **Set up uptime monitoring** - Add external URL checks
2. **Create custom dashboards** - Visualize key business metrics
3. **Configure alerting** - Get notified of critical issues
4. **Explore integrations** - Connect with Slack, PagerDuty, etc.

---

🎉 **Congratulations!** Your BattleOne infrastructure now has modern, powerful monitoring with Better Stack.