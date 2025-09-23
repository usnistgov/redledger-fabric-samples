#!/bin/bash

# RedLedger Matrix Info Decode Script
# This script queries the RedLedger QSCC for block matrix information and decodes it
# Usage: ./decode_matrix.sh [channel_name]
# Example: ./decode_matrix.sh dbmchannel

# Get channel name from parameter (required)
CHANNEL_NAME=$1

# Validate that channel name is provided
if [[ -z "$CHANNEL_NAME" ]]; then
    echo "Error: Channel name is required"
    echo "Usage: $0 <channel_name>"
    echo "Example: $0 dbmchannel"
    exit 1
fi

# Determine the correct path to the proto file
# Get the actual script location and construct absolute path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Debug: Script directory is: $SCRIPT_DIR"

# Always construct path relative to script location, not working directory
if [[ "$SCRIPT_DIR" == *"/scripts" ]]; then
    # Script is in scripts subdirectory, proto file is in parent directory
    PROTO_PATH="$(dirname "$SCRIPT_DIR")"
    PROTO_FILE="$PROTO_PATH/blockmatrix.proto"
    echo "Debug: Detected scripts directory, using parent path"
else
    # Script is in network directory
    PROTO_PATH="$SCRIPT_DIR"
    PROTO_FILE="$SCRIPT_DIR/blockmatrix.proto"
    echo "Debug: Detected network directory, using current path"
fi

echo "Debug: PROTO_PATH=$PROTO_PATH"
echo "Debug: PROTO_FILE=$PROTO_FILE"

# Check if proto file exists
if [[ ! -f "$PROTO_FILE" ]]; then
    echo "Error: blockmatrix.proto not found at $PROTO_FILE"
    echo "Make sure blockmatrix.proto is in the network directory"
    exit 1
fi

echo "Querying block matrix info for channel: $CHANNEL_NAME"
echo "Using proto file: $PROTO_FILE"

# Step 1: Query RedLedger's QSCC for block matrix information and decode it
peer chaincode query -C "$CHANNEL_NAME" -n qscc -c "{\"Args\":[\"GetMatrixInfo\",\"$CHANNEL_NAME\"]}" | python -c "import sys; sys.stdout.buffer.write(sys.stdin.buffer.read().rstrip(b'\n'))" | protoc --proto_path="$PROTO_PATH" --decode=blockmatrix.Info "$PROTO_FILE"

echo "Matrix info decode complete for channel: $CHANNEL_NAME"