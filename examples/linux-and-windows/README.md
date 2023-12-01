# Azure Virtual Machine Scale Set

Example of creating both Windows Server 2019 and Ubuntu Linux 22.04 Azure VMSS with the Azure CLI installed on both.

For Linux the Azure CLI will be installed with `cloud-init` and for Windows the Custom Script Extension is used, along with some supplied custom settings.

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
| vmss | ../../ | n/a |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | Map of the tags to use for the resources that are deployed | `map(string)` | <pre>{<br>  "environment": "test",<br>  "project": "vmss"<br>}</pre> | no |
| vmss\_admin\_password | Password to allocate to the admin user account | `string` | n/a | yes |
| vmss\_deployments | VMSS deployments | <pre>map(object({<br>    vmss_name                   = string<br>    vmss_computer_name_prefix   = string<br>    vmss_se_enabled             = bool<br>    vmss_win_se_settings        = string<br>    vmss_source_image_publisher = optional(string)<br>    vmss_source_image_offer     = optional(string)<br>    vmss_source_image_sku       = optional(string)<br>    vmss_source_image_version   = optional(string)<br>  }))</pre> | `{}` | no |
| vmss\_location | Azure location | `string` | n/a | yes |
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
  for_each = var.vmss_deployments

  # source                   = "tonyskidmore/vmss/azurerm"
  # version                  = "0.4.0"
  source                      = "../../"
  vmss_os                     = each.key
  vmss_name                   = each.value.vmss_name
  vmss_computer_name_prefix   = each.value.vmss_computer_name_prefix
  vmss_resource_group_name    = azurerm_resource_group.vmss.name
  vmss_subnet_id              = azurerm_subnet.agents.id
  vmss_admin_password         = var.vmss_admin_password
  vmss_se_enabled             = each.value.vmss_se_enabled
  vmss_source_image_publisher = each.value.vmss_source_image_publisher
  vmss_source_image_offer     = each.value.vmss_source_image_offer
  vmss_source_image_sku       = each.value.vmss_source_image_sku
  vmss_source_image_version   = each.value.vmss_source_image_version
  vmss_win_se_settings        = each.value.vmss_win_se_settings
  vmss_custom_data = (
    each.key == "linux" ?
    base64encode(templatefile("${path.module}/cloud-init.tpl", {})) :
    null
  )
}
```
<!-- END_TF_DOCS -->
