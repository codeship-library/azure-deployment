## Create Azure Service Principal for Authentication

To make it easy for you to deploy your application to Azure, we've built a script to create an Azure Service Principal for use with CodeShip.

## Pre-requisites

In order to encrypt the azure authentication file, you will need to [install the CodeShip jet CLI locally first](https://documentation.codeship.com/pro/getting-started/installation/).

After you install the jet CLI, you will need to get you CodeShip AES key.

### Getting the key

#### Codeship.com

## 

If you have a project on https://codeship.com, head over to the _General_ page of your project settings and you’ll find a section labeled _AES Key_which allows you to either copy or download the key.

Save that file as codeship.aes in your repository root and don’t forget to add the key to your .gitignore file so you don’t accidentally commit it to your repository.

```
echo "KEY_COPIED_FROM_CODESHIP.COM" > codeship.aes

echo "codeship.aes" >> .gitignore
```

## Service Principal Creation and Authentication

In order to login to Azure using a service principal, we use the following comand:

```
azure login -u $spn -p $password --tenant $tenant --service-principal
```

You can either pass the command through using the codeship-steps.yml file, or you can include it in a shell script. However, in order for it to work, you first need to create the service principal and store the variables in a file in your repository.

The file needs to contain an encrypted version of the following file:

```
spn=service_principal_name
password=service_principal_password
tenant=azure_tenant_id
```

To help you get started, we have created a [Service Principal Creation Script](https://raw.githubusercontent.com/rachelnicole/cs50-ascend/JD-Dev/scripts/serviceprincipal.sh?token=AHUhNhoZGTiIPgVKCyAtyY1EmnJFj14Zks5Ydv7bwA%3D%3D), which needs to be run on your local machine. You will also need to have [Azure CLI](https://docs.microsoft.com/azure/xplat-cli-install) installed. 

To run the script save it to the root of your repository and give it executable permissions:

```
chmod +x serviceprincipal.sh
```

Then run the script: 
```
./serviceprincipal.sh id_name_here password_here role_here
```

id_name_here - Name of Service Principal (for your reference only)

password_here - Password for service principal created

role_here - Desired role see [RBAC: Built-in roles](https://docs.microsoft.com/azure/active-directory/role-based-access-built-in-roles)

Example:

```
./serviceprincipal.sh AzureDemo PasswOrd!! Contributor
```

The spn creation script will create a service principal for you and assign it the role of Contributor. The script will then encrypt the environment file containing the service principal, password, and tenant ID for your Azure subscription for you and add the unencrypted one to your .gitignore file.

The unencrypted environment file will be saved as azure.env.

The encrypted environment file will be saved as azure.env.encrypted.

## See Also:

- [Use Azure CLI to create a service principal to access resources](https://docs.microsoft.com/azure/azure-resource-manager/resource-group-authenticate-service-principal-cli)
- [Use portal to create Active Directory application and service principal that can access resources](https://docs.microsoft.com/azure/azure-resource-manager/resource-group-create-service-principal-portal)
- [Manage Role-Based Access Control with the Azure command-line interface](https://docs.microsoft.com/azure/active-directory/role-based-access-control-manage-access-azure-cli)
- [RBAC: Built-in roles](https://docs.microsoft.com/azure/active-directory/role-based-access-built-in-roles)




