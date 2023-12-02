output "vmss_id" {
  value       = { for key, vmss_instance in module.vmss : key => vmss_instance.vmss_id }
  description = "Virtual Machine Scale Set ID"
}
