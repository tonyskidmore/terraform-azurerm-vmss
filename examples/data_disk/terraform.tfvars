vmss_name                    = "vmss-agent-pool-linux-003"
vmss_resource_group_name     = "rg-tests-terraform-azurerm-vmss"
vmss_location                = "uksouth"
vmss_subnet_name             = "snet-azdo-agents-01"
vmss_subnet_address_prefixes = ["192.168.0.0/29"]
vmss_vnet_name               = "vnet-azdo-agents-01"
vmss_vnet_address_space      = ["192.168.0.0/24"]
vmss_admin_password          = "Sup3rS3cr3tP@55w0rd!"
vmss_data_disks = [
  {
    caching              = "None"
    create_option        = "Empty"
    disk_size_gb         = "10"
    lun                  = 1
    storage_account_type = "Standard_LRS"
  }
]
