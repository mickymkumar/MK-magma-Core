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

# Install build tools + Bazel dependencies
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
    openjdk-17-jdk \
    unzip \
 && rm -rf /var/lib/apt/lists/*

# Install Bazelisk (recommended way to manage Bazel versions)
RUN curl -Lo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.15.0/bazelisk-linux-amd64 \
 && chmod +x /usr/local/bin/bazel

WORKDIR /magma

# Copy repo into builder
COPY . /magma

# Install Python dependencies if they exist
RUN if [ -f ./lte/gateway/docker/requirements.txt ]; then \
      pip3 install --no-cache-dir -r ./lte/gateway/docker/requirements.txt || true; \
    fi

# Build all AGW C binaries using Bazel
WORKDIR /magma/lte/gateway
RUN bazel build //lte/gateway/c/... --config=opt

########################
# Runtime stage
########################
FROM ubuntu:24.04 AS runtime

ARG CPU_ARCH
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Runtime deps needed by AGW
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

# Copy the repo and Bazel-built binaries from builder
COPY --from=builder /magma /magma
COPY --from=builder /magma/lte/gateway/bazel-bin/c /magma/lte/gateway/build/c

# Ensure scripts are executable
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh || true

# Default environment
ENV MAGMA_ROOT=/magma

# Entrypoint script from repo
ENTRYPOINT ["/magma/lte/gateway/docker/run_agw_services.sh"]

# Alternative for debugging
# CMD ["/bin/bash"]
