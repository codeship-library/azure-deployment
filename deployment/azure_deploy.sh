#!/bin/bash
#
# Run the create_vm_creds.sh script locally prior to running this file.

# Azure login
azure login -u $spn -p $password --tenant $tenant --service-principal

# Hardcoded variables
Template=https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/docker-simple-on-ubuntu/azuredeploy.json
deploymentName=TestDeploy
paramFile=DockerDeploy.parameters.json
dnspre=cs50-az

# Parameter variables
storageacctname=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n 1)
dnsname=$dnspre$(cat /dev/urandom | tr -dc 'a-z0-9' | head -c 4)


# Create Resource Group
azure group create $Resource $Location
echo "Created Resource Group:" $Resource

# Create Docker Deployment Parameters JSON File
echo '{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "newStorageAccountName": {
      "value": "'$storageacctname'"
    },
    "adminUsername": {
      "value": "'$adminusername'"
    },
    "adminPassword": {
      "value": "'$adminpassword'"
    },
    "dnsNameForPublicIP": {
      "value": "'$dnsname'"
    },
    "ubuntuOSVersion": {
      "value": "16.04.0-LTS"
    }
  }
}
' > DockerDeploy.parameters.json
echo "Created Docker Deploy Parameters File"

# Initiate Resource Group Deployment
azure group deployment create -g $Resource -f $Template -e $paramFile $deploymentName

# Grab the fully qualified domain name in an environment variable
fqdn=$dnsname.$Location.cloudapp.azure.com

# Copy FQDN to host from container and to .gitignore
echo $fqdn > /deploy/fqdn
echo fqdn >> /deploy/.gitignore

# Confirm FQDN is captured and print to screen
echo "Your fully qualified domain name is $fqdn"