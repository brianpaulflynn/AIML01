resource "azurerm_virtual_network" "ds" {
  name                = "ds-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
}

resource "azurerm_subnet" "ds" {
  name                 = "ds-subnet"
  resource_group_name  = "${azurerm_resource_group.default.name}"
  virtual_network_name = "${azurerm_virtual_network.ds.name}"
  address_prefixes     = [ "10.0.2.0/24" ]
}

resource "azurerm_network_security_group" "ds-nsg" {
  name                = "ds-nsg"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_network_security_group_association" "ds" {
  subnet_id                 = azurerm_subnet.ds.id
  network_security_group_id = azurerm_network_security_group.ds-nsg.id
}

