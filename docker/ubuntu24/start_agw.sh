#!/bin/bash
set -e

echo "=========================="
echo "Starting Magma AGW (LTE + 5G)"
echo "=========================="

# Enable IP forwarding
echo "[*] Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1

# Install necessary system packages
echo "[*] Installing system packages..."
apt update
apt install -y python3 python3-pip python3-venv curl git net-tools iproute2 iptables sudo

# Setup Python virtual environment
VENV_DIR="/magma/venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "[*] Creating Python virtual environment at $VENV_DIR..."
    if ! python3 -m venv "$VENV_DIR"; then
        echo "[!] Failed to create venv. Attempting to bootstrap pip..."
        python3 -m venv --without-pip "$VENV_DIR"
        curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
        "$VENV_DIR/bin/python3" /tmp/get-pip.py
    fi
fi

# Activate virtual environment
echo "[*] Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Upgrade pip and setuptools
echo "[*] Upgrading pip and setuptools..."
pip install --upgrade pip setuptools wheel

# Install Magma Python dependencies
PYTHON_DIR="/magma/magma/lte/gateway/python"
echo "[*] Installing Magma Python dependencies..."
cd "$PYTHON_DIR"
pip install -r requirements.txt || echo "[!] Requirements file missing or failed, skipping."

# Start LTE Gateway
echo "[*] Starting LTE Gateway..."
if [ -f "$PYTHON_DIR/scripts/lte_gateway.py" ]; then
    python3 -m scripts.lte_gateway &
else
    echo "[!] LTE gateway script not found, skipping..."
fi

# Start 5G Core services
CORE_DIR="/magma/5g/core"
if [ -d "$CORE_DIR" ]; then
    echo "[*] Starting 5G Core services..."
    cd "$CORE_DIR"
    [ -f ./run_amf.sh ] && ./run_amf.sh &
    [ -f ./run_smf.sh ] && ./run_smf.sh &
    [ -f ./run_upf.sh ] && ./run_upf.sh &
else
    echo "[!] 5G core directory not found, skipping..."
fi

# Wait a few seconds
sleep 5

# Verify services
echo "[*] Checking LTE and 5G services..."
ps aux | grep -E "lte|amf|smf|upf" | grep -v grep

echo "=========================="
echo "Magma AGW startup complete"
echo "=========================="

# Keep container alive
tail -f /dev/null
