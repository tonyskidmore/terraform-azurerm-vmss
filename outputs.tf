output "vmss_id" {
  value       = try(local.vmss_resource.id, null)
  description = "Virtual Machine Scale Set resource ID"
}

output "vmss_name" {
  value       = try(local.vmss_resource.name, null)
  description = "Virtual Machine Scale Set name"
}

output "vmss_unique_id" {
  value       = try(local.vmss_resource.unique_id, null)
  description = "The generated unique identifier of the Virtual Machine Scale Set"
}

output "vmss_identity" {
  value = {
    principal_id               = try(local.vmss_resource.identity[0].principal_id, null)
    tenant_id                  = try(local.vmss_resource.identity[0].tenant_id, null)
    user_assigned_identity_ids = try(local.vmss_resource.identity[0].identity_ids, [])
  }
  description = "Flattened managed identity details for the Virtual Machine Scale Set"
}
