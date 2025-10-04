# ----------------------------
# Stage 0: Base image
# ----------------------------
FROM ubuntu:24.04 AS base

# Prevent interactive prompts during install
ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools and Python
RUN apt-get update && apt-get install -y \
    python3.12 python3.12-venv python3.12-dev \
    build-essential git curl wget pkg-config \
    libssl-dev libffi-dev libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Set python3 -> python3.12
RUN ln -s /usr/bin/python3.12 /usr/bin/python3 && \
    ln -s /usr/bin/pip3 /usr/bin/pip

# ----------------------------
# Stage 1: Python environment
# ----------------------------
FROM base AS build-python

# Create a virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip & tools inside venv
RUN pip install --upgrade pip setuptools wheel

# Copy Magma LTE Python source
WORKDIR /magma
COPY . .

# Install Python deps via setup.py (instead of requirements.txt)
WORKDIR /magma/lte/gateway/python
RUN pip install -e .

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

# Default command (adjust if you want to run specific service)
CMD ["python3", "-m", "magma"]
