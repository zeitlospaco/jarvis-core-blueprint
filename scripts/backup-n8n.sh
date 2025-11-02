#!/bin/bash
# n8n Workflows Backup Script
# Exports all n8n workflows to JSON

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/data/backups/n8n}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting n8n workflows backup..."

# Export workflows
docker-compose exec -T n8n n8n export:workflow --all --output=/tmp/workflows_$TIMESTAMP.json

if [ $? -eq 0 ]; then
    # Copy from container to host
    docker cp jarvis-n8n:/tmp/workflows_$TIMESTAMP.json "$BACKUP_DIR/"
    
    # Compress
    gzip "$BACKUP_DIR/workflows_$TIMESTAMP.json"
    
    echo "[$(date)] Workflows backup completed: workflows_$TIMESTAMP.json.gz"
else
    echo "[$(date)] ERROR: Workflows backup failed!"
    exit 1
fi

# Backup n8n data directory (optional - contains encrypted credentials)
echo "[$(date)] Backing up n8n data directory..."
docker cp jarvis-n8n:/home/node/.n8n "$BACKUP_DIR/n8n_data_$TIMESTAMP"
tar -czf "$BACKUP_DIR/n8n_data_$TIMESTAMP.tar.gz" -C "$BACKUP_DIR" "n8n_data_$TIMESTAMP"
rm -rf "$BACKUP_DIR/n8n_data_$TIMESTAMP"

echo "[$(date)] n8n data backup completed: n8n_data_$TIMESTAMP.tar.gz"

# Upload to S3 (optional)
if [ -n "$BACKUP_S3_BUCKET" ]; then
    echo "[$(date)] Uploading to S3..."
    aws s3 cp "$BACKUP_DIR/workflows_$TIMESTAMP.json.gz" "s3://$BACKUP_S3_BUCKET/n8n/"
    aws s3 cp "$BACKUP_DIR/n8n_data_$TIMESTAMP.tar.gz" "s3://$BACKUP_S3_BUCKET/n8n/"
fi

# Clean old backups
echo "[$(date)] Cleaning backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "workflows_*.json.gz" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "n8n_data_*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "[$(date)] n8n backup completed successfully"
