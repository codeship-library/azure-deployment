#!/bin/bash
# This file will create an adminusername and adminpassword for use with Azure_Deploy.sh
# Run by typing ./create_vm_creds.sh admin_username admin_password

# Positional Parameters
adminusername="$1"
adminpassword="$2" 

# Write Parameters to vm.env file
echo 'adminusername='$1'
adminpassword='$2'
' > vm.env
echo "vm.env created"

# Add azure.env to .gitignore
echo "vm.env" >> .gitignore
echo "vm.env copied to .gitignore"

# Encrypt vm.env using CodeShip Jet
# jet encrypt [--key-path=codeship.aes] plain_file encrypted_file
jet encrypt vm.env vm.env.encrypted
echo "vm.env.encrypted created successfully "