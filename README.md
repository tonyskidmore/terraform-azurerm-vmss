# terraform-azurevm-vmss

[![GitHub Super-Linter](https://github.com/tonyskidmore/terraform-azurerm-vmss/workflows/Lint%20Code%20Base/badge.svg)](https://github.com/marketplace/actions/super-linter)

Azure Virtual Machine Scale Set Terraform module.
It forms the starting point for the creation of a Windows or Linux
[Azure virtual machine scale set agent][scale-agents]
pool in Azure DevOps.

This module is used by the [terraform-azurerm-vmss-devops-agent](https://registry.terraform.io/modules/tonyskidmore/vmss-devops-agent/azurerm/latest)
to create the Azure VMSS side of a self-hosted Azure DevOps Scale Set agent pool.

## Requirements

* Terraform `>= 1.10`
* AzureRM provider `~> 4.0`

## Migrating from 0.4.x to 1.0.0

Version 1.0.0 is a breaking release. Key caller-facing changes:

* Identity inputs `vmss_identity_type` + `vmss_identity_ids` have been replaced
  by a single object `vmss_identity = { type, identity_ids }`.
* `vmss_auto_upgrade_minor_version` and `vmss_enable_automatic_updates` are now
  typed as `bool` (were `string`).
* `vmss_data_disks[].disk_size_gb` is now typed as `number` (was `string`).
* `vmss_ssh_public_key` now defaults to `null` (was `""`).
* The full `vmss` object output has been removed — use the narrower
  `vmss_id`, `vmss_name`, `vmss_unique_id`, and `vmss_identity` outputs.

See [`CHANGELOG.md`](CHANGELOG.md) for the complete list and
[`DEVELOPMENT.md`](DEVELOPMENT.md) for a side-by-side migration snippet.

<!-- BEGIN_TF_DOCS -->



## Basic example

```hcl
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "vmss" {
  name     = "rg-vmss-example"
  location = "uksouth"
}

resource "azurerm_virtual_network" "vmss" {
  name                = "vnet-vmss-example"
  resource_group_name = azurerm_resource_group.vmss.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vmss.location
}

resource "azurerm_subnet" "agents" {
  name                 = "snet-vmss-agents"
  resource_group_name  = azurerm_resource_group.vmss.name
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.vmss.name
}

module "vmss" {
  source  = "tonyskidmore/vmss/azurerm"
  version = "~> 1.0"

  vmss_name                = "vmss-example"
  vmss_resource_group_name = azurerm_resource_group.vmss.name
  vmss_subnet_id           = azurerm_subnet.agents.id
  vmss_admin_password      = var.vmss_admin_password
}
```
## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine_scale_set.ado_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |
| [azurerm_windows_virtual_machine_scale_set.ado_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine_scale_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to Azure Virtual Machine Scale | `map(string)` | `{}` | no |
| <a name="input_vmss_admin_password"></a> [vmss\_admin\_password](#input\_vmss\_admin\_password) | Azure Virtual Machine Scale Set instance administrator password | `string` | `null` | no |
| <a name="input_vmss_admin_username"></a> [vmss\_admin\_username](#input\_vmss\_admin\_username) | Azure Virtual Machine Scale Set instance administrator name | `string` | `"adminuser"` | no |
| <a name="input_vmss_auto_upgrade_minor_version"></a> [vmss\_auto\_upgrade\_minor\_version](#input\_vmss\_auto\_upgrade\_minor\_version) | Specifies whether or not to use the latest minor version available | `bool` | `true` | no |
| <a name="input_vmss_computer_name_prefix"></a> [vmss\_computer\_name\_prefix](#input\_vmss\_computer\_name\_prefix) | The prefix which should be used for the name of the Virtual Machines in this Scale Set | `string` | `null` | no |
| <a name="input_vmss_custom_data"></a> [vmss\_custom\_data](#input\_vmss\_custom\_data) | The base64 encoded data to use as custom data for the VMSS instances | `string` | `null` | no |
| <a name="input_vmss_data_disks"></a> [vmss\_data\_disks](#input\_vmss\_data\_disks) | Additional data disks | <pre>list(object({<br/>    caching              = string<br/>    create_option        = string<br/>    disk_size_gb         = number<br/>    lun                  = number<br/>    storage_account_type = string<br/>  }))</pre> | `[]` | no |
| <a name="input_vmss_disk_size_gb"></a> [vmss\_disk\_size\_gb](#input\_vmss\_disk\_size\_gb) | The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine Scale Set is sourced from | `number` | `null` | no |
| <a name="input_vmss_enable_automatic_updates"></a> [vmss\_enable\_automatic\_updates](#input\_vmss\_enable\_automatic\_updates) | Are automatic updates enabled for this Virtual Machine? (Windows) | `bool` | `null` | no |
| <a name="input_vmss_encryption_at_host_enabled"></a> [vmss\_encryption\_at\_host\_enabled](#input\_vmss\_encryption\_at\_host\_enabled) | Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host? | `bool` | `false` | no |
| <a name="input_vmss_identity"></a> [vmss\_identity](#input\_vmss\_identity) | Managed Service Identity configuration for the Virtual Machine Scale Set.<br/><br/>- `type`: one of `SystemAssigned`, `UserAssigned`, or `SystemAssigned, UserAssigned`. When `type` is `null` (default), no identity block is created.<br/>- `identity_ids`: list of User Assigned Managed Identity IDs, required when `type` includes `UserAssigned`.<br/><br/>Pass `{}` (the default) to omit identity. Passing `null` is not supported. | <pre>object({<br/>    type         = optional(string)<br/>    identity_ids = optional(list(string), [])<br/>  })</pre> | `{}` | no |
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
| <a name="input_vmss_sku"></a> [vmss\_sku](#input\_vmss\_sku) | Azure Virtual Machine Scale Set SKU | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_vmss_source_image_id"></a> [vmss\_source\_image\_id](#input\_vmss\_source\_image\_id) | Azure Virtual Machine Scale Set Image ID | `string` | `null` | no |
| <a name="input_vmss_source_image_offer"></a> [vmss\_source\_image\_offer](#input\_vmss\_source\_image\_offer) | Azure Virtual Machine Scale Set Source Image Offer | `string` | `null` | no |
| <a name="input_vmss_source_image_publisher"></a> [vmss\_source\_image\_publisher](#input\_vmss\_source\_image\_publisher) | Azure Virtual Machine Scale Set Source Image Publisher | `string` | `null` | no |
| <a name="input_vmss_source_image_sku"></a> [vmss\_source\_image\_sku](#input\_vmss\_source\_image\_sku) | Azure Virtual Machine Scale Set Source Image SKU | `string` | `null` | no |
| <a name="input_vmss_source_image_version"></a> [vmss\_source\_image\_version](#input\_vmss\_source\_image\_version) | Azure Virtual Machine Scale Set Source Image Version | `string` | `null` | no |
| <a name="input_vmss_ssh_public_key"></a> [vmss\_ssh\_public\_key](#input\_vmss\_ssh\_public\_key) | Public key to use for SSH access to VMs | `string` | `null` | no |
| <a name="input_vmss_storage_account_uri"></a> [vmss\_storage\_account\_uri](#input\_vmss\_storage\_account\_uri) | VMSS boot diagnostics storage account URI | `string` | `null` | no |
| <a name="input_vmss_subnet_id"></a> [vmss\_subnet\_id](#input\_vmss\_subnet\_id) | Existing subnet ID of where the VMSS will be connected | `string` | n/a | yes |
| <a name="input_vmss_user_data"></a> [vmss\_user\_data](#input\_vmss\_user\_data) | The base64 encoded data to use as user data for the VMSS instances | `string` | `null` | no |
| <a name="input_vmss_win_se_settings"></a> [vmss\_win\_se\_settings](#input\_vmss\_win\_se\_settings) | The value to pass to the Windows VMSS custom script extension | `string` | `null` | no |
| <a name="input_vmss_win_se_settings_data"></a> [vmss\_win\_se\_settings\_data](#input\_vmss\_win\_se\_settings\_data) | The base64 encoded data to use as the script for the Windows VMSS custom script extension | `string` | `"scripts/Set-VmssConfig.ps1"` | no |
| <a name="input_vmss_win_se_settings_script"></a> [vmss\_win\_se\_settings\_script](#input\_vmss\_win\_se\_settings\_script) | The path of the file to use as the caller script for the Windows VMSS custom script extension | `string` | `"scripts/Start-VmssConfig.ps1"` | no |
| <a name="input_vmss_zones"></a> [vmss\_zones](#input\_vmss\_zones) | A collection of availability zones to spread the Virtual Machines over | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vmss_data_disks"></a> [vmss\_data\_disks](#output\_vmss\_data\_disks) | Data disks configured on the Virtual Machine Scale Set, as accepted by Azure post-apply |
| <a name="output_vmss_id"></a> [vmss\_id](#output\_vmss\_id) | Virtual Machine Scale Set resource ID |
| <a name="output_vmss_identity"></a> [vmss\_identity](#output\_vmss\_identity) | Flattened managed identity details for the Virtual Machine Scale Set |
| <a name="output_vmss_instances"></a> [vmss\_instances](#output\_vmss\_instances) | Number of instances configured on the VMSS |
| <a name="output_vmss_location"></a> [vmss\_location](#output\_vmss\_location) | Azure region the VMSS was deployed to |
| <a name="output_vmss_name"></a> [vmss\_name](#output\_vmss\_name) | Virtual Machine Scale Set name |
| <a name="output_vmss_sku"></a> [vmss\_sku](#output\_vmss\_sku) | VM SKU in use by the VMSS |
| <a name="output_vmss_unique_id"></a> [vmss\_unique\_id](#output\_vmss\_unique\_id) | The generated unique identifier of the Virtual Machine Scale Set |
| <a name="output_vmss_zones"></a> [vmss\_zones](#output\_vmss\_zones) | Availability zones the VMSS instances are spread across |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.69.0 |

<!-- END_TF_DOCS -->

## Troubleshooting

### Linux

Use the Serial console in the portal or via the Azure CLI to help troubleshoot deployment issues:

````bash

# Press enter to get a login
vmss-agent-pool-linux-003000000 login: adminuser
Password:

Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.15.0-1052-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sat Dec  2 13:18:05 UTC 2023

  System load:  0.04              Processes:             122
  Usage of /:   7.5% of 28.89GB   Users logged in:       0
  Memory usage: 5%                IPv4 address for eth0: 192.168.0.4
  Swap usage:   0%

Expanded Security Maintenance for Applications is not enabled.

2 updates can be applied immediately.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.


````


### Windows

Use the Serial console in the portal or via the Azure CLI to help troubleshoot deployment issues:

````bash

# specify the VMSS name (-n), Resource group (-g) and instance number (e.g. 0)
az serial-console connect -n vmss-win-ado-001 -g rg-vmss-win-001 --instance-id 0

````

````bash

cmd
ch
ch -si 1

Please enter login credentials.
?Username: ?adminuser
Domain  : ?
Password: ?********************

````

[scale-agents]: https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents
