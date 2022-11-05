# Azure Virtual Machine Scale Set

Example of creating an Azure VMSS with a custom source image

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | >=3.1.0 |
| http | >=3.2.0 |
| tls | ~>4.0 |
## Providers

| Name | Version |
|------|---------|
| azurerm | 3.30.0 |
| http | 3.2.0 |
| tls | 4.0.4 |
## Modules

| Name | Source | Version |
|------|--------|---------|
| vmss | ../.. | n/a |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vmss\_admin\_password | Password associated to vmss\_admin\_username | `string` | n/a | yes |
| vmss\_instances | Number of initial instances in the Virtual Machine Scale Set to create | `number` | n/a | yes |
| vmss\_name | Name of the Virtual Machine Scale Set to create | `string` | n/a | yes |
| vmss\_resource\_group\_name | Existing resource group name of where the VMSS will be created | `string` | n/a | yes |
| vmss\_se\_enabled | Whether to enable the VMSS custom script extension | `bool` | n/a | yes |
| vmss\_se\_settings\_data | The base64 encoded data to use as the script for the VMSS custom script extension | `string` | `null` | no |
| vmss\_se\_settings\_script | The path of the file to use as the script for the VMSS custom script extension | `string` | n/a | yes |
| vmss\_subnet\_name | Name of subnet where the vmss will be connected | `string` | n/a | yes |
| vmss\_vnet\_name | Name of the Vnet that the target subnet is a member of | `string` | n/a | yes |
| vmss\_vnet\_resource\_group\_name | Existing resource group where the Vnet containing the subnet is located | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| acg\_versions | Available ACG image versions |
| source\_ip | Source IP address of Terraform execution |
| tls\_private\_key | SSH privatte key |
| vmss\_id | Virtual Machine Scale Set ID |

Example

```hcl
data "azurerm_subnet" "agents" {
  name                 = var.vmss_subnet_name
  virtual_network_name = var.vmss_vnet_name
  resource_group_name  = var.vmss_vnet_resource_group_name
}

data "azurerm_shared_image_version" "runner-image" {
  name                = "latest"
  image_name          = "ubuntu20"
  gallery_name        = "acg_01"
  resource_group_name = "rg-ve-acg-01"
  # sort_versions_by_semver = true
}

data "http" "ifconfig" {
  url = "https://ifconfig.me/ip"
}

resource "tls_private_key" "vmss_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "vmss" {
  # source                   = "tonyskidmore/vmss/azurerm"
  # version                  = "0.1.0"
  source                   = "../.."
  vmss_name                = var.vmss_name
  vmss_resource_group_name = var.vmss_resource_group_name
  vmss_subnet_id           = data.azurerm_subnet.agents.id
  vmss_source_image_id     = data.azurerm_shared_image_version.runner-image.id
  vmss_ssh_public_key      = tls_private_key.vmss_ssh.public_key_openssh
  vmss_admin_password      = var.vmss_admin_password
  vmss_se_enabled          = var.vmss_se_enabled
  vmss_instances           = var.vmss_instances
  vmss_se_settings_data    = var.vmss_se_settings_data == null ? null : base64encode(var.vmss_se_settings_data)
  vmss_se_settings_script  = var.vmss_se_settings_script
}
```
<!-- END_TF_DOCS -->
