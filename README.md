# terraform-azurevm-vmss

[![GitHub Super-Linter](https://github.com/tonyskidmore/terraform-azurerm-vmss/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)

Azure Virtual Machine Scale Set Terraform module.
It is a single resource module, with opinionated defaults
that form the starting point for the creation of an
[Azure virtual machine scale set agent][scale-agents]
pool in Azure DevOps.

<!-- BEGIN_TF_DOCS -->



## Basic example

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
  # TODO:
  # source                   = "tonyskidmore/vmss/azurerm"
  # version                  = "0.2.2"
  source                   = "../../"
  vmss_name                = var.vmss_name
  vmss_resource_group_name = var.vmss_resource_group_name
  vmss_subnet_id           = azurerm_subnet.agents.id
  vmss_admin_password      = var.vmss_admin_password
}

```
## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine_scale_set.ado_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to Azure Virtual Machine Scale | `map(string)` | `{}` | no |
| <a name="input_vmss_admin_password"></a> [vmss\_admin\_password](#input\_vmss\_admin\_password) | Azure Virtual Machine Scale Set instance administrator password | `string` | `null` | no |
| <a name="input_vmss_admin_username"></a> [vmss\_admin\_username](#input\_vmss\_admin\_username) | Azure Virtual Machine Scale Set instance administrator name | `string` | `"adminuser"` | no |
| <a name="input_vmss_custom_data"></a> [vmss\_custom\_data](#input\_vmss\_custom\_data) | The base64 encoded data to use as custom data for the VMSS instances | `string` | `null` | no |
| <a name="input_vmss_data_disks"></a> [vmss\_data\_disks](#input\_vmss\_data\_disks) | Additional data disks | <pre>list(object({<br>    caching              = string<br>    create_option        = string<br>    disk_size_gb         = string<br>    lun                  = number<br>    storage_account_type = string<br>  }))</pre> | `[]` | no |
| <a name="input_vmss_disk_size_gb"></a> [vmss\_disk\_size\_gb](#input\_vmss\_disk\_size\_gb) | The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine Scale Set is sourced from | `number` | `null` | no |
| <a name="input_vmss_encryption_at_host_enabled"></a> [vmss\_encryption\_at\_host\_enabled](#input\_vmss\_encryption\_at\_host\_enabled) | Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host? | `bool` | `false` | no |
| <a name="input_vmss_identity_ids"></a> [vmss\_identity\_ids](#input\_vmss\_identity\_ids) | Specifies a list of User Assigned Managed Identity IDs to be assigned to this Linux Virtual Machine Scale Set | `list(string)` | `null` | no |
| <a name="input_vmss_identity_type"></a> [vmss\_identity\_type](#input\_vmss\_identity\_type) | Specifies the type of Managed Service Identity that should be configured on this Linux Virtual Machine Scale Set | `string` | `null` | no |
| <a name="input_vmss_instances"></a> [vmss\_instances](#input\_vmss\_instances) | Azure Virtual Machine Scale Set number of instances | `number` | `0` | no |
| <a name="input_vmss_load_balancer_backend_address_pool_ids"></a> [vmss\_load\_balancer\_backend\_address\_pool\_ids](#input\_vmss\_load\_balancer\_backend\_address\_pool\_ids) | A list of Backend Address Pools IDs from a Load Balancer which this Virtual Machine Scale Set should be connected to | `list(string)` | `null` | no |
| <a name="input_vmss_location"></a> [vmss\_location](#input\_vmss\_location) | Existing resource group name of where the VMSS will be created | `string` | `"uksouth"` | no |
| <a name="input_vmss_name"></a> [vmss\_name](#input\_vmss\_name) | Azure Virtual Machine Scale Set name | `string` | `"azdo-vmss-pool-001"` | no |
| <a name="input_vmss_os"></a> [vmss\_os](#input\_vmss\_os) | Whether to process the Linux Virtual Machine Scale Set resource | `string` | `"linux"` | no |
| <a name="input_vmss_os_disk_caching"></a> [vmss\_os\_disk\_caching](#input\_vmss\_os\_disk\_caching) | The Type of Caching which should be used for the Internal OS Disk | `string` | `"ReadOnly"` | no |
| <a name="input_vmss_os_disk_storage_account_type"></a> [vmss\_os\_disk\_storage\_account\_type](#input\_vmss\_os\_disk\_storage\_account\_type) | The Type of Storage Account which should back this the Internal OS Disk | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_vmss_resource_group_name"></a> [vmss\_resource\_group\_name](#input\_vmss\_resource\_group\_name) | Existing resource group name of where the VMSS will be created | `string` | n/a | yes |
| <a name="input_vmss_resource_prefix"></a> [vmss\_resource\_prefix](#input\_vmss\_resource\_prefix) | Prefix to apply to VMSS resources | `string` | `"vmss"` | no |
| <a name="input_vmss_se_enabled"></a> [vmss\_se\_enabled](#input\_vmss\_se\_enabled) | Whether to process the Linux Virtual Machine Scale Set extension resource | `bool` | `false` | no |
| <a name="input_vmss_se_settings_data"></a> [vmss\_se\_settings\_data](#input\_vmss\_se\_settings\_data) | The base64 encoded data to use as the script for the VMSS custom script extension | `string` | `null` | no |
| <a name="input_vmss_se_settings_script"></a> [vmss\_se\_settings\_script](#input\_vmss\_se\_settings\_script) | The path of the file to use as the script for the VMSS custom script extension | `string` | `"scripts/vmss-startup.sh"` | no |
| <a name="input_vmss_sku"></a> [vmss\_sku](#input\_vmss\_sku) | Azure Virtual Machine Scale Set SKU | `string` | `"Standard_D2_v3"` | no |
| <a name="input_vmss_source_image_id"></a> [vmss\_source\_image\_id](#input\_vmss\_source\_image\_id) | Azure Virtual Machine Scale Set Image ID | `string` | `null` | no |
| <a name="input_vmss_source_image_offer"></a> [vmss\_source\_image\_offer](#input\_vmss\_source\_image\_offer) | Azure Virtual Machine Scale Set Source Image Offer | `string` | `"0001-com-ubuntu-server-focal"` | no |
| <a name="input_vmss_source_image_publisher"></a> [vmss\_source\_image\_publisher](#input\_vmss\_source\_image\_publisher) | Azure Virtual Machine Scale Set Source Image Publisher | `string` | `"Canonical"` | no |
| <a name="input_vmss_source_image_sku"></a> [vmss\_source\_image\_sku](#input\_vmss\_source\_image\_sku) | Azure Virtual Machine Scale Set Source Image SKU | `string` | `"20_04-lts"` | no |
| <a name="input_vmss_source_image_version"></a> [vmss\_source\_image\_version](#input\_vmss\_source\_image\_version) | Azure Virtual Machine Scale Set Source Image Version | `string` | `"latest"` | no |
| <a name="input_vmss_ssh_public_key"></a> [vmss\_ssh\_public\_key](#input\_vmss\_ssh\_public\_key) | Public key to use for SSH access to VMs | `string` | `""` | no |
| <a name="input_vmss_storage_account_uri"></a> [vmss\_storage\_account\_uri](#input\_vmss\_storage\_account\_uri) | VMSS boot diagnostics storage account URI | `string` | `null` | no |
| <a name="input_vmss_subnet_id"></a> [vmss\_subnet\_id](#input\_vmss\_subnet\_id) | Existing subnet ID of where the VMSS will be connected | `string` | n/a | yes |
| <a name="input_vmss_zones"></a> [vmss\_zones](#input\_vmss\_zones) | A collection of availability zones to spread the Virtual Machines over | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vmss"></a> [vmss](#output\_vmss) | Virtual Machine Scale Set object |
| <a name="output_vmss_id"></a> [vmss\_id](#output\_vmss\_id) | Virtual Machine Scale Set ID |
| <a name="output_vmss_system_assigned_identity_id"></a> [vmss\_system\_assigned\_identity\_id](#output\_vmss\_system\_assigned\_identity\_id) | Virtual Machine Scale Set SystemAssigned Identity |
| <a name="output_vmss_user_assigned_identity_ids"></a> [vmss\_user\_assigned\_identity\_ids](#output\_vmss\_user\_assigned\_identity\_ids) | Virtual Machine Scale Set UserAssigned Identities |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.28.0 |


<!-- END_TF_DOCS -->

[scale-agents]: https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents
