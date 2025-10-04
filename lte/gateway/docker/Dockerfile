# ----------------------------
# Stage 0: Base image
# ----------------------------
FROM ubuntu:24.04 AS base

# Prevent interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Install system tools, Python, Bazel dependencies
RUN apt-get update && apt-get install -y \
    python3.12 python3.12-venv python3.12-dev python3-pip \
    build-essential git curl wget pkg-config gnupg software-properties-common \
    libssl-dev libffi-dev libpq-dev libsystemd-dev lsb-release unzip \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set python3 -> python3.12 and pip -> pip3 using update-alternatives
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1 \
    && update-alternatives --set python3 /usr/bin/python3.12 \
    && update-alternatives --set pip /usr/bin/pip3

# ----------------------------
# Stage 1: Bazel install
# ----------------------------
FROM base AS bazel

# Install Bazelisk (recommended for Bazel builds)
RUN curl -LO "https://github.com/bazelbuild/bazelisk/releases/download/v1.22.0/bazelisk-linux-amd64" \
    && mv bazelisk-linux-amd64 /usr/local/bin/bazel \
    && chmod +x /usr/local/bin/bazel \
    && bazel version

# ----------------------------
# Stage 2: Python build
# ----------------------------
FROM base AS build-python

# Create virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip & tools
RUN pip install --upgrade pip setuptools wheel

# Copy Magma AGW source code
WORKDIR /magma
COPY . .

# Install Python deps via setup.py
WORKDIR /magma/lte/gateway/python
RUN pip install -e .

# ----------------------------
# Stage 3: Bazel build of C/C++ services
# ----------------------------
FROM bazel AS build-agw

WORKDIR /magma

# Copy source code
COPY . .

# Bazel build (adjust targets as needed)
RUN bazel build //lte/gateway/c/... --jobs=$(nproc)

# ----------------------------
# Stage 4: Runtime image
# ----------------------------
FROM base AS runtime

# Copy Python virtual environment
COPY --from=build-python /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy Magma source code
WORKDIR /magma
COPY . .

# Copy Bazel build outputs (C/C++ binaries)
COPY --from=build-agw /magma/bazel-bin /magma/bazel-bin

# Default command (adjust to launch AGW service)
CMD ["python3", "-m", "magma"]
