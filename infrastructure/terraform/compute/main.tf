terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# module "linux_vm" {
#   source = "./linux.tf"
# }

provider "azurerm" {
  features {}
}

# Variable for location with default set to Southeast Asia
variable "rg_location" {
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
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["192.168.0.0/16"]

  # Subnets
  subnet {
    name           = var.web_subnet
    address_prefix = "192.168.1.0/24"
  }

  subnet {
    name           = var.app_subnet
    address_prefix = "192.168.2.0/24"
  }
}

# Outputs to be accessed in other files
output "rg_name" {
  description = "Resource group"
  value = azurerm_resource_group.rg.name
}

output "rg_location" {
  description = "Resource group location"
  value = azurerm_resource_group.rg.location
}

output "vnet_id" {
  description = "Virtual network"
  value = azurerm_virtual_network.vnet.id
}

output "web_subnet_id" {
  value = data.azurerm_subnet.web_subnet.id
}
