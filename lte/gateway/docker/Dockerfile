# ----------------------------
# Stage 0: Base image
# ----------------------------
FROM ubuntu:24.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

# Install basic packages and Python 3.12
RUN apt-get update && apt-get install -y \
    python3.12 python3.12-venv python3.12-dev \
    build-essential git curl wget pkg-config \
    libssl-dev libffi-dev libpq-dev \
    libxml2-dev libxslt1-dev zlib1g-dev \
    openjdk-11-jdk unzip bash \
    && rm -rf /var/lib/apt/lists/*

# Symlink python & pip
RUN ln -sf /usr/bin/python3.12 /usr/bin/python3 && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# ----------------------------
# Stage 1: Python environment
# ----------------------------
FROM base AS build-python

WORKDIR /magma

# Copy Magma code
COPY . .

# Create virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip & setuptools
RUN pip install --upgrade pip setuptools wheel

# Install system deps for lxml & pystemd
RUN apt-get update && apt-get install -y \
    libsystemd-dev pkg-config

# Install Python dependencies for Magma LTE gateway
WORKDIR /magma/lte/gateway/python
RUN pip install --upgrade cython && pip install -e .


# ----------------------------
# Stage 2: Build AGW binaries
# ----------------------------
FROM build-python AS build-agw

WORKDIR /magma

# Install Bazel
RUN curl -LO https://github.com/bazelbuild/bazel/releases/download/5.2.0/bazel-5.2.0-linux-x86_64 && \
    chmod +x bazel-5.2.0-linux-x86_64 && mv bazel-5.2.0-linux-x86_64 /usr/local/bin/bazel

# Clean Bazel caches
RUN bazel clean --expunge

# Build AGW C binaries
RUN bazel build //lte/gateway/c/... --jobs=$(nproc)

# ----------------------------
# Stage 3: Runtime image
# ----------------------------
FROM base AS runtime

# Copy Python virtual environment
COPY --from=build-python /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy Magma AGW binaries
COPY --from=build-agw /magma /magma

WORKDIR /magma

# Default command
CMD ["python3", "-m", "magma"]
