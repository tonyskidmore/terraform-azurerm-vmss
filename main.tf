# data "azurerm_client_config" "current" {}


resource "azurerm_linux_virtual_machine_scale_set" "ado_pool" {
  count                           = var.vmss_os == "linux" ? 1 : 0
  name                            = var.vmss_name
  resource_group_name             = var.vmss_resource_group_name
  location                        = var.vmss_location
  sku                             = var.vmss_sku
  instances                       = var.vmss_instances
  encryption_at_host_enabled      = var.vmss_encryption_at_host_enabled
  admin_username                  = var.vmss_admin_username
  admin_password                  = var.vmss_admin_password
  disable_password_authentication = local.disable_password_authentication
  source_image_id                 = var.vmss_source_image_id
  tags                            = var.tags
  custom_data                     = var.vmss_custom_data
  zones                           = var.vmss_zones
  # https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops#create-the-scale-set
  overprovision = false
  upgrade_mode  = "Manual"

  dynamic "admin_ssh_key" {
    for_each = var.vmss_ssh_public_key == "" ? [] : [1]
    content {
      username   = var.vmss_admin_username
      public_key = var.vmss_ssh_public_key
    }
  }

  lifecycle {
    ignore_changes = [
      extension,
      # tags,
      tags["__AzureDevOpsElasticPool"],
      tags["__AzureDevOpsElasticPoolTimeStamp"],
      automatic_instance_repair,
      automatic_os_upgrade_policy,
      instances
    ]
  }

  dynamic "source_image_reference" {
    for_each = var.vmss_source_image_id != null ? [] : [1]
    content {
      offer     = var.vmss_source_image_offer
      publisher = var.vmss_source_image_publisher
      sku       = var.vmss_source_image_sku
      version   = var.vmss_source_image_version
    }
  }


  dynamic "identity" {
    for_each = var.vmss_identity_type != null ? [1] : []
    content {
      type         = var.vmss_identity_type
      identity_ids = var.vmss_identity_type == "UserAssigned" || var.vmss_identity_type == "SystemAssigned, UserAssigned" ? var.vmss_identity_ids : null
    }
  }

  os_disk {
    storage_account_type = var.vmss_os_disk_storage_account_type
    caching              = var.vmss_os_disk_caching
    disk_size_gb         = var.vmss_disk_size_gb
  }

  network_interface {
    name    = "${var.vmss_resource_prefix}-nic"
    primary = true

    ip_configuration {
      name      = "${var.vmss_resource_prefix}-ipconfig"
      primary   = true
      subnet_id = var.vmss_subnet_id
    }
  }

  boot_diagnostics {
    storage_account_uri = var.vmss_storage_account_uri
  }
}

# TODO: remove references
# https://github.com/anandraju/vmss_customscript_ado/blob/main/vmss-creation.tf
# https://github.com/MicrosoftDocs/azure-docs/issues/10862
# this shoudl be in root module
# resource "azurerm_virtual_machine_scale_set_extension" "ado_pool" {
#   count                        = var.vmss_se_enabled ? 1 : 0
#   name                         = "vmss_se"
#   virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.ado_pool[0].id
#   publisher                    = "Microsoft.Azure.Extensions"
#   type                         = "CustomScript"
#   type_handler_version         = "2.0"
#   settings                     = local.vmss_se_settings
# }
