# -----------------------------
# Magma Core AGW (LTE + 5G) Ubuntu 24.04
# -----------------------------
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV container docker
ENV VENV_PATH=/opt/venv
ENV PATH="$VENV_PATH/bin:$PATH"

# -----------------------------
# Step 0: Install system dependencies
# -----------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sudo systemd systemd-sysv \
        net-tools iproute2 bridge-utils openvswitch-switch iputils-ping tcpdump iptables \
        python3 python3-venv python3-pip python3-dev \
        curl wget git unzip make build-essential cmake pkg-config software-properties-common \
        libsystemd-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev libgmp-dev zlib1g-dev rsync zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Step 1: Add Magma user
# -----------------------------
RUN useradd -ms /bin/bash magma && \
    echo "magma ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/magma
VOLUME /home/magma

# -----------------------------
# Step 2: Install Python 3.10 via deadsnakes
# -----------------------------
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y python3.10 python3.10-venv python3.10-dev python3-pip && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# Step 3: Setup Python virtual environment
# -----------------------------
RUN python3.10 -m venv $VENV_PATH && \
    $VENV_PATH/bin/pip install --upgrade pip setuptools wheel cython

# -----------------------------
# Step 4: Clone Magma LTE code
# -----------------------------
WORKDIR /magma/lte/gateway
RUN git clone --depth 1 https://github.com/magma/magma.git /magma_src && \
    cp -r /magma_src/lte/gateway/python . && rm -rf /magma_src

# -----------------------------
# Step 5: Install Python dependencies
# -----------------------------
WORKDIR /magma/lte/gateway/python
RUN pip install --no-cache-dir grpcio requests six protobuf

# -----------------------------
# Step 6: Setup 5G core (optional)
# -----------------------------
WORKDIR /magma/5g/core
# If scripts exist, they'll be executed by startup script

# -----------------------------
# Step 7: Enable IP forwarding
# -----------------------------
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p

# -----------------------------
# Step 8: Add startup script
# -----------------------------
COPY start_agw.sh /magma/lte/gateway/start_agw.sh
RUN chmod +x /magma/lte/gateway/start_agw.sh

# -----------------------------
# Step 9: Entrypoint
# -----------------------------
WORKDIR /magma/lte/gateway
CMD ["./start_agw.sh"]
