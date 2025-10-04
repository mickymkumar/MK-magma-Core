#!/bin/bash
set -e

echo "=========================="
echo "Starting Magma AGW (LTE + 5G)"
echo "=========================="

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Paths
VENV_PATH=/opt/venv
LTE_PYTHON_PATH=/magma/lte/gateway/python

# Activate venv
echo "[*] Activating virtual environment..."
source $VENV_PATH/bin/activate

# Upgrade pip, setuptools, wheel
pip install --upgrade pip setuptools wheel

# Add LTE python directories to PYTHONPATH
export PYTHONPATH=$LTE_PYTHON_PATH:$LTE_PYTHON_PATH/magma:$PYTHONPATH

# Start LTE Gateway services
for service in magmad mobilityd state_service; do
    if [ -f "$LTE_PYTHON_PATH/$service.py" ]; then
        echo "[*] Starting $service..."
        python3 "$LTE_PYTHON_PATH/$service.py" &
    fi
done

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
ps aux | grep -E "python3.*_service|amf|smf|upf" | grep -v grep

echo "=========================="
echo "Magma AGW startup complete"
echo "=========================="

# Keep container alive
tail -f /dev/null
