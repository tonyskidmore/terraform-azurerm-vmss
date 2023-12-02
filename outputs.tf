output "vmss_id" {
  value = (
    var.vmss_os == "linux" ?
    try(azurerm_linux_virtual_machine_scale_set.ado_pool[0].id, null) :
    try(azurerm_windows_virtual_machine_scale_set.ado_pool[0].id, null)
  )
  description = "Virtual Machine Scale Set ID"
}

output "vmss" {
  value = (
    var.vmss_os == "linux" ?
    try(azurerm_linux_virtual_machine_scale_set.ado_pool[0], null) :
    try(azurerm_windows_virtual_machine_scale_set.ado_pool[0], null)
  )
  description = "Virtual Machine Scale Set object"
}

output "vmss_system_assigned_identity_id" {
  value = (
    var.vmss_os == "linux" ?
    try(azurerm_linux_virtual_machine_scale_set.ado_pool[0].identity[0].principal_id, null) :
    try(azurerm_windows_virtual_machine_scale_set.ado_pool[0].identity[0].principal_id, null)
  )
  description = "Virtual Machine Scale Set SystemAssigned Identity"
}

output "vmss_user_assigned_identity_ids" {
  value = (
    var.vmss_os == "linux" ?
    try(azurerm_linux_virtual_machine_scale_set.ado_pool[0].identity[0].identity_ids, null) :
    try(azurerm_windows_virtual_machine_scale_set.ado_pool[0].identity[0].identity_ids, null)
  )
  description = "Virtual Machine Scale Set UserAssigned Identities"
}
