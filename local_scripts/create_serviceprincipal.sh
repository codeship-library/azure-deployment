#!/bin/bash
#
# Run this script LOCALLY before any other script, run by typing ./serviceprincipal.sh id password role
# To view the available roles, see https://docs.microsoft.com/azure/active-directory/role-based-access-built-in-roles Default recommended is Contributor, which can manage everything except access

# Positional Parameters
id="$1"
password="$2" 
role="$3"
# Login - Complete this process using a browser
#azure login

# Capture tenant ID
tenant=$(azure account show | grep "Tenant ID" | awk '{print $NF}')

# Begin AD Service Principal Creation 
azure ad sp create -n $id -p $password

# Capture spn in variable
spn=$(azure ad sp show -c $id --json | jq -r '.[].appId')
echo "Your Service Principal Name is $spn."

sleep 2

# Create a role assignment
azure role assignment create --spn "$spn" -o "$role"

# Output service principal
echo "Successfully created Service Principal."
echo "==============Created Serivce Principal=============="
echo "spn=$spn" 
echo "password=$password"
echo "tenant=$tenant"

# Copy service principal to environment variables file
echo '# azure serivce principal auth
spn='$spn'
password='$password'
tenant='$tenant'
' > azure.env
echo "azure.env created"

# Add azure.env to .gitignore
echo "azure.env" >> .gitignore
echo "azure.env copied to .gitignore"

# Encrypt azure.env using CodeShip Jet
# jet encrypt [--key-path=codeship.aes] plain_file encrypted_file
jet encrypt azure.env azure.env.encrypted
