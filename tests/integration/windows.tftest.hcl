# Integration test for examples/windows.
# Provisions a Windows VMSS using the example's user_data/custom_data/CSE
# wiring. See admin_password.tftest.hcl for prerequisites and cleanup notes.

variables {
  vmss_name                    = "vmss-tftest-win-01"
  vmss_computer_name_prefix    = "winvmss"
  vmss_os                      = "windows"
  vmss_resource_group_name     = "rg-vmss-tftest-win-01"
  vmss_location                = "uksouth"
  vmss_subnet_name             = "snet-vmss-tftest-01"
  vmss_subnet_address_prefixes = ["192.168.0.0/29"]
  vmss_vnet_name               = "vnet-vmss-tftest-win-01"
  vmss_vnet_address_space      = ["192.168.0.0/24"]
  vmss_admin_password          = "Ch@ngeMeTftest01!"
  vmss_se_enabled              = true
}

run "apply_windows_example" {
  command = apply

  module {
    source = "./examples/windows"
  }

  assert {
    condition     = output.vmss_id != null
    error_message = "Expected vmss_id output to be non-null after apply."
  }

  assert {
    condition     = can(regex("/virtualMachineScaleSets/vmss-tftest-win-01$", output.vmss_id))
    error_message = "Expected vmss_id to end with the VMSS name we passed in."
  }

  assert {
    condition     = output.vmss_name == var.vmss_name
    error_message = "Expected vmss_name output to equal the name we passed in."
  }

  assert {
    condition     = output.vmss_location == var.vmss_location
    error_message = "Expected the Windows VMSS to be deployed in the requested region."
  }

  assert {
    condition     = output.vmss_sku == "Standard_D2s_v3"
    error_message = "Expected the Windows example to use the module default SKU."
  }

  assert {
    condition     = output.vmss_instances == 0
    error_message = "Expected the Windows example to inherit the module default instance count."
  }
}
