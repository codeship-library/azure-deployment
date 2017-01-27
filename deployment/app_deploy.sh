#!/bin/bash

# Copy files from local container to remote Azure Docker Engine
sshpass -p $adminpassword scp -o StrictHostKeyChecking=no -r app $adminusername@$(cat fqdn):/home/$adminusername && echo 'app folder copied successfully'

# Temp check to ensure docker app runs in remote azure container
#sshpass -p $adminpassword ssh -o StrictHostKeyChecking=no $adminusername@$(cat fqdn) 'docker run -d -p 80:80 nginx'

# Change directory to app folder, build test node app, run node app and check output
sshpass -p $adminpassword ssh -o StrictHostKeyChecking=no $adminusername@$(cat fqdn) 'cd ~/app ; docker build -t csazure . ; docker run -p 80:8000 -d csazure ; docker ps'

# Output to end user
echo "Your web application can now be viewed at" $(cat fqdn)