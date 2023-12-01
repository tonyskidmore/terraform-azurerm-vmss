variable "vmss_deployments" {
  description = "VMSS deployments"
  type = map(object({
    vmss_name                   = string
    vmss_computer_name_prefix   = string
    vmss_se_enabled             = bool
    vmss_win_se_settings        = string
    vmss_source_image_publisher = optional(string)
    vmss_source_image_offer     = optional(string)
    vmss_source_image_sku       = optional(string)
    vmss_source_image_version   = optional(string)
  }))

  default = {}
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

variable "tags" {
  type        = map(string)
  description = "Map of the tags to use for the resources that are deployed"
  default = {
    environment = "test"
    project     = "vmss"
  }
}
