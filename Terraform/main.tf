resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

locals {
  dns_servers = [
    "192.168.2.51",
    "192.168.2.52",
    "192.168.2.53",
    "192.168.2.54"
  ]

  vms = {
    ContosoDC1  = { ip = "192.168.2.51", role = "contoso_dc_primary" }
    ContosoDC2  = { ip = "192.168.2.52", role = "contoso_dc_additional" }
    ChildDC1    = { ip = "192.168.2.53", role = "child_dc_primary" }
    FabrikamDC1 = { ip = "192.168.2.54", role = "fabrikam_dc_primary" }
    Client1     = { ip = "192.168.2.65", role = "contoso_client" }
    Server1     = { ip = "192.168.2.67", role = "contoso_member" }
    Client2     = { ip = "192.168.2.66", role = "child_client" }
    ChildDC2    = { ip = "192.168.2.55", role = "child_dc_additional" }
    ChildDC3    = { ip = "192.168.2.56", role = "child_dc_additional" }
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = var.address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_servers         = local.dns_servers
}

resource "azurerm_subnet" "lab" {
  name                 = "LabSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.lab_subnet_prefix]
}

resource "azurerm_network_security_group" "lab" {
  name                = "${var.prefix}-lab-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowBastionRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "AzureCloud"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVNetIntra"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_subnet_network_security_group_association" "lab" {
  subnet_id                 = azurerm_subnet.lab.id
  network_security_group_id = azurerm_network_security_group.lab.id
}

# Optional: Bastion
resource "azurerm_subnet" "bastion" {
  count                = var.use_bastion ? 1 : 0
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.bastion_subnet_prefix]
}

resource "azurerm_public_ip" "bastion" {
  count               = var.use_bastion ? 1 : 0
  name                = "${var.prefix}-bastion-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  count               = var.use_bastion ? 1 : 0
  name                = "${var.prefix}-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion[0].id
    public_ip_address_id = azurerm_public_ip.bastion[0].id
  }
}

# Availability set for DCs
resource "azurerm_availability_set" "dc_as" {
  name                = "${var.prefix}-dc-as"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed = true
}

# NICs
resource "azurerm_network_interface" "nic" {
  for_each            = local.vms
  name                = "${each.key}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_servers         = local.dns_servers

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.lab.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.ip
  }
}

# Windows VMs
resource "azurerm_windows_virtual_machine" "vm" {
  for_each              = local.vms
  name                  = each.key
  computer_name         = each.key
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  availability_set_id   = contains(["contoso_dc_primary","contoso_dc_additional","child_dc_primary","child_dc_additional","fabrikam_dc_primary"], each.value.role) ? azurerm_availability_set.dc_as.id : null

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}

output "vm_private_ips_map" {
  description = "Private IPs for lab VMs (map)"
  value       = { for k, v in azurerm_network_interface.nic : k => v.ip_configuration[0].private_ip_address }
}