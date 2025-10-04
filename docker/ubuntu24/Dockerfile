# -----------------------------
# Magma Core AGW (LTE + 5G) Ubuntu 24.04
# -----------------------------
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV container docker
ENV PATH="/opt/venv/bin:$PATH"

# -----------------------------
# Step 0: Install basic dependencies
# -----------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sudo systemd systemd-sysv \
        net-tools iproute2 bridge-utils openvswitch-switch iputils-ping tcpdump iptables \
        python3 python3-venv python3-pip python3-dev python3-distutils \
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
RUN python3.10 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel cython

# -----------------------------
# Step 4: Copy Magma source code
# -----------------------------
WORKDIR /magma
COPY . .

# -----------------------------
# Step 5: Install Python dependencies manually
# -----------------------------
WORKDIR /magma/lte/gateway/python
RUN pip install --no-cache-dir "setuptools==65.5.0"
RUN pip install --no-cache-dir grpcio requests six protobuf

# -----------------------------
# Step 6: Setup 5G Core (optional: build or copy binaries)
# -----------------------------
WORKDIR /magma/5g/core
# Uncomment and modify if you need to build from source
# RUN git clone https://github.com/magma/magma.git . && ./build.sh

# -----------------------------
# Step 7: Enable IP forwarding for UPF
# -----------------------------
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p

# -----------------------------
# Step 8: Fix Open vSwitch service for Ubuntu 24.04
# -----------------------------
RUN systemctl enable openvswitch-switch

# -----------------------------
# Step 9: Add startup script for AGW services
# -----------------------------
COPY start_agw.sh /magma/lte/gateway/start_agw.sh
RUN chmod +x /magma/lte/gateway/start_agw.sh

# Patch AGW scripts to replace ifup/ifdown with ip commands
RUN sed -i 's/ifdown /ip link set /g; s/ifup /ip link set /g' /magma/lte/gateway/start_agw.sh || true

# -----------------------------
# Step 10: systemd entrypoint for Docker
# -----------------------------
STOPSIGNAL SIGRTMIN+3
VOLUME ["/sys/fs/cgroup"]
CMD ["/lib/systemd/systemd"]
