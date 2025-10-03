# ============================
# Ubuntu 24.04 Base Image
# ============================
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV MAGMA_ROOT=/magma

# ----------------------------
# Install system dependencies
# ----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    curl \
    lsb-release \
    gnupg \
    sudo \
    bash \
    procps \
    build-essential \
    cmake \
    pkg-config \
    git \
    unzip \
    autoconf \
    automake \
    libtool \
    libssl-dev \
    libffi-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libgdbm-dev \
    libnss3-dev \
    liblzma-dev \
    bison \
    flex \
    asn1c \
    iproute2 \
    iputils-ping \
    net-tools \
    openvswitch-switch \
    socat \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# Install Python 3.9 from deadsnakes
# ----------------------------
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && apt-get install -y --no-install-recommends \
    python3.9 \
    python3.9-venv \
    python3.9-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 points to python3.9
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
RUN python3 -m ensurepip --upgrade
RUN python3 -m pip install --upgrade pip setuptools wheel

# ----------------------------
# Install Bazel
# ----------------------------
ARG BAZEL_VERSION=5.2.0
RUN wget https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-x86_64 \
    -O /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel && \
    bazel version

# ----------------------------
# Set working directory
# ----------------------------
WORKDIR ${MAGMA_ROOT}

# ----------------------------
# Copy Magma source code
# ----------------------------
# Assumes you have cloned the magma repo locally
COPY . ${MAGMA_ROOT}

# ----------------------------
# Build AGW C binaries
# ----------------------------
RUN bazel build //lte/gateway/c/...

# ----------------------------
# Optional: verify python deps
# ----------------------------
RUN python3 --version && pip3 --version

# ----------------------------
# Runtime stage (slim)
# ----------------------------
FROM ubuntu:24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV MAGMA_ROOT=/magma

# ----------------------------
# Install runtime dependencies
# ----------------------------
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

# Ensure python3 points to python3.9
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
RUN python3 -m ensurepip --upgrade
RUN python3 -m pip install --upgrade pip setuptools wheel

# ----------------------------
# Copy AGW build artifacts from builder
# ----------------------------
COPY --from=builder /magma /magma

WORKDIR ${MAGMA_ROOT}
CMD ["/bin/bash"]
