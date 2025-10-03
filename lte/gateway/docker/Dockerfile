# ============================
# Magma AGW Dockerfile - Ubuntu 24.04, Python 3.9
# ============================
FROM ubuntu:24.04 AS builder

# ---------------------------
# Environment variables
# ---------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PATH="/usr/local/bin:$PATH"

# ---------------------------
# Install basic tools and dependencies
# ---------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    curl \
    lsb-release \
    gnupg \
    build-essential \
    git \
    unzip \
    cmake \
    pkg-config \
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
    openjdk-11-jdk \
 && rm -rf /var/lib/apt/lists/*

# ---------------------------
# Install Python 3.9 and pip
# ---------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.9 \
    python3.9-venv \
    python3.9-dev \
    python3-pip \
 && python3.9 -m pip install --upgrade pip \
 && rm -rf /var/lib/apt/lists/*

# ---------------------------
# Build Google glog from source
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
# Install Bazelisk (Bazel version manager)
# ---------------------------
RUN curl -Lo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64 && chmod +x /usr/local/bin/bazel

# ---------------------------
# Copy Magma source
# ---------------------------
WORKDIR /magma
COPY . /magma
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh

# ---------------------------
# Pre-install Python packages for Bazel rules_python
# ---------------------------
RUN python3.9 -m pip install \
    setuptools \
    wheel \
    packaging \
    tomli \
    protobuf \
    pyparsing \
    pyyaml \
    six

# ---------------------------
# Build all C binaries
# ---------------------------
WORKDIR /magma/lte/gateway
RUN bazel build //lte/gateway/c/...

# ============================
# Runtime image
# ============================
FROM ubuntu:24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PATH="/usr/local/bin:$PATH"

# ---------------------------
# Install runtime dependencies
# ---------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.9 \
    python3-pip \
    iproute2 \
    iputils-ping \
    net-tools \
    ca-certificates \
    curl \
    openvswitch-switch \
    socat \
    sudo \
    bash \
    procps \
 && rm -rf /var/lib/apt/lists/*

# ---------------------------
# Copy built binaries and scripts
# ---------------------------
COPY --from=builder /magma/lte/gateway/bazel-bin/c /magma/lte/gateway/build/c
COPY --from=builder /magma/lte/gateway/docker/run_agw_services.sh /magma/lte/gateway/docker/run_agw_services.sh
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh

WORKDIR /magma/lte/gateway

# ---------------------------
# Start AGW services
# ---------------------------
CMD ["/magma/lte/gateway/docker/run_agw_services.sh"]
