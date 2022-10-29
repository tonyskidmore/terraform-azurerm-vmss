locals {

  disable_password_authentication = var.vmss_admin_password == null ? true : false

}
