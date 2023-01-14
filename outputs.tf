output "vmss_id" {
  value       = try(azurerm_linux_virtual_machine_scale_set.ado_pool[0].id, null)
  description = "Virtual Machine Scale Set ID"
}

output "vmss" {
  value       = try(azurerm_linux_virtual_machine_scale_set.ado_pool[0], null)
  description = "Virtual Machine Scale Set object"
}

output "vmss_system_assigned_identity_id" {
  value       = try(azurerm_linux_virtual_machine_scale_set.ado_pool[0].identity[0].principal_id, null)
  description = "Virtual Machine Scale Set SystemAssigned Identity"
}

output "vmss_user_assigned_identity_ids" {
  value       = try(azurerm_linux_virtual_machine_scale_set.ado_pool[0].identity[0].identity_ids, null)
  description = "Virtual Machine Scale Set UserAssigned Identities"
}
