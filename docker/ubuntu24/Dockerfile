# -----------------------------
# Magma Core AGW (LTE + 5G) Ubuntu 24.04
# -----------------------------
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/opt/venv/bin:$PATH"

# -----------------------------
# Step 0: Install base dependencies
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo systemd systemd-sysv \
        net-tools iproute2 bridge-utils openvswitch-switch iputils-ping tcpdump iptables \
        python3 python3-venv python3-pip python3-dev \
        curl wget git unzip make build-essential cmake pkg-config software-properties-common \
        libsystemd-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev libgmp-dev zlib1g-dev rsync zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Step 1: Add Magma user
# -----------------------------
RUN useradd -ms /bin/bash magma && echo "magma ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
WORKDIR /home/magma
VOLUME /home/magma

# -----------------------------
# Step 2: Install Python 3.10
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
# Step 4: Clone Magma repo (or COPY local source)
# -----------------------------
WORKDIR /magma
RUN git clone https://github.com/magma/magma.git . || true
# If using local source instead, uncomment the next line and comment out the git clone
# COPY . .

# -----------------------------
# Step 5: Install Python dependencies
# -----------------------------
WORKDIR /magma/lte/gateway/python
RUN /opt/venv/bin/pip install --no-cache-dir grpcio requests six protobuf

# -----------------------------
# Step 6: Enable IP forwarding
# -----------------------------
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p

# -----------------------------
# Step 7: Add startup script
# -----------------------------
COPY start_agw.sh /magma/lte/gateway/start_agw.sh
RUN chmod +x /magma/lte/gateway/start_agw.sh

# -----------------------------
# Step 8: Patch AGW scripts (if any ifup/ifdown)
# -----------------------------
RUN sed -i 's/ifdown /ip link set /g; s/ifup /ip link set /g' /magma/lte/gateway/start_agw.sh || true

# -----------------------------
# Step 9: Keep container alive
# -----------------------------
WORKDIR /magma/lte/gateway
CMD ["/magma/lte/gateway/start_agw.sh"]
