########################
# Runtime Stage
########################
FROM ubuntu:24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    MAGMA_ROOT=/magma

WORKDIR /magma

# Add deadsnakes PPA for Python 3.11
RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common \
 && add-apt-repository ppa:deadsnakes/ppa \
 && apt-get update && apt-get install -y --no-install-recommends \
    iproute2 \
    iputils-ping \
    net-tools \
    ca-certificates \
    curl \
    openvswitch-switch \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    socat \
    sudo \
    bash \
    procps \
 && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2 \
 && update-alternatives --config python3 || true

# Copy Docker scripts
COPY lte/gateway/docker /magma/lte/gateway/docker

# Copy AGW binaries from builder
COPY --from=builder /magma/lte/gateway/bazel-bin/c /magma/lte/gateway/build/c

# Ensure the run script is executable
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh || true

# Entrypoint
ENTRYPOINT ["/magma/lte/gateway/docker/run_agw_services.sh"]
