# Multi-stage Dockerfile for Magma AGW with 5G support on Ubuntu 24.04
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

# Install build tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    curl \
    unzip \
    software-properties-common \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    cmake \
    pkg-config \
    gnupg \
    libssl-dev \
    libnl-3-dev \
    libnl-genl-3-dev \
    sudo \
    bash \
    procps \
 && rm -rf /var/lib/apt/lists/*

# Install Bazel 5.2.0
RUN mkdir -p /usr/local/lib/bazel/bin \
 && curl -L -o /usr/local/lib/bazel/bin/bazel-5.2.0-linux-x86_64 https://releases.bazel.build/5.2.0/release/bazel-5.2.0-linux-x86_64 \
 && chmod +x /usr/local/lib/bazel/bin/bazel-5.2.0-linux-x86_64 \
 && ln -sf /usr/local/lib/bazel/bin/bazel-5.2.0-linux-x86_64 /usr/local/bin/bazel

WORKDIR /magma

# Copy source code into builder
COPY . /magma

# Install Python dependencies if present
RUN if [ -f ./lte/gateway/docker/requirements.txt ]; then \
      python3.11 -m pip install --no-cache-dir -r ./lte/gateway/docker/requirements.txt; \
    fi

# Build AGW C binaries using Bazel
RUN bazel build //lte/gateway/c/... || true

########################
# Runtime stage
########################
FROM ubuntu:24.04 AS runtime

ARG CPU_ARCH
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    iproute2 \
    iputils-ping \
    net-tools \
    ca-certificates \
    curl \
    openvswitch-switch \
    python3.11 \
    python3-pip \
    socat \
    sudo \
    bash \
    procps \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /magma

# Copy AGW binaries and scripts from builder
COPY --from=builder /magma/lte/gateway/bazel-bin/c /magma/lte/gateway/build/c
COPY --from=builder /magma/lte/gateway/docker/run_agw_services.sh /magma/lte/gateway/docker/run_agw_services.sh
COPY --from=builder /magma/lte/gateway/docker/requirements.txt /magma/lte/gateway/docker/requirements.txt

# Ensure run script is executable
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh

# Environment variable
ENV MAGMA_ROOT=/magma

# Entry point
ENTRYPOINT ["/magma/lte/gateway/docker/run_agw_services.sh"]

# Optional for debugging
# CMD ["/bin/bash"]
