# Jarvis Core Blueprint

> Enterprise-grade n8n workflow automation platform with AI capabilities (CrewAI, LangChain) and comprehensive DevOps setup.

## 🚀 Overview

Jarvis Core Blueprint is a production-ready deployment configuration for n8n workflow automation with integrated AI frameworks. It includes:

- **n8n**: Workflow automation platform with visual editor
- **Python AI Stack**: CrewAI, LangChain, OpenAI, Anthropic
- **PostgreSQL**: Persistent database for workflows and credentials
- **Traefik**: Automatic HTTPS with Let's Encrypt
- **Watchtower**: Automatic container updates
- **Operations Agent**: Health checks, logging, and alerting

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment Options](#deployment-options)
  - [Deploy on Render.com](#deploy-on-rendercom)
  - [Deploy on Hetzner](#deploy-on-hetzner)
  - [Local Development](#local-development)
  - [Deployment mit Supabase](#deployment-mit-supabase)
- [Configuration](#configuration)
- [Integration Guide](#integration-guide)
- [Backup & Restore](#backup--restore)
- [Monitoring & Alerts](#monitoring--alerts)
- [Troubleshooting](#troubleshooting)
- [Security Best Practices](#security-best-practices)

## ✨ Features

### Core Functionality
- ✅ **n8n Workflow Automation**: Visual workflow builder with 400+ integrations
- ✅ **AI Integration**: CrewAI multi-agent framework and LangChain
- ✅ **Python Support**: Full Python 3.11 environment in n8n
- ✅ **Supabase Integration**: Built-in database and auth support
- ✅ **Automatic HTTPS**: SSL certificates via Let's Encrypt
- ✅ **Auto-Updates**: Container updates with Watchtower

### DevOps & Operations
- ✅ **Health Monitoring**: Automated health checks with alerts
- ✅ **Structured Logging**: Logs to Supabase with retention policies
- ✅ **Email Alerts**: SMTP notifications for critical issues
- ✅ **Backup Support**: Automated backup configuration
- ✅ **High Availability**: Load balancing ready with Traefik

## 🔧 Prerequisites

### For Render.com Deployment
- Render.com account
- Domain name (optional but recommended)
- API keys for integrations (OpenAI, Supabase, etc.)

### For Hetzner/Self-Hosted Deployment
- Ubuntu 22.04 LTS server (or similar)
- Docker 24.0+ and Docker Compose 2.20+
- Domain name with DNS access
- Minimum 2GB RAM, 2 CPU cores, 20GB storage
- Root or sudo access

### For Local Development
- Docker Desktop or Docker Engine + Docker Compose
- 4GB+ RAM available for Docker
- macOS, Linux, or Windows with WSL2

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/zeitlospaco/jarvis-core-blueprint.git
cd jarvis-core-blueprint
```

### 2. Configure Environment

```bash
# Copy example environment file
cp .env.example .env

# Edit with your credentials
nano .env
```

**Required Variables:**
- `DOMAIN`: Your domain name
- `N8N_BASIC_AUTH_USER` & `N8N_BASIC_AUTH_PASSWORD`: n8n login
- `N8N_ENCRYPTION_KEY`: Generate with `openssl rand -hex 32`
- `POSTGRES_PASSWORD`: Database password
- `ACME_EMAIL`: Email for SSL certificates

### 3. Start Services

```bash
# Build and start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f n8n
```

### 4. Access n8n

- **URL**: `https://n8n.yourdomain.com` (or `http://localhost:5678` for local)
- **Username**: Value from `N8N_BASIC_AUTH_USER`
- **Password**: Value from `N8N_BASIC_AUTH_PASSWORD`

## 🌐 Deployment Options

## Deploy on Render.com

Render.com provides a managed platform with automatic scaling, zero-config SSL, and global CDN.

**👉 [Complete Render Deployment Guide](RENDER_DEPLOYMENT.md)** - Detailed step-by-step instructions

### Quick Deploy

1. **Fork this repository** to your GitHub account

2. **Click to deploy**:
   
   [![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

3. **Configure environment variables** when prompted:
   - `N8N_BASIC_AUTH_USER` - Your n8n username
   - `N8N_BASIC_AUTH_PASSWORD` - Secure password
   - `N8N_ENCRYPTION_KEY` - Generate with: `openssl rand -hex 32`
   - API keys for integrations (OpenAI, Supabase, etc.)

4. **Wait for deployment** (~5-10 minutes)

5. **Access your n8n** at the provided Render URL

### What Gets Deployed

The `render.yaml` blueprint automatically provisions:

- ✅ **n8n Web Service** (Docker-based)
- ✅ **PostgreSQL Database** (15GB storage)
- ✅ **10GB Persistent Disk** for workflows and credentials
- ✅ **Automatic SSL/HTTPS** via Let's Encrypt
- ✅ **Health Checks** with auto-restart
- ✅ **Auto-deploy** on git push

### Configuration

- **Region**: Frankfurt (eu-central) - GDPR compliant
- **Plan**: Standard ($25/month) + Database Starter ($7/month)
- **Total Cost**: ~$32/month

### Custom Domain

After deployment:

1. Go to **Settings → Custom Domain**
2. Add your domain: `n8n.yourdomain.com`
3. Update DNS: `CNAME n8n.yourdomain.com → your-service.onrender.com`
4. SSL certificate is automatic

### Troubleshooting

If you see "A render.yaml file was found, but there was an issue":

1. Ensure you have the latest version of `render.yaml`
2. Check that all required environment variables are set
3. Verify your repository is accessible to Render
4. See [RENDER_DEPLOYMENT.md](RENDER_DEPLOYMENT.md) for detailed troubleshooting

### Need Help?

- 📖 [Detailed Deployment Guide](RENDER_DEPLOYMENT.md)
- 💬 [Render Community](https://community.render.com)
- 🐛 [Report Issues](https://github.com/zeitlospaco/jarvis-core-blueprint/issues)

## Deploy on Hetzner

Hetzner provides excellent price/performance for EU-based hosting.

### Step 1: Create Server

1. Go to [Hetzner Cloud Console](https://console.hetzner.cloud)
2. Create new project: "jarvis-n8n"
3. Create server:
   - **Location**: Falkenstein (Germany) or Helsinki
   - **Image**: Ubuntu 22.04
   - **Type**: CPX21 (3 vCPU, 4GB RAM) - €7.99/month
   - **Networking**: Enable IPv4 & IPv6
   - **SSH Key**: Add your public key

### Step 2: Initial Server Setup

```bash
# SSH into server
ssh root@your-server-ip

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh

# Install Docker Compose
apt install docker-compose-plugin -y

# Create application user
useradd -m -s /bin/bash jarvis
usermod -aG docker jarvis

# Switch to application user
su - jarvis
```

### Step 3: Deploy Application

```bash
# Clone repository
git clone https://github.com/zeitlospaco/jarvis-core-blueprint.git
cd jarvis-core-blueprint

# Configure environment
cp .env.example .env
nano .env

# Generate secure passwords
openssl rand -base64 32  # For passwords
openssl rand -hex 32     # For encryption keys

# Start services
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f
```

### Step 4: Configure DNS

Point your domain to server IP:

```
A     n8n.yourdomain.com    → your-server-ip
A     traefik.yourdomain.com → your-server-ip
```

Wait for DNS propagation (check with: `dig n8n.yourdomain.com`)

### Step 5: Configure Firewall

```bash
# Enable UFW firewall
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable

# Check status
ufw status
```

### Step 6: Verify Deployment

```bash
# Check container status
docker-compose ps

# Check SSL certificate
docker-compose logs traefik | grep certificate

# Test endpoints
curl -I https://n8n.yourdomain.com
```

### Hetzner Backup Configuration

Enable automated backups in Hetzner Console:

1. Go to your server
2. Enable "Backups" (20% of server cost)
3. Backups run daily automatically

For application-level backups, see [Backup & Restore](#backup--restore).

## Local Development

For testing and development on your local machine:

```bash
# Clone repository
git clone https://github.com/zeitlospaco/jarvis-core-blueprint.git
cd jarvis-core-blueprint

# Use local environment
cp .env.example .env.local

# Edit for local development
nano .env.local

# Important: Change DOMAIN to localhost
DOMAIN=localhost

# Start services (detached)
docker-compose --env-file .env.local up -d

# Access n8n at http://localhost:5678
```

**Note**: For local development:
- HTTPS/Traefik is optional
- Use `http://localhost:5678` directly
- PostgreSQL data persists in named volume

## Deployment mit Supabase

This section provides step-by-step instructions for deploying Jarvis Core with a Supabase PostgreSQL database instead of a local or managed PostgreSQL instance.

### Why Use Supabase?

- **Free Tier Available**: Up to 500MB database (enough for getting started)
- **Global CDN**: Fast database access from anywhere
- **Built-in Features**: Auth, Storage, and Realtime capabilities
- **Easy Setup**: No server management required
- **Scalable**: Upgrade as you grow

### Prerequisites

1. A [Supabase](https://supabase.com) account (free tier works)
2. Your deployment platform ready (Render, Railway, Hetzner, or local)

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click **"New Project"**
3. Choose your organization or create a new one
4. Fill in project details:
   - **Name**: `jarvis-n8n` (or your preferred name)
   - **Database Password**: Generate a strong password (save it!)
   - **Region**: Choose closest to your deployment (e.g., `eu-central` for Europe)
5. Click **"Create new project"** and wait 1-2 minutes for provisioning

### Step 2: Get Database Connection String

1. In your Supabase project dashboard, go to **Settings → Database**
2. Scroll down to **Connection string** section
3. Select the **URI** tab
4. You'll see a connection string like:
   ```
   postgresql://postgres:{YOUR_PASSWORD}@db.xxxxxxxxxxxxx.supabase.co:5432/postgres
   ```
5. Replace `{YOUR_PASSWORD}` with your actual database password from Step 1

**Important for Render/Railway/Serverless deployments**: Consider using the connection pooler (port 6543) for better reliability:
```
postgresql://postgres:{YOUR_PASSWORD}@db.xxxxxxxxxxxxx.supabase.co:6543/postgres
```

The connection pooler is recommended for container-based deployments as it handles connections more efficiently.
6. **Copy the complete connection string** - you'll need it in the next step

**⚠️ Security Warning**: This connection string contains your database password. Keep it secret and never commit it to public repositories!

### Step 3: Configure Your Deployment

Choose your deployment method:

#### A. Deploy on Render.com

1. Follow the [Render Deployment Guide](RENDER_DEPLOYMENT.md)
2. When prompted for environment variables, add:
   ```
   SUPABASE_DB_URL=postgresql://postgres:{YOUR_PASSWORD}@db.xxxxx.supabase.co:5432/postgres
   ```
3. The blueprint will automatically use this instead of creating a Render database
4. Complete the deployment as normal

**Cost Savings**: Using Supabase means you don't pay for Render's PostgreSQL ($7/month), only the web service ($25/month for Standard plan).

#### B. Deploy on Railway

1. Create a new project on [Railway](https://railway.app)
2. Connect your GitHub repository
3. Add environment variable in Railway dashboard:
   - Key: `SUPABASE_DB_URL`
   - Value: Your Supabase connection string
4. Add other required variables (see [ENV_VARIABLES.md](ENV_VARIABLES.md))
5. Deploy from the dashboard

#### C. Deploy on Hetzner or Self-Hosted

1. Follow the [Hetzner deployment steps](#deploy-on-hetzner)
2. When editing `.env` file:
   ```bash
   nano .env
   ```
3. Add this line:
   ```bash
   SUPABASE_DB_URL=postgresql://postgres:{YOUR_PASSWORD}@db.xxxxx.supabase.co:5432/postgres
   ```
4. Comment out local PostgreSQL settings (optional - n8n will prioritize `SUPABASE_DB_URL`)
5. Start services with `docker-compose up -d`

#### D. Local Development with Supabase

1. Clone the repository:
   ```bash
   git clone https://github.com/zeitlospaco/jarvis-core-blueprint.git
   cd jarvis-core-blueprint
   ```

2. Create `.env` file:
   ```bash
   cp .env.example .env
   ```

3. Edit `.env` and set:
   ```bash
   SUPABASE_DB_URL=postgresql://postgres:{YOUR_PASSWORD}@db.xxxxx.supabase.co:5432/postgres
   ```

4. Start only n8n (skip local PostgreSQL):
   ```bash
   docker-compose up n8n -d
   ```

### Step 4: Verify Database Connection

After deployment, verify n8n is using Supabase:

1. Access your n8n instance
2. Check the logs for successful database connection:
   ```bash
   # For Docker Compose
   docker-compose logs n8n | grep -i "database"
   
   # For Render
   # Check logs in Render dashboard
   ```

3. You should see messages indicating PostgreSQL connection success

4. In Supabase dashboard, go to **Database → Roles and Policies**
   - You'll see new tables created by n8n (like `execution_entity`, `workflow_entity`)

### Step 5: Configure Additional Supabase Features (Optional)

Beyond just using Supabase as a database, you can integrate other features:

#### Enable Supabase Integration in n8n

1. In Supabase project, go to **Settings → API**
2. Copy these credentials:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: For client-side operations
   - **service_role key**: For server-side operations (keep secret!)

3. Add to your environment variables:
   ```bash
   SUPABASE_URL=https://xxxxx.supabase.co
   SUPABASE_ANON_KEY=your_anon_key_here
   SUPABASE_SERVICE_KEY=your_service_role_key_here
   ```

4. In n8n, you can now:
   - Use Supabase nodes in workflows
   - Store workflow data in Supabase tables
   - Use Supabase Auth for user management
   - Leverage Supabase Storage for files

### Troubleshooting Supabase Connection

#### Connection Timeout

**Problem**: n8n logs show "connection timeout" or "ETIMEDOUT" or "TCP FAIL"

**Solutions**:
1. **Check if database is paused**: Supabase free tier databases pause after 7 days of inactivity
   - Go to your Supabase project dashboard
   - If you see "Database paused", click "Resume" 
   - Wait 1-2 minutes for the database to wake up
2. **Use Connection Pooler**: For better reliability on platforms like Render, use port 6543 instead of 5432:
   ```
   postgresql://postgres:{YOUR_PASSWORD}@db.xxxxx.supabase.co:6543/postgres?sslmode=require
   ```
   This uses Supabase's connection pooler which is more stable for serverless/container deployments
3. Check your Supabase password is correct in the connection string
4. Verify the region matches (some regions may have slower connections)
5. Check firewall settings on your deployment platform
6. Ensure you're using the correct connection string format with `postgresql://` (not `postgres://`)

**Note**: If deploying to Render, the startup script automatically converts `postgres://` to `postgresql://` for compatibility.

#### SSL/TLS Errors

**Problem**: "SSL connection error" or certificate validation issues

**Solution**: Supabase requires SSL. Add `?sslmode=require` to your connection string:
```
postgresql://postgres:{YOUR_PASSWORD}@db.xxxxx.supabase.co:5432/postgres?sslmode=require
```

#### Too Many Connections

**Problem**: "too many connections" error

**Solution**: 
1. Free tier has connection limits (60 concurrent connections)
2. Upgrade to Pro plan for more connections
3. Or adjust n8n execution mode to use fewer connections

#### Cannot Connect from IP

**Problem**: Connection refused or blocked

**Solution**: 
1. Go to Supabase → **Settings → Database**
2. Check **Connection Pooling** settings
3. Ensure your deployment IP isn't blocked
4. Consider using connection pooling mode

### Security Best Practices for Supabase

1. **Never commit connection strings**: Always use environment variables
2. **Use strong passwords**: Generate with `openssl rand -base64 32`
3. **Rotate credentials regularly**: Every 90 days
4. **Enable Row Level Security (RLS)**: In Supabase for production data
5. **Monitor access logs**: Check Supabase dashboard regularly
6. **Use connection pooling**: For production deployments
7. **Backup regularly**: Use Supabase's backup features

### Database Backups with Supabase

Supabase automatically backs up your database:

- **Free Tier**: Daily backups, 7-day retention
- **Pro Tier**: Daily backups, 30-day retention
- **Enterprise**: Custom retention policies

**Manual Backup**:
```bash
# Export from Supabase dashboard
# Settings → Database → Database Backups → Download

# Or use pg_dump with your connection string
pg_dump "postgresql://postgres:{YOUR_PASSWORD}@db.xxxxx.supabase.co:5432/postgres" > backup.sql
```

### Migration from Local PostgreSQL to Supabase

If you're already running n8n with local PostgreSQL and want to migrate:

1. **Backup existing data**:
   ```bash
   docker-compose exec postgres pg_dump -U n8n_user n8n > backup.sql
   ```

2. **Set up Supabase** (follow Step 1 & 2 above)

3. **Import to Supabase**:
   ```bash
   psql "postgresql://postgres:{YOUR_PASSWORD}@db.xxxxx.supabase.co:5432/postgres" < backup.sql
   ```

4. **Update environment**:
   - Add `SUPABASE_DB_URL` to your `.env`
   - Restart n8n

5. **Verify data**:
   - Check workflows are present
   - Test executions work
   - Verify credentials are accessible

### Cost Comparison

| Component | Local PostgreSQL | Render PostgreSQL | Supabase Free | Supabase Pro |
|-----------|------------------|-------------------|---------------|--------------|
| Database | Free (self-host) | $7/month | $0/month | $25/month |
| Storage | Self-managed | 15GB | 500MB | 8GB |
| Bandwidth | Unlimited | Unlimited | 5GB/month | 250GB/month |
| Connections | No limit | 97 | 60 | 200 |
| Backups | Manual | 30 days | 7 days | 30 days |

**Recommendation**:
- **Development/Testing**: Supabase Free
- **Small Production**: Supabase Pro
- **Large Scale**: Self-hosted or Render managed database

### Next Steps

After deploying with Supabase:

1. ✅ Test your first workflow in n8n
2. ✅ Configure additional integrations (OpenAI, etc.)
3. ✅ Set up monitoring and alerts
4. ✅ Configure automated backups
5. ✅ Review security settings

For detailed environment variable configuration, see [ENV_VARIABLES.md](ENV_VARIABLES.md).

## ⚙️ Configuration

### Environment Variables

All configuration is done via `.env` file. See `.env.example` for full list.

**Critical Variables:**

```bash
# Domain
DOMAIN=yourdomain.com

# n8n Authentication
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your-secure-password
N8N_ENCRYPTION_KEY=your-encryption-key-32-chars

# Database
POSTGRES_PASSWORD=your-db-password

# SSL Email
ACME_EMAIL=your-email@example.com

# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-key

# AI APIs
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
```

### Generating Secure Keys

```bash
# Password (32 characters)
openssl rand -base64 32

# Encryption key (64 hex characters)
openssl rand -hex 32

# htpasswd for Traefik
htpasswd -nb admin your-password
```

### Custom n8n Configuration

Edit `docker-compose.yml` environment section for n8n service:

```yaml
environment:
  - EXECUTIONS_PROCESS=main  # or 'own' for separate process
  - EXECUTIONS_MODE=regular  # or 'queue' for Redis queue
  - N8N_METRICS=true         # Enable Prometheus metrics
```

## 🔌 Integration Guide

### Supabase Integration

1. **Create Supabase Project**: Go to [supabase.com](https://supabase.com)

2. **Get Credentials**:
   - Project URL: Settings → API
   - Anon Key: Settings → API → anon public
   - Service Key: Settings → API → service_role (keep secret!)

3. **Configure Tables for Logging**:

```sql
-- Create ops_logs table
CREATE TABLE ops_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  level TEXT NOT NULL,
  service TEXT NOT NULL,
  message TEXT NOT NULL,
  context JSONB,
  trace_id UUID
);

-- Create index for faster queries
CREATE INDEX idx_ops_logs_timestamp ON ops_logs(timestamp DESC);
CREATE INDEX idx_ops_logs_level ON ops_logs(level);

-- Create ops_metrics table
CREATE TABLE ops_metrics (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  metric_name TEXT NOT NULL,
  metric_value NUMERIC NOT NULL,
  metric_type TEXT,
  tags JSONB
);

-- Create index
CREATE INDEX idx_ops_metrics_timestamp ON ops_metrics(timestamp DESC);
```

4. **Add to n8n**: In n8n, credentials → Add Credential → Supabase

### OpenAI Integration

1. Get API key from [platform.openai.com](https://platform.openai.com)
2. Add to `.env`: `OPENAI_API_KEY=sk-...`
3. Use in n8n workflows via OpenAI node

### LangChain/LangSmith Integration

1. Sign up at [smith.langchain.com](https://smith.langchain.com)
2. Get API key
3. Configure in `.env`:

```bash
LANGCHAIN_API_KEY=ls__...
LANGCHAIN_TRACING_V2=true
LANGCHAIN_PROJECT=jarvis-core
```

### Slack Integration

1. Create Slack App at [api.slack.com](https://api.slack.com)
2. Add Bot Token Scopes: `chat:write`, `channels:read`
3. Install app to workspace
4. Get Bot Token and add to `.env`
5. Configure webhook URL in n8n: `https://n8n.yourdomain.com/webhook/slack`

### Email (SMTP) Integration

**Gmail:**
```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password  # Generate in Google Account
```

**SendGrid:**
```bash
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASSWORD=your-sendgrid-api-key
```

## 💾 Backup & Restore

### Automated Backups

#### PostgreSQL Database Backup

Create backup script: `scripts/backup-db.sh`

```bash
#!/bin/bash
# Database backup script

# Configuration
BACKUP_DIR="/data/backups/postgres"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
docker-compose exec -T postgres pg_dump -U $POSTGRES_USER $POSTGRES_DB | gzip > $BACKUP_DIR/backup_$TIMESTAMP.sql.gz

# Upload to S3 (optional)
# aws s3 cp $BACKUP_DIR/backup_$TIMESTAMP.sql.gz s3://your-bucket/backups/

# Clean old backups
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: backup_$TIMESTAMP.sql.gz"
```

Make executable and add to cron:

```bash
chmod +x scripts/backup-db.sh

# Add to crontab (daily at 2 AM)
crontab -e
0 2 * * * /home/jarvis/jarvis-core-blueprint/scripts/backup-db.sh
```

#### n8n Data Backup

```bash
#!/bin/bash
# n8n data backup script

BACKUP_DIR="/data/backups/n8n"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup
docker-compose exec -T n8n n8n export:workflow --all --output=/tmp/workflows.json
docker cp jarvis-n8n:/tmp/workflows.json $BACKUP_DIR/workflows_$TIMESTAMP.json

# Backup credentials (encrypted)
docker cp jarvis-n8n:/home/node/.n8n $BACKUP_DIR/n8n_data_$TIMESTAMP

echo "n8n backup completed"
```

### Restore from Backup

#### Restore Database

```bash
# Stop n8n
docker-compose stop n8n

# Restore database
gunzip -c backup_20240101_120000.sql.gz | docker-compose exec -T postgres psql -U $POSTGRES_USER $POSTGRES_DB

# Restart services
docker-compose up -d
```

#### Restore n8n Workflows

```bash
# Import workflows
docker cp workflows_20240101_120000.json jarvis-n8n:/tmp/workflows.json
docker-compose exec n8n n8n import:workflow --input=/tmp/workflows.json

# Or restore entire .n8n folder
docker-compose stop n8n
docker cp n8n_data_20240101_120000 jarvis-n8n:/home/node/.n8n
docker-compose up -d n8n
```

### Backup to S3

Configure AWS CLI or S3-compatible storage:

```bash
# Install AWS CLI
apt install awscli -y

# Configure
aws configure

# Sync backups to S3
aws s3 sync /data/backups s3://your-bucket/jarvis-backups/
```

## 📊 Monitoring & Alerts

### Health Checks

The ops_agent.yml configures automated health checks:

- **Schedule**: 3x daily (9 AM, 3 PM, 9 PM)
- **Endpoints**: n8n web, API, PostgreSQL, Supabase
- **Alerts**: Email via SMTP on failures

### Logging to Supabase

All application logs, health check results, and metrics are logged to Supabase:

1. **View Logs**:
   ```sql
   SELECT * FROM ops_logs 
   WHERE level = 'error' 
   ORDER BY timestamp DESC 
   LIMIT 100;
   ```

2. **View Metrics**:
   ```sql
   SELECT * FROM ops_metrics 
   WHERE metric_name = 'cpu_usage' 
   ORDER BY timestamp DESC 
   LIMIT 100;
   ```

### Email Alerts

Configure SMTP in `.env` and ops_agent.yml handles:

- Service down alerts
- High CPU/memory usage
- Database connection failures
- SSL certificate expiry warnings
- Workflow execution failures

### Traefik Dashboard

Access at `https://traefik.yourdomain.com` (configure authentication in docker-compose.yml)

### Manual Health Check

```bash
# Check all services
docker-compose ps

# Check n8n health
curl https://n8n.yourdomain.com/healthz

# Check database
docker-compose exec postgres pg_isready

# View logs
docker-compose logs -f n8n
docker-compose logs -f traefik
docker-compose logs -f postgres
```

## 🔧 Troubleshooting

### n8n Won't Start

```bash
# Check logs
docker-compose logs n8n

# Common issues:
# 1. Database not ready - wait for postgres health check
# 2. Port conflict - ensure 5678 is available
# 3. Permission issues - check volume permissions
```

### Cannot Access via Domain

```bash
# Check DNS
dig n8n.yourdomain.com

# Check Traefik logs
docker-compose logs traefik

# Check SSL certificate
docker-compose exec traefik cat /letsencrypt/acme.json
```

### Database Connection Error

```bash
# Check database status
docker-compose ps postgres

# Test connection
docker-compose exec postgres psql -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1;"

# Reset database (WARNING: deletes data)
docker-compose down -v
docker-compose up -d
```

### High Memory Usage

```bash
# Check resource usage
docker stats

# Adjust memory limits in docker-compose.yml
deploy:
  resources:
    limits:
      memory: 2G  # Increase as needed
```

### SSL Certificate Issues

```bash
# Force certificate renewal
docker-compose exec traefik rm /letsencrypt/acme.json
docker-compose restart traefik

# Check Let's Encrypt rate limits
# Max 5 certificates per domain per week
```

## 🔒 Security Best Practices

### 1. Use Strong Credentials

```bash
# Generate strong passwords
openssl rand -base64 32

# Never use default passwords
# Rotate keys regularly (every 90 days)
```

### 2. Secure Environment Files

```bash
# Never commit .env to git
echo ".env" >> .gitignore

# Set proper permissions
chmod 600 .env
```

### 3. Enable Firewall

```bash
# On server
ufw enable
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
```

### 4. Regular Updates

```bash
# Update system packages
apt update && apt upgrade -y

# Watchtower handles container updates automatically
# Check watchtower logs
docker-compose logs watchtower
```

### 5. Limit API Access

- Use API key rotation
- Implement rate limiting
- Monitor API usage in logs

### 6. Enable 2FA

For critical integrations (Supabase, AWS, etc.), enable two-factor authentication.

### 7. Backup Encryption

```bash
# Encrypt backups before upload
gpg --symmetric --cipher-algo AES256 backup.sql.gz
```

## 📚 Additional Resources

### Documentation

- [n8n Documentation](https://docs.n8n.io)
- [LangChain Documentation](https://python.langchain.com)
- [CrewAI Documentation](https://docs.crewai.com)
- [Docker Documentation](https://docs.docker.com)
- [Traefik Documentation](https://doc.traefik.io/traefik/)

### Support

- GitHub Issues: [Create issue](https://github.com/zeitlospaco/jarvis-core-blueprint/issues)
- n8n Community: [community.n8n.io](https://community.n8n.io)

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🙏 Acknowledgments

- n8n team for the amazing workflow automation platform
- Traefik team for the reverse proxy
- CrewAI and LangChain communities

---

**Made with ❤️ for the automation community**