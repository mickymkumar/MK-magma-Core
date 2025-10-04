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
    net-tools \
    iproute2 \
    iputils-ping \
    tcpdump \
    iptables \
    sudo \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Step 2: Install Python 3.10 via deadsnakes
# -----------------------------
RUN add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        python3.10 \
        python3.10-venv \
        python3-pip \
        python3.10-dev \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Step 3: Setup Python virtual environment
# -----------------------------
WORKDIR /magma/lte/gateway/python
RUN python3.10 -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip setuptools wheel cython

ENV PATH="/opt/venv/bin:$PATH"

# -----------------------------
# Step 4: Copy Magma source code
# -----------------------------
WORKDIR /magma
COPY . .

# -----------------------------
# Step 5: Install Python dependencies for LTE/5G gateway
# -----------------------------
WORKDIR /magma/lte/gateway/python

# Install system build dependencies for wheels
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libxml2-dev libxslt1-dev zlib1g-dev python3-dev build-essential libffi-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Pin setuptools for ryu compatibility
RUN pip install --no-cache-dir --upgrade pip wheel cython
RUN pip install --no-cache-dir "setuptools==65.5.0"

# Install Magma Python packages
RUN pip install --no-cache-dir -e .

# -----------------------------
# Step 6: Setup 5G Core binaries (AMF, SMF, UPF)
# -----------------------------
WORKDIR /magma/5g/core
# Optional: clone or build 5G core binaries if not included
# RUN git clone https://github.com/magma/magma.git . && ./build.sh

# -----------------------------
# Step 7: Enable IP forwarding for UPF
# -----------------------------
RUN sysctl -w net.ipv4.ip_forward=1

# -----------------------------
# Step 8: Add startup script to launch AGW services
# -----------------------------
COPY ../start_agw.sh /magma/start_agw.sh
RUN chmod +x /magma/start_agw.sh

# -----------------------------
# Step 9: Default runtime
# -----------------------------
WORKDIR /magma
CMD ["/magma/start_agw.sh"]
