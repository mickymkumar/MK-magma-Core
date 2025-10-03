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
    socat \
    libgoogle-glog-dev \
    openjdk-11-jdk \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# ----------------------------
# Install Python 3.11 via deadsnakes
# ----------------------------
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
 && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

RUN python3 -m ensurepip --upgrade && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3 && \
    python3 -m pip install --upgrade --break-system-packages setuptools wheel

# Fix glog symlink for Bazel
RUN ln -sf /usr/lib/x86_64-linux-gnu/libglog.so.0.6.0 /usr/lib/x86_64-linux-gnu/libglog.so.0

# ----------------------------
# Install Bazel
# ----------------------------
ARG BAZEL_VERSION=5.2.0
RUN wget https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-x86_64 \
    -O /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel && \
    bazel version

# ----------------------------
# Copy Magma source
# ----------------------------
WORKDIR ${MAGMA_ROOT}
COPY . ${MAGMA_ROOT}

# ----------------------------
# Pre-download and extract liblfds locally
# ----------------------------
RUN mkdir -p ${MAGMA_ROOT}/third_party/liblfds && \
    wget --no-check-certificate -O ${MAGMA_ROOT}/third_party/liblfds/liblfds-release-7.1.0-source.zip \
    "https://liblfds.org/downloads/liblfds%20release%207.1.0%20source.zip" && \
    unzip ${MAGMA_ROOT}/third_party/liblfds/liblfds-release-7.1.0-source.zip -d ${MAGMA_ROOT}/third_party/liblfds/

# ----------------------------
# Avoid Bazel SSL errors for Java
# ----------------------------
ENV JAVA_TOOL_OPTIONS="-Djavax.net.ssl.trustStore=/etc/ssl/certs/java/cacerts"

# ----------------------------
# Build Magma using local liblfds
# ----------------------------
RUN bazel build //lte/gateway/c/...

# ============================
# Runtime Stage
# ============================
FROM ubuntu:24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV MAGMA_ROOT=/magma

# ----------------------------
# Runtime dependencies
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
    socat \
    openjdk-11-jre \
 && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
 && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

RUN python3 -m ensurepip --upgrade && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3 && \
    python3 -m pip install --upgrade --break-system-packages setuptools wheel

# ----------------------------
# Copy Magma build artifacts from builder
# ----------------------------
COPY --from=builder /magma /magma

WORKDIR ${MAGMA_ROOT}
CMD ["/bin/bash"]
