# -----------------------------
# Magma Core AGW (LTE + 5G) Ubuntu 24.04
# -----------------------------
FROM ubuntu:24.04

# -----------------------------
# Step 1: Install system dependencies
# -----------------------------
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    curl \
    wget \
    git \
    pkg-config \
    libsystemd-dev \
    libffi-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libgmp-dev \
    python3.11 \
    python3.11-venv \
    python3-pip \
    python3.11-dev \
    libpq-dev \
    net-tools \
    iproute2 \
    iputils-ping \
    tcpdump \
    iptables \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Step 2: Setup Python virtual environment
# -----------------------------
WORKDIR /magma/lte/gateway/python

RUN python3.11 -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip setuptools wheel cython

ENV PATH="/opt/venv/bin:$PATH"

# -----------------------------
# Step 3: Copy Magma source code
# -----------------------------
WORKDIR /magma
COPY . .

# -----------------------------
# Step 4: Install Python dependencies for LTE/5G gateway
# -----------------------------
WORKDIR /magma/lte/gateway/python
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libxml2-dev libxslt1-dev zlib1g-dev \
    && pip install --no-cache-dir -e .

# -----------------------------
# Step 5: Setup 5G Core binaries (AMF, SMF, UPF)
# -----------------------------
# You may need to build or copy Magma 5G binaries into /magma/5g/core
WORKDIR /magma/5g/core

# Example: clone Magma 5G repo if not already included
# RUN git clone https://github.com/magma/magma.git . && ./build.sh

# -----------------------------
# Step 6: Setup networking for LTE/5G
# -----------------------------
# Enable IP forwarding for UPF
RUN sysctl -w net.ipv4.ip_forward=1

# -----------------------------
# Step 7: Default runtime
# -----------------------------
WORKDIR /magma
CMD ["/bin/bash"]
