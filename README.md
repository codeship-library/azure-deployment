## Continuous Delivery to Azure with Kubernetes

To make it easy for you to deploy your application to Azure we’ve built a container that has the AzureCLI installed. We will set up a simple example showing you how to configure any deployment to Azure.

For information about prerequisites and authentication, please review: [Codeship2.0/README.md](../README.md)

### Azure Container Service Deployment Examples

Before reading through the documentation please take a look at the [Services](https://documentation.codeship.com/pro/getting-started/services/) and [Steps](https://documentation.codeship.com/pro/getting-started/steps/) documentation page so you have a good understanding how services and steps on Codeship work.

The codeship-services.yml file uses the azuresdk/azure-cli-python container and sets the encrypted environment file created by running the Service Principal Creation Script. Additionally it sets the resource group name (resource) and location (location) through the environment config setting. We set up a volume that shares ./ (the repository folder) to /deploy. This gives us access to all files in the repository in /deploy/... for the following deployment step. Note: The following step only deploys out an Azure Container Service instance for Kubernetes.

```
k8acsdeploy:
  image: azuresdk/azure-cli-python:latest
  encrypted_env_file: azure.env.encrypted
  environment:
  - Resource=Codeshipk8
  - Location=eastus
  - Servicename=K8Demo
  - Orchestrator=kubernetes
  - Dnsprefix=k8acs001
  volumes:
  - ./:/deploy
```

To interact with different Azure services you can simply call the Azure command directly. You can use any Azure service or command provided by [Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli). You can use environment variables or command arguments to set the Azure Datacenter Location or other parameters. Take a look at the [command line reference for Azure CLI 2.0](https://docs.microsoft.com/en-us/cli/azure/) to get started.   

Take a look at the [Steps](https://documentation.codeship.com/pro/getting-started/steps/) documentation page so you have a good understanding how steps on Codeship work and how to set it up in your codeship-steps.yml.

The following script will deploy your new Azure Container Service environment with Kubernetes as your orchestrator. The deployment script can access any files in your repository through /deploy. To confirm, the [Azure Deployment Script](scripts/k8_acs_deploy.sh), stands up an Azure Container Service resource group for Kubernetes. 

Disclaimer: It is always recommended to read any script thoroughly before executing it in your environment. These scripts are provided for demo purposes only.

#### By default, and unless otherwise instructed to with the appropriate switch, ACS provisions clusters with a single master and 3 agents. All of them use D2 by default, so it will be quite an expensive cluster, be careful and cleanup resources when you do not need them.

### Azure Kubernetes App Deployment Service Definition and Examples

To interact with the ACS Kubernetes instance you configured in the previous step, we will now create a second service to connect using kubectrl passing the appropriate commands. An example of the code we use is as follows:

```
kubectl:
  build:
    image: kubectl
    dockerfile_path: Dockerfile
    add_docker: true
  encrypted_env_file: azure.env.encrypted
  environment: 
  - Servicename=K8Demo
  - Resource=Codeshipk8
  - Orchestrator=kubernetes
```
To interact with the service, we will create a step that will execute the build of the image using the supplied [Dockerfile](./Dockerfile). The Dockerfile will copy the repo's app folder so it can be used for build and deployment in the ACS Kubernetes Cluster. From there, the Dockerfile will also establish a connection using [Kubectrl](https://docs.microsoft.com/en-us/azure/container-service/container-service-kubernetes-walkthrough) we can use to pass commands to build the image with our app. At the end of the app deployment, you will also see the website where your webapp can be viewed. One example of our steps file to pass multiple docker commands is as follows:

```
- type: serial
  name: KubeCtrl
  service: kubectl
  steps:
  - command: kubectl get nodes
```

Note: This can be modified to deploy pods to the K8 cluster.

Disclaimer: It is always recommended to read any script thoroughly before executing it in your environment. These scripts are provided for demo purposes only.

### See also

- [Deploy a Docker container hosting solution using the Azure portal](https://docs.microsoft.com/en-us/azure/container-service/container-service-deployment)
- [Deploy a Docker container hosting solution using the Azure CLI 2.0](https://docs.microsoft.com/en-us/azure/container-service/container-service-create-acs-cluster-cli)