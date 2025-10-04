# ============================
# Stage 1: Build Magma
# ============================
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV MAGMA_ROOT=/magma

# ----------------------------
# Install system dependencies
# ----------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    unzip \
    curl \
    git \
    python3 \
    python3-pip \
    python3-setuptools \
    build-essential \
    cmake \
    ninja-build \
    openjdk-11-jdk \
    pkg-config \
    libssl-dev \
    asn1c \
    && rm -rf /var/lib/apt/lists/*

# Set Python alternative
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

WORKDIR $MAGMA_ROOT

# ----------------------------
# Copy Magma source code
# ----------------------------
# COPY your local Magma source code here
# COPY . $MAGMA_ROOT

# ----------------------------
# liblfds setup
# ----------------------------
RUN mkdir -p ${MAGMA_ROOT}/third_party/liblfds && \
    wget --no-check-certificate -O ${MAGMA_ROOT}/third_party/liblfds/liblfds-release-7.1.0-source.zip \
    "https://liblfds.org/downloads/liblfds%20release%207.1.0%20source.zip" && \
    unzip -q -o ${MAGMA_ROOT}/third_party/liblfds/liblfds-release-7.1.0-source.zip -d ${MAGMA_ROOT}/third_party/liblfds/

# ----------------------------
# Bazel install
# ----------------------------
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor >bazel-archive-keyring.gpg && \
    mv bazel-archive-keyring.gpg /usr/share/keyrings && \
    apt-get update && \
    apt-get install -y apt-transport-https gnupg && \
    echo "deb [signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://bazel.build/apt stable jdk1.11" \
    | tee /etc/apt/sources.list.d/bazel.list && \
    apt-get update && apt-get install -y bazel && \
    apt-get clean

# ----------------------------
# Local system_libraries for Bazel
# ----------------------------
RUN mkdir -p ${MAGMA_ROOT}/bazel/external/system_libraries && \
    echo "" > ${MAGMA_ROOT}/bazel/external/system_libraries/WORKSPACE && \
    echo 'filegroup(name = "asn1c", srcs = [])' > ${MAGMA_ROOT}/bazel/external/system_libraries/BUILD.bazel

# ----------------------------
# Build Magma
# ----------------------------
RUN bazel clean --expunge && \
    bazel build //lte/gateway/c/...

# ============================
# Stage 2: Runtime Image
# ============================
FROM ubuntu:22.04

ENV MAGMA_ROOT=/magma

# ----------------------------
# Install runtime dependencies
# ----------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libssl-dev \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR $MAGMA_ROOT

# Copy Magma binaries from builder
COPY --from=builder /magma/bazel-bin/lte/gateway/c /magma/binaries

# Set PATH to include Magma binaries
ENV PATH="$MAGMA_ROOT/binaries:$PATH"

# Default command (optional)
CMD ["/bin/bash"]
