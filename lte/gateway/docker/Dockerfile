# Magma AGW container for 5G services
FROM ubuntu:24.04

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    MAGMA_ROOT=/magma

# Install runtime dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    iproute2 \
    iputils-ping \
    net-tools \
    ca-certificates \
    curl \
    openvswitch-switch \
    python3 \
    python3-pip \
    socat \
    sudo \
    bash \
    procps \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /magma

# Copy Docker scripts (does not include compiled binaries)
COPY lte/gateway/docker /magma/lte/gateway/docker

# Make the AGW start script executable
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh

# Entrypoint to start AGW services
ENTRYPOINT ["/magma/lte/gateway/docker/run_agw_services.sh"]

# Optional for debugging:
# CMD ["/bin/bash"]
