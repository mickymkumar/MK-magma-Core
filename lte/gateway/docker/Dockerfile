# -----------------------------
# Magma LTE/AGW Ubuntu 24.04
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
    python3.12 \
    python3.12-venv \
    python3.12-distutils \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Step 2: Setup virtual environment
# -----------------------------
WORKDIR /magma/lte/gateway/python

RUN python3.12 -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip setuptools wheel cython

ENV PATH="/opt/venv/bin:$PATH"

# -----------------------------
# Step 3: Copy source code
# -----------------------------
WORKDIR /magma
COPY . .

# -----------------------------
# Step 4: Install Magma LTE Python dependencies
# -----------------------------
WORKDIR /magma/lte/gateway/python
RUN pip install --no-cache-dir -e .

# -----------------------------
# Step 5: Default runtime
# -----------------------------
WORKDIR /magma
CMD ["/bin/bash"]
