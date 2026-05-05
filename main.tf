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

resource "azurerm_resource_group" "oc-rg" {
  name     = "oc-resources"
  location = "centralindia"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "oc-vn" {
    name = "oc-network"
    resource_group_name = azurerm_resource_group.oc-rg.name
    location = azurerm_resource_group.oc-rg.location
    address_space = ["10.123.0.0/16"]

    tags = {
        environment = "dev"
    }
}