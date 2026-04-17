output "vmss_id" {
  value       = try(local.vmss_resource.id, null)
  description = "Virtual Machine Scale Set resource ID"
}

output "vmss_name" {
  value       = try(local.vmss_resource.name, null)
  description = "Virtual Machine Scale Set name"
}

output "vmss_location" {
  value       = try(local.vmss_resource.location, null)
  description = "Azure region the VMSS was deployed to"
}

output "vmss_sku" {
  value       = try(local.vmss_resource.sku, null)
  description = "VM SKU in use by the VMSS"
}

output "vmss_instances" {
  value       = try(local.vmss_resource.instances, null)
  description = "Number of instances configured on the VMSS"
}

output "vmss_unique_id" {
  value       = try(local.vmss_resource.unique_id, null)
  description = "The generated unique identifier of the Virtual Machine Scale Set"
}

output "vmss_data_disks" {
  value       = try(local.vmss_resource.data_disk, [])
  description = "Data disks configured on the Virtual Machine Scale Set, as accepted by Azure post-apply"
}

output "vmss_identity" {
  value = {
    # AzureRM returns "" (not null) when a given identity field is unset;
    # normalize so consumers can do `identity.principal_id != null` checks.
    principal_id               = try(local.vmss_resource.identity[0].principal_id, "") != "" ? local.vmss_resource.identity[0].principal_id : null
    tenant_id                  = try(local.vmss_resource.identity[0].tenant_id, "") != "" ? local.vmss_resource.identity[0].tenant_id : null
    user_assigned_identity_ids = try(local.vmss_resource.identity[0].identity_ids, [])
  }
  description = "Flattened managed identity details for the Virtual Machine Scale Set"
}
