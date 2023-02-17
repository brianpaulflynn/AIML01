# must run from cmd prompt: az vm image terms accept --urn microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:latest
# ref: https://github.com/anoff/tf-azure-datascience
variable "vm-name" {
  default = "ds01"
}

# resource "tls_private_key" "example_ssh" {
#   algorithm = "RSA"
#   rsa_bits = 4096
# }
# output "tls_private_key" { 
#     value = tls_private_key.example_ssh.private_key_pem 
#     sensitive = true
# }

resource "azurerm_public_ip" "ds-pip" {
  name                = "${var.vm-name}-pip"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  allocation_method   = "Dynamic"
  tags = {
    environment = "Production"
  }
  depends_on = [azurerm_resource_group.default]
}

resource "random_string" "vm_password" {
  length  = 16
  upper   = true
  special = false
  numeric  = true 
}

resource "azurerm_network_interface" "ds" {
  name                = "${var.vm-name}-ni"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"

  ip_configuration {
    name                          = "dsconfiguration1"
    subnet_id                     = "${azurerm_subnet.ds.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.ds-pip.id
  }
}

resource "azurerm_virtual_machine" "ds" {
  name                  = "${var.vm-name}-vm"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.default.name}"
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
    computer_name  = "${var.vm-name}" #"hostname"
    admin_username = "${var.admin_username}" 
    admin_password = random_string.vm_password.result 
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

#   tags {
#     environment = "datascience-vm, ${var.vm-name}"
#   }

    # admin_ssh_key {
    #     username       = "azureuser"
    #     public_key     = file("~/.ssh/id_rsa.pub")
    # }

  #   connection {
  #     #host      = "${data.azurerm_public_ip.ds-pip.ip_address}" 
  #     host      = "${azurerm_public_ip.ds-pip.ip_address}"
  #     user      = "${var.admin_username}"
  #     type      = "ssh"
  #     password  = "${random_string.vm_password.result}"
  #     agent = true    
  #     # private_key = "${file("~/.ssh/id_rsa")}"
  #     # timeout = "4m"  
  #   }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1",
  #     "sudo apt-get update",
  #     "sudo apt-get install -y python3-pip",
  #     "sudo -H pip3 install --upgrade pip",
  #     "pip3 install jupyter",
  #     "pip3 install matplotlib tensorflow-gpu==2.10.0",
  #     "pip3 install azure-ai-ml==1.2.0 azure-identity==1.12.0"
  #   ]
  # }
}

resource "time_sleep" "stall_for_pip" {
  depends_on = [ 
    azurerm_virtual_machine.ds
    ]
  create_duration = "15s" # wait a little after public IP is bound to VM so it is assigned.
}
data "azurerm_public_ip" "ds-pip" {
  name = azurerm_public_ip.ds-pip.name
  resource_group_name = azurerm_resource_group.default.name
  depends_on = [ time_sleep.stall_for_pip ]
}
resource "null_resource" "copy-config-file" {
  connection {
    type     = "ssh"
    host     = "${data.azurerm_public_ip.ds-pip.ip_address}"
    user     = "${var.admin_username}"
    password = "${random_string.vm_password.result}"
  }
  provisioner "file" {
    source      = "../scripts/config-vm.sh"
    destination = "config-vm.sh"
  }
}
# variable "source_files" {
#   default = fileset("../scripts/", "*")
# }
# resource "local_file" "dest" {
#   for_each = var.source_files
#   filename       = "..scripts/${each.value}"
#   content_base64 = filebase64("~/${each.value}")
# }

# resource "null_resource" "copy-labs" {
#   connection {
#     type     = "ssh"
#     host     = "${data.azurerm_public_ip.ds-pip.ip_address}"
#     user     = "${var.admin_username}"
#     password = "${random_string.vm_password.result}"
#   }
#   provisioner "file" {
#     source      = "../sazureml-tutorial/*"
#     destination = "sazureml-tutorial/"
#   }
# }
# resource "azurerm_virtual_machine_extension" "helloterraformvm" {
#   name                 = "${var.vm-name}-ext2"
#   virtual_machine_id   = "${azurerm_virtual_machine.ds.id}"
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"
#   depends_on = [ null_resource.copy-config-file ]
#   protected_settings = <<PROT
#     {
#         "commandToExecute": "${base64encode(file("../scripts/config-vm.sh"))}"
#     }
#     PROT
# }


