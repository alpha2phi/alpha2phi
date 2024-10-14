terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Variable for location with default set to Southeast Asia
variable "location" {
  description = "The location/region where the resources will be deployed."
  type        = string
  default     = "southeastasia"
}

# Variable for Resource Group Name
variable "rg_name" {
  description = "The name of the Resource Group"
  type        = string
  default     = "Alpha2phi"  # Default Resource Group name
}

# Variable for VNet Name
variable "vnet_name" {
  description = "The name of the Virtual Network"
  type        = string
  default     = "Alpha2phi"  # Default VNet name
}

# Variable for Subnet 1 Name
variable "web_subnet" {
  description = "The name of the first subnet"
  type        = string
  default     = "alpha2phi_web"  # Default Subnet 1 name
}

# Variable for Subnet 2 Name
variable "app_subnet" {
  description = "The name of the second subnet"
  type        = string
  default     = "alpha2phi_app"  # Default Subnet 2 name
}

# Resource Group
resource "azurerm_resource_group" "alpha2phi_rg" {
  name     = var.rg_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "alpha2phi_vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.alpha2phi_rg.location
  resource_group_name = azurerm_resource_group.alpha2phi_rg.name
  address_space       = ["10.0.0.0/16"]

  # Subnets
  subnet {
    name           = var.web_subnet
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = var.app_subnet
    address_prefix = "10.0.2.0/24"
  }
}

output "vnet_id" {
  description = "The name of the created virtual network"
  value = azurerm_virtual_network.alpha2phi_vnet.id
}
