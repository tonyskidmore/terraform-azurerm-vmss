locals {

  disable_password_authentication = var.vmss_admin_password == null ? true : false

  # we are assuming that if the azurerm_virtual_machine_scale_set_extension is enabled (var.vmss_se_enabled)
  # we want to run the script specified, defaulting to resolving the path issue as per:
  # https://www.skidmore.co.uk/post/2022_04_20_azure_devops_vmss_agents_part2/#path-issue
  # other scripts can be added to the module and used or base64 content can be passed in via var.vmss_se_settings_data
  # first non-empty value will be returned
  vmss_se_settings = jsonencode(
    {
      "script" : coalesce(var.vmss_se_settings_data, filebase64("${path.module}/${var.vmss_se_settings_script}"))
    }
  )
}
