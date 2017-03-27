[ ![Codeship Status for jldeen/codeship2.0](https://app.codeship.com/projects/2cad1f50-ebdf-0134-1415-52722a5ec4af/status?branch=master)](https://app.codeship.com/projects/208179)

## Continuous Delivery to Azure with Docker

To make it easy for you to deploy your application to Azure we’ve built a container that has the AzureCLI installed. We will set up a simple example showing you how to configure any deployment to Azure.

### Codeship Azure deployment container

The Azure deployment container lets you plugin your deployment tools without the need to include that in the testing or even production container. That keeps your containers small and focused on the specific task they need to accomplish in the build. By using the Azure deployment container you get the tools you need to deploy to any Azure service and still have the flexibility to adapt it to your needs.

We will use the microsoft/azure-cli docker image throughout the documentation to interact with various Azure services.

## Prerequisites

Prior to getting started, please ensure you have the following installed in your local linux/unix environment.
- [Docker](https://www.docker.com/products/overview) (Optional but highly recommended if you plan to test your codeship-steps and codeship-services.yml files locally)
- [Jet Codeship's CLI](https://documentation.codeship.com/pro/getting-started/installation/)
- [Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Git](https://git-scm.com/downloads)
- [JQ 1.5 or higher](https://stedolan.github.io/jq/)

It is strongly recommended to fork this repo, or download the files separately.

#### You will need to connect your own repo to Codeship pro in order to use this Azure Deployment Demo.

### Using other tools

While the container we provide for interacting with Azure gives you an easy and straight forward way to run your deployments it is not the only way you can interact with Azure services. You can install your own dependencies, write your own deployment scripts, talk to the Azure API directly or bring 3rd party tools to do it for you. By installing those tools into a Docker container and running them you have a lot of flexibility in how to deploy to Azure.

### Authentication

Before setting up the codeship-services.yml and codeship-steps.yml file we’re going to create an encrypted environment file that contains a service principal, password, and tenant ID.

You will first need to get your AES key from Codeship to encrypt your environment files. Take a look at CodeShip's [encrypted environment files documentation](https://documentation.codeship.com/pro/getting-started/encryption/), specifically the 'Getting the Key' section and download/save the key as 'codeship.aes'. Next, you need to add it to your .gitnore file by typing the following.

```
echo "codeship.aes" >> .gitignore
```

#### Azure Authentication
We have created a script to help you get started after you obtain your AES key from Codeship. The azure.env file needs to contain an encrypted version of the following data:

```
spn=service_principal_name
password=service_principal_password
tenant=azure_tenant_id
```
You can get the spn, password, and tenant ID from running the [Service Principal Creation Script](local_scripts/create_serviceprincipal.sh) on your local machine with Azure-Cli installed. You do not have to add the .env files to your .gitignore file as the creation script will do so for you.

It is higly recommended you  [click here](local_scripts/create_serviceprincipal.md) to learn how to use the service principal creation script.

### Azure Container Service Deployment Examples

Before reading through the documentation please take a look at the [Services](https://documentation.codeship.com/pro/getting-started/services/) and [Steps](https://documentation.codeship.com/pro/getting-started/steps/) documentation page so you have a good understanding how services and steps on Codeship work.

The codeship-services.yml file uses the azuresdk/azure-cli-python container and sets the encrypted environment file created by running the Service Principal Creation Script. Additionally it sets the resource group name (resource) and location (location) through the environment config setting. We set up a volume that shares ./ (the repository folder) to /deploy. This gives us access to all files in the repository in /deploy/... for the following deployment step. Note: The following step only deploys out an Azure Container Service instance for Docker Swarm Azure.

```
acsdeploy:
  image: azuresdk/azure-cli-python:latest
  encrypted_env_file: azure.env.encrypted
  environment:
  - Resource=Codeshipaz
  - Location=eastus
  - Servicename=ACSJDDemo
  - Orchestrator=Swarm
  - Dnsprefix=jdacs2
  volumes:
  - ./:/deploy
```

To interact with different Azure services you can simply call the Azure command directly. You can use any Azure service or command provided by [Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli). You can use environment variables or command arguments to set the Azure Datacenter Location or other parameters. Take a look at the [command line reference for Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/) to get started.   

Take a look at the [Steps](https://documentation.codeship.com/pro/getting-started/steps/) documentation page so you have a good understanding how steps on Codeship work and how to set it up in your codeship-steps.yml.

The following script will deploy your new Azure Container Service environment with Docker Swarm as your orchestrator. The deployment script can access any files in your repository through /deploy. To confirm, the [Azure Deployment Script](deployment/acs_deploy.sh), stands up an Azure Container Service resource group for Docker Swarm. 

Disclaimer: It is always recommended to read any script thoroughly before executing it in your environment. These scripts are provided for demo purposes only.

#### By default, and unless otherwise instructed to with the appropriate switch, ACS provisions clusters with a single master and 3 agents. All of them use D2 by default, so it will be quite an expensive cluster, be careful and cleanup resources when you do not need them.

### Azure Docker App Deployment Service Definition and Examples

To interact with the ACS Docker Swarm instance you configured in the previous step, we will now create a second service to connect to the Docker engine and pass the appropriate commands. An example of the code we use is as follows:

```
sshtunnel:
  build:
    image: sshtunnel
    dockerfile_path: sshtunnel/Dockerfile
    add_docker: true
  encrypted_env_file: azure.env.encrypted
  environment: 
  - Servicename=ACSJDDemo
  - Resource=Codeshipaz
  - Orchestrator=Swarm
  - local_port=2375
  - remote_port=2375
```
To interact with the service, we will create a step that will execute the build of the image using the supplied [Dockerfile](sshtunnel/Dockerfile). The Dockerfile will copy the private key generated in the first step so it can be used to establish the [SSH Tunnel](https://docs.microsoft.com/en-us/azure/container-service/container-service-connect) to the ACS Docker Swarm Cluster. We can then pass docker commands directly from our codeship-steps.yml file since our service is using the tunnel. At the end of each command execution, you will also see the website where your webapps can be viewed. One example of our steps file to pass multiple docker commands is as follows:

```
- type: serial
  name: SSH Tunnel
  service: sshtunnel
  steps:
  - command: docker run -d --name docker-nginx -p 80:80 nginx
  - command: docker ps -a
  - command: docker run -d --name node-demo -p 8080:8000 jldeen/node-demo
  - command: docker ps -a
```

Note: The demo maps port 80:8000 for the node app running the container. For the second example, node-demo, we built our app and pushed to a public repo our swarm cluster can pull from.

Another example of our steps file to run a simple nginx webserver, without serial steps, is as follows:
```
- name: SSH Tunnel
  service: sshtunnel
  command: docker run -d --name docker-nginx -p 80:80 nginx
```

Disclaimer: It is always recommended to read any script thoroughly before executing it in your environment. These scripts are provided for demo purposes only.

### See also

- [Deploy a Docker container hosting solution using the Azure portal](https://docs.microsoft.com/en-us/azure/container-service/container-service-deployment)
- [Deploy a Docker container hosting solution using the Azure CLI 2.0](https://docs.microsoft.com/en-us/azure/container-service/container-service-create-acs-cluster-cli)