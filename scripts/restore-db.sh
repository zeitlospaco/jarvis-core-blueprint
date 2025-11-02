#!/bin/bash
# Database Restore Script
# Restores PostgreSQL database from a backup file

set -e

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Configuration
POSTGRES_USER="${POSTGRES_USER:-n8n_user}"
POSTGRES_DB="${POSTGRES_DB:-n8n}"

# Check arguments
if [ $# -eq 0 ]; then
    echo "Usage: $0 <backup-file.sql.gz>"
    echo ""
    echo "Available backups:"
    ls -lh /data/backups/postgres/backup_*.sql.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE="$1"

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "WARNING: This will REPLACE the current database with the backup!"
echo "Database: $POSTGRES_DB"
echo "Backup file: $BACKUP_FILE"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Restore cancelled"
    exit 0
fi

echo "[$(date)] Starting database restore..."

# Stop n8n to prevent conflicts
echo "[$(date)] Stopping n8n service..."
docker-compose stop n8n

# Drop and recreate database
echo "[$(date)] Recreating database..."
docker-compose exec -T postgres psql -U "$POSTGRES_USER" -d postgres -c "DROP DATABASE IF EXISTS $POSTGRES_DB;"
docker-compose exec -T postgres psql -U "$POSTGRES_USER" -d postgres -c "CREATE DATABASE $POSTGRES_DB;"

# Restore database
echo "[$(date)] Restoring from backup..."
gunzip -c "$BACKUP_FILE" | docker-compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"

if [ $? -eq 0 ]; then
    echo "[$(date)] Database restored successfully"
else
    echo "[$(date)] ERROR: Database restore failed!"
    exit 1
fi

# Restart services
echo "[$(date)] Restarting services..."
docker-compose up -d

echo "[$(date)] Restore completed successfully"
echo "Check logs: docker-compose logs -f n8n"
