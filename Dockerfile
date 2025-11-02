# Dockerfile for n8n with Python AI Frameworks
# Base: n8n latest official image
# Extensions: Python 3.11, CrewAI, LangChain, and dependencies

FROM n8nio/n8n:latest

# Metadata
LABEL maintainer="jarvis-core-blueprint"
LABEL description="n8n workflow automation with Python AI frameworks (CrewAI, LangChain)"
LABEL version="1.0.0"

# Switch to root user for installing system packages
USER root

# Update package lists and install system dependencies
# Required for Python, pip, and compilation of Python packages
RUN apk update && apk add --no-cache \
    # Python 3.11 and pip
    python3 \
    py3-pip \
    python3-dev \
    # Build tools for Python packages
    gcc \
    g++ \
    make \
    musl-dev \
    libffi-dev \
    openssl-dev \
    # Additional utilities
    curl \
    git \
    bash \
    # Cleanup
    && rm -rf /var/cache/apk/*

# Create symlinks for python and pip commands
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# Upgrade pip, setuptools, and wheel
RUN pip install --no-cache-dir --upgrade \
    pip \
    setuptools \
    wheel

# Install Python AI Frameworks and Dependencies
# LangChain: Framework for LLM applications (using stable versions)
RUN pip install --no-cache-dir \
    langchain==0.1.20 \
    langchain-community==0.0.38 \
    langchain-core==0.1.52 \
    langchain-openai==0.1.7 \
    langchain-anthropic==0.1.11

# CrewAI: Multi-agent AI framework
RUN pip install --no-cache-dir \
    crewai==0.11.0 \
    crewai-tools==0.2.6

# Additional AI and ML libraries
RUN pip install --no-cache-dir \
    # OpenAI client
    openai==1.6.1 \
    # Anthropic Claude client
    anthropic==0.8.0 \
    # Vector databases and embeddings
    chromadb==0.4.22 \
    sentence-transformers==2.2.2 \
    # Data processing
    pandas==2.1.4 \
    numpy==1.26.2 \
    # HTTP clients
    httpx==0.26.0 \
    requests==2.31.0 \
    # Environment management
    python-dotenv==1.0.0 \
    # Supabase client for database integration
    supabase==2.3.0 \
    # JSON and YAML parsing
    pyyaml==6.0.1 \
    # Additional utilities
    beautifulsoup4==4.12.2 \
    lxml==5.0.0

# Install additional n8n community nodes (optional)
# These can be installed via n8n UI as well
# RUN cd /usr/local/lib/node_modules/n8n && \
#     npm install n8n-nodes-supabase

# Create directories for custom Python scripts
RUN mkdir -p /home/node/.n8n/custom \
    && mkdir -p /home/node/.n8n/nodes \
    && mkdir -p /data/.n8n

# Set permissions for n8n user
RUN chown -R node:node /home/node/.n8n /data

# Switch back to node user (n8n default user)
USER node

# Set working directory
WORKDIR /home/node

# Environment variables (can be overridden at runtime)
ENV PYTHON_PATH=/usr/bin/python3
ENV N8N_USER_FOLDER=/home/node/.n8n
ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom

# Expose n8n default port
EXPOSE 5678

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:5678/healthz || exit 1

# Start n8n
CMD ["n8n"]
