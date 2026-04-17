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
