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

