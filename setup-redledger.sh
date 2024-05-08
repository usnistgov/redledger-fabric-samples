# Clone the redledger-fabric repository
echo "### Getting the binaries ... ###"
git clone --single-branch --branch binaries https://github.com/usnistgov/redledger-fabric.git temp_redledger_repo

# Check if the repository was cloned successfully
if [ $? -ne 0 ]; then
    echo "Failed to clone the repository."
    exit 1
fi
# Copy the entire bin directory from temp_redledger_repo to redledger-fabric-samples
cp -r temp_redledger_repo/bin bin/
# Maybe need to mkdir bin

# Clean up: Remove the temporary repository directory
rm -rf /path/to/temp_redledger_repo

echo "### Binaries successfully pulled ###"


# Pull the Docker images
# Need to find a way to specify that it needs to pull the ARM images
echo "### Getting the docker images ... ###"
docker pull csd773/redledger-fabric-peer
docker pull csd773/redledger-fabric-orderer
docker pull csd773/redledger-fabric-tools
docker pull csd773/redledger-fabric-ca
docker pull csd773/redledger-fabric-ccenv
docker pull csd773/redledger-fabric-baseos

echo "### Docker images successfully pulled ###"
# Need to update the network.sh script with the environment variable pointing at redledger ones instead of hyperledger
# Need to update the network.sh script to include the ledgertype. Refer to this commit : https://github.com/usnistgov/redledger-fabric-samples/commit/8ff57cef2cc973a70c63ffe56b2b6ccf963e072f

Launch the test network
echo "### Preparing to launch network ###"
cd test-network
echo "### launching network with blockmatrix ledgertype .. ###"
./network.sh up createChannel -c mychannel -ca -l blockmatrix
echo "### Shutting down the network ###"
./network.sh down


# Need some testing 