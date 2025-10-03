#!/bin/bash
set -e

echo "Starting Magma AGW services..."

# Check if AGW binaries exist
AGW_BIN="/magma/lte/gateway/build/c"
if [ ! -d "$AGW_BIN" ]; then
    echo "ERROR: AGW binaries path not found: $AGW_BIN"
    echo "Make sure Bazel build ran successfully or use pre-built binaries."
    exit 1
fi

cd "$AGW_BIN"

# Start each service in background
./session_manager/sessiond &
./spgw/pgw &
./li_agent/liagentd &
./sctpd/sctpd &

echo "All AGW services started."

# Keep container running
tail -f /dev/null
