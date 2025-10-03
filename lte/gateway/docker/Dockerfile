# Use Ubuntu 24.04 as base
FROM ubuntu:24.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    iproute2 \
    iputils-ping \
    net-tools \
    iptables \
    sudo \
    curl \
    wget \
    lsb-release \
    software-properties-common \
    build-essential \
    python3 \
    python3-pip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Docker Compose Python package
RUN pip3 install --break-system-packages docker-compose

# Copy Magma code (assumes you cloned MK-magma-Core to /lte/gateway)
COPY ../ /magma

# Copy run script
COPY run_agw_services.sh /magma/run_agw_services.sh
RUN chmod +x /magma/run_agw_services.sh

# Set working directory
WORKDIR /magma

# Start AGW services when container runs
CMD ["/magma/run_agw_services.sh"]
