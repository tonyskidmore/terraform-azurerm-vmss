output "vmss_id" {
  value       = try(module.vmss.vmss_id, null)
  description = "Virtual Machine Scale Set ID"
}

output "acg_versions" {
  value       = data.azurerm_shared_image_version.runner-image.id
  description = "Available ACG image versions"
}

output "tls_private_key" {
  value       = tls_private_key.vmss_ssh.private_key_pem
  description = "SSH privatte key"
  sensitive   = true
}

output "source_ip" {
  value       = data.http.ifconfig.response_body
  description = "Source IP address of Terraform execution"
}

output "public_ip" {
  value       = azurerm_public_ip.vmss.ip_address
  description = "Public IP associate to VMSS load balancer"
}
