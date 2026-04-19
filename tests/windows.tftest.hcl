mock_provider "azurerm" {}

variables {
  vmss_resource_group_name = "rg-test"
  vmss_subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
  vmss_admin_password      = "ExampleP@ssw0rd!"
}

run "windows_defaults_use_windows_image" {
  command = plan

  variables {
    vmss_os = "windows"
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.ado_pool[0].source_image_reference[0].publisher == "MicrosoftWindowsServer"
    error_message = "Expected the default Windows publisher to be MicrosoftWindowsServer."
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.ado_pool[0].source_image_reference[0].offer == "WindowsServer"
    error_message = "Expected the default Windows offer to be WindowsServer."
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.ado_pool[0].source_image_reference[0].sku == "2022-datacenter-core"
    error_message = "Expected the default Windows SKU to be 2022-datacenter-core."
  }
}

run "windows_extension_populates_custom_data" {
  command = plan

  variables {
    vmss_os         = "windows"
    vmss_se_enabled = true
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.ado_pool[0].custom_data != null
    error_message = "Expected Windows custom_data to be populated when the custom script extension is enabled."
  }
}

run "windows_custom_data_override_is_respected" {
  command = plan

  variables {
    vmss_os         = "windows"
    vmss_se_enabled = true
    vmss_custom_data = base64encode(
      <<-EOT
      Write-Host "hello from test"
      EOT
    )
  }

  assert {
    condition     = azurerm_windows_virtual_machine_scale_set.ado_pool[0].custom_data == var.vmss_custom_data
    error_message = "Expected vmss_custom_data to override the default Windows script payload."
  }
}
