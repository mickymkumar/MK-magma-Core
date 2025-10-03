# ============================
# Builder Stage
# ============================
FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV MAGMA_ROOT=/magma

# ----------------------------
# Install build tools and dependencies
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
    socat

# ----------------------------
# Install Python 3.11 via deadsnakes
# ----------------------------
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Make python3 point to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Ensure pip is available and upgraded safely
RUN python3 -m ensurepip --upgrade
RUN python3 -m pip install --upgrade --break-system-packages pip setuptools wheel

# ----------------------------
# Install Bazel
# ----------------------------
ARG BAZEL_VERSION=5.2.0
RUN wget https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-x86_64 \
    -O /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel && \
    bazel version

# ----------------------------
# Copy Magma source and build
# ----------------------------
WORKDIR ${MAGMA_ROOT}
COPY . ${MAGMA_ROOT}
RUN bazel build //lte/gateway/c/...

# ============================
# Runtime Stage
# ============================
FROM ubuntu:24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV MAGMA_ROOT=/magma

# ----------------------------
# Install runtime dependencies and Python 3.11
# ----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    lsb-release \
    gnupg \
    wget \
    curl \
    sudo \
    bash \
    procps \
    iproute2 \
    iputils-ping \
    net-tools \
    ca-certificates \
    openvswitch-switch \
    socat && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Make python3 point to python3.11
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Ensure pip is available and upgraded safely
RUN python3 -m ensurepip --upgrade
RUN python3 -m pip install --upgrade --break-system-packages pip setuptools wheel

# ----------------------------
# Copy Magma build artifacts from builder
# ----------------------------
COPY --from=builder /magma /magma

WORKDIR ${MAGMA_ROOT}
CMD ["/bin/bash"]
