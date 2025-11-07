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

### 1. Datadog Account Setup
1. Sign up for a Datadog account at [datadoghq.com](https://datadoghq.com)
2. Get your API key from **Organization Settings** → **API Keys**
3. Note your Datadog site (usually `datadoghq.com` for US, `datadoghq.eu` for EU)

### 2. GitHub Secrets Configuration
Add these secrets to your GitHub repository (**Settings** → **Secrets and variables** → **Actions**):

```
DATADOG_API_KEY=your_datadog_api_key_here
DATADOG_SITE=datadoghq.com  # (optional, defaults to datadoghq.com)
```

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

## 🚀 Deployment

### Automatic Deployment
The Datadog Agent will be automatically deployed when you run the Terraform pipeline, provided the GitHub secrets are configured.

### Manual Deployment
1. Ensure `DATADOG_API_KEY` is set in GitHub secrets
2. Push any infrastructure change to trigger deployment
3. Or manually trigger via GitHub Actions

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

## 💰 Cost Optimization
- Datadog pricing is based on hosts and custom metrics
- This setup uses ~1 host + standard integrations
- Expected cost: ~$15-25/month depending on usage
- Monitor your usage in Datadog billing dashboard

## 📚 Next Steps
1. Set up custom dashboards for your specific use cases
2. Configure alert notifications (email, Slack, PagerDuty)
3. Explore APM (Application Performance Monitoring) for your BFF
4. Set up synthetic monitoring for external health checks