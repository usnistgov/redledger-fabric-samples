#!/bin/bash

# Setup Peer CLI Environment Script
# This script configures the peer CLI to connect to a specific organization's peer
# Usage: source ./setup_peer_cli.sh [1|2]
# Important: This script should be sourced, not executed

echo "=== Peer CLI Environment Setup ==="

# Check if script is being sourced (recommended)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Warning: This script should be sourced for environment variables to persist"
    echo "Use: source $0 [1|2]"
  
fi

# Get script directory and calculate network directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$SCRIPT_DIR" == *"/scripts" ]]; then
    NETWORK_DIR="$(dirname "$SCRIPT_DIR")"
else
    NETWORK_DIR="$SCRIPT_DIR"
fi

echo "Script location: $SCRIPT_DIR"
echo "Network directory: $NETWORK_DIR"

# Validate that network directory exists
if [[ ! -d "$NETWORK_DIR" ]]; then
    echo "Error: Network directory not found: $NETWORK_DIR"
    return 1 2>/dev/null || exit 1
fi

# Validate that required directories exist
if [[ ! -d "$NETWORK_DIR/organizations" ]]; then
    echo "Error: Organizations directory not found. Make sure you're in a Fabric network directory"
    return 1 2>/dev/null || exit 1
fi

# Default organization (can be overridden with command line argument)
ORG=${1:-"1"}

# Validate organization input
if [[ "$ORG" != "1" && "$ORG" != "2" ]]; then
    echo "Error: Invalid organization. Use '1' or '2'"
    echo "Usage: source $0 [1|2]"
    echo "  source $0        # Defaults to Org1"
    echo "  source $0 1      # Configure for Org1"
    echo "  source $0 2      # Configure for Org2"
    return 1 2>/dev/null || exit 1
fi

echo "Configuring peer CLI for Org${ORG}..."

# Step 1: Set Fabric binary paths using absolute paths
echo "Setting Fabric binary paths..."
BIN_DIR="$NETWORK_DIR/../bin"
CONFIG_DIR="$NETWORK_DIR/../config"

if [[ -d "$BIN_DIR" ]]; then
    export PATH="$BIN_DIR:$PATH"
    echo "Added Fabric binaries to PATH: $BIN_DIR"
else
    echo "Warning: Fabric bin directory not found: $BIN_DIR"
fi

if [[ -d "$CONFIG_DIR" ]]; then
    export FABRIC_CFG_PATH="$CONFIG_DIR"
    echo "Set Fabric config path: $CONFIG_DIR"
else
    echo "Warning: Fabric config directory not found: $CONFIG_DIR"
fi

# Step 2: Set common peer settings
export CORE_PEER_TLS_ENABLED=true

# Step 3: Configure organization-specific settings using absolute paths
if [[ "$ORG" == "1" ]]; then
    # Org1 Configuration
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE="$NETWORK_DIR/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt"
    export CORE_PEER_MSPCONFIGPATH="$NETWORK_DIR/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp"
    export CORE_PEER_ADDRESS=localhost:7051
    
    echo "Peer CLI configured for Org1"
    echo "  - Peer Address: localhost:7051"
    echo "  - MSP ID: Org1MSP"
    
elif [[ "$ORG" == "2" ]]; then
    # Org2 Configuration  
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE="$NETWORK_DIR/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"
    export CORE_PEER_MSPCONFIGPATH="$NETWORK_DIR/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp"
    export CORE_PEER_ADDRESS=localhost:9051
    
    echo "Peer CLI configured for Org2"
    echo "  - Peer Address: localhost:9051" 
    echo "  - MSP ID: Org2MSP"
fi

# Validate that certificate files exist
if [[ ! -f "$CORE_PEER_TLS_ROOTCERT_FILE" ]]; then
    echo "Warning: TLS root cert file not found: $CORE_PEER_TLS_ROOTCERT_FILE"
fi

if [[ ! -d "$CORE_PEER_MSPCONFIGPATH" ]]; then
    echo "Warning: MSP config path not found: $CORE_PEER_MSPCONFIGPATH"
fi

# Step 4: Verify configuration
echo ""
echo "=== Verification ==="

# Test peer CLI binary availability
echo "Testing peer CLI binary..."
if command -v peer >/dev/null 2>&1; then
    echo "Peer CLI binary found"
    # Safely get version without risking crashes
    PEER_VERSION=$(peer version 2>/dev/null | head -1 || echo "Version check failed")
    echo "Version: $PEER_VERSION"
else
    echo "Warning: Peer CLI binary not found in PATH"
    echo "Make sure Fabric binaries are installed and accessible"
fi

# Test peer connectivity (if network is running) - safer approach
echo ""
echo "Testing peer connectivity..."
if command -v peer >/dev/null 2>&1; then
    # Test with a simple command that's less likely to crash terminal
    if timeout 5s peer channel list >/dev/null 2>&1; then
        echo "Peer connectivity successful"
        echo "Available channels:"
        peer channel list 2>/dev/null || echo "Failed to list channels"
    else
        echo "Warning: Cannot connect to peer or command timed out"
        echo "This is normal if the network isn't running or peer environment needs adjustment"
    fi
else
    echo "Skipping connectivity test - peer command not available"
fi

echo ""
echo "=== Peer CLI Environment Ready ==="
echo "Current configuration:"
echo "  Organization: Org${ORG}"
echo "  Peer Address: $CORE_PEER_ADDRESS"
echo "  MSP ID: $CORE_PEER_LOCALMSPID"
echo "  Working Directory: $(pwd)"
echo ""
echo "Common commands you can now run:"
echo "  peer version"
echo "  peer channel list"
echo "  peer channel getinfo -c channelname"
echo ""
echo "To switch organizations, run:"
echo "  source $0 1    # Switch to Org1"
echo "  source $0 2    # Switch to Org2"