#!/usr/bin/env sh
set -e

# N8N wird mit SQLite starten und den persistent Disk nutzen
# Das ist viel zuverlässiger als PostgreSQL auf Render

printf "DEBUG_STARTUP: Configuring N8N with SQLite backend\\n"
printf "DEBUG_STARTUP: Using persistent storage at /data/.n8n\\n"

# Konfiguriere N8N für SQLite
export DB_TYPE=sqlite
export DB_SQLITE_PATH=/data/.n8n/database.sqlite
export N8N_PORT=${PORT:-5678}
export N8N_HOST=0.0.0.0

printf "DEBUG_STARTUP: DB_TYPE=%s\\n" "$DB_TYPE"
printf "DEBUG_STARTUP: DB_SQLITE_PATH=%s\\n" "$DB_SQLITE_PATH"
printf "DEBUG_STARTUP: N8N_PORT=%s\\n" "$N8N_PORT"

# Stelle sicher, dass die Verzeichnisse existieren
mkdir -p /data/.n8n
mkdir -p /home/node/.n8n

printf "DEBUG_STARTUP: Starting n8n with SQLite...\\n"
exec n8n start
