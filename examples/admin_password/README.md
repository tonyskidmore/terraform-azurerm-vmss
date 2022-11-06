# Azure Virtual Machine Scale Set

Example of creating an Azure VMSS with instances configured with an
administrator password as opposed to an SSH key pair
(SSH key pair is recommended).

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | >=3.1.0 |
## Providers

| Name | Version |
|------|---------|
| azurerm | 3.29.1 |
## Modules

| Name | Source | Version |
|------|--------|---------|
| vmss | tonyskidmore/vmss/azurerm | 0.2.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | Map of the tags to use for the resources that are deployed | `map(string)` | <pre>{<br>  "environment": "test",<br>  "project": "vmss"<br>}</pre> | no |
| vmss\_admin\_password | Password to allocate to the admin user account | `string` | n/a | yes |
| vmss\_name | Name of the Virtual Machine Scale Set to create | `string` | n/a | yes |
| vmss\_resource\_group\_name | Existing resource group name of where the VMSS will be created | `string` | n/a | yes |
| vmss\_subnet\_address\_prefixes | Subnet address prefixes | `list(string)` | n/a | yes |
| vmss\_subnet\_name | Name of subnet where the vmss will be connected | `string` | n/a | yes |
| vmss\_vnet\_address\_space | Vnet network address spaces | `list(string)` | n/a | yes |
| vmss\_vnet\_name | Name of the Vnet that the target subnet is a member of | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| vmss\_id | Virtual Machine Scale Set ID |

Example

```hcl
provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "vmss" {
  name = var.vmss_resource_group_name
}

resource "azurerm_virtual_network" "vmss" {
  name                = var.vmss_vnet_name
  resource_group_name = data.azurerm_resource_group.vmss.name
  address_space       = var.vmss_vnet_address_space
  location            = data.azurerm_resource_group.vmss.location
  tags                = var.tags
}

resource "azurerm_subnet" "agents" {
  name                 = var.vmss_subnet_name
  resource_group_name  = data.azurerm_resource_group.vmss.name
  address_prefixes     = var.vmss_subnet_address_prefixes
  virtual_network_name = azurerm_virtual_network.vmss.name
}

module "vmss" {
  source                   = "tonyskidmore/vmss/azurerm"
  version                  = "0.2.0"
  vmss_name                = var.vmss_name
  vmss_resource_group_name = var.vmss_resource_group_name
  vmss_subnet_id           = azurerm_subnet.agents.id
  vmss_admin_password      = var.vmss_admin_password
}
```
<!-- END_TF_DOCS -->
