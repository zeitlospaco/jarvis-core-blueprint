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

# Add a lightweight startup wrapper to handle environment variables and connection strings
RUN printf '#!/usr/bin/env sh\nset -e\n\n# Map SUPABASE_DB_URL to DB_POSTGRESDB_CONNECTION_STRING if SUPABASE_DB_URL is set\n# and DB_POSTGRESDB_CONNECTION_STRING is not already set\nif [ -n "$SUPABASE_DB_URL" ]; then\n  if [ -z "$DB_POSTGRESDB_CONNECTION_STRING" ]; then\n    export DB_POSTGRESDB_CONNECTION_STRING="$SUPABASE_DB_URL"\n  fi\nfi\n\n# Normalize postgres:// to postgresql:// for n8n compatibility\nif [ -n "$DB_POSTGRESDB_CONNECTION_STRING" ]; then\n  # Replace postgres:// with postgresql:// if needed\n  DB_POSTGRESDB_CONNECTION_STRING=$(echo "$DB_POSTGRESDB_CONNECTION_STRING" | sed "s|^postgres://|postgresql://|")\n  export DB_POSTGRESDB_CONNECTION_STRING\n  echo "Database connection configured"\nelse\n  echo "WARNING: No database connection string found!"\n  echo "Please set SUPABASE_DB_URL or DB_POSTGRESDB_CONNECTION_STRING"\nfi\n\n# Use PORT from Render if set, otherwise default to N8N_PORT or 5678\nif [ -n "$PORT" ]; then\n  export N8N_PORT="$PORT"\nelif [ -z "$N8N_PORT" ]; then\n  export N8N_PORT="5678"\nfi\n\necho "Starting n8n on port $N8N_PORT"\necho "DB Connection String: ${DB_POSTGRESDB_CONNECTION_STRING:0:30}..." \n\nexec n8n start\n' > /usr/local/bin/start-n8n.sh \
 && chmod +x /usr/local/bin/start-n8n.sh

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
