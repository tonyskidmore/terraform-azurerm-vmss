vmss_deployments = {
  "linux" = {
    vmss_name                   = "vmss-lin-ado-001"
    vmss_computer_name_prefix   = "linvmss"
    vmss_se_enabled             = false
    vmss_win_se_settings        = null
    vmss_source_image_publisher = "Canonical"
    vmss_source_image_sku       = "22_04-lts-gen2"
    vmss_source_image_offer     = "0001-com-ubuntu-server-jammy"
    vmss_source_image_version   = "latest"
  }
  "windows" = {
    vmss_name                   = "vmss-win-ado-001"
    vmss_computer_name_prefix   = "winvmss"
    vmss_se_enabled             = true
    vmss_win_se_settings        = "{\"fileUris\": [\"https://raw.githubusercontent.com/tonyskidmore/azure-customscriptextension-scripts/main/Install-AzureCliWIndows.ps1\"], \"commandToExecute\": \"powershell -ExecutionPolicy Unrestricted -File Install-AzureCliWIndows.ps1\"}"
    vmss_source_image_publisher = "MicrosoftWindowsServer"
    vmss_source_image_sku       = "2019-datacenter-core-g2"
    vmss_source_image_offer     = "WindowsServer"
    vmss_source_image_version   = "latest"
  }
}

vmss_resource_group_name     = "rg-vmss-win-001"
vmss_location                = "uksouth"
vmss_subnet_name             = "snet-azdo-agents-01"
vmss_subnet_address_prefixes = ["192.168.0.0/29"]
vmss_vnet_name               = "vnet-azdo-agents-01"
vmss_vnet_address_space      = ["192.168.0.0/24"]
vmss_admin_password          = "Sup3rS3cr3tP@55w0rd!"
