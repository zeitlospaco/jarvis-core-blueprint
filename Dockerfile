# Dockerfile for n8n with Python & optional Node.js AI frameworks
FROM n8nio/n8n:latest

LABEL maintainer="jarvis-core-blueprint"
LABEL description="n8n with Python AI dependencies and optional Node packages"
LABEL version="1.1.0"

USER root

# Install system packages (Alpine)
RUN apk update && apk add --no-cache \
    python3 \
    py3-pip \
    jq \
    curl \
    git \
    bash \
    build-base \
    libffi-dev \
    openssl-dev \
    && rm -rf /var/cache/apk/*

# Ensure python/pip commands
RUN ln -sf /usr/bin/python3 /usr/bin/python && ln -sf /usr/bin/pip3 /usr/bin/pip

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install Python packages (CrewAI, LangChain, OpenAI, Supabase python client, Pinecone client)
RUN pip install --no-cache-dir \
    crewai \
    langchain \
    openai \
    supabase \
    python-dotenv \
    pinecone-client \
    chromadb \
    sentence-transformers \
    pandas \
    numpy \
    requests

# Install Node packages globally if n8n JS nodes need them (optional)
# Note: package names may change; keep them minimal to avoid increasing image size excessively.
RUN corepack enable \
 && npm set progress=false \
 && npm set fund=false \
 && npm set audit=false \
 && npm i -g --no-audit --no-fund @supabase/supabase-js openai langchain crewai || true

# Create directories and set ownership
RUN mkdir -p /home/node/.n8n/custom /data/.n8n \
 && chown -R node:node /home/node/.n8n /data

USER node
WORKDIR /home/node

ENV PYTHONPATH=/usr/bin/python3
ENV N8N_USER_FOLDER=/home/node/.n8n
ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom

EXPOSE 5678

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:5678/healthz || exit 1

# Explicit start command
CMD ["n8n", "start"]
