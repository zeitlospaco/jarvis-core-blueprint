# Dockerfile for n8n with Python & optional Node.js AI frameworks
FROM n8nio/n8n:latest

LABEL maintainer="jarvis-core-blueprint"
LABEL description="n8n with Python AI dependencies and optional Node packages"
LABEL version="1.2.2"

USER root

# Install system packages (Alpine) + CA certs
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    ca-certificates \
    jq \
    curl \
    git \
    bash \
    build-base \
    libffi-dev \
    openssl-dev \
  && update-ca-certificates \
  && rm -rf /var/cache/apk/*

# Create and use a virtual environment to avoid PEP 668 (externally-managed)
RUN python3 -m venv /opt/venv
ENV VIRTUAL_ENV=/opt/venv
# Ensure n8n in /usr/local/bin remains discoverable
ENV PATH="/opt/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Upgrade pip tooling inside the venv
RUN python -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Install a minimal, build-friendly Python dependency set
RUN python -m pip install --no-cache-dir \
    langchain \
    openai \
    supabase \
    python-dotenv \
    pinecone-client \
    requests

# Optional: Install Node packages globally if n8n JS nodes need them
RUN corepack enable \
 && npm set progress=false \
 && npm set fund=false \
 && npm set audit=false \
 && npm i -g --no-audit --no-fund @supabase/supabase-js openai langchain || true

# Create directories and set ownership
RUN mkdir -p /home/node/.n8n/custom /data/.n8n \
 && chown -R node:node /home/node/.n8n /data

# Add a startup wrapper script that maps SUPABASE_DB_URL -> DB_POSTGRESDB_CONNECTION_STRING if needed
# and prints debug info about the DB env vars so we can see them in Render logs.
RUN cat > /usr/local/bin/start-n8n.sh <<'EOF'\n#!/usr/bin/env sh\nset -e\n\n# Print debug info to logs to verify which DB env vars are available at container start\nprintf "DEBUG_STARTUP: DB_POSTGRESDB_CONNECTION_STRING='%s'\n" "$DB_POSTGRESDB_CONNECTION_STRING"\nprintf "DEBUG_STARTUP: SUPABASE_DB_URL='%s'\n" "$SUPABASE_DB_URL"\nprintf "DEBUG_STARTUP: DATABASE_URL='%s'\n" "$DATABASE_URL"\n\n# If SUPABASE_DB_URL is set but DB_POSTGRESDB_CONNECTION_STRING is not, map it\nif [ -n "$SUPABASE_DB_URL" ] && [ -z "$DB_POSTGRESDB_CONNECTION_STRING" ]; then\n  export DB_POSTGRESDB_CONNECTION_STRING="$SUPABASE_DB_URL"\n  printf "DEBUG_STARTUP: MAPPED DB_POSTGRESDB_CONNECTION_STRING from SUPABASE_DB_URL\n"\nfi\n\nexec n8n start\nEOF\n\n&& chmod +x /usr/local/bin/start-n8n.sh

# Optional: Fix n8n config settings permissions warnings
RUN chmod 600 /home/node/.n8n/config || true
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

USER node
WORKDIR /home/node

# Keep custom extensions path if needed
ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom

EXPOSE 5678

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl --fail --silent http://localhost:5678/healthz || exit 1

# Use wrapper as ENTRYPOINT to ensure DB connection string is set from Supabase variable
ENTRYPOINT ["/usr/local/bin/start-n8n.sh"]
