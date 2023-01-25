How to build the redledger binaries and docker images.

1. Clone the repository using the command "git clone" https://github.com/usnistgov/redledger-fabric

2. run "make native docker" from the root.

It will create a "build" folder with the binaries and will install the docker images on your machine.

4. Copy the new binaries created in the bin folder and paste them in redledger-samples/basic/bin

5. Now you can start your network and create channels from the redledger-samples repository.


How to get the fabric-ca-server and fabric-ca-client executables and docker images.

1. Clone the repository using the command "git clone" https://github.com/hyperledger/fabric-ca

2. run "make native docker" from the root.

It will create a "bin" folder with the binaries and will install the docker images on your machine.

4. Copy the new binaries created in the bin folder and paste them in redledger-samples/basic/bin

5. Now you can start your network and create channels from the redledger-samples repository.