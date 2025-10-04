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

RUN add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        python3.10 \
        python3.10-venv \
        python3-pip \
        python3.10-dev \
    && rm -rf /var/lib/apt/lists/*

RUN python3.10 -m venv /opt/venv \
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

# Install system build dependencies for wheels
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libxml2-dev libxslt1-dev zlib1g-dev python3-dev build-essential libffi-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Pin setuptools to a compatible version for ryu
RUN pip install --no-cache-dir --upgrade pip wheel cython
RUN pip install --no-cache-dir "setuptools==65.5.0"

# Now install Magma Python packages in editable mode
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
