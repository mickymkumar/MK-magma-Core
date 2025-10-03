# Multi-stage Dockerfile for Magma AGW with Python 3.10

########################
# Builder stage
########################
FROM ubuntu:24.04 AS builder

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
    python3.10 \
    python3.10-venv \
    python3.10-dev \
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

WORKDIR /magma

# Copy full Magma repo into builder
COPY . /magma

# Install Python dependencies if requirements exist
RUN if [ -f ./lte/gateway/docker/requirements.txt ]; then \
      python3.10 -m pip install --no-cache-dir -r ./lte/gateway/docker/requirements.txt || true; \
    fi

# Install Bazel 5.2.0
RUN mkdir -p /usr/local/lib/bazel/bin \
 && curl -fLo /usr/local/lib/bazel/bin/bazel-5.2.0-linux-x86_64 https://releases.bazel.build/5.2.0/release/bazel-5.2.0-linux-x86_64 \
 && chmod +x /usr/local/lib/bazel/bin/bazel-5.2.0-linux-x86_64 \
 && ln -sf /usr/local/lib/bazel/bin/bazel-5.2.0-linux-x86_64 /usr/local/bin/bazel

# Build AGW C binaries
WORKDIR /magma/lte/gateway
RUN bazel build //lte/gateway/c/...

########################
# Runtime stage
########################
FROM ubuntu:24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    MAGMA_ROOT=/magma

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    iproute2 \
    iputils-ping \
    net-tools \
    ca-certificates \
    curl \
    openvswitch-switch \
    python3.10 \
    python3-pip \
    socat \
    sudo \
    bash \
    procps \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /magma

# Copy full Magma repo and C binaries from builder
COPY --from=builder /magma /magma
COPY --from=builder /magma/bazel-bin/c /magma/lte/gateway/build/c

# Ensure the run script is executable
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh

# Entrypoint to start AGW services
ENTRYPOINT ["/magma/lte/gateway/docker/run_agw_services.sh"]

# Optional CMD for debugging
# CMD ["/bin/bash"]
