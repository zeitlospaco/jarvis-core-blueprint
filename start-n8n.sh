#!/usr/bin/env sh
set -e

printf "DEBUG_STARTUP: DB_POSTGRESDB_CONNECTION_STRING='%s'\n" "$DB_POSTGRESDB_CONNECTION_STRING"
printf "DEBUG_STARTUP: SUPABASE_DB_URL='%s'\n" "$SUPABASE_DB_URL"
printf "DEBUG_STARTUP: DATABASE_URL='%s'\n" "$DATABASE_URL"
printf "DEBUG_STARTUP: PORT='%s'\n" "$PORT"

# KRITISCHER FIX: N8N braucht DATABASE_URL!
# Map SUPABASE_DB_URL zu allen erforderlichen Variablen
if [ -n "$SUPABASE_DB_URL" ]; then
  export DATABASE_URL="$SUPABASE_DB_URL"
  export DB_POSTGRESDB_CONNECTION_STRING="$SUPABASE_DB_URL"
  printf "DEBUG_STARTUP: ✅ MAPPED DATABASE_URL from SUPABASE_DB_URL\n"
elif [ -n "$DB_POSTGRESDB_CONNECTION_STRING" ]; then
  export DATABASE_URL="$DB_POSTGRESDB_CONNECTION_STRING"
  export SUPABASE_DB_URL="$DB_POSTGRESDB_CONNECTION_STRING"
  printf "DEBUG_STARTUP: ✅ MAPPED DATABASE_URL from DB_POSTGRESDB_CONNECTION_STRING\n"
elif [ -n "$DATABASE_URL" ]; then
  export DB_POSTGRESDB_CONNECTION_STRING="$DATABASE_URL"
  export SUPABASE_DB_URL="$DATABASE_URL"
  printf "DEBUG_STARTUP: ✅ Using existing DATABASE_URL\n"
else
  printf "DEBUG_STARTUP: ❌ ERROR: No database URL found!\n"
  exit 1
fi

export N8N_PORT=${PORT:-5678}
printf "DEBUG_STARTUP: N8N_PORT=%s\n" "$N8N_PORT"

# Test DB connection
db_host=$(printf "%s" "$DATABASE_URL" | sed -n 's#.*@\([^:/]*\):\([0-9]*\)/.*#\1:\2#p')
if [ -n "$db_host" ]; then
  host=$(echo "$db_host" | cut -d: -f1)
  portnum=$(echo "$db_host" | cut -d: -f2)
  printf "DEBUG_STARTUP: Testing connection to %s:%s\n" "$host" "$portnum"
  if (echo >/dev/tcp/$host/$portnum) >/dev/null 2>&1; then
    printf "DEBUG_STARTUP: ✅ TCP connection OK\n"
  else
    printf "DEBUG_STARTUP: ⚠️  TCP connection FAILED\n"
  fi
fi

printf "DEBUG_STARTUP: Starting n8n...\n"
exec n8n start
