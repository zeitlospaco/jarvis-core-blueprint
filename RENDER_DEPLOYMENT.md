# Render.com Deployment Guide

This guide walks you through deploying Jarvis Core Blueprint on Render.com using the Blueprint feature.

## Prerequisites

Before you begin, ensure you have:

1. A [Render.com](https://render.com) account
2. A GitHub account with this repository forked or accessible
3. API keys for your integrations (OpenAI, Supabase, etc.)

## Deployment Steps

### 1. Prepare Your Repository

Fork or clone this repository to your GitHub account.

### 2. Deploy via Render Blueprint

#### Option A: Deploy via Dashboard (Recommended)

1. Log in to your [Render Dashboard](https://dashboard.render.com)
2. Click **"New +"** in the top right corner
3. Select **"Blueprint"** from the dropdown menu
4. Connect your GitHub account if you haven't already
5. Select this repository from the list
6. Render will automatically detect the `render.yaml` file
7. Click **"Apply"** to start the deployment

#### Option B: Deploy via One-Click Button

Click this button to deploy directly:

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

### 3. Configure Environment Variables

After deployment is initiated, you'll need to configure the environment variables. Render will prompt you to fill in values for all `generateValue: true` variables.

#### Required Variables

You must provide values for:

- **N8N_BASIC_AUTH_USER**: Your desired n8n username (e.g., `admin`)
- **N8N_BASIC_AUTH_PASSWORD**: Strong password for n8n access
  ```bash
  # Generate a secure password:
  openssl rand -base64 32
  ```
- **N8N_ENCRYPTION_KEY**: 32-character hex string for encrypting credentials
  ```bash
  # Generate encryption key:
  openssl rand -hex 32
  ```

#### Optional But Recommended Variables

For full functionality, provide:

- **SUPABASE_URL**: Your Supabase project URL (e.g., `https://xxxxx.supabase.co`)
- **SUPABASE_ANON_KEY**: Supabase anonymous key
- **SUPABASE_SERVICE_KEY**: Supabase service role key (keep secret!)
  - **Note**: In Supabase dashboard, this is labeled as `service_role` key
  - Previous versions used `SUPABASE_SERVICE_ROLE` - both names work, but `SUPABASE_SERVICE_KEY` is recommended
- **OPENAI_API_KEY**: OpenAI API key for AI workflows
- **ANTHROPIC_API_KEY**: Anthropic/Claude API key
- **SMTP_HOST**: SMTP server for email notifications
- **SMTP_USER**: SMTP username
- **SMTP_PASSWORD**: SMTP password
- **SMTP_FROM_EMAIL**: Email address for sending notifications

You can add or update these variables later in the Render dashboard under:
**Your Service → Environment → Environment Variables**

### 4. Wait for Deployment

The initial deployment takes approximately 5-10 minutes:

1. **Building Docker Image**: ~3-5 minutes
2. **Provisioning Database**: ~1-2 minutes
3. **Starting Services**: ~1-2 minutes

You can monitor progress in the Render dashboard under **Events** and **Logs**.

### 5. Access Your n8n Instance

Once deployment is complete:

1. Navigate to your service in the Render dashboard
2. Find the URL (e.g., `https://jarvis-n8n.onrender.com`)
3. Open the URL in your browser
4. Log in with your `N8N_BASIC_AUTH_USER` and `N8N_BASIC_AUTH_PASSWORD`

## Post-Deployment Configuration

### Set Up Custom Domain (Optional)

To use your own domain:

1. Go to **Settings → Custom Domain** in your service
2. Add your domain (e.g., `n8n.yourdomain.com`)
3. Update your DNS with the provided CNAME record:
   ```
   CNAME  n8n.yourdomain.com  →  jarvis-n8n.onrender.com
   ```
4. Render will automatically provision an SSL certificate

### Configure Supabase Integration

1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Get your credentials from **Project Settings → API**
3. Add the credentials to Render environment variables
4. Create required tables for logging (see main README.md)

### Test Your Deployment

1. Access your n8n URL
2. Create a simple workflow
3. Execute it to ensure everything works
4. Check the health endpoint: `https://your-url.onrender.com/healthz`

## Configuration Details

### Service Configuration

The `render.yaml` defines the following:

- **Service Type**: Web Service (Docker)
- **Region**: Frankfurt (eu-central) - GDPR compliant
- **Plan**: Standard ($25/month)
- **Disk**: 10GB persistent storage for n8n data
- **Health Check**: `/healthz` endpoint monitored every 30s

### Database Configuration

- **Database**: PostgreSQL 15
- **Plan**: Starter ($7/month)
- **Database Name**: jarvis_n8n
- **User**: jarvis_admin
- **Connection**: Automatically linked to web service

### Auto-Scaling

The Standard plan includes:

- Automatic SSL/TLS
- Auto-deploy on git push
- Zero-downtime deployments
- Health checks with auto-restart

## Cost Estimate

Monthly costs on Render:

- **Web Service (Standard)**: $25/month
- **PostgreSQL (Starter)**: $7/month
- **Total**: ~$32/month

You can downgrade to the Starter plan ($7/month) for testing, but it has limitations:
- Service sleeps after 15 minutes of inactivity
- Slower cold starts

## Troubleshooting

### Service Won't Start

Check the logs in Render dashboard:

1. Go to **Logs** tab
2. Look for error messages
3. Common issues:
   - Missing required environment variables
   - Database connection timeout (wait a few minutes)
   - Docker build failure (check Dockerfile)

### Cannot Access Service

1. Check service status in dashboard (should be "Live")
2. Verify health check is passing
3. Check if firewall/network is blocking access
4. Try accessing the health endpoint: `https://your-url/healthz`

### Database Connection Errors

1. Ensure database is "Available" in dashboard
2. Check that `fromDatabase` references in render.yaml match your database name
3. Verify database credentials in environment variables

### SSL Certificate Issues

Render automatically provisions SSL certificates via Let's Encrypt. If you see certificate errors:

1. Wait 5-10 minutes for certificate to provision
2. Check custom domain DNS is properly configured
3. Contact Render support if issues persist

## Updating Your Deployment

### Automatic Updates

With `autoDeploy: true` in render.yaml, any push to your main branch triggers automatic deployment.

### Manual Updates

1. Go to your service in Render dashboard
2. Click **"Manual Deploy"** → **"Deploy latest commit"**
3. Or select a specific commit/branch to deploy

### Update Environment Variables

1. Go to **Environment** tab
2. Edit existing variables or add new ones
3. Click **"Save Changes"**
4. Service will automatically restart

## Monitoring and Logs

### View Logs

Real-time logs available in Render dashboard:

1. Go to **Logs** tab
2. Filter by log level (Info, Warn, Error)
3. Search for specific messages

### Health Monitoring

Render automatically monitors the `/healthz` endpoint:

- **Interval**: Every 30 seconds
- **Timeout**: 10 seconds
- **Action**: Auto-restart on failure

### Set Up Alerts

Configure email alerts for:

1. Service down/unhealthy
2. Deploy success/failure
3. High resource usage

Go to **Settings → Notifications** to configure.

## Backup and Recovery

### Database Backups

Render automatically backs up your PostgreSQL database:

- **Frequency**: Daily
- **Retention**: 30 days (Starter plan) / 90 days (Standard+ plans)
- **Location**: Settings → Backups

### Manual Backup

Export your data:

1. Use n8n's export feature for workflows
2. Use pg_dump for database backup
3. Download via Render shell or external connection

### Restore from Backup

1. Go to **Backups** tab
2. Select a backup
3. Click **"Restore"**

## Security Best Practices

1. **Use Strong Credentials**: Generate secure passwords for all services
2. **Rotate Keys Regularly**: Update API keys and passwords every 90 days
3. **Enable 2FA**: On both Render and GitHub accounts
4. **Restrict Access**: Use IP allowlists if available
5. **Monitor Logs**: Regularly check for suspicious activity
6. **Keep Updated**: Enable auto-deploy to get security updates

## Getting Help

- **Render Documentation**: https://render.com/docs
- **Render Community**: https://community.render.com
- **GitHub Issues**: https://github.com/zeitlospaco/jarvis-core-blueprint/issues
- **n8n Community**: https://community.n8n.io

## Next Steps

After successful deployment:

1. Create your first workflow in n8n
2. Set up Supabase integration
3. Configure AI integrations (OpenAI, Anthropic)
4. Set up email notifications
5. Create backups of your workflows

---

**Need help?** Open an issue on GitHub or consult the [main README](README.md) for detailed integration guides.
