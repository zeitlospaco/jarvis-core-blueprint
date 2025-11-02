#!/bin/bash
# healthcheck.sh - prüft n8n, Postgres und notwendige API-Keys
set -euo pipefail

TIMESTAMP="$(date --iso-8601=seconds || date +%Y-%m-%dT%H:%M:%S)"

log() { echo "[$TIMESTAMP] $*"; }

STATUS_OK=true
ERRORS=()

# 1) n8n health endpoint (lokal)
if curl -fsS http://localhost:5678/healthz >/dev/null 2>&1; then
  log "n8n: OK"
else
  log "n8n: NOK"
  STATUS_OK=false
  ERRORS+=("n8n not reachable")
fi

# 2) Postgres (lokal/container)
if command -v pg_isready >/dev/null 2>&1 && pg_isready -h "${POSTGRES_HOST:-postgres}" -p "${POSTGRES_PORT:-5432}" -U "${POSTGRES_USER:-n8n_user}" >/dev/null 2>&1; then
  log "Postgres: OK"
else
  log "Postgres: NOK"
  STATUS_OK=false
  ERRORS+=("Postgres not reachable or pg_isready missing")
fi

# 3) Supabase / API keys presence
if [ -z "${SUPABASE_SERVICE_ROLE:-}" ]; then
  log "SUPABASE_SERVICE_ROLE: MISSING"
  ERRORS+=("SUPABASE_SERVICE_ROLE missing")
fi
if [ -z "${OPENAI_API_KEY:-}" ]; then
  log "OPENAI_API_KEY: MISSING"
  ERRORS+=("OPENAI_API_KEY missing")
fi

# Result
if [ "$STATUS_OK" = true ] && [ ${#ERRORS[@]} -eq 0 ]; then
  log "SYSTEM OK"
  exit 0
else
  log "SYSTEM DEGRADED: ${ERRORS[*]}"
  # Optional: send email via SMTP (if configured)
  if [ -n "${SMTP_HOST:-}" ] && [ -n "${SMTP_USER:-}" ] && [ -n "${SMTP_PASSWORD:-}" ]; then
    SUBJECT="[Jarvis] Healthcheck failed"
    BODY="Healthcheck errors:\n\n${ERRORS[*]}"
    printf "%b" "$BODY" | mail -s "$SUBJECT" -r "${SMTP_FROM_EMAIL:-noreply@localhost}" "${ADMIN_EMAIL:-admin@localhost}" 2>/dev/null || true
  fi
  exit 2
fi
