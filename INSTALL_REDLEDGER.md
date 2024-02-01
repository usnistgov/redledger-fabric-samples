# How to use Redledger blockmatrix binaries
This document explains how to use the blockmatrix ledger type. 

## Building Redledger binaries
In the redledger-fabric repository (after cloning it), use this command to produce the binaries : 

```
$ make clean-all docker native 
```
It should produce 8 binaries files under the `build/bin` folder. 

## Setting up the Redledger-Fabric-Samples 
First thing is to clone the project with this command : 

```
$ git clone https://github.com/usnistgov/redledger-fabric-samples.git
```

Then, 

```
$ cd redledger-fabric-samples
```

Inside this directory, import the install fabric script : 

```
$ curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
```

It should add the script file `install-fabric.sh`. As we only need the binaries and the docker images, we will execute this command (version > 2.4.8 are not stable): 

```
$ ./install-fabric.sh -f 2.4.8 binary docker 
```

It should install the binaries under the `bin` folder, some config files, and also pulled the docker images necessaries to interact with the **test-network**.

Next, you have to replace all the binaries except **fabric-ca-client** and **fabric-ca-server** with the ones created in the previous step for the Redledger-Fabric. 

## Launch the test network

To launch the test network and use the blockmatrix ledger type, enter :

```
$ ./network.sh up createChannel -c mychannel -ca -l blockmatrix
```


## Troubleshooting

A lot of problems can occur during this steps. One common solution is usually to bring down the network by entering : 

```
$ ./network.sh down
```


# Next steps
 - [ ] Write a script that automatize the process described above. 

