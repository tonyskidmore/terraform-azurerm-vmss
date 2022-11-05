variable "vmss_name" {
  type        = string
  description = "Name of the Virtual Machine Scale Set to create"
}

variable "vmss_instances" {
  type        = number
  description = "Number of initial instances in the Virtual Machine Scale Set to create"
}

variable "vmss_admin_password" {
  type        = string
  description = "Password associated to vmss_admin_username"
}

variable "vmss_resource_group_name" {
  type        = string
  description = "Existing resource group name of where the VMSS will be created"
}

variable "vmss_vnet_resource_group_name" {
  type        = string
  description = "Existing resource group where the Vnet containing the subnet is located"
}

variable "vmss_subnet_name" {
  type        = string
  description = "Name of subnet where the vmss will be connected"
}

variable "vmss_vnet_name" {
  type        = string
  description = "Name of the Vnet that the target subnet is a member of"
}

variable "vmss_se_enabled" {
  type        = bool
  description = "Whether to enable the VMSS custom script extension"
}

variable "vmss_se_settings_data" {
  type        = string
  description = "The base64 encoded data to use as the script for the VMSS custom script extension"
  default     = null
}

variable "vmss_se_settings_script" {
  type        = string
  description = "The path of the file to use as the script for the VMSS custom script extension"
}
