# Reference the existing resource group, VNet, and subnet

# Accessing the outputs defined in main.tf
data "azurerm_subnet" "web_subnet" {
  name                 = var.web_subnet
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}


# Create the Network Interface (NIC) without a public IP
resource "azurerm_network_interface" "linux_vm_nic" {
  name                = "linux-vm-nic"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create the Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                = "my-linux-vm"
  resource_group_name = var.rg_name
  location            = var.rg_location
  size                = "Standard_B1s"  # Free tier-eligible size

  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.linux_vm_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer = "ubuntu-24_04-lts"
    sku = "server"
    version = "latest"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")  # Make sure this file exists
  }

  disable_password_authentication = true

  tags = {
    environment = "Development"
  }
}
