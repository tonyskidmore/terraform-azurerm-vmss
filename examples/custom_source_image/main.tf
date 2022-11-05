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
