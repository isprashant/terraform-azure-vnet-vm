terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id = "4d08eb22-ff8d-4693-ae72-2e8e33d392fc"
}


resource "azurerm_resource_group" "oc_rg" {
  name     = "oc-resources"
  location = "centralindia"
  tags = {
    environment = "dev"
  }
}


resource "azurerm_virtual_network" "oc_vn" {
  name                = "oc-network"
  resource_group_name = azurerm_resource_group.oc_rg.name
  location            = azurerm_resource_group.oc_rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}


resource "azurerm_subnet" "oc_sn" {
  name                 = "oc-subnet"
  resource_group_name  = azurerm_resource_group.oc_rg.name
  virtual_network_name = azurerm_virtual_network.oc_vn.name
  address_prefixes     = ["10.123.1.0/24"]
}


resource "azurerm_network_security_group" "oc_nsg" {
  name                = "oc-security_group"
  location            = azurerm_resource_group.oc_rg.location
  resource_group_name = azurerm_resource_group.oc_rg.name
  tags = {
    environment = "dev"
  }

}


resource "azurerm_network_security_rule" "oc_dev_rule" {
  name                        = "oc-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "58.84.61.187/32"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.oc_rg.name
  network_security_group_name = azurerm_network_security_group.oc_nsg.name
}


resource "azurerm_subnet_network_security_group_association" "oc_sga" {
  subnet_id                 = azurerm_subnet.oc_sn.id
  network_security_group_id = azurerm_network_security_group.oc_nsg.id
}

resource "azurerm_public_ip" "oc_ip" {
  name                = "oc-ip"
  resource_group_name = azurerm_resource_group.oc_rg.name
  location            = azurerm_resource_group.oc_rg.location
  allocation_method   = "Static"

  tags = {
    environment = "dev"
  }
}


resource "azurerm_network_interface" "oc_nic" {
  name                = "oc-nic"
  location            = azurerm_resource_group.oc_rg.location
  resource_group_name = azurerm_resource_group.oc_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.oc_sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.oc_ip.id
  }

  tags = {
    environment = "dev"
  }
}


resource "azurerm_linux_virtual_machine" "oc_vm" {
  name                = "oc-vm-1"
  resource_group_name = azurerm_resource_group.oc_rg.name
  location            = azurerm_resource_group.oc_rg.location
  size                = "Standard_D2as_v5"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.oc_nic.id,
  ]

  custom_data = filebase64("customedata.tpl")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntuServer"
    sku       = "18.04-lts"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname = self.public_ip_address,
      user = "adminuser"
    })
    interpreter = ["powershell", "-Command"]
  }

  tags = {
    environment="dev"
  }
}

data "azurerm_public_ip" "oc_ip_data" {
  name = azurerm_public_ip.oc_ip.name
  resource_group_name = azurerm_resource_group.oc_rg.name
}

output "public_ip_address" {
  value = "${azurerm_linux_virtual_machine.oc_vm.name}: ${data.azurerm_public_ip.oc_ip_data.ip_address}"
}