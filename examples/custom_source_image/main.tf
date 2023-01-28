data "azurerm_shared_image_version" "runner-image" {
  name                = "latest"
  image_name          = "ubuntu20"
  gallery_name        = "acg_01"
  resource_group_name = "rg-ve-acg-01"
}

data "azurerm_resource_group" "vmss" {
  name = var.vmss_resource_group_name
}

data "http" "ifconfig" {
  url = "https://ifconfig.me/ip"
}

resource "tls_private_key" "vmss_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_virtual_network" "vmss" {
  name                = var.vmss_vnet_name
  resource_group_name = data.azurerm_resource_group.vmss.name
  address_space       = var.vmss_vnet_address_space
  location            = data.azurerm_resource_group.vmss.location
  tags                = var.tags
}

resource "azurerm_subnet" "agents" {
  name                 = var.vmss_subnet_name
  resource_group_name  = data.azurerm_resource_group.vmss.name
  address_prefixes     = var.vmss_subnet_address_prefixes
  virtual_network_name = azurerm_virtual_network.vmss.name
}

resource "azurerm_public_ip" "vmss" {
  name                = "pip-vmss-linux-002"
  location            = data.azurerm_resource_group.vmss.location
  resource_group_name = data.azurerm_resource_group.vmss.name
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_lb" "vmss" {
  name                = "lb-vmss-linux-002"
  location            = data.azurerm_resource_group.vmss.location
  resource_group_name = data.azurerm_resource_group.vmss.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vmss.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.vmss.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss" {
  loadbalancer_id = azurerm_lb.vmss.id
  name            = "ssh-running-probe"
  port            = var.ssh_port
}

resource "azurerm_lb_rule" "lbnatrule" {
  loadbalancer_id                = azurerm_lb.vmss.id
  name                           = "ssh"
  protocol                       = "Tcp"
  frontend_port                  = var.ssh_port
  backend_port                   = var.ssh_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.vmss.id
}

resource "azurerm_network_security_group" "vmss" {
  name                = "nsg-vmss-linux-002"
  location            = data.azurerm_resource_group.vmss.location
  resource_group_name = data.azurerm_resource_group.vmss.name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "nsg-rule-ssh-mgmt" {
  name                        = "ssh-vmss"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.ssh_port
  source_address_prefix       = "${data.http.ifconfig.response_body}/32"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.vmss.name
  network_security_group_name = azurerm_network_security_group.vmss.name
}

resource "azurerm_subnet_network_security_group_association" "nsg-rule" {
  subnet_id                 = azurerm_subnet.agents.id
  network_security_group_id = azurerm_network_security_group.vmss.id
}

module "vmss" {
  source                                      = "tonyskidmore/vmss/azurerm"
  version                                     = "0.3.1"
  vmss_name                                   = var.vmss_name
  vmss_resource_group_name                    = var.vmss_resource_group_name
  vmss_subnet_id                              = azurerm_subnet.agents.id
  vmss_source_image_id                        = data.azurerm_shared_image_version.runner-image.id
  vmss_ssh_public_key                         = tls_private_key.vmss_ssh.public_key_openssh
  vmss_admin_password                         = var.vmss_admin_password
  vmss_se_enabled                             = var.vmss_se_enabled
  vmss_instances                              = var.vmss_instances
  vmss_se_settings_data                       = var.vmss_se_settings_data == null ? null : base64encode(var.vmss_se_settings_data)
  vmss_se_settings_script                     = var.vmss_se_settings_script
  vmss_load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
  tags                                        = var.tags

  depends_on = [
    azurerm_lb_probe.vmss
  ]
}
