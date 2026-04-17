output "vmss_id" {
  value       = module.vmss.vmss_id
  description = "Virtual Machine Scale Set ID"
}

output "vmss_name" {
  value       = module.vmss.vmss_name
  description = "Virtual Machine Scale Set name"
}

output "vmss_location" {
  value       = module.vmss.vmss_location
  description = "Azure region"
}

output "vmss_sku" {
  value       = module.vmss.vmss_sku
  description = "VM SKU"
}
