#!/bin/bash
echo "### Cloning the Redledger Fabric repository ... ###"
git clone -b redledger-main https://github.com/usnistgov/redledger-fabric.git
echo "### Changing directory ... ###"
cd redledger-fabric
echo "### cleaning the environment ###"
make clean-all
echo "### Pulling the docker images ###" 
make docker
echo "### Creating the Redledger fabric binaries ###"
make native 
echo "### TODO :Checking if the binaries are created ###"
cd ..
echo "### Installing the fabric samples repository ###"
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
echo "### launching install fabric to get binaries and docker images v 2.4.8 to interact with the test-nertwork ###"
./install-fabric.sh -f 2.4.8 binary docker
echo "### Replacing binaries from redledger-fabric-samples with those from redledger-fabric ###"
find bin/ -type f -not -name 'fabric*' -exec rm {} \;
cp -r redledger-fabric/build/bin/ bin/
echo "### Preparing to launch network ###"
cd test-network
echo "### launching network with blockmatrix ledgertype ###"
./network.sh up createChannel -c mychannel -ca -l blockmatrix
