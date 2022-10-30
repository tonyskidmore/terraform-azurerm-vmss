# required variables

variable "vmss_resource_group_name" {
  type        = string
  description = "Existing resource group name of where the VMSS will be created"
}

variable "vmss_subnet_id" {
  type        = string
  description = "Existing subnet ID of where the VMSS will be connected"
}

# variables with predefined defaults

variable "vmss_location" {
  type        = string
  description = "Existing resource group name of where the VMSS will be created"
  default     = "uksouth"
}

# needs to be enabled on the subscription, see:
# Use the Azure CLI to enable end-to-end encryption using encryption at host
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/disks-enable-host-based-encryption-cli
variable "vmss_encryption_at_host_enabled" {
  type        = bool
  description = "Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?"
  default     = false
}

variable "tags" {
  description = "Tags to apply to Azure Virtual Machine Scale"
  type        = map(string)
  default     = {}
}

variable "vmss_os" {
  type        = string
  description = "Whether to process the Linux Virtual Machine Scale Set resource"
  default     = "linux"
}

variable "vmss_name" {
  type        = string
  description = "Azure Virtual Machine Scale Set name"
  default     = "azdo-vmss-pool-001"
}

variable "vmss_sku" {
  type        = string
  description = "Azure Virtual Machine Scale Set SKU"
  default     = "Standard_D2_v3"
}

variable "vmss_instances" {
  type        = number
  description = "Azure Virtual Machine Scale Set number of instances"
  default     = 0
}

variable "vmss_admin_username" {
  type        = string
  description = "Azure Virtual Machine Scale Set instance administrator name"
  default     = "adminuser"
}

variable "vmss_admin_password" {
  type        = string
  description = "Azure Virtual Machine Scale Set instance administrator password"
  default     = null
}

variable "vmss_source_image_id" {
  description = "Azure Virtual Machine Scale Set Image ID"
  type        = string
  default     = null
}

variable "vmss_source_image_offer" {
  description = "Azure Virtual Machine Scale Set Source Image Offer"
  type        = string
  default     = "0001-com-ubuntu-server-focal"
}

variable "vmss_source_image_publisher" {
  description = "Azure Virtual Machine Scale Set Source Image Publisher"
  type        = string
  default     = "Canonical"
}

variable "vmss_source_image_sku" {
  description = "Azure Virtual Machine Scale Set Source Image SKU"
  type        = string
  default     = "20_04-lts"
}

variable "vmss_source_image_version" {
  description = "Azure Virtual Machine Scale Set Source Image Version"
  type        = string
  default     = "latest"
}

variable "vmss_ssh_public_key" {
  description = "Public key to use for SSH access to VMs"
  type        = string
  default     = ""
}

variable "vmss_storage_account_uri" {
  type        = string
  description = "VMSS boot diagnostics storage account URI"
  default     = null
}

variable "vmss_os_disk_caching" {
  type        = string
  description = "The Type of Caching which should be used for the Internal OS Disk"
  default     = "ReadOnly"

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.vmss_os_disk_caching)
    error_message = "The vmss_os_disk_caching must be a valid type."
  }
}

variable "vmss_os_disk_storage_account_type" {
  type        = string
  description = "The Type of Storage Account which should back this the Internal OS Disk"
  default     = "StandardSSD_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.vmss_os_disk_storage_account_type)
    error_message = "The vmss_os_disk_storage_account_type must be a valid type."
  }
}

variable "vmss_disk_size_gb" {
  type        = number
  description = "The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine Scale Set is sourced from"
  default     = null
}

variable "vmss_resource_prefix" {
  type        = string
  description = "Prefix to apply to VMSS resources"
  default     = "vmss"
}

variable "vmss_custom_data" {
  type        = string
  description = "The base64 encoded data to use as custom data for the VMSS instances"
  default     = null
}

variable "vmss_identity_type" {
  type        = string
  description = "Specifies the type of Managed Service Identity that should be configured on this Linux Virtual Machine Scale Set`"
  default     = null

  validation {
    condition     = var.vmss_identity_type != null ? alltrue([for v in split(",", var.vmss_identity_type) : contains(["SystemAssigned", "UserAssigned"], trimspace(v))]) : true
    error_message = "The vmss_identity_type must be a valid type."
  }
}

variable "vmss_identity_ids" {
  type        = list(string)
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Linux Virtual Machine Scale Set"
  default     = null
}

variable "vmss_zones" {
  type        = list(string)
  description = "A collection of availability zones to spread the Virtual Machines over"
  default     = []
}
