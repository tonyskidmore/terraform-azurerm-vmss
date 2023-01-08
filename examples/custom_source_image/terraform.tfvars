vmss_name = "vmss-agent-pool-linux-002"
# it can be useful during testing to set a password for serial console access
# but this is not the preferred configuration from a security perspective
# vmss_admin_password          = "Vm55P@sw0rd123"
vmss_instances               = 1
vmss_resource_group_name     = "rg-tests-terraform-azurerm-vmss"
vmss_vnet_name               = "vnet-azdo-agents-02"
vmss_vnet_address_space      = ["172.16.0.0/12"]
vmss_subnet_name             = "snet-azdo-agents-02"
vmss_subnet_address_prefixes = ["172.16.0.0/24"]
vmss_se_enabled              = true
# we can set the below to test passing data rather than a script
# vmss_se_settings_data will be used before vmss_se_settings_script
# vmss_se_settings_data         = "echo 'vmss_se_settings_data' > /tmp/vmss_se_settings"
vmss_se_settings_script = "scripts/vmss-test.sh"
vmss_data_disks = {
  data1 = {
    caching              = "None"
    create_option        = "Empty"
    disk_size_gb         = 10
    lun                  = 1
    storage_account_type = "Standard_LRS"
  }
}
