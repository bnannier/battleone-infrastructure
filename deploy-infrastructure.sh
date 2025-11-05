#!/bin/bash

# BattleOne Infrastructure Deployment Script
# Deploys PostgreSQL, Redis, and Kratos services

set -e  # Exit on any error

echo "⚡ Starting BattleOne Infrastructure deployment..."

# Configuration
INFRA_DIR="/opt/battleone/infrastructure"
BACKUP_DIR="/opt/battleone/infrastructure/backups"
LOG_FILE="/opt/battleone/infrastructure-deploy.log"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

# Function to check if service is healthy
check_health() {
    local service=$1
    local port=${2:-5432}
    local retries=30
    local count=0
    
    log "⏳ Waiting for $service to be healthy on port $port..."
    
    while [ $count -lt $retries ]; do
        case $service in
            "postgres")
                if docker compose -f docker-compose.infrastructure.yml exec postgres pg_isready -U "${POSTGRES_USER:-battleone_user}" -d "${POSTGRES_DB:-battleone}" > /dev/null 2>&1; then
                    log "✅ $service is healthy"
                    return 0
                fi
                ;;
            "redis")
                if docker compose -f docker-compose.infrastructure.yml exec redis redis-cli ping > /dev/null 2>&1; then
                    log "✅ $service is healthy"
                    return 0
                fi
                ;;
            "kratos")
                if curl -f http://localhost:$port/health/ready > /dev/null 2>&1; then
                    log "✅ $service is healthy on port $port"
                    return 0
                fi
                ;;
        esac
        
        count=$((count + 1))
        sleep 10
        
        if [ $count -eq 15 ]; then
            log "⚠️  $service taking longer than expected, checking logs..."
            docker compose -f docker-compose.infrastructure.yml logs --tail=20 $service || true
        fi
    done
    
    log "❌ $service failed to become healthy after $((retries * 10)) seconds"
    return 1
}

# Ensure we're in the correct directory
cd $INFRA_DIR

# Create necessary directories
mkdir -p $BACKUP_DIR
mkdir -p logs

# Validate required environment variables
required_vars=("POSTGRES_PASSWORD" "REDIS_PASSWORD")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        log "❌ Required environment variable $var is not set!"
        exit 1
    fi
done

# Install Docker if not present
if ! command -v docker &> /dev/null; then
    log "📥 Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    apt install docker-compose-plugin -y
fi

# Backup existing data if containers are running
if docker ps | grep -q "battleone-postgres"; then
    log "📦 Creating backup before deployment..."
    docker exec battleone-postgres pg_dump -U battleone_user battleone > $BACKUP_DIR/pre_deploy_$(date +%Y%m%d_%H%M%S).sql || log "⚠️  Database backup failed"
fi

# Stop any existing services
log "🛑 Stopping existing infrastructure services..."
docker compose -f docker-compose.infrastructure.yml down || true

# Start infrastructure services
log "🚀 Starting infrastructure services..."
docker compose -f docker-compose.infrastructure.yml up -d postgres redis

# Wait for database to be ready
check_health "postgres" 5432 || {
    log "❌ PostgreSQL failed to start"
    exit 1
}

# Wait for Redis to be ready
check_health "redis" 6379 || {
    log "❌ Redis failed to start"
    exit 1
}

# Run Kratos migration
log "🚀 Starting Kratos migration..."
docker compose -f docker-compose.infrastructure.yml up -d kratos-migrate

# Wait for migration to complete
max_wait=180  # 3 minutes max for migration
wait_time=0
while [ $wait_time -lt $max_wait ]; do
    # Check if kratos-migrate container is still running
    if docker compose -f docker-compose.infrastructure.yml ps kratos-migrate | grep -q "Up"; then
        log "⏳ Migration still running... (${wait_time}s elapsed)"
        sleep 10
        wait_time=$((wait_time + 10))
        continue
    fi
    
    # Check for success message in logs
    if docker compose -f docker-compose.infrastructure.yml logs kratos-migrate --tail=20 | grep -q "Successfully applied SQL migrations"; then
        log "✅ Kratos database migration completed successfully"
        break
    elif docker compose -f docker-compose.infrastructure.yml ps kratos-migrate | grep -q "Exit 0"; then
        log "✅ Kratos database migration completed successfully (exit 0)"
        break
    elif docker compose -f docker-compose.infrastructure.yml ps kratos-migrate | grep -q "Exit"; then
        log "❌ Kratos migration failed"
        docker compose -f docker-compose.infrastructure.yml logs kratos-migrate --tail=50
        exit 1
    else
        sleep 10
        wait_time=$((wait_time + 10))
    fi
done

if [ $wait_time -ge $max_wait ]; then
    log "❌ Migration timed out after ${max_wait} seconds"
    exit 1
fi

# Start Kratos service
log "🚀 Starting Kratos service..."
docker compose -f docker-compose.infrastructure.yml up -d kratos

check_health "kratos" 4433 || {
    log "❌ Kratos failed to start"
    exit 1
}

# Display deployment status
log "📊 Infrastructure deployment status:"
docker compose -f docker-compose.infrastructure.yml ps

# Display resource usage
log "💻 Resource usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" | head -10

log "🎉 Infrastructure deployment completed successfully!"
log "✅ PostgreSQL: Running on port 5432"
log "✅ Redis: Running on port 6379"  
log "✅ Kratos: Running on ports 4433/4434"

echo ""
echo "🎯 INFRASTRUCTURE DEPLOYMENT SUMMARY"
echo "===================================="
echo "✅ Database: PostgreSQL running on port 5432"
echo "✅ Cache: Redis running on port 6379"  
echo "✅ Auth: Ory Kratos running on ports 4433/4434"
echo "✅ Network: battleone-network created"
echo ""
echo "📝 Management commands:"
echo "   Status: cd $INFRA_DIR && docker compose -f docker-compose.infrastructure.yml ps"
echo "   Logs: cd $INFRA_DIR && docker compose -f docker-compose.infrastructure.yml logs -f"

log "🏁 Infrastructure deployment script finished"