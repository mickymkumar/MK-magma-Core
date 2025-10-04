# ----------------------------
# Stage 0: Base image
# ----------------------------
FROM ubuntu:22.04 AS base  # use Ubuntu 22.04 to get Python 3.10

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    build-essential \
    git \
    python3.10 \
    python3.10-venv \
    python3.10-distutils \
    python3-pip \
    openvswitch-switch \
    iproute2 \
    net-tools \
    iputils-ping \
    sudo \
    software-properties-common \
    pkg-config \
    libssl-dev \
    libffi-dev \
    cmake \
    libtins-dev \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV MAGMA_ROOT=/magma
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR $MAGMA_ROOT

# ----------------------------
# Stage 1: Build C dependencies
# ----------------------------
FROM base AS build-c

# Install Bazel 5.2.0
RUN apt-get update && apt-get install -y curl gnupg apt-transport-https && \
    curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > /usr/share/keyrings/bazel-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" \
        | tee /etc/apt/sources.list.d/bazel.list && \
    apt-get update && apt-get install -y bazel-5.2.0 && \
    ln -s /usr/bin/bazel-5.2.0 /usr/bin/bazel

# Copy Magma source
COPY . $MAGMA_ROOT

# Download and unzip liblfds
RUN mkdir -p $MAGMA_ROOT/third_party/liblfds && \
    wget --no-check-certificate -O $MAGMA_ROOT/third_party/liblfds/liblfds-release-7.1.0-source.zip \
    "https://liblfds.org/downloads/liblfds%20release%207.1.0%20source.zip" && \
    unzip -o -q $MAGMA_ROOT/third_party/liblfds/liblfds-release-7.1.0-source.zip -d $MAGMA_ROOT/third_party/liblfds

# Build all C services with Bazel
RUN bazel build //lte/gateway/c/...

# ----------------------------
# Stage 2: Python build
# ----------------------------
FROM base AS build-python

# Use Python 3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

WORKDIR /magma

# Copy Magma source
COPY . .

# Create virtual environment
RUN python3 -m venv /opt/venv

# Activate venv and install dependencies
RUN /opt/venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/venv/bin/pip install -r lte/gateway/python/requirements.txt

# Set environment to use the venv by default
ENV PATH="/opt/venv/bin:$PATH"

# ----------------------------
# Stage 3: Final runtime image
# ----------------------------
FROM base AS runtime

# Copy C binaries from build stage
COPY --from=build-c $MAGMA_ROOT/bazel-bin/lte/gateway/c/sctpd/sctpd /usr/local/bin/sctpd
COPY --from=build-c $MAGMA_ROOT/bazel-bin/lte/gateway/c/oai_mme/oai_mme /usr/local/bin/oai_mme
COPY --from=build-c $MAGMA_ROOT/bazel-bin/lte/gateway/c/sessiond/sessiond /usr/local/bin/sessiond
COPY --from=build-c $MAGMA_ROOT/bazel-bin/lte/gateway/c/connectiond/connectiond /usr/local/bin/connectiond
COPY --from=build-c $MAGMA_ROOT/bazel-bin/lte/gateway/c/liagentd/liagentd /usr/local/bin/liagentd

# Copy Python files and dependencies
COPY --from=build-python $MAGMA_ROOT /magma

# Set environment
ENV MAGMA_ROOT=/magma
WORKDIR $MAGMA_ROOT

# Expose necessary ports
EXPOSE 50051-50082 60051 60055 8443

# Entrypoint
ENTRYPOINT ["/usr/bin/env", "python3", "-m", "magma.magmad.main"]
