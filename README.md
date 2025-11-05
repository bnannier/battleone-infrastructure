# BattleOne Infrastructure Dependencies

This folder contains all the infrastructure dependencies that need to be deployed to the DigitalOcean droplet before the BFF application can be deployed.

## Components

### 1. PostgreSQL Database
- **Image**: `postgres:15-alpine`
- **Port**: `127.0.0.1:5432:5432`
- **Container**: `battleone-postgres`
- **Purpose**: Primary database for user data, sessions, and application state

### 2. Redis Cache
- **Image**: `redis:7-alpine`  
- **Port**: `127.0.0.1:6379:6379`
- **Container**: `battleone-redis`
- **Purpose**: Session storage, caching, and rate limiting

### 3. Ory Kratos Identity Management
- **Image**: `oryd/kratos:v1.0.0`
- **Ports**: 
  - Public API: `127.0.0.1:4433:4433`
  - Admin API: `127.0.0.1:4434:4434`
- **Container**: `battleone-kratos`
- **Purpose**: User authentication, registration, and identity management
- **Migrations**: Kratos handles its own table creation automatically

## Files Structure

```
battleone-infrastructure/
├── README.md                           # This file
├── docker-compose.infrastructure.yml   # Infrastructure services
├── deploy-infrastructure.sh            # Infrastructure deployment script
└── ory/                                # Kratos configuration
    ├── kratos.yml                      # Main Kratos config
    ├── identity.schema.json            # User identity schema
    └── email-templates/                # Email templates
```

## Deployment Order

1. **First**: Deploy infrastructure using this folder
2. **Second**: Deploy BFF application from the main project

## Infrastructure Deployment

### Prerequisites
- Docker and Docker Compose installed on the droplet
- Required environment variables set

### Required Environment Variables
```bash
export POSTGRES_PASSWORD="your_postgres_password"
export REDIS_PASSWORD="your_redis_password" 
export POSTGRES_DB="battleone"
export POSTGRES_USER="battleone_user"
export KRATOS_LOG_LEVEL="warn"
```

### Deploy Infrastructure
```bash
# Copy this folder to the droplet
scp -r battleone-infrastructure/ user@droplet:/opt/battleone/infrastructure/

# SSH to droplet and deploy
ssh user@droplet
cd /opt/battleone/infrastructure
chmod +x deploy-infrastructure.sh
./deploy-infrastructure.sh
```

### Manual Deployment
```bash
# Start infrastructure services
docker compose -f docker-compose.infrastructure.yml up -d

# Check status
docker compose -f docker-compose.infrastructure.yml ps

# View logs
docker compose -f docker-compose.infrastructure.yml logs -f
```

## Network

The infrastructure creates a Docker network called `battleone-network` that the BFF application will connect to. This allows the BFF containers to communicate with the infrastructure services using service names:

- `postgres` - PostgreSQL database
- `redis` - Redis cache  
- `kratos` - Kratos identity service

## Health Checks

All services include health checks:
- **PostgreSQL**: `pg_isready` command
- **Redis**: `redis-cli ping` command  
- **Kratos**: HTTP health endpoint `/health/ready`

## Resource Limits

Conservative resource limits are set:
- **PostgreSQL**: 256MB RAM, 0.4 CPU
- **Redis**: 128MB RAM, 0.2 CPU
- **Kratos**: 256MB RAM, 0.3 CPU

## Data Persistence

Persistent volumes are created for:
- `postgres_data` - PostgreSQL data
- `redis_data` - Redis data

## Management Commands

```bash
# Check status
docker compose -f docker-compose.infrastructure.yml ps

# View logs
docker compose -f docker-compose.infrastructure.yml logs -f [service_name]

# Stop services
docker compose -f docker-compose.infrastructure.yml down

# Restart a service
docker compose -f docker-compose.infrastructure.yml restart [service_name]

# Backup database
docker exec battleone-postgres pg_dump -U battleone_user battleone > backup.sql

# Access PostgreSQL
docker exec -it battleone-postgres psql -U battleone_user -d battleone

# Access Redis
docker exec -it battleone-redis redis-cli
```

## Troubleshooting

### Check Infrastructure Status
```bash
cd /opt/battleone/infrastructure
docker compose -f docker-compose.infrastructure.yml ps
```

### View Service Logs
```bash
docker compose -f docker-compose.infrastructure.yml logs postgres
docker compose -f docker-compose.infrastructure.yml logs redis  
docker compose -f docker-compose.infrastructure.yml logs kratos
```

### Test Connectivity
```bash
# Test PostgreSQL
docker exec battleone-postgres pg_isready -U battleone_user -d battleone

# Test Redis
docker exec battleone-redis redis-cli ping

# Test Kratos
curl http://localhost:4433/health/ready
```

## Security Notes

- PostgreSQL and Redis are bound to `127.0.0.1` (localhost only)
- Kratos public/admin APIs are bound to `127.0.0.1` 
- All services communicate over the internal Docker network
- Strong passwords should be used for all database connections