output "vmss_id" {
  value       = azurerm_linux_virtual_machine_scale_set.ado_pool[0].id
  description = "Virtual Machine Scale Set ID"
}
