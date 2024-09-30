#!/bin/bash

# Check if architecture is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <architecture>"
    echo "Please specify architecture: amd64 or arm64"
    exit 1
fi

ARCH=$1

# Validate architecture argument
if [[ "$ARCH" != "amd64" && "$ARCH" != "arm64" ]]; then
    echo "Invalid architecture: $ARCH"
    echo "Please specify architecture: amd64 or arm64"
    exit 1
fi

echo "### Getting the binaries for $ARCH ... ###"
git clone --single-branch --branch binaries https://github.com/usnistgov/redledger-fabric.git temp_redledger_repo

# Check if the repository was cloned successfully
if [ $? -ne 0 ]; then
    echo "Failed to clone the repository."
    exit 1
fi

# Check if bin directory exists, create if not
if [ ! -d "bin" ]; then
    mkdir bin
fi

# Copy the binaries based on the architecture
cp -r temp_redledger_repo/bin/$ARCH/* bin/

# Clean up: Remove the temporary repository directory
rm -rf temp_redledger_repo

echo "### Binaries for $ARCH successfully pulled ###"

# Pull the Docker images
echo "### Getting the docker images for $ARCH ... ###"

if [ "$ARCH" == "amd64" ]; then
    docker pull csd773/redledger-fabric-peer
    docker pull csd773/redledger-fabric-orderer
    docker pull csd773/redledger-fabric-tools
    docker pull csd773/redledger-fabric-ca
    docker pull csd773/redledger-fabric-ccenv
    docker pull csd773/redledger-fabric-baseos
else
    docker pull csd773/redledger-fabric-peer-arm
    docker pull csd773/redledger-fabric-orderer-arm
    docker pull csd773/redledger-fabric-tools-arm
    docker pull csd773/redledger-fabric-ca-arm
    docker pull csd773/redledger-fabric-ccenv-arm
    docker pull csd773/redledger-fabric-baseos-arm
fi

echo "### Docker images for $ARCH successfully pulled ###"

# Update the network.sh script (optional)
echo "### Preparing to launch network ###"
cd test-network
echo "### Launching network with blockmatrix ledgertype ... ###"
./network.sh up createChannel -c mychannel -ca -l blockmatrix
echo "### Network launched successfully ###"