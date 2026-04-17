# Integration test for examples/identity_user_assigned.
# Creates a User Assigned Managed Identity and attaches it to the VMSS via the
# new `vmss_identity` object input. Verifies the identity block is wired up.
# See admin_password.tftest.hcl for prerequisites.

variables {
  vmss_name                    = "vmss-tftest-uai-01"
  vmss_resource_group_name     = "rg-vmss-tftest-uai-01"
  vmss_location                = "uksouth"
  vmss_subnet_name             = "snet-vmss-tftest-01"
  vmss_subnet_address_prefixes = ["192.168.0.0/29"]
  vmss_vnet_name               = "vnet-vmss-tftest-uai-01"
  vmss_vnet_address_space      = ["192.168.0.0/24"]
  vmss_admin_password          = "Ch@ngeMeTftest01!"
  user_assigned_identity_name  = "id-vmss-tftest-uai-01"
}

run "apply_identity_user_assigned_example" {
  command = apply

  module {
    source = "./examples/identity_user_assigned"
  }

  assert {
    condition     = output.vmss_id != null
    error_message = "Expected vmss_id output to be non-null after apply."
  }

  assert {
    condition     = length(output.vmss_identity.user_assigned_identity_ids) == 1
    error_message = "Expected exactly one user-assigned identity attached to the VMSS."
  }

  assert {
    condition     = output.vmss_identity.principal_id == null
    error_message = "Expected no SystemAssigned principal_id when only UserAssigned identity is used."
  }

  assert {
    condition     = output.user_assigned_identity_client_id != null
    error_message = "Expected client_id output from the user-assigned identity."
  }
}
