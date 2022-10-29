# Azure Virtual Machines Scale Set

Example of creating an Azure VMSS with instances configured with an
administrator password as opposed to an SSH key pair
(SSH key pair is recommended ).

You can instantiate this directly using the following parameters:

````hcl

module "vmss" {
  source                   = "tonyskidmore/vmss/azurerm"
  version                  = "0.1.0"
  vmss_resource_group_name = "rg-vmss-azdo-agents-01"
  vmss_subnet_id           = data.azurerm_subnet.agents.id
  vmss_admin_password      = "P@55w0rd2022"
}

````
