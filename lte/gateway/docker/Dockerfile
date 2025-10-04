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
    python3.12 \
    python3.12-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Step 2: Set Python path
# -----------------------------
ENV PATH="/usr/local/bin:$PATH"
ENV PYTHON_BIN_PATH=/usr/bin/python3.12

# Upgrade pip & setuptools & wheel
RUN python3.12 -m pip install --upgrade pip setuptools wheel cython

# -----------------------------
# Step 3: Copy Magma gateway source
# -----------------------------
WORKDIR /magma
COPY . .

# -----------------------------
# Step 4: Install Python LTE packages
# -----------------------------
WORKDIR /magma/lte/gateway/python
RUN pip install --no-cache-dir -e .

# -----------------------------
# Step 5: Default runtime
# -----------------------------
WORKDIR /magma
CMD ["/bin/bash"]
