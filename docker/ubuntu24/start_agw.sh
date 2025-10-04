#!/bin/bash
set -e

echo "=========================="
echo "Starting Magma AGW (LTE + 5G)"
echo "=========================="

# Enable IP forwarding (needed for UPF/NAT)
sysctl -w net.ipv4.ip_forward=1 || echo "Warning: Could not set ip_forward"

# Activate Python venv
source /opt/venv/bin/activate

# Set PYTHONPATH for Magma Python modules
export PYTHONPATH=/magma/magma/lte/gateway/python:$PYTHONPATH

# ---------------------------
# Start LTE Gateway services
# ---------------------------
echo "[*] Starting LTE Gateway services..."
cd /magma/magma/lte/gateway/python/scripts

# List of LTE Gateway CLI services to start
LTE_SERVICES=(
  "agw_health_cli.py"
  "pipelined_cli.py"
  "mobility_cli.py"
  "s6a_proxy_cli.py"
  "spgw_service_cli.py"
  "subscriber_cli.py"
)

for svc in "${LTE_SERVICES[@]}"; do
    if [ -f "$svc" ]; then
        echo "[*] Starting $svc..."
        python3 "$svc" &
    fi
done

# ---------------------------
# Start 5G Core services
# ---------------------------
if [ -d /magma/5g/core ]; then
    echo "[*] Starting 5G Core services..."
    cd /magma/5g/core

    [ -f ./run_amf.sh ] && ./run_amf.sh &
    [ -f ./run_smf.sh ] && ./run_smf.sh &
    [ -f ./run_upf.sh ] && ./run_upf.sh &
fi

# Wait a few seconds for services to initialize
sleep 5

# ---------------------------
# Verify services
# ---------------------------
echo "[*] Checking LTE and 5G services..."
ps aux | grep -E "python3.*_cli|amf|smf|upf" | grep -v grep

echo "=========================="
echo "Magma AGW startup complete"
echo "=========================="

# Keep container alive (useful for Docker)
tail -f /dev/null
