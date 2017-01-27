[ ![Codeship Status for rachelnicole/cs50-ascend](https://app.codeship.com/projects/2e799880-a2ce-0134-f153-76e92e43cf6d/status?branch=JD-Dev)](https://app.codeship.com/projects/190079)

## Continuous Delivery to Azure with Docker

To make it easy for you to deploy your application to Azure we’ve built a container that has the AzureCLI installed. We will set up a simple example showing you how to configure any deployment to Azure.

### Codeship Azure deployment container

The Azure deployment container lets you plugin your deployment tools without the need to include that in the testing or even production container. That keeps your containers small and focused on the specific task they need to accomplish in the build. By using the Azure deployment container you get the tools you need to deploy to any Azure service and still have the flexibility to adapt it to your needs.

We will use the microsoft/azure-cli docker image throughout the documentation to interact with various Azure services.

## Prerequisites

Prior to getting started, please ensure you have the following installed in your local linux/unix environment. 
- [Jet Codeship's CLI](https://documentation.codeship.com/pro/getting-started/installation/)
- [Docker](https://www.docker.com/products/overview)
- [Azure CLI](https://docs.microsoft.com/azure/xplat-cli-install)

### Using other tools

While the container we provide for interacting with Azure gives you an easy and straight forward way to run your deployments it is not the only way you can interact with Azure services. You can install your own dependencies, write your own deployment scripts, talk to the Azure API directly or bring 3rd party tools to do it for you. By installing those tools into a Docker container and running them you have a lot of flexibility in how to deploy to Azure.

### Authentication

Before setting up the codeship-services.yml and codeship-steps.yml file we’re going to create an encrypted environment file that contains a service principal, password, and tenant ID.

#### Azure Authentication
Take a look at CodeShip's [encrypted environment files documentation](https://documentation.codeship.com/pro/getting-started/encryption/) and add a azure.env.encrypted file to your repository. The file needs to contain an encrypted version of the following file:

```
spn=service_principal_name
password=service_principal_password
tenant=azure_tenant_id
```
You can get the spn, password, and tenant ID from running the [Service Principal Creation Script](local_scripts/create_serviceprincipal.sh) on your local machine with Azure-Cli installed.

To learn more about the script, [click here](local_scripts/create_serviceprincipal.md).

#### Virtual Machine Authentication

You will also need to create an encrypted environment file for the credentials to your Azure Docker Virtual Machine you will setup in the next step. We have generated a script to help you get started. You can run the [VM Credential Creation Script](local_scripts/create_vm_creds.sh) and it will generate something similar to the following:

```
adminusername=username_here
adminpassword=password_here
```

### Auzre Deployment Service Definition and Examples

Before reading through the documentation please take a look at the [Services](https://documentation.codeship.com/pro/getting-started/services/) and [Steps](https://documentation.codeship.com/pro/getting-started/steps/) documentation page so you have a good understanding how services and steps on Codeship work.

The codeship-services.yml file uses the microsoft/azure-cli container and sets the encrypted environment file created by running the Service Principal Creation Script. Additionally it sets the resource group name (resource) and location (location) through the environment config setting. We set up a volume that shares ./ (the repository folder) to /deploy. This gives us access to all files in the repository in /deploy/... for the following deployment step. Note: The following step only deploys out infrastrucutre in Azure with a pre-built Ubuntu 16.04 virtual machine and the Docker engine pre-configured.

```
azuredeployment:
  image: microsoft/azure-cli
  encrypted_env_file: azure.env.encrypted
  environment:
  - Resource=resource_group_name
  - Location=eastus
  volumes:
  - ./:/deploy
```

To interact with different Azure services you can simply call the Azure command directly. You can use any Azure service or command provided by the [AzureCLI](https://docs.microsoft.com/azure/xplat-cli-install). You can use environment variables or command arguments to set the Azure Datacentert Location or other parameters. Take a look at their (environment variable documentation](https://docs.microsoft.com/azure/azure-resource-manager/resource-group-authoring-templates).

Take a look at the [Steps](https://documentation.codeship.com/pro/getting-started/steps/) documentation page so you have a good understanding how steps on Codeship work and how to set it up in your codeship-steps.yml.

The following script will use the [Azure GitHub QuickStart Templates](https://github.com/Azure/azure-quickstart-templates) to deploy your new Docker virtual machine and resourece group. The deployment script can access any files in your repository through /deploy. To confirm, the [Azure Deployment Script](deployment/azure_deploy.sh), stands up an AzureRM resource group with all necessary dependencies for an Ubuntu 16.04 image with Docker pre-installed. 

Disclaimer: It is always recommended to read any script thoroughly before exectuting it in your environment. These scripts are provided for demo purposes only.

### Azure Docker App Deployment Service Definition and Examples

To interact with the new Docker VM on Azure you configured in the previous step, we will now create a second service to connect to the Docker engine and pass the appropriate commands. An example of the code we use is as follows:

```
azureappdeploy:
  build:
    image: alpine:latest
    dockerfile_path: deployment/Dockerfilessh
  encrypted_env_file: 
  - vm.env.encrypted
```
To interact with the service, we will create a step that will call the [Azure App Deployment Script](deployment/app_deploy.sh), which copies the repo's app folder from Codeship's host to the Docker VM in Azure. From there, we can use ssh to pass docker commands to build the image with our app and run the new image in a container accessible from the FQDN created in the previous step. At the end of the app deployment, you will also see the website where your webapp can be viewed. 

Note: The demo maps port 80:8080 for the node app running the container.

Disclaimer: It is always recommended to read any script thoroughly before exectuting it in your environment. These scripts are provided for demo purposes only.

### See also

- [Create a Docker environment in Azure using the Docker VM extension](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-linux-dockerextension)
 
