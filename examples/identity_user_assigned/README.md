# Azure Virtual Machine Scale Set

Example of creating an Azure VMSS with a User Assigned Managed Identity
attached via the `vmss_identity` input.

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.10.0 |
| azurerm | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | 4.69.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| vmss | ../.. | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | Tags to apply to all resources | `map(string)` | <pre>{<br/>  "environment": "test",<br/>  "example": "identity_user_assigned",<br/>  "project": "vmss"<br/>}</pre> | no |
| user\_assigned\_identity\_name | Name of the User Assigned Managed Identity to create and attach to the VMSS | `string` | n/a | yes |
| vmss\_admin\_password | Admin password for the VMSS instances | `string` | n/a | yes |
| vmss\_location | Azure location | `string` | n/a | yes |
| vmss\_name | Name of the Virtual Machine Scale Set to create | `string` | n/a | yes |
| vmss\_resource\_group\_name | Resource group name to create for the VMSS | `string` | n/a | yes |
| vmss\_subnet\_address\_prefixes | Subnet address prefixes | `list(string)` | n/a | yes |
| vmss\_subnet\_name | Name of subnet where the VMSS will be connected | `string` | n/a | yes |
| vmss\_vnet\_address\_space | Virtual network address spaces | `list(string)` | n/a | yes |
| vmss\_vnet\_name | Name of the virtual network | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| user\_assigned\_identity\_client\_id | Client ID of the user-assigned managed identity attached to the VMSS |
| vmss\_id | Virtual Machine Scale Set resource ID |
| vmss\_identity | Flattened managed identity details for the VMSS |
| vmss\_name | Virtual Machine Scale Set name |



Example

```hcl
resource "azurerm_resource_group" "vmss" {
  name     = var.vmss_resource_group_name
  location = var.vmss_location
  tags     = var.tags
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

resource "azurerm_user_assigned_identity" "vmss" {
  name                = var.user_assigned_identity_name
  resource_group_name = azurerm_resource_group.vmss.name
  location            = azurerm_resource_group.vmss.location
  tags                = var.tags
}

module "vmss" {
  source = "../.."

  vmss_name                = var.vmss_name
  vmss_resource_group_name = azurerm_resource_group.vmss.name
  vmss_subnet_id           = azurerm_subnet.agents.id
  vmss_admin_password      = var.vmss_admin_password

  vmss_identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.vmss.id]
  }

  tags = var.tags
}
```
<!-- END_TF_DOCS -->
