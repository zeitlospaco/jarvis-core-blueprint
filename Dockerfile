# Dockerfile for n8n with Python & optional Node.js AI frameworks
FROM n8nio/n8n:latest

LABEL maintainer="jarvis-core-blueprint"
LABEL description="n8n with Python AI dependencies and optional Node packages"
LABEL version="1.2.1"

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

USER node
WORKDIR /home/node

# Do NOT override N8N_USER_FOLDER; base image handles it to avoid /.n8n/.n8n
# Optionally keep custom extensions path if needed:
ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom

EXPOSE 5678

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl --fail --silent http://localhost:5678/healthz || exit 1

# Do NOT override CMD; use base image's startup to ensure n8n is found
