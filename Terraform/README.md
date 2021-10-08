# General Terraform Notes

Here are my general notes on Terraform as I come across items worth documenting.

## Azure Backend State

Backend states are required when working on Terraform from multiple locations or when using CI/CD. There are a few options for backend state including AWS, GCP, Azure, and hosted tools including Terraform Cloud. The state file can contain secrets so it should be protected and secured.

Here is the configuration for using a Storage Account as the backend state file location in Terraform

```bash
terraform {
  backend "azurerm" {
    resource_group_name  = "resource_group_name"
    storage_account_name = "storage_account_name"
    container_name       = "container_name"
    key                  = "dev.terraform.tfstate"
  }
}
```

The backend can also be configured from the command line, which is important when using CI/CD tools. The following file can be used to store the values of the backend state configuration:

```bash
#backend.hcl
resource_group_name  = "rg-terraformstate"
storage_account_name = "terrastatestorage2134"
container_name       = "terraformdemo"
key                  = "dev.terraform.tfstate"
```

The following is an example of using the configuration file in the terraform CLI

```bash
terraform init -backend-config=backend.hcl
```

Here is an example of using the Terraform CLI to configure the backend without the file:

```bash
terraform init \
    -backend-config="resource_group_name=rg-terraformstate" \
    -backend-config="storage_account_name=terrastatestorage2134" \
    -backend-config="container_name=terraformdemo" \
    -backend-config="key=dev.terraform.tfstate"
```

### Storage Account Configuration

The storage account used for the backend state should be configured to ensure the data is protected AND can be recovered if accidentally or intentionally deleted. If the state file is destroyed, it's very difficult to get the project back in sync. The script below will create a storage account, enable versioning, delete retention, TLS version, and HTTPS only.

```bash
az group create --location westus2 --name rg-terraformstate
az storage account create --name terrastatestorage2134 --resource-group rg-terraformstate --location westus2 --sku Standard_LRS
az storage account blob-service-properties update --enable-delete-retention true --enable-versioning true --name terrastatestorage2134 --resource-group rg-terraformstate 
az storage container create --name terraformdemo --account-name terrastatestorage2134 --min-tls-version TLS1_2 --https-only true
```

## Reading in data from a remote state

## Reading in JSON files

This might be required when wanting to read in configuration files or state files.

```bash
locals {
  json_data = jsondecode(file("./file.json"))
}

output "json" {
    value = local.json_data.path.to.object
}
```

## Output a template file

This might be useful when you want to output certain data to a separate file for consumption in the next stage of the process.

```bash
data "template_file" "render" {
  template = file("./templates/template.tpl")
  vars = {
    somedata = somevalue
  }
}

output "render" {
  value = data.template_file.render.rendered
}
```

Here is the template file example for some JSON

```bash
# ./templates/template.tpl
{
    "somedata": "${ somedata }"
}
```

## Randomly generate password

```bash
provider "random" {
}

resource "random_password" "windows_admin_password" {
  keepers = {
    resource_group = azurerm_resource_group.spoke.name # used to ensure the password does not rotate or get removed unless these resources are removed
  }
  length      = 10
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
}

# usage
admin_password = random_password.windows_admin_password.result
```

## Importing Resources

<https://www.terraform.io/docs/cli/commands/import.html>

```bash
terraform import module.foo.aws_instance.bar i-abcd1234
```