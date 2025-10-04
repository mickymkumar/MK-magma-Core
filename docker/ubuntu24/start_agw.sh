#!/bin/bash
set -e

echo "=========================="
echo "Starting Magma AGW (LTE + 5G)"
echo "=========================="

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Paths
VENV_PATH=/magma/venv
LTE_PYTHON_PATH=/magma/magma/lte/gateway/python

# Check python3-venv and create venv if missing
if [ ! -f "$VENV_PATH/bin/activate" ]; then
    echo "[*] Creating Python virtual environment at $VENV_PATH..."
    python3 -m venv $VENV_PATH
fi

# Activate venv
echo "[*] Activating virtual environment..."
source $VENV_PATH/bin/activate

# Upgrade pip etc.
pip install --upgrade pip setuptools wheel

# Add LTE python directories to PYTHONPATH
export PYTHONPATH=$LTE_PYTHON_PATH:$LTE_PYTHON_PATH/magma:$PYTHONPATH

# Start LTE Gateway CLI
echo "[*] Starting LTE Gateway..."
cd $LTE_PYTHON_PATH
# Example: you can pick any CLI script here from scripts folder
# For full functionality, you might start hello_cli.py as a test
python3 -m magma.cli & 2>/dev/null || echo "[!] magma.cli not found, try specific CLI scripts"

# Start 5G Core services if available
if [ -d /magma/5g/core ]; then
    echo "[*] Starting 5G Core services..."
    cd /magma/5g/core
    [ -f ./run_amf.sh ] && ./run_amf.sh &
    [ -f ./run_smf.sh ] && ./run_smf.sh &
    [ -f ./run_upf.sh ] && ./run_upf.sh &
fi

# Wait for initialization
sleep 5

# Verify
echo "[*] Checking LTE and 5G services..."
ps aux | grep -E "python3.*magma|amf|smf|upf" | grep -v grep

echo "=========================="
echo "Magma AGW startup complete"
echo "=========================="

# Keep container alive
tail -f /dev/null
