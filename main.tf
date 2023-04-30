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
  user_data                       = var.vmss_user_data
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

  dynamic "data_disk" {
    for_each = var.vmss_data_disks
    content {
      caching              = data_disk.value.caching
      create_option        = data_disk.value.create_option
      disk_size_gb         = data_disk.value.disk_size_gb
      lun                  = data_disk.value.lun
      storage_account_type = data_disk.value.storage_account_type
    }
  }

  network_interface {
    name    = "${var.vmss_resource_prefix}-nic"
    primary = true

    ip_configuration {
      name                                   = "${var.vmss_resource_prefix}-ipconfig"
      primary                                = true
      subnet_id                              = var.vmss_subnet_id
      load_balancer_backend_address_pool_ids = var.vmss_load_balancer_backend_address_pool_ids
    }
  }

  boot_diagnostics {
    storage_account_uri = var.vmss_storage_account_uri
  }

  dynamic "extension" {
    for_each = var.vmss_se_enabled ? [1] : []
    content {
      name                 = "vmss_se"
      publisher            = "Microsoft.Azure.Extensions"
      type                 = "CustomScript"
      type_handler_version = "2.0"
      settings             = local.vmss_se_settings
    }
  }
}
