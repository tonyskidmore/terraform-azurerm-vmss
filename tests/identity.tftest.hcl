mock_provider "azurerm" {}

variables {
  vmss_resource_group_name = "rg-test"
  vmss_subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
  vmss_admin_password      = "ExampleP@ssw0rd!"
}

run "no_identity_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.ado_pool[0].identity) == 0
    error_message = "Expected no identity block when vmss_identity.type is null (default)."
  }
}

run "system_assigned_identity" {
  command = plan

  variables {
    vmss_identity = {
      type = "SystemAssigned"
    }
  }

  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.ado_pool[0].identity) == 1
    error_message = "Expected one identity block for SystemAssigned."
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.ado_pool[0].identity[0].type == "SystemAssigned"
    error_message = "Expected identity.type to equal \"SystemAssigned\"."
  }
}

run "user_assigned_identity" {
  command = plan

  variables {
    vmss_identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-test"]
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.ado_pool[0].identity[0].type == "UserAssigned"
    error_message = "Expected identity.type to equal \"UserAssigned\"."
  }

  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.ado_pool[0].identity[0].identity_ids) == 1
    error_message = "Expected one user assigned identity id to be passed through."
  }
}

run "system_and_user_assigned_identity" {
  command = plan

  variables {
    vmss_identity = {
      type         = "SystemAssigned, UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-test"]
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine_scale_set.ado_pool[0].identity[0].type == "SystemAssigned, UserAssigned"
    error_message = "Expected identity.type to equal \"SystemAssigned, UserAssigned\"."
  }

  assert {
    condition     = length(azurerm_linux_virtual_machine_scale_set.ado_pool[0].identity[0].identity_ids) == 1
    error_message = "Expected user-assigned identity IDs to be passed through for combined identity type."
  }
}
