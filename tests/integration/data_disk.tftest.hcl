# Integration test for examples/data_disk.
# Provisions a Linux VMSS with one attached data disk.
# See the top-level comment in admin_password.tftest.hcl for prerequisites.

variables {
  vmss_name                    = "vmss-tftest-datadisk-01"
  vmss_resource_group_name     = "rg-vmss-tftest-datadisk-01"
  vmss_location                = "uksouth"
  vmss_subnet_name             = "snet-vmss-tftest-01"
  vmss_subnet_address_prefixes = ["192.168.0.0/29"]
  vmss_vnet_name               = "vnet-vmss-tftest-datadisk-01"
  vmss_vnet_address_space      = ["192.168.0.0/24"]
  vmss_admin_password          = "Ch@ngeMeTftest01!"
  vmss_data_disks = [
    {
      caching              = "None"
      create_option        = "Empty"
      disk_size_gb         = 10
      lun                  = 0
      storage_account_type = "Standard_LRS"
    }
  ]
}

run "apply_data_disk_example" {
  command = apply

  module {
    source = "./examples/data_disk"
  }

  assert {
    condition     = output.vmss_id != null
    error_message = "Expected vmss_id output to be non-null after apply."
  }

  assert {
    condition     = length(output.vmss_data_disks) == 1
    error_message = "Expected exactly one data disk on the VMSS."
  }

  assert {
    condition     = one([for d in output.vmss_data_disks : d.disk_size_gb]) == 10
    error_message = "Expected the data disk to be 10 GB."
  }

  # Note: with vmss_instances = 0 (module default), no actual VM instances run,
  # so the Azure portal's "Disks" view will show nothing. The data_disk block
  # above is on the VMSS template — bump vmss_instances to 1 locally if you
  # want to verify a real attached disk in the portal.
}
