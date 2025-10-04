#!/bin/bash
set -e

echo "=========================="
echo "Starting Magma AGW (LTE + 5G)"
echo "=========================="

# -----------------------------
# Function for error checking
# -----------------------------
check_command() {
    if [ $? -ne 0 ]; then
        echo "[ERROR] $1"
        exit 1
    fi
}

# Enable IP forwarding
echo "[*] Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
check_command "Failed to enable IP forwarding"

# Install system packages if missing
echo "[*] Installing system packages..."
apt update
apt install -y python3 python3-pip python3-venv curl git sudo net-tools iproute2 iptables
check_command "Failed to install required system packages"

# Set virtual environment directory
VENV_DIR="/magma/venv"

# Create venv if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "[*] Creating Python virtual environment at $VENV_DIR..."
    mkdir -p /magma
    check_command "Failed to create /magma directory"
    python3 -m venv "$VENV_DIR"
    check_command "Failed to create virtual environment"
fi

# Activate virtual environment
if [ -f "$VENV_DIR/bin/activate" ]; then
    echo "[*] Activating virtual environment..."
    source "$VENV_DIR/bin/activate"
else
    echo "[ERROR] Virtual environment activate script not found at $VENV_DIR/bin/activate"
    exit 1
fi

# Upgrade pip and setuptools
echo "[*] Upgrading pip, setuptools, and wheel..."
pip install --upgrade pip setuptools wheel
check_command "Failed to upgrade pip, setuptools, or wheel"

# Install Magma Python dependencies
PYTHON_DIR="/magma/magma/lte/gateway/python"
if [ -f "$PYTHON_DIR/requirements.txt" ]; then
    echo "[*] Installing Python dependencies from requirements.txt..."
    cd "$PYTHON_DIR"
    pip install -r requirements.txt
    check_command "Failed to install dependencies from requirements.txt"
elif [ -f "$PYTHON_DIR/setup.py" ]; then
    echo "[*] Installing Python dependencies from setup.py..."
    cd "$PYTHON_DIR"
    pip install .
    check_command "Failed to install dependencies from setup.py"
else
    echo "[ERROR] No requirements.txt or setup.py found in $PYTHON_DIR"
    exit 1
fi

# Start LTE Gateway
echo "[*] Starting LTE Gateway scripts..."
SCRIPTS_DIR="$PYTHON_DIR/scripts"
if [ -d "$SCRIPTS_DIR" ]; then
    cd "$SCRIPTS_DIR"
    for cli in *_cli.py; do
        echo "[*] Starting $cli..."
        python3 "$cli" &
        check_command "Failed to start $cli"
    done
else
    echo "[ERROR] Scripts directory not found at $SCRIPTS_DIR"
    exit 1
fi

# Start 5G Core services if directory exists
CORE_DIR="/magma/5g/core"
if [ -d "$CORE_DIR" ]; then
    echo "[*] Starting 5G Core services..."
    cd "$CORE_DIR"
    [ -f ./run_amf.sh ] && ./run_amf.sh & || echo "[WARN] run_amf.sh not found"
    [ -f ./run_smf.sh ] && ./run_smf.sh & || echo "[WARN] run_smf.sh not found"
    [ -f ./run_upf.sh ] && ./run_upf.sh & || echo "[WARN] run_upf.sh not found"
else
    echo "[WARN] 5G core directory not found, skipping 5G services"
fi

# Wait a few seconds for services to initialize
sleep 5

# Verify services
echo "[*] Checking LTE and 5G services..."
ps aux | grep -E "lte|amf|smf|upf" | grep -v grep || echo "[WARN] Some services may not be running"

echo "=========================="
echo "Magma AGW startup complete"
echo "=========================="

# Keep container alive
tail -f /dev/null
