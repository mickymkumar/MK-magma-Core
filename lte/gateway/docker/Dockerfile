# Base image
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    MAGMA_ROOT=/magma

# Install runtime dependencies only
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

# Copy the Docker folder and pre-built AGW binaries
COPY . /magma

# Make the AGW start script executable
RUN chmod +x /magma/lte/gateway/docker/run_agw_services.sh

# Entrypoint to start AGW
ENTRYPOINT ["/magma/lte/gateway/docker/run_agw_services.sh"]

# Optional debugging
# CMD ["/bin/bash"]
