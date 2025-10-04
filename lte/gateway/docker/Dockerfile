# ----------------------------
# Stage 0: Base image
# ----------------------------
# Use Ubuntu 22.04 to get Python 3.10
FROM ubuntu:22.04 AS base

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    build-essential \
    git \
    python3 \
    python3-pip \
    python3-venv \
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
RUN apt-get update && apt-get install -y curl gnupg apt-transport-https
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel-archive-keyring.gpg \
    && mv bazel-archive-keyring.gpg /usr/share/keyrings
RUN echo "deb [signed-by=/usr/share/keyrings/bazel-archive-keyring.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" \
    | tee /etc/apt/sources.list.d/bazel.list
RUN apt-get update && apt-get install -y bazel-5.2.0

# Copy Magma source
COPY . $MAGMA_ROOT

# Download and unzip liblfds
RUN mkdir -p $MAGMA_ROOT/third_party/liblfds && \
    wget --no-check-certificate -O $MAGMA_ROOT/third_party/liblfds/liblfds-release-7.1.0-source.zip \
    "https://liblfds.org/downloads/liblfds%20release%207.1.0%20source.zip" && \
    unzip -o -q $MAGMA_ROOT/third_party/liblfds/liblfds-release-7.1.0-source.zip -d $MAGMA_ROOT/third_party/liblfds

# Build all C services with Bazel
RUN bazel-5.2.0 build //lte/gateway/c/...

# ----------------------------
# Stage 2: Python build
# ----------------------------
FROM ubuntu:22.04 AS build-python

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    git \
    build-essential \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /magma

# Copy Magma source
COPY . .

# Create virtual environment
RUN python3 -m venv /opt/venv

# Activate venv and install dependencies
RUN /opt/venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/venv/bin/pip install -r /magma/lte/gateway/python/requirements.txt


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

# Entrypoint for Python services
ENTRYPOINT ["/usr/bin/env", "python3", "-m", "magma.magmad.main"]
