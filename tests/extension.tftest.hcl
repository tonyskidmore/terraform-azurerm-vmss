mock_provider "azurerm" {}

variables {
  vmss_resource_group_name = "rg-test"
  vmss_subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
  vmss_admin_password      = "ExampleP@ssw0rd!"
}

run "extension_disabled_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.ado_pool[0].extension) == 0
    error_message = "Expected no extension block when vmss_se_enabled is false."
  }
}

run "extension_enabled_with_inline_data" {
  command = plan

  variables {
    vmss_se_enabled       = true
    vmss_se_settings_data = base64encode("echo hello")
  }

  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.ado_pool[0].extension) == 1
    error_message = "Expected an extension block when vmss_se_enabled is true."
  }

  assert {
    condition     = one(azurerm_linux_virtual_machine_scale_set.ado_pool[0].extension).type == "CustomScript"
    error_message = "Expected Linux extension type to be CustomScript."
  }
}

run "windows_extension_uses_customscriptextension" {
  command = plan

  variables {
    vmss_os              = "windows"
    vmss_admin_password  = "ExampleP@ssw0rd!"
    vmss_se_enabled      = true
    vmss_win_se_settings = jsonencode({ commandToExecute = "powershell.exe -Command Write-Host hello" })
  }

  assert {
    condition     = one(azurerm_windows_virtual_machine_scale_set.ado_pool[0].extension).type == "CustomScriptExtension"
    error_message = "Expected Windows extension type to be CustomScriptExtension."
  }
}
