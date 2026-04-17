output "vmss_id" {
  value       = module.vmss.vmss_id
  description = "Virtual Machine Scale Set resource ID"
}

output "vmss_name" {
  value       = module.vmss.vmss_name
  description = "Virtual Machine Scale Set name"
}

output "vmss_identity" {
  value       = module.vmss.vmss_identity
  description = "Flattened managed identity details for the VMSS"
}

output "user_assigned_identity_client_id" {
  value       = azurerm_user_assigned_identity.vmss.client_id
  description = "Client ID of the user-assigned managed identity attached to the VMSS"
}
