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
