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
