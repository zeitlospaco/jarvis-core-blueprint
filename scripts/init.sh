#!/bin/bash
# init.sh - Erstinitialisierung (Wrapper)
set -euo pipefail

echo "🚀 Jarvis Core: Initialisierung gestartet"

# Beispiel-Aktionen:
# - Prüfe n8n erreichbar
# - Führe healthcheck aus
# - Importiere initiale Workflows falls vorhanden

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1) Healthcheck
if /bin/bash "$SCRIPT_DIR/healthcheck.sh"; then
  echo "✅ Healthcheck erfolgreich"
else
  echo "⚠️ Healthcheck meldet Fehler (siehe Protokolle)"
fi

# 2) Optional: Import initialer Workflows (falls /app/initial-workflows existiert)
if [ -d "/app/initial-workflows" ]; then
  for f in /app/initial-workflows/*.json; do
    echo "Importiere Workflow: $f"
    # Kopiere in Container und importiere (Best-Effort)
    docker cp "$f" jarvis-n8n:/tmp/ || true
    docker-compose exec -T n8n n8n import:workflow --input "/tmp/$(basename "$f")" || true
  done
fi

echo "🏁 Initialisierung beendet"