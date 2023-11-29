locals {

  # TODO: probably need to do something about this
  disable_password_authentication = var.vmss_admin_password == null ? true : false

  # TODO: do something about Windows script
  # we are assuming that if the azurerm_virtual_machine_scale_set_extension is enabled (var.vmss_se_enabled)
  # we want to run the script specified, defaulting to resolving the path issue as per:
  # https://www.skidmore.co.uk/post/2022_04_20_azure_devops_vmss_agents_part2/#path-issue
  # other scripts can be added to the module and used or base64 content can be passed in via var.vmss_se_settings_data
  # first non-empty value will be returned

  # See:
  # https://learn.microsoft.com/en-us/azure/virtual-machines/custom-data
  # https://learn.microsoft.com/en-us/azure/virtual-machines/instance-metadata-service
  vmss_se_settings = (
    var.vmss_os == "linux" ?
    jsonencode({ "script" = coalesce(var.vmss_se_settings_data, filebase64("${path.module}/${var.vmss_se_settings_script}")) }) :
    jsonencode({ "commandToExecute" = "PowerShell -ExecutionPolicy Unrestricted -EncodedCommand ${textencodebase64(
    file("${path.module}/${var.vmss_win_se_settings_script}"), "UTF-16LE")}" })
    # coalesce(jsonencode(var.vmss_win_se_settings), jsonencode(
    #                                               { "commandToExecute" = "PowerShell -ExecutionPolicy Unrestricted -EncodedCommand ${textencodebase64(
    #                                                 file("${path.module}/${var.vmss_win_se_settings_script}"),"UTF-16LE")}" })
    # )
  )

  custom_data = (
    var.vmss_os == "linux" ?
    var.vmss_custom_data :
    (
      var.vmss_se_enabled == true ?
      coalesce(var.vmss_custom_data, filebase64("${path.module}/${var.vmss_win_se_settings_data}")) :
      null
    )
  )

  source_images = {
    "linux" = {
      offer     = coalesce(var.vmss_source_image_offer, "0001-com-ubuntu-server-focal"),
      publisher = coalesce(var.vmss_source_image_publisher, "Canonical"),
      sku       = coalesce(var.vmss_source_image_sku, "20_04-lts"),
      version   = coalesce(var.vmss_source_image_version, "latest")
    },
    "windows" = {
      offer     = coalesce(var.vmss_source_image_offer, "WindowsServer"),
      publisher = coalesce(var.vmss_source_image_offer, "MicrosoftWindowsServer"),
      sku       = coalesce(var.vmss_source_image_offer, "2022-datacenter-core"),
      # sku       = coalesce(var.vmss_source_image_offer, "2019-Datacenter-Core"),
      version = coalesce(var.vmss_source_image_offer, "latest")
    }
    # "windows" = {
    #   offer     = coalesce(var.vmss_source_image_offer, "WindowsServer"),
    #   publisher = coalesce(var.vmss_source_image_offer, "MicrosoftWindowsServer"),
    #   sku       = coalesce(var.vmss_source_image_offer, "ws2019-dotnetcore-2-2"),
    #   version   = coalesce(var.vmss_source_image_offer, "latest")
  }
}

# az vm image list --publisher MicrosoftWindowsServer --query "[?version=='latest']"
# az vm image list --publisher MicrosoftWindowsServer --all --query "[?contains(sku, 'core')]"
# az vm image list --publisher MicrosoftWindowsServer --query "[?contains(sku, '2019')]" | jq -r '[(.[].sku )] | unique'
# az vm image list --publisher MicrosoftWindowsServer --query "[?contains(sku, 'core')]" | jq -r '[(.[].sku )] | unique'
# az vm image list --publisher MicrosoftWindowsServer --query "[?contains(sku, 'core')]" --all | jq -r '[(.[].sku )] | unique'

