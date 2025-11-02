#!/bin/bash
# Database Backup Script
# Backs up PostgreSQL database with compression and optional S3 upload

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/data/backups/postgres}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"
POSTGRES_USER="${POSTGRES_USER:-n8n_user}"
POSTGRES_DB="${POSTGRES_DB:-n8n}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting database backup..."

# Backup database
docker-compose exec -T postgres pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$BACKUP_DIR/backup_$TIMESTAMP.sql.gz"

if [ $? -eq 0 ]; then
    echo "[$(date)] Database backup completed: backup_$TIMESTAMP.sql.gz"
    
    # Calculate file size
    SIZE=$(du -h "$BACKUP_DIR/backup_$TIMESTAMP.sql.gz" | cut -f1)
    echo "[$(date)] Backup size: $SIZE"
else
    echo "[$(date)] ERROR: Database backup failed!"
    exit 1
fi

# Upload to S3 (optional)
if [ -n "$BACKUP_S3_BUCKET" ]; then
    echo "[$(date)] Uploading to S3..."
    aws s3 cp "$BACKUP_DIR/backup_$TIMESTAMP.sql.gz" "s3://$BACKUP_S3_BUCKET/postgres/" --storage-class STANDARD_IA
    
    if [ $? -eq 0 ]; then
        echo "[$(date)] S3 upload completed"
    else
        echo "[$(date)] WARNING: S3 upload failed"
    fi
fi

# Clean old local backups
echo "[$(date)] Cleaning backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete

# Count remaining backups
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/backup_*.sql.gz 2>/dev/null | wc -l)
echo "[$(date)] Total backups: $BACKUP_COUNT"

echo "[$(date)] Backup script completed successfully"
