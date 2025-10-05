# -----------------------------
# Magma Core AGW (LTE + 5G) Ubuntu 24.04 with DKMS
# -----------------------------
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/venv/bin:$PATH"

# -----------------------------
# Step 0: Install base dependencies including DKMS and headers
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo systemd systemd-sysv \
        net-tools iproute2 bridge-utils openvswitch-switch iputils-ping tcpdump iptables \
        build-essential dkms linux-headers-$(uname -r) pkg-config \
        python3 python3-venv python3-pip python3-dev \
        curl wget git unzip make cmake software-properties-common \
        libsystemd-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev libgmp-dev zlib1g-dev rsync zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Step 1: Add Magma user
# -----------------------------
RUN useradd -ms /bin/bash magma && echo "magma ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
WORKDIR /home/magma
VOLUME /home/magma

# -----------------------------
# Step 2: Setup Python virtual environment
# -----------------------------
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel cython grpcio requests six protobuf

# -----------------------------
# Step 3: Clone Magma repo (or COPY local source)
# -----------------------------
WORKDIR /magma
RUN git clone https://github.com/magma/magma.git . || true
# If using local source instead, uncomment the next line and comment out git clone
# COPY . .

# -----------------------------
# Step 4: Build and install Open vSwitch DKMS module
# -----------------------------
RUN mkdir -p /usr/src/openvswitch-2.15.4-9 && \
    cd /usr/src/openvswitch-2.15.4-9 && \
    wget https://www.openvswitch.org/releases/openvswitch-2.15.4.tar.gz && \
    tar -xzf openvswitch-2.15.4.tar.gz --strip-components=1 && \
    dkms add -m openvswitch -v 2.15.4-9 && \
    dkms build -m openvswitch -v 2.15.4-9 && \
    dkms install -m openvswitch -v 2.15.4-9

# -----------------------------
# Step 5: Enable IP forwarding
# -----------------------------
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p

# -----------------------------
# Step 6: Default CMD to run all AGW services directly
# -----------------------------
WORKDIR /magma/lte/gateway
CMD ["bash", "-c", "\
    sysctl -w net.ipv4.ip_forward=1 && \
    /opt/venv/bin/python3 python/mme.py & \
    /opt/venv/bin/python3 python/sessiond.py & \
    /opt/venv/bin/python3 python/pipelined.py & \
    /usr/sbin/sctpd -d & \
    wait \
"]

# -----------------------------
# Notes:
# 1. Container must run privileged to insert OVS kernel module:
#    docker run -it --rm --privileged --network host \
#      -v /lib/modules:/lib/modules \
#      -v /run/openvswitch:/run/openvswitch \
#      magma-agw:24.04
# 2. Ensure enough disk space on EC2 (>20GB free) for linux-headers & DKMS build.
# 3. This image installs python3, pip, virtualenv for Magma services.
# -----------------------------
