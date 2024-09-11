# Redledger Setup on PI

## Setup

1. Install git, and docker on the PI 
(Maybe some operations to do with the login for docker)

2. Clone this repository 
```
    git clone --single-branch --branch redledger-setup-pi https://github.com/usnistgov/redledger-fabric.git 
```
(maybe add the name of the directory at the end of this command)

3. launch the setup script
```
    cd redledger-fabric
    ./setup-redledger.sh
```

4. Check if any erros appears
