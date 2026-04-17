mock_provider "azurerm" {}

variables {
  vmss_resource_group_name = "rg-test"
  vmss_subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
  vmss_admin_password      = "ExampleP@ssw0rd!"
}

run "linux_is_default" {
  command = plan

  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.ado_pool) == 1
    error_message = "Expected the linux VMSS resource to be created when vmss_os defaults to \"linux\"."
  }

  assert {
    condition     = length(azurerm_windows_virtual_machine_scale_set.ado_pool) == 0
    error_message = "Expected no windows VMSS when vmss_os defaults to \"linux\"."
  }
}

run "windows_branch" {
  command = plan

  variables {
    vmss_os             = "windows"
    vmss_admin_password = "ExampleP@ssw0rd!"
  }

  assert {
    condition     = length(azurerm_windows_virtual_machine_scale_set.ado_pool) == 1
    error_message = "Expected the windows VMSS resource to be created when vmss_os=\"windows\"."
  }

  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.ado_pool) == 0
    error_message = "Expected no linux VMSS when vmss_os=\"windows\"."
  }
}

run "data_disks_are_propagated" {
  command = plan

  variables {
    vmss_data_disks = [
      {
        caching              = "None"
        create_option        = "Empty"
        disk_size_gb         = 10
        lun                  = 0
        storage_account_type = "Standard_LRS"
      },
      {
        caching              = "ReadOnly"
        create_option        = "Empty"
        disk_size_gb         = 20
        lun                  = 1
        storage_account_type = "Premium_LRS"
      },
    ]
  }

  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.ado_pool[0].data_disk) == 2
    error_message = "Expected two data_disk blocks to be rendered from vmss_data_disks."
  }
}
