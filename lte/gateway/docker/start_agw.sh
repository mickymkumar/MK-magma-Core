#!/bin/bash
set -e

echo "=========================="
echo "Starting Magma AGW (LTE + 5G)"
echo "=========================="

# Enable IP forwarding (needed for UPF/NAT)
sysctl -w net.ipv4.ip_forward=1

# Start LTE Gateway Python service
echo "[*] Starting LTE Gateway..."
cd /magma/lte/gateway/python
# Run in background
python3 -m lte.cli &

# Start 5G Core binaries if available
if [ -d /magma/5g/core ]; then
    echo "[*] Starting 5G Core services..."
    cd /magma/5g/core
    # You may need to adjust these scripts according to your setup
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
