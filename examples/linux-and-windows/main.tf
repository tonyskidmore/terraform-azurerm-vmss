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
