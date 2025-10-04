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
    python3.12 \
    python3.12-venv \
    python3-pip \
    python3.12-dev \
    libpq-dev \
    net-tools \
    iproute2 \
    iputils-ping \
    tcpdump \
    iptables \
    sudo \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Step 2: Setup Python virtual environment
# -----------------------------
WORKDIR /magma/lte/gateway/python

RUN python3.12 -m venv /opt/venv \
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

# Install required build dependencies for common wheels (lxml, ryu, pystemd)
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    python3-dev \
    build-essential \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Magma Python packages in editable mode
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -e .

# -----------------------------
# Step 5: Setup 5G Core binaries (AMF, SMF, UPF)
# -----------------------------
WORKDIR /magma/5g/core

# Example: clone Magma 5G repo if not already included
# RUN git clone https://github.com/magma/magma.git . && ./build.sh

# -----------------------------
# Step 6: Enable IP forwarding for UPF
# -----------------------------
RUN sysctl -w net.ipv4.ip_forward=1

# -----------------------------
# Step 7: Default runtime
# -----------------------------
WORKDIR /magma
CMD ["/bin/bash"]
