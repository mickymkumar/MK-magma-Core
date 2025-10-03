# ==============================
# Magma AGW Dockerfile for 5G
# ==============================

# Arguments for architecture
ARG CPU_ARCH=amd64
ARG DEB_PORT=amd64

########################
# Builder Stage
########################
FROM --platform=linux/${CPU_ARCH} ubuntu:24.04 AS builder

ARG CPU_ARCH
ARG DEB_PORT
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    MAGMA_ROOT=/magma

WORKDIR /magma

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    curl \
    unzip \
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

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2 \
 && update-alternatives --config python3 || true

# Install Bazel 5.2.0
RUN mkdir -p /usr/local/lib/bazel/bin \
 && curl -fLO https://releases.bazel.build/5.2.0/release/bazel-5.2.0-linux-x86_64 \
 && chmod +x bazel-5.2.0-linux-x86_64 \
 && mv bazel-5.2.0-linux-x86_64 /usr/local/lib/bazel/bin/ \
 && ln -sf /usr/local/lib/bazel/bin/bazel-5.2.0-linux-x86_64 /usr/local/bin/bazel

# Copy source code into builder
COPY . /magma

# Upgrade pip and install Python dependencies if requirements.txt exists
RUN python3 -m pip install --upgrade pip \
 && if [ -f ./lte/gateway/docker/requirements.txt ]; then \
      pip3 install --no-cache-dir -r ./lte/gateway/docker/requirements.txt || true; \
    fi

# Build all AGW C binaries using Bazel
WORKDIR /magma/lte/gateway
RUN bazel clean --expunge \
 && export PYTHON_BIN_PATH=/usr/bin/python3 \
 && bazel build //lte/gateway/c/...

########################
# Runtime Stage
########################
FROM ubuntu:24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    MAGMA_ROOT=/magma

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# Copy Docker scripts
COPY lte/gateway/docker /magma/lte/gateway/docker

# Copy AGW binaries from builder
COPY --from=builder /magma/lte/gateway/bazel-bin/c /magma/lte/gateway/build/c

# Ensure the run script is executable
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh || true

# Entrypoint
ENTRYPOINT ["/magma/lte/gateway/docker/run_agw_services.sh"]

# Optional: CMD for debugging
# CMD ["/bin/bash"]
