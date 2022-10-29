data "azurerm_client_config" "current" {}

module "vmss" {
  source                   = "../../"
  vmss_resource_group_name = "rg-vmss-azdo-agents-01"
  vmss_subnet_id           = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/rg-azdo-agents-networks-01/providers/Microsoft.Network/virtualNetworks/vnet-azdo-agents-01/subnets/snet-azdo-agents-01"
  vmss_admin_password      = "P@55w0rd2022"
}
