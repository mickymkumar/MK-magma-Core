# ============================
# Stage 1: Builder
# ============================
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV BAZEL_VERSION=5.2.0

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
    autoconf \
    automake \
    libtool \
    pkg-config \
    libglog-dev \
    asn1c \
    bison \
    flex \
 && rm -rf /var/lib/apt/lists/*

# Install Bazel
RUN mkdir -p /usr/local/lib/bazel/bin && \
    curl -fLO https://releases.bazel.build/${BAZEL_VERSION}/release/bazel-${BAZEL_VERSION}-linux-x86_64 && \
    chmod +x bazel-${BAZEL_VERSION}-linux-x86_64 && \
    mv bazel-${BAZEL_VERSION}-linux-x86_64 /usr/local/lib/bazel/bin/bazel && \
    ln -sf /usr/local/lib/bazel/bin/bazel /usr/local/bin/bazel

# Set working directory
WORKDIR /magma

# Copy Magma source code
COPY . /magma

# Make run script executable
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh

# Build AGW binaries
WORKDIR /magma/lte/gateway
RUN bazel build //lte/gateway/c/...

# ============================
# Stage 2: Runtime
# ============================
FROM ubuntu:22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# Set working directory
WORKDIR /magma/lte/gateway

# Copy AGW binaries from builder
COPY --from=builder /magma/lte/gateway/bazel-bin/c /magma/lte/gateway/build/c

# Copy run script
COPY --from=builder /magma/lte/gateway/docker/run_agw_services.sh /magma/lte/gateway/docker/run_agw_services.sh
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh

# Set entrypoint
ENTRYPOINT ["/magma/lte/gateway/docker/run_agw_services.sh"]
