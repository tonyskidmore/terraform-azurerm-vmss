locals {

  # Linux only - admin_password is required on Windows
  disable_password_authentication = var.vmss_admin_password == null ? true : false

  # On Linux, we are assuming that if the azurerm_virtual_machine_scale_set_extension is enabled (var.vmss_se_enabled)
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
    var.vmss_win_se_settings != null ?
    var.vmss_win_se_settings :
    jsonencode({ "commandToExecute" = "PowerShell -ExecutionPolicy Unrestricted -EncodedCommand ${textencodebase64(
    file("${path.module}/${var.vmss_win_se_settings_script}"), "UTF-16LE")}" })
  )

  # custom_data is used to transfer script content to the VMSS instances in Windows
  # and this defaults to the value of var.vmss_win_se_settings_data e.g. scripts/Set-VmssConfig.ps1
  # the custom script extension runs the var.vmss_win_se_settings_script command to launch the custom data script
  custom_data = (
    var.vmss_os == "linux" ?
    var.vmss_custom_data :
    (
      var.vmss_se_enabled == true ?
      coalesce(var.vmss_custom_data, filebase64("${path.module}/${var.vmss_win_se_settings_data}")) :
      null
    )
  )

  # defaults based on vmss_os
  source_images = {
    "linux" = {
      offer     = coalesce(var.vmss_source_image_offer, "0001-com-ubuntu-server-focal"),
      publisher = coalesce(var.vmss_source_image_publisher, "Canonical"),
      sku       = coalesce(var.vmss_source_image_sku, "20_04-lts"),
      version   = coalesce(var.vmss_source_image_version, "latest")
    },
    "windows" = {
      offer     = coalesce(var.vmss_source_image_offer, "WindowsServer"),
      publisher = coalesce(var.vmss_source_image_publisher, "MicrosoftWindowsServer"),
      sku       = coalesce(var.vmss_source_image_sku, "2022-datacenter-core"),
      version   = coalesce(var.vmss_source_image_version, "latest")
    }
  }
}
