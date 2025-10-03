# ============================
# Stage 1: Builder
# ============================
FROM ubuntu:24.04 AS builder

# Set noninteractive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    wget \
    curl \
    unzip \
    software-properties-common \
    python3 \
    python3-venv \
    python3-dev \
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
RUN mkdir -p /usr/local/lib/bazel/bin && \
    cd /usr/local/lib/bazel/bin && \
    curl -fLO https://releases.bazel.build/5.2.0/release/bazel-5.2.0-linux-x86_64 && \
    chmod +x bazel-5.2.0-linux-x86_64 && \
    ln -sf /usr/local/lib/bazel/bin/bazel-5.2.0-linux-x86_64 /usr/local/bin/bazel

# Set workdir
WORKDIR /magma

# Copy source code
COPY . /magma

# Give execute permissions to AGW scripts
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh

# Build AGW binaries
WORKDIR /magma/lte/gateway
RUN bazel build //lte/gateway/c/... --config=opt

# ============================
# Stage 2: Runtime
# ============================
FROM ubuntu:24.04 AS runtime

# Set noninteractive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    iproute2 \
    iputils-ping \
    net-tools \
    ca-certificates \
    curl \
    openvswitch-switch \
    python3 \
    python3-venv \
    python3-dev \
    python3-pip \
    socat \
    sudo \
    bash \
    procps \
 && rm -rf /var/lib/apt/lists/*

# Create magma runtime directories
RUN mkdir -p /magma/lte/gateway/build/c \
             /var/opt/magma

# Copy built AGW binaries from builder
COPY --from=builder /magma/lte/gateway/bazel-bin/c /magma/lte/gateway/build/c

# Copy run script
COPY --from=builder /magma/lte/gateway/docker/run_agw_services.sh /magma/lte/gateway/docker/run_agw_services.sh
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh

# Set workdir
WORKDIR /magma/lte/gateway

# Entry point
CMD ["/magma/lte/gateway/docker/run_agw_services.sh"]
