#!/usr/bin/env sh
set -e

printf "DEBUG_STARTUP: DB_POSTGRESDB_CONNECTION_STRING='%s'\n" "$DB_POSTGRESDB_CONNECTION_STRING"
printf "DEBUG_STARTUP: SUPABASE_DB_URL='%s'\n" "$SUPABASE_DB_URL"
printf "DEBUG_STARTUP: DATABASE_URL='%s'\n" "$DATABASE_URL"
printf "DEBUG_STARTUP: PORT='%s'\n" "$PORT"

if [ -n "$SUPABASE_DB_URL" ] && [ -z "$DB_POSTGRESDB_CONNECTION_STRING" ]; then
  export DB_POSTGRESDB_CONNECTION_STRING="$SUPABASE_DB_URL"
  printf "DEBUG_STARTUP: MAPPED DB_POSTGRESDB_CONNECTION_STRING from SUPABASE_DB_URL\n"
fi

export N8N_PORT=${PORT:-5678}
printf "DEBUG_STARTUP: N8N_PORT=%s\n" "$N8N_PORT"

# extract host:port from connection string and test TCP connectivity
db_host=$(printf "%s" "$DB_POSTGRESDB_CONNECTION_STRING" | sed -n "s#.*@\([^:/]*\):\([0-9]*\)/.*#\1:\2#p")
if [ -n "$db_host" ]; then
  host=$(echo "$db_host" | cut -d: -f1)
  portnum=$(echo "$db_host" | cut -d: -f2)
  (echo >/dev/tcp/$host/$portnum) >/dev/null 2>&1 && printf "DEBUG_STARTUP: TCP OK %s\n" "$db_host" || printf "DEBUG_STARTUP: TCP FAIL %s\n" "$db_host"
fi

exec n8n start
