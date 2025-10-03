# Multi-stage Dockerfile for Magma AGW on Ubuntu 24.04 (Noble)
ARG CPU_ARCH=amd64
ARG DEB_PORT=amd64

########################
# Builder stage
########################
FROM --platform=linux/${CPU_ARCH} ubuntu:24.04 AS builder

ARG CPU_ARCH
ARG DEB_PORT
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install build tools (update if your AGW build requires more)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    cmake \
    pkg-config \
    wget \
    curl \
    ca-certificates \
    python3 \
    python3-pip \
    gnupg \
    libssl-dev \
    libnl-3-dev \
    libnl-genl-3-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /magma

# Copy repo into builder
COPY . /magma

# Example: install Python dependencies if they exist
RUN if [ -f ./lte/gateway/docker/requirements.txt ]; then \
      pip3 install --no-cache-dir -r ./lte/gateway/docker/requirements.txt || true; \
    fi

########################
# Runtime stage
########################
FROM ubuntu:24.04 AS runtime

ARG CPU_ARCH
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Runtime deps needed by AGW (tweak as needed)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    iproute2 \
    iputils-ping \
    net-tools \
    ca-certificates \
    curl \
    openvswitch-switch \
    python3 \
    python3-pip \
    socat \
    sudo \
    bash \
    procps \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /magma

# Copy artifacts from builder
COPY --from=builder /magma /magma

# Ensure scripts are executable
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh || true

# Default env
ENV MAGMA_ROOT=/magma

# Entrypoint script from repo
ENTRYPOINT ["/magma/lte/gateway/docker/run_agw_services.sh"]

# Alternative for debugging:
# CMD ["/bin/bash"]
