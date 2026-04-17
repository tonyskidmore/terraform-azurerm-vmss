# Integration test for examples/admin_password.
#
# Runs `terraform apply` against a real Azure subscription, asserts on the
# module output, then `terraform test` automatically destroys the resources
# on teardown.
#
# Requires: Azure credentials (ARM_SUBSCRIPTION_ID or `az login` context).
# Cost: a small amount — a VMSS with instances=0 (set by module default).
#
# Run via: scripts/test-integration.sh admin_password

variables {
  vmss_name                    = "vmss-tftest-adminpw-01"
  vmss_resource_group_name     = "rg-vmss-tftest-adminpw-01"
  vmss_location                = "uksouth"
  vmss_subnet_name             = "snet-vmss-tftest-01"
  vmss_subnet_address_prefixes = ["192.168.0.0/29"]
  vmss_vnet_name               = "vnet-vmss-tftest-adminpw-01"
  vmss_vnet_address_space      = ["192.168.0.0/24"]
  vmss_admin_password          = "Ch@ngeMeTftest01!"
}

run "apply_admin_password_example" {
  command = apply

  module {
    source = "./examples/admin_password"
  }

  assert {
    condition     = output.vmss_id != null
    error_message = "Expected vmss_id output to be non-null after apply."
  }

  assert {
    condition     = can(regex("/virtualMachineScaleSets/", output.vmss_id))
    error_message = "Expected vmss_id to be an Azure VMSS resource ID."
  }
}
