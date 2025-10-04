# ----------------------------
# Stage 0: Base image
# ----------------------------
FROM ubuntu:24.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

# System deps for Python, Bazel, lxml, pystemd, etc.
RUN apt-get update && apt-get install -y \
    python3.12 python3.12-venv python3.12-dev python3-pip \
    build-essential git curl wget pkg-config gnupg software-properties-common \
    libssl-dev libffi-dev libpq-dev libsystemd-dev lsb-release unzip \
    openjdk-11-jdk \
    libxml2-dev libxslt-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Make python3/pip point to Python 3.12
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1


# ----------------------------
# Stage 1: Bazel install
# ----------------------------
FROM base AS bazel

RUN curl -LO "https://github.com/bazelbuild/bazelisk/releases/download/v1.22.0/bazelisk-linux-amd64" \
    && mv bazelisk-linux-amd64 /usr/local/bin/bazel \
    && chmod +x /usr/local/bin/bazel \
    && bazel version


# ----------------------------
# Stage 2: Python dependencies build
# ----------------------------
FROM base AS build-python

# Create isolated venv
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip/wheel and pin setuptools < 68 for legacy packages like ryu
RUN pip install --upgrade pip wheel && pip install "setuptools<68"

# Copy Magma source into container
WORKDIR /magma
COPY . .

# Install Python deps (editable mode for AGW Python services)
WORKDIR /magma/lte/gateway/python
RUN pip install -e .


# ----------------------------
# Stage 3: Build AGW C services with Bazel
# ----------------------------
FROM bazel AS build-agw

WORKDIR /magma
COPY . .

RUN bazel build //lte/gateway/c/... --jobs=$(nproc)


# ----------------------------
# Stage 4: Runtime image
# ----------------------------
FROM base AS runtime

# Copy Python venv with all deps
COPY --from=build-python /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy Magma source and built binaries
WORKDIR /magma
COPY . .
COPY --from=build-agw /magma/bazel-bin /magma/bazel-bin

# Default command (adjust as needed, e.g., run enodebd, mme, or python service)
CMD ["python3", "-m", "magma"]
