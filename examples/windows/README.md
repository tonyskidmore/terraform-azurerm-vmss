# Azure Virtual Machine Scale Set

Example of creating a Windows Azure VMSS.

The example shows how various deployment setting options _could_ be used to piece together an installation mechanism on Windows in Azure.
It serves as an example of using the [Custom Script Extension (CSE)](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows), [custom_data](https://learn.microsoft.com/en-us/azure/virtual-machines/custom-data#pass-custom-data-to-the-vm), [IMDS](https://learn.microsoft.com/en-us/azure/virtual-machines/instance-metadata-service) and [user_data](https://learn.microsoft.com/en-us/azure/virtual-machines/user-data) together

The files that are used are listed in the table below.

| Module file resource             | Description                                                                                              |
|----------------------------------|----------------------------------------------------------------------------------------------------------|
| scripts/Set-VmssConfig.ps1       | An example PowerShell script with functions for installing tools, it is created as `custom_data`         |
| scripts/Start-VmssConfig.ps1     | A PowerShell script that takes the custom_data and executes it by means of the CSE                       |
| examples/windows/user_data.json  | A JSON file that contains instructions on which installer functions should be run, passed as `user_data` |

_Note:_  Adding tools during instance deployment extends the time it takes an instance to come ready, at some point a custom image with all requirements baked in becomes a better option.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | >=3.1.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | 3.83.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| vmss | tonyskidmore/vmss/azurerm | 0.4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | Map of the tags to use for the resources that are deployed | `map(string)` | <pre>{<br>  "environment": "test",<br>  "project": "vmss"<br>}</pre> | no |
| vmss\_admin\_password | Password to allocate to the admin user account | `string` | n/a | yes |
| vmss\_computer\_name\_prefix | The prefix which should be used for the name of the Virtual Machines in this Scale Set | `string` | `null` | no |
| vmss\_location | Azure location | `string` | n/a | yes |
| vmss\_name | Name of the Virtual Machine Scale Set to create | `string` | n/a | yes |
| vmss\_os | Whether to deploy a Linux or Windows Virtual Machine Scale Set resource | `string` | n/a | yes |
| vmss\_resource\_group\_name | Existing resource group name of where the VMSS will be created | `string` | n/a | yes |
| vmss\_se\_enabled | Whether to process the Linux Virtual Machine Scale Set extension resource | `bool` | `false` | no |
| vmss\_subnet\_address\_prefixes | Subnet address prefixes | `list(string)` | n/a | yes |
| vmss\_subnet\_name | Name of subnet where the vmss will be connected | `string` | n/a | yes |
| vmss\_vnet\_address\_space | Vnet network address spaces | `list(string)` | n/a | yes |
| vmss\_vnet\_name | Name of the Vnet that the target subnet is a member of | `string` | n/a | yes |
| vmss\_win\_se\_settings | The value to pass to the Windows VMSS custom script extension | `string` | `null` | no |
| vmss\_win\_se\_settings\_data | The base64 encoded data to use as the script for the Windows VMSS custom script extension | `string` | `"scripts/Set-VmssConfig.ps1"` | no |
| vmss\_win\_se\_settings\_script | The path of the file to use as the script for the Windows VMSS custom script extension | `string` | `"scripts/Start-VmssConfig.ps1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| vmss\_id | Virtual Machine Scale Set ID |



Example

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vmss" {
  name     = var.vmss_resource_group_name
  location = var.vmss_location
}

resource "azurerm_virtual_network" "vmss" {
  name                = var.vmss_vnet_name
  resource_group_name = azurerm_resource_group.vmss.name
  address_space       = var.vmss_vnet_address_space
  location            = azurerm_resource_group.vmss.location
  tags                = var.tags
}

resource "azurerm_subnet" "agents" {
  name                 = var.vmss_subnet_name
  resource_group_name  = azurerm_resource_group.vmss.name
  address_prefixes     = var.vmss_subnet_address_prefixes
  virtual_network_name = azurerm_virtual_network.vmss.name
}

module "vmss" {
  source                    = "tonyskidmore/vmss/azurerm"
  version                   = "0.4.0"
  vmss_os                   = var.vmss_os
  vmss_name                 = var.vmss_name
  vmss_computer_name_prefix = var.vmss_computer_name_prefix
  vmss_resource_group_name  = var.vmss_resource_group_name
  vmss_subnet_id            = azurerm_subnet.agents.id
  vmss_admin_password       = var.vmss_admin_password
  vmss_se_enabled           = var.vmss_se_enabled
  # passing user_data that contains a JSON configuration for installs
  vmss_user_data              = filebase64("${path.module}/user_data.json")
  vmss_win_se_settings_script = var.vmss_win_se_settings_script
  vmss_win_se_settings_data   = var.vmss_win_se_settings_data
  vmss_win_se_settings        = var.vmss_win_se_settings
}
```
<!-- END_TF_DOCS -->
