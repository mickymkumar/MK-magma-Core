# ============================
# Magma AGW Dockerfile - Ubuntu 24.04, Python 3.10
# ============================

# ---------------------------
# Builder stage
# ---------------------------
FROM ubuntu:24.04 AS builder

# Set environment
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PATH="/usr/local/bin:$PATH"

# ---------------------------
# Install build dependencies
# ---------------------------
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
    asn1c \
    bison \
    flex \
 && rm -rf /var/lib/apt/lists/*

# ---------------------------
# Build and install Google glog from source
# ---------------------------
RUN git clone https://github.com/google/glog.git /tmp/glog && \
    cd /tmp/glog && \
    mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /tmp/glog

# ---------------------------
# Set working directory
# ---------------------------
WORKDIR /magma

# Copy source code
COPY . /magma

# Make scripts executable
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh

# ---------------------------
# Build AGW binaries using Bazel
# ---------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-11-jdk \
 && rm -rf /var/lib/apt/lists/*

# Install Bazelisk
RUN curl -Lo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64 && \
    chmod +x /usr/local/bin/bazel

WORKDIR /magma/lte/gateway

# Build all C binaries
RUN bazel build //lte/gateway/c/...

# ---------------------------
# Runtime stage
# ---------------------------
FROM ubuntu:24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PATH="/usr/local/bin:$PATH"

# ---------------------------
# Install runtime dependencies
# ---------------------------
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

# Copy AGW binaries from builder
COPY --from=builder /magma/lte/gateway/bazel-bin/c /magma/lte/gateway/build/c

# Copy scripts
COPY --from=builder /magma/lte/gateway/docker/run_agw_services.sh /magma/lte/gateway/docker/run_agw_services.sh
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh

WORKDIR /magma/lte/gateway

# Entry point
CMD ["/magma/lte/gateway/docker/run_agw_services.sh"]
