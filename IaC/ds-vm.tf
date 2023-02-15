# must run from cmd prompt: az vm image terms accept --urn microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:latest
# ref: https://github.com/anoff/tf-azure-datascience
variable "vm-name" {
  default = "user1"
}

resource "azurerm_resource_group" "ds" {
  name     = "rcs-datascience"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "ds" {
  name                = "ds-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.ds.name}"
}

resource "azurerm_subnet" "ds" {
  name                 = "ds-subnet"
  resource_group_name  = "${azurerm_resource_group.ds.name}"
  virtual_network_name = "${azurerm_virtual_network.ds.name}"
  address_prefixes     = [ "10.0.2.0/24" ]
}

resource "azurerm_network_security_group" "ds-nsg" {
  name                = "ds-nsg"
  location            = azurerm_resource_group.ds.location
  resource_group_name = azurerm_resource_group.ds.name

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

resource "azurerm_public_ip" "ds-pip" {
  name                = "ds-pip"
  resource_group_name = azurerm_resource_group.ds.name
  location            = azurerm_resource_group.ds.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}

data "azurerm_public_ip" "ds-pip" {
  name = "ds-pip"
  resource_group_name = azurerm_resource_group.ds.name
}
output "public_ip_address" {
  #value = "${data.azurerm_public_ip.ds-pip.*.ip_address}"
  value = data.azurerm_public_ip.ds-pip.ip_address
}

resource "azurerm_network_interface" "ds" {
  name                = "ds-ni"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.ds.name}"

  ip_configuration {
    name                          = "dsconfiguration1"
    subnet_id                     = "${azurerm_subnet.ds.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = azurerm_public_ip.ds-pip.id
  }
}

resource "azurerm_virtual_machine" "ds" {
  name                  = "${var.vm-name}-vm"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.ds.name}"
  network_interface_ids = ["${azurerm_network_interface.ds.id}"]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  # plan {
  #   name = "linuxdsvmubuntu"
  #   publisher = "microsoft-ads"
  #   product = "linux-data-science-vm-ubuntu"
  # }

  storage_image_reference {
    publisher = "microsoft-dsvm" #"microsoft-ads"
    offer     = "ubuntu-2004" #"linux-data-science-vm-ubuntu"
    sku       = "2004-gen2" #"linuxdsvmubuntu"
    version     = "latest"
  }

  storage_os_disk {
    name              = "${var.vm-name}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS" #"Standard_LRS"
  }

  # Optional data disks
  # storage_data_disk {
  #   name              = "${var.vm-name}-data"
  #   managed_disk_type = "Standard_LRS"
  #   create_option     = "Attach" #"FromImage"
  #   lun               = 0
  #   disk_size_gb      = "120"
  # }

  os_profile {
    computer_name  = "hostname"
    admin_username = "${var.admin_username}" #"dsadmin"
    admin_password = "${var.admin_password}" #"Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

#   tags {
#     environment = "datascience-vm, ${var.vm-name}"
#   }
}


resource "null_resource" "copy-test-file" {

  connection {
    type     = "ssh"
    host     = "${azurerm_public_ip.ds-pip.ip_address}"
    user     = "${var.admin_username}"
    password = "${var.admin_password}"
  }t

  provisioner "file" {
    source      = "../scripts/config-vm.sh"
    destination = "config-vm.sh"
  }

}