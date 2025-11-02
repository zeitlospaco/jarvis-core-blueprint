# 🚀 Quick Start Guide

Get Jarvis Core Blueprint running in 5 minutes!

## Prerequisites

- Docker & Docker Compose installed
- Domain name (for production) or use localhost
- API keys ready (OpenAI, Supabase, etc.)

## Step 1: Clone & Setup

```bash
git clone https://github.com/zeitlospaco/jarvis-core-blueprint.git
cd jarvis-core-blueprint
cp .env.example .env
```

## Step 2: Configure Environment

Edit `.env` and set these **required** variables:

```bash
# Minimal configuration for local testing
DOMAIN=localhost
POSTGRES_PASSWORD=$(openssl rand -base64 32)
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=$(openssl rand -base64 32)
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)
ACME_EMAIL=your-email@example.com
```

**For production**, also configure:
- `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`
- `OPENAI_API_KEY` or `ANTHROPIC_API_KEY`
- `SMTP_*` settings for email alerts

## Step 3: Start Services

```bash
# Start all services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f n8n
```

## Step 4: Access n8n

**Local:**
- URL: http://localhost:5678
- Username: `admin` (or your N8N_BASIC_AUTH_USER)
- Password: Check your `.env` file

**Production:**
- URL: https://n8n.yourdomain.com
- HTTPS is automatic via Traefik + Let's Encrypt

## 🔧 Common Commands

```bash
# Stop all services
docker compose down

# Restart n8n
docker compose restart n8n

# View logs
docker compose logs -f n8n
docker compose logs -f postgres
docker compose logs -f traefik

# Backup database
./scripts/backup-db.sh

# Backup workflows
./scripts/backup-n8n.sh

# Update containers
docker compose pull
docker compose up -d
```

## 📚 Next Steps

1. **Configure Integrations**: See README.md → Integration Guide
2. **Set Up Backups**: Configure `scripts/backup-*.sh` in cron
3. **Monitor System**: Check ops_agent.yml configuration
4. **Create Workflows**: Start building in n8n UI!

## 🆘 Troubleshooting

### Can't access n8n
```bash
# Check if services are running
docker compose ps

# Check logs for errors
docker compose logs n8n
```

### Database connection error
```bash
# Wait for PostgreSQL to be ready (takes ~30 seconds)
docker compose logs postgres

# Restart services
docker compose restart
```

### Port already in use
```bash
# Check what's using the port
sudo lsof -i :5678

# Change port in docker-compose.yml
ports:
  - "5679:5678"  # Use different port
```

## 📖 Full Documentation

See [README.md](README.md) for:
- Deployment to Render.com
- Deployment to Hetzner
- Complete integration guides
- Backup & restore procedures
- Monitoring & alerts setup

## 🎯 Production Checklist

Before going to production:

- [ ] Set strong passwords in `.env`
- [ ] Configure domain and DNS
- [ ] Set up SSL certificates (automatic with Traefik)
- [ ] Configure Supabase for logging
- [ ] Set up email alerts (SMTP)
- [ ] Enable automatic backups
- [ ] Configure firewall rules
- [ ] Test restore procedure
- [ ] Review security settings

---

**Need help?** Check [README.md](README.md) or create an issue on GitHub.
