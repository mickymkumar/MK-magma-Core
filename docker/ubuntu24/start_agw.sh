#!/bin/bash
set -e

echo "=========================="
echo "Starting Magma AGW (LTE + 5G)"
echo "=========================="

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

VENV_PATH=/opt/venv
LTE_PATH=/magma/lte/gateway/python
CORE5G_PATH=/magma/5g/core

# Activate venv
source $VENV_PATH/bin/activate
pip install --upgrade pip setuptools wheel

# Export PYTHONPATH
export PYTHONPATH=$LTE_PATH:$LTE_PATH/magma:$PYTHONPATH

# Start LTE services if available
if [ -d "$LTE_PATH/magma" ]; then
    echo "[*] Starting LTE services..."
    for svc in magmad mobilityd state_service; do
        if [ -f "$LTE_PATH/magma/$svc.py" ]; then
            python3 "$LTE_PATH/magma/$svc.py" &
        fi
    done
fi

# Start 5G Core services if available
if [ -d "$CORE5G_PATH" ]; then
    echo "[*] Starting 5G Core services..."
    cd $CORE5G_PATH
    for svc in run_amf.sh run_smf.sh run_upf.sh; do
        [ -f "$svc" ] && bash "$svc" &
    done
fi

# Wait and check
sleep 5
echo "[*] Active processes:"
ps aux | grep -E "python3|amf|smf|upf" | grep -v grep

echo "=========================="
echo "Magma AGW startup complete"
echo "=========================="

# Keep container alive
tail -f /dev/null
