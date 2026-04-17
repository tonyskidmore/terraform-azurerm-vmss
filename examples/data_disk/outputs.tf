output "vmss_id" {
  value       = module.vmss.vmss_id
  description = "Virtual Machine Scale Set ID"
}

output "vmss_data_disks" {
  value       = module.vmss.vmss_data_disks
  description = "Data disks configured on the Virtual Machine Scale Set"
}
