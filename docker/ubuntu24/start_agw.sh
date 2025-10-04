#!/bin/bash
set -e

echo "=========================="
echo "Starting Magma AGW (LTE + 5G)"
echo "=========================="

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Define virtual environment path
VENV_PATH=/opt/venv

# Create virtual environment if it doesn't exist
if [ ! -d "$VENV_PATH" ]; then
    echo "[*] Creating Python virtual environment at $VENV_PATH..."
    python3 -m venv $VENV_PATH
fi

# Activate virtual environment
echo "[*] Activating virtual environment..."
source $VENV_PATH/bin/activate

# Upgrade pip and install requirements if not installed
pip install --upgrade pip setuptools wheel
REQ_FILE=/magma/magma/lte/gateway/python/requirements.txt
if [ -f "$REQ_FILE" ]; then
    pip install -r $REQ_FILE
fi

# Start LTE Gateway Python service
echo "[*] Starting LTE Gateway..."
cd /magma/magma/lte/gateway/python
python3 -m lte.cli &

# Start 5G Core binaries if available
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
