#!/bin/bash
set -e

echo "=========================="
echo "Starting Magma AGW (LTE + 5G)"
echo "=========================="

# Enable IP forwarding (needed for UPF/NAT)
sysctl -w net.ipv4.ip_forward=1

# Install system dependencies if missing
echo "[*] Installing system dependencies..."
apt-get update
apt-get install -y python3 python3-venv python3-pip

# Create virtual environment if it doesn't exist
VENV_DIR="/magma/venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "[*] Creating Python virtual environment at $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
fi

# Activate virtual environment
echo "[*] Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Upgrade pip inside venv
pip install --upgrade pip setuptools wheel

# Install required Python packages for LTE
echo "[*] Installing Python dependencies..."
LTE_PYTHON_DIR="/magma/lte/gateway/python"
if [ -f "$LTE_PYTHON_DIR/setup.py" ]; then
    pip install -e "$LTE_PYTHON_DIR"
fi

# Start LTE Gateway Python service
echo "[*] Starting LTE Gateway..."
cd "$LTE_PYTHON_DIR"
# Check if lte.cli module exists
if python -c "import lte.cli" &> /dev/null; then
    python -m lte.cli &
else
    echo "[!] Could not find lte.cli module. Skipping LTE Gateway."
fi

# Start 5G Core binaries if available
CORE_DIR="/magma/5g/core"
if [ -d "$CORE_DIR" ]; then
    echo "[*] Starting 5G Core services..."
    cd "$CORE_DIR"
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
