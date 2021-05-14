provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "hero-app-rg" {
  name     = "hero-app-rg"
  location = "West US"
}

# Create a virtual network
resource "azurerm_virtual_network" "hero-app-vnet" {
    name                = "hero-app-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = "westus2"
    resource_group_name = azurerm_resource_group.hero-app-rg.name
}

# Create subnet
resource "azurerm_subnet" "hero-app-subnet" {
  name                 = "hero-app-subnet"
  resource_group_name  = azurerm_resource_group.hero-app-rg.name
  virtual_network_name = azurerm_virtual_network.hero-app-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "hero-app-public-ip" {
  name                = "hero-app-public-ip"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.hero-app-rg.name
  allocation_method   = "Static"
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "hero-app-nsg" {
  name                = "hero-app-nsg"
  location            = "westus2"
  resource_group_name = azurerm_resource_group.hero-app-rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "hero-app-nic" {
  name                      = "hero-app-nic"
  location                  = "westus2"
  resource_group_name       = azurerm_resource_group.hero-app-rg.name

  ip_configuration {
    name                          = "hero-app-nic-ip-config"
    subnet_id                     = azurerm_subnet.hero-app-subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.hero-app-public-ip.id
  }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "hero-app-vm" {
  name                  = "hero-app-vm"
  location              = "westus2"
  resource_group_name   = azurerm_resource_group.hero-app-rg.name
  network_interface_ids = [azurerm_network_interface.hero-app-nic.id]
  vm_size               = "Standard_D2as_v4"

  storage_os_disk {
    name              = "hero-app-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18_04-lts-gen2"
    version   = "18.04.202105120"
  }

  os_profile {
    computer_name  = "hero-app-server"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.hero-app-public-ip.name
  resource_group_name = azurerm_virtual_machine.hero-app-vm.resource_group_name
  depends_on          = [azurerm_virtual_machine.hero-app-vm]
}

output "public_ip_address" {
  value = data.azurerm_public_ip.ip.ip_address
}
