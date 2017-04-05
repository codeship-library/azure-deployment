#!/bin/bash
#
# Run the create_vm_creds.sh script locally prior to running this file.

#login
    az login \
        --service-principal \
        -u $spn \
        -p $password \
        --tenant $tenant

# Group creation
    az group create \
        -l $Location \
        -n $Resource
    echo "Created Resource Group:" $Resource

    echo "Beginning Azure Container Service creation now. Please note this can take more than 20 minutes to complete."
# ACS Creation for Docker Swarm
    az acs create \
        -g $Resource \
        -n $Servicename \
        -d $Dnsprefix \
        --orchestrator-type $Orchestrator \
        --service-principal $spn \
        --client-secret $password \
        --generate-ssh-keys \
        --verbose

# Space for readabilty
    echo

# Copy Private Key to host from container and to .gitignore
    cp /root/.ssh/id_rsa /deploy/id_rsa
    echo id_rsa >> /deploy/.gitignore

# Outputs
    # Code to capture ACS master info
        master_fqdn=$(az acs show -n $Servicename -g $Resource | jq -r '.masterProfile | .fqdn')

    # Set ssh connection string addt'l info
        admin_username=$(az acs show -n $Servicename -g $Resource | jq -r '.linuxProfile.adminUsername')

    # Print results 
        echo "------------------------------------------------------------------"
        echo "Important information:"
        echo 
        echo "SSH Connection String: ssh $admin_username@$master_fqdn -A -p 2200"
        echo "Master FQDN: $master_fqdn"
        echo "Your web applications can be viewed at $master_fqdn."
        echo "------------------------------------------------------------------"