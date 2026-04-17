variable "vmss_name" {
  type        = string
  description = "Name of the Virtual Machine Scale Set to create"
}

variable "vmss_resource_group_name" {
  type        = string
  description = "Resource group name to create for the VMSS"
}

variable "vmss_location" {
  type        = string
  description = "Azure location"
}

variable "vmss_subnet_name" {
  type        = string
  description = "Name of subnet where the VMSS will be connected"
}

variable "vmss_subnet_address_prefixes" {
  type        = list(string)
  description = "Subnet address prefixes"
}

variable "vmss_vnet_name" {
  type        = string
  description = "Name of the virtual network"
}

variable "vmss_vnet_address_space" {
  type        = list(string)
  description = "Virtual network address spaces"
}

variable "vmss_admin_password" {
  type        = string
  description = "Admin password for the VMSS instances"
  sensitive   = true
}

variable "user_assigned_identity_name" {
  type        = string
  description = "Name of the User Assigned Managed Identity to create and attach to the VMSS"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default = {
    environment = "test"
    project     = "vmss"
    example     = "identity_user_assigned"
  }
}
