
variable "vmss_os" {
  type        = string
  description = "Whether to deploy a Linux or Windows Virtual Machine Scale Set resource"
}

variable "vmss_name" {
  type        = string
  description = "Name of the Virtual Machine Scale Set to create"
}

variable "vmss_computer_name_prefix" {
  type        = string
  description = "The prefix which should be used for the name of the Virtual Machines in this Scale Set"
  default     = null
}

variable "vmss_resource_group_name" {
  type        = string
  description = "Existing resource group name of where the VMSS will be created"
}

variable "vmss_location" {
  type        = string
  description = "Azure location"
}

variable "vmss_subnet_name" {
  type        = string
  description = "Name of subnet where the vmss will be connected"
}

variable "vmss_subnet_address_prefixes" {
  type        = list(string)
  description = "Subnet address prefixes"
}

variable "vmss_vnet_name" {
  type        = string
  description = "Name of the Vnet that the target subnet is a member of"
}

variable "vmss_vnet_address_space" {
  type        = list(string)
  description = "Vnet network address spaces"
}

variable "vmss_admin_password" {
  type        = string
  description = "Password to allocate to the admin user account"
}

variable "vmss_enable_automatic_updates" {
  type        = string
  description = "Are automatic updates enabled for this Virtual Machine? (Windows)"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Map of the tags to use for the resources that are deployed"
  default = {
    environment = "test"
    project     = "vmss"
  }
}

variable "vmss_se_enabled" {
  type        = bool
  description = "Whether to process the Linux Virtual Machine Scale Set extension resource"
  default     = false
}

variable "vmss_user_data" {
  description = "The base64 encoded data to use as user data for the VMSS instances"
  type        = string
  default     = null
}

variable "vmss_win_se_settings_script" {
  type        = string
  description = "The path of the file to use as the script for the Windows VMSS custom script extension"
  default     = "scripts/Start-VmssConfig.ps1"
}

variable "vmss_win_se_settings_data" {
  type        = string
  description = "The base64 encoded data to use as the script for the Windows VMSS custom script extension"
  default     = "scripts/Set-VmssConfig.ps1"
}

variable "vmss_win_se_settings" {
  type        = string
  description = "The value to pass to the Windows VMSS custom script extension"
  default     = null
}
