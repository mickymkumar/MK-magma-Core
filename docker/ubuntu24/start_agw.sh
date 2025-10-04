#!/bin/bash
set -e

echo "=========================="
echo "Starting Magma AGW (LTE + 5G)"
echo "=========================="

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Paths
VENV_PATH=/magma/venv

# Detect LTE Python path
if [ -d /magma/magma/lte/gateway/python ]; then
    LTE_PYTHON_PATH=/magma/magma/lte/gateway/python
elif [ -d /magma/lte/gateway/python ]; then
    LTE_PYTHON_PATH=/magma/lte/gateway/python
else
    echo "[ERROR] Could not find LTE python directory!"
    exit 1
fi

# Create venv if missing
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

# Start LTE Gateway CLI (pick a default script to run)
DEFAULT_CLI="$LTE_PYTHON_PATH/scripts/hello_cli.py"
if [ -f "$DEFAULT_CLI" ]; then
    echo "[*] Starting LTE Gateway CLI: $DEFAULT_CLI"
    python3 "$DEFAULT_CLI" &
else
    echo "[WARN] No default CLI script found, check $LTE_PYTHON_PATH/scripts/"
fi

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
ps aux | grep -E "python3.*_cli|amf|smf|upf" | grep -v grep

echo "=========================="
echo "Magma AGW startup complete"
echo "=========================="

# Keep container alive
tail -f /dev/null
