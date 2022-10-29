data "azurerm_subnet" "agents" {
  name                 = "snet-azdo-agents-01"
  virtual_network_name = "vnet-azdo-agents-01"
  resource_group_name  = "rg-azdo-agents-networks-01"
}

module "vmss" {
  source                   = "tonyskidmore/vmss/azurerm"
  version                  = "0.1.0"
  vmss_resource_group_name = "rg-vmss-azdo-agents-01"
  vmss_subnet_id           = data.azurerm_subnet.agents.id
  vmss_admin_password      = "P@55w0rd2022"
}
