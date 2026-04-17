mock_provider "azurerm" {}

variables {
  vmss_resource_group_name = "rg-test"
  vmss_subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet"
}

run "invalid_os_is_rejected" {
  command = plan

  variables {
    vmss_os = "mac"
  }

  expect_failures = [var.vmss_os]
}

run "invalid_os_disk_caching_is_rejected" {
  command = plan

  variables {
    vmss_os_disk_caching = "Bogus"
  }

  expect_failures = [var.vmss_os_disk_caching]
}

run "negative_instances_are_rejected" {
  command = plan

  variables {
    vmss_instances = -1
  }

  expect_failures = [var.vmss_instances]
}

run "excessive_disk_size_is_rejected" {
  command = plan

  variables {
    vmss_disk_size_gb = 999999
  }

  expect_failures = [var.vmss_disk_size_gb]
}

run "identity_with_user_assigned_requires_ids" {
  command = plan

  variables {
    vmss_identity = {
      type = "UserAssigned"
    }
  }

  expect_failures = [var.vmss_identity]
}

run "invalid_identity_type_is_rejected" {
  command = plan

  variables {
    vmss_identity = {
      type = "SomethingElse"
    }
  }

  expect_failures = [var.vmss_identity]
}
