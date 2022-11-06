# Azure Virtual Machine Scale Set

In this example instead of using a Marketplace operating system image we will use a custom built source image.
The custom image that we will us is the same image that is used by Azure DevOps [Microsoft-hosted agents][ms-hosted]
and [GitHub-hosted runners][github-hosted].

You can learn more about and also create this image yourself by following along with [Azure DevOps Self-Hosted VMSS Agents Part 1][vmss-series-1].

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| azurerm | >=3.1.0 |
| http | >=3.2.0 |
| tls | ~>4.0 |
## Providers

| Name | Version |
|------|---------|
| azurerm | 3.30.0 |
| http | 3.2.0 |
| tls | 4.0.4 |
## Modules

| Name | Source | Version |
|------|--------|---------|
| vmss | tonyskidmore/vmss/azurerm | 0.2.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ssh\_port | SSH port number | `number` | `22` | no |
| tags | Map of the tags to use for the resources that are deployed | `map(string)` | <pre>{<br>  "environment": "test",<br>  "project": "vmss"<br>}</pre> | no |
| vmss\_admin\_password | Password associated to vmss\_admin\_username | `string` | `null` | no |
| vmss\_instances | Number of initial instances in the Virtual Machine Scale Set to create | `number` | n/a | yes |
| vmss\_name | Name of the Virtual Machine Scale Set to create | `string` | n/a | yes |
| vmss\_resource\_group\_name | Existing resource group name of where the VMSS will be created | `string` | n/a | yes |
| vmss\_se\_enabled | Whether to enable the VMSS custom script extension | `bool` | n/a | yes |
| vmss\_se\_settings\_data | The base64 encoded data to use as the script for the VMSS custom script extension | `string` | `null` | no |
| vmss\_se\_settings\_script | The path of the file to use as the script for the VMSS custom script extension | `string` | n/a | yes |
| vmss\_subnet\_address\_prefixes | Subnet address prefixes | `list(string)` | n/a | yes |
| vmss\_subnet\_name | Name of subnet where the vmss will be connected | `string` | n/a | yes |
| vmss\_vnet\_address\_space | Vnet network address spaces | `list(string)` | n/a | yes |
| vmss\_vnet\_name | Name of the Vnet that the target subnet is a member of | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| acg\_versions | Available ACG image versions |
| public\_ip | Public IP associate to VMSS load balancer |
| source\_ip | Source IP address of Terraform execution |
| tls\_private\_key | SSH privatte key |
| vmss\_id | Virtual Machine Scale Set ID |

Example

```hcl
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
  version                                     = "0.2.0"
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
```
<!-- END_TF_DOCS -->

[ms-hosted]: https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/hosted
[github-hosted]: https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners
[vmss-series-1]: https://www.skidmore.co.uk/post/2022_04_19_azure_devops_vmss_agents_part1/
