#!/bin/bash
set -e

echo "=========================="
echo "Starting Magma AGW (LTE + 5G)"
echo "=========================="

# Enable IP forwarding (needed for UPF/NAT)
sysctl -w net.ipv4.ip_forward=1

# Paths
VENV_PATH=/magma/venv
LTE_PYTHON_PATH=/magma/magma/lte/gateway/python

# Check if python3-venv is installed
if ! dpkg -s python3-venv >/dev/null 2>&1; then
    echo "[*] Installing python3-venv..."
    apt-get update && apt-get install -y python3-venv
fi

# Create virtual environment if not exists
if [ ! -f "$VENV_PATH/bin/activate" ]; then
    echo "[*] Creating Python virtual environment at $VENV_PATH..."
    python3 -m venv $VENV_PATH
fi

# Activate virtual environment
echo "[*] Activating virtual environment..."
source $VENV_PATH/bin/activate

# Upgrade pip, setuptools, wheel
echo "[*] Upgrading pip, setuptools, wheel..."
pip install --upgrade pip setuptools wheel

# Install required Python dependencies if requirements.txt exists
if [ -f "$LTE_PYTHON_PATH/requirements.txt" ]; then
    echo "[*] Installing Python dependencies from requirements.txt..."
    pip install -r $LTE_PYTHON_PATH/requirements.txt
else
    echo "[!] No requirements.txt found at $LTE_PYTHON_PATH"
    echo "[*] Installing common Magma dependencies..."
    pip install -U aiohttp eventlet flask requests lte
fi

# Start LTE Gateway Python service
echo "[*] Starting LTE Gateway..."
cd $LTE_PYTHON_PATH
# Run in background
python3 -m lte.cli &

# Start 5G Core services if available
if [ -d /magma/5g/core ]; then
    echo "[*] Starting 5G Core services..."
    cd /magma/5g/core
    [ -f ./run_amf.sh ] && ./run_amf.sh &
    [ -f ./run_smf.sh ] && ./run_smf.sh &
    [ -f ./run_upf.sh ] && ./run_upf.sh &
fi

# Wait a few seconds for services to initialize
sleep 5

# Verify services
echo "[*] Checking LTE and 5G services..."
ps aux | grep -E "lte_gateway_service|python3.*lte|amf|smf|upf" | grep -v grep

echo "=========================="
echo "Magma AGW startup complete"
echo "=========================="

# Keep container alive
tail -f /dev/null
