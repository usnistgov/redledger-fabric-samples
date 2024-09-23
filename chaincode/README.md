1. Go to your root repository, example:

 Users\scc7\GolandProjects\redledger-samples\basic

2. Place yourself in the network folder:
	
	cd ./network

3. Start network:
	
	./network.sh up

4. Create Channel:
	
	./network.sh createChannel -c dbmchannel -l blockmatrix

5. Before we package the chaincode, we need to install the chaincode dependences. Navigate to the folder that contains the Go version of the asset-transfer (basic) chaincode:

	cd ../chaincode

6. To install the smart contract dependencies, run the following command from the chaincode directory:

	GO111MODULE=on go mod vendor

	cd ../network

7. You can use the peer CLI to create a chaincode package in the required format. The peer binaries are located in the bin folder of the fabric-samples repository. Use the following command to add those binaries to your CLI Path:

	export PATH=${PWD}/../bin:$PATH

8. You also need to set the FABRIC_CFG_PATH to point to the core.yaml file in the config repository:

	export FABRIC_CFG_PATH=$PWD/../config/

To confirm that you are able to use the peer CLI, check the version of the binaries. The binaries need to be version 2.0.0 or later to run this tutorial:
	
	peer version

9. You can now create the chaincode package using the peer lifecycle chaincode package command:

	peer lifecycle chaincode package DBM-chaincode.tar.gz --path ../chaincode/ --lang golang --label basic_1.0

	

10. After we package the smart contract, we can install the chaincode on our peers. The chaincode needs to be installed on every peer that will endorse a transaction. Because we are going to set the endorsement policy to require endorsements from both Org1 and Org2, we need to install the chaincode on the peers operated by both organizations:
•	peer0.org1.example.com
•	peer0.org2.example.com
Let’s install the chaincode on the Org1 peer first. Set the following environment variables to operate the peer CLI as the Org1 admin user. The CORE_PEER_ADDRESS will be set to point to the Org1 peer, peer0.org1.example.com:

	export CORE_PEER_TLS_ENABLED=true
	export CORE_PEER_LOCALMSPID="Org1MSP"
	export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
	export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
	export CORE_PEER_ADDRESS=localhost:7051

Issue the peer lifecycle chaincode install command to install the chaincode on the peer:

	peer lifecycle chaincode install DBM-chaincode.tar.gz

If the command is successful, the peer will generate and return the package identifier. This package ID (DIFFERENT FOR EVERYONE) will be used to approve the chaincode in the next step. 

11. We can now install the chaincode on the Org2 peer. Set the following environment variables to operate as the Org2 admin and target the Org2 peer, peer0.org2.example.com.
	
	export CORE_PEER_TLS_ENABLED=true
	export CORE_PEER_LOCALMSPID="Org2MSP"
	export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
	export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
	export CORE_PEER_ADDRESS=localhost:9051

Issue the following command to install the chaincode:
	
	peer lifecycle chaincode install DBM-chaincode.tar.gz


12. Command to deply the chaincode on the channel defined before:

	./network.sh deployCC -ccn DBM-chaincode -ccp ../chaincode -ccl go -c dbmchannel 

13. Invoke the chaincode:

	peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C dbmchannel -n DBM-chaincode --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt -c '{"function":"Put","Args":["[{\"Key\":\"key1\",\"Value\":\"value1\"}]"]}'