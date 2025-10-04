# -----------------------------
# Full Magma LTE + AGW build
# -----------------------------
FROM ubuntu:22.04

# -----------------------------
# Step 1: Install system dependencies
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    pkg-config \
    libsystemd-dev \
    libssl-dev \
    libffi-dev \
    git \
    curl \
    wget \
    unzip \
    openjdk-11-jdk \
    python3.11 \
    python3.11-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Step 2: Install Bazelisk (Bazel manager)
# -----------------------------
RUN curl -Lo /usr/local/bin/bazel https://github.com/bazelbuild/bazelisk/releases/download/v1.15.0/bazelisk-linux-amd64 \
    && chmod +x /usr/local/bin/bazel

# -----------------------------
# Step 3: Setup Python
# -----------------------------
ENV PATH="/usr/local/bin:$PATH"
ENV PYTHON_BIN_PATH=/usr/bin/python3.11

# Upgrade pip, setuptools, wheel, cython
RUN python3.11 -m pip install --upgrade pip setuptools wheel cython

# -----------------------------
# Step 4: Copy Magma repo
# -----------------------------
WORKDIR /magma
COPY . .

# -----------------------------
# Step 5: Install LTE Python dependencies
# -----------------------------
WORKDIR /magma/lte/gateway/python
RUN pip install -e .

# -----------------------------
# Step 6: Build C gateway with Bazel
# -----------------------------
WORKDIR /magma
RUN bazel build //lte/gateway/c/... --jobs=$(nproc)

# -----------------------------
# Step 7: Default runtime
# -----------------------------
WORKDIR /magma
CMD ["/bin/bash"]
