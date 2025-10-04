# ----------------------------
# Stage 0: Base image
# ----------------------------
FROM ubuntu:24.04 AS base

# Prevent interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies, dev headers, and pkg-config
RUN apt-get update && apt-get install -y \
    python3.12 python3.12-venv python3.12-dev \
    build-essential git curl wget pkg-config \
    libssl-dev libffi-dev libpq-dev libsystemd-dev \
    unzip gnupg software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Ensure python3 -> python3.12 and pip -> pip3
RUN ln -s /usr/bin/python3.12 /usr/bin/python3 && \
    ln -s /usr/bin/pip3 /usr/bin/pip

# ----------------------------
# Stage 1: Python + Bazel build environment
# ----------------------------
FROM base AS build-python

# Create a virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip, setuptools, wheel in venv
RUN pip install --upgrade pip setuptools wheel

# ----------------------------
# Install Bazel 5.2.0
# ----------------------------
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg && \
    mv bazel.gpg /usr/share/keyrings/ && \
    echo "deb [signed-by=/usr/share/keyrings/bazel.gpg] https://storage.googleapis.com/bazel-apt stable jdk1.8" > /etc/apt/sources.list.d/bazel.list && \
    apt-get update && apt-get install -y bazel-5.2.0 && \
    rm -rf /var/lib/apt/lists/*

# Copy Magma LTE source code
WORKDIR /magma
COPY . .

# Install Python deps via setup.py (instead of requirements.txt)
WORKDIR /magma/lte/gateway/python
RUN pip install -e .

# Build C services with Bazel
WORKDIR /magma
RUN bazel build //lte/gateway/c/...

# ----------------------------
# Stage 2: Runtime image
# ----------------------------
FROM base AS runtime

# Copy virtual environment from build stage
COPY --from=build-python /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy Magma LTE gateway code
WORKDIR /magma
COPY . .

# Copy Bazel-built binaries (optional, if you need them in runtime)
COPY --from=build-python /magma/bazel-bin /magma/bazel-bin

# Default command (adjust to run a specific service)
CMD ["python3", "-m", "magma"]
