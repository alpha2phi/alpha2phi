# Specify the provider
provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "centralized-warehouse-rg"
  location = "Southeast Asia"
}

# Create a Virtual Network (Optional if you want to keep resources inside a VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "central-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet for Azure Synapse Analytics
resource "azurerm_subnet" "synapse_subnet" {
  name                 = "synapse-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Azure Synapse Analytics Workspace in Southeast Asia (Centralized)
resource "azurerm_synapse_workspace" "synapse" {
  name                = "central-synapse"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_account.datalake.id
  sql_administrator_login               = "synapseadmin"
  sql_administrator_login_password      = "YourStrongPassword123"
}

# Create Synapse SQL Dedicated Pool (SQL Data Warehouse) in Southeast Asia
resource "azurerm_synapse_sql_pool" "sqlpool" {
  name                = "central-sqlpool"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  synapse_workspace_id = azurerm_synapse_workspace.synapse.id
  sku {
    name     = "DW100c"
    capacity = 100
  }
}

# Create ADLS Gen2 Storage Account for centralized storage in Southeast Asia
resource "azurerm_storage_account" "datalake" {
  name                     = "centraldatalake"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  is_hns_enabled            = true  # Hierarchical namespace for ADLS Gen2

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }
}

# Azure Data Factory in Southeast Asia
resource "azurerm_data_factory" "adf" {
  name                = "central-adf"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Create an Azure IR in Southeast Asia for data movement in that region
resource "azurerm_data_factory_integration_runtime_azure" "ir_southeastasia" {
  name                = "central-adf-ir-sea"
  data_factory_name   = azurerm_data_factory.adf.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name = "Standard"
  }
}

# Create an Azure IR in Australia East for data movement in that region
resource "azurerm_data_factory_integration_runtime_azure" "ir_australiaeast" {
  name                = "central-adf-ir-aue"
  data_factory_name   = azurerm_data_factory.adf.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = "Australia East"

  sku {
    name = "Standard"
  }
}

# Optional - Add Managed Private Endpoint for Synapse and ADLS for secure data transfer
resource "azurerm_synapse_private_link_hub" "private_link_hub" {
  name                = "synapse-private-link-hub"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Output the Synapse Analytics and ADLS endpoints
output "synapse_workspace_url" {
  value = azurerm_synapse_workspace.synapse.id
}

output "adls_storage_account" {
  value = azurerm_storage_account.datalake.primary_blob_endpoint
}
