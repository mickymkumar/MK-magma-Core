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
        build-essential dkms libelf-dev linux-libc-dev pkg-config \
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
# Step 3: Clone Magma repo
# -----------------------------
WORKDIR /magma
RUN git clone https://github.com/magma/magma.git . || true
# If using local source instead, uncomment the next line
# COPY . .

# -----------------------------
# Step 4: Build Open vSwitch kernel module via DKMS
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends linux-headers-$(uname -r) \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure DKMS module for Open vSwitch is built
RUN dkms remove -m openvswitch -v 2.15.4-9 --all || true && \
    dkms add -m openvswitch -v 2.15.4-9 && \
    dkms build -m openvswitch -v 2.15.4-9 && \
    dkms install -m openvswitch -v 2.15.4-9

# -----------------------------
# Step 5: Enable IP forwarding
# -----------------------------
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p

# -----------------------------
# Step 6: Setup Open vSwitch integration bridge
# -----------------------------
RUN /etc/init.d/openvswitch-switch start && \
    ovs-vsctl --may-exist add-br br-int && \
    ip link set dev br-int up

# -----------------------------
# Step 7: Run all AGW services
# -----------------------------
WORKDIR /magma/lte/gateway
CMD ["bash", "-c", "\
    sysctl -w net.ipv4.ip_forward=1 && \
    /opt/venv/bin/python3 /magma/lte/gateway/python/mme.py & \
    /opt/venv/bin/python3 /magma/lte/gateway/python/sessiond.py & \
    /opt/venv/bin/python3 /magma/lte/gateway/python/pipelined.py & \
    /usr/sbin/sctpd -d & \
    ovs-vsctl --may-exist add-br br-int && \
    ip link set dev br-int up && \
    wait \
"]
