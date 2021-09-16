provider   "azurerm"   { 
   version   =   "= 2.0.0" 
   features   {} 
   subscription_id = "8404638f-6960-4ffc-987b-cee596972584"
   client_id       = "e770e440-c746-4b88-bca8-c09a0f477933"
   client_secret   = "2.o1PeBDgG0sCU_PE5tp4qhT~KDdN4hZ2G"
   tenant_id       = "cb024171-6400-4826-aa59-adf6c7afac87"
 } 
 resource   "azurerm_resource_group"   "example"   { 
   name               = "${var.resource_name}" 
   location           = "${var.location}" 
 }
 resource "azurerm_virtual_network" "example" {
  name                = "dev-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "dev-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefix       = "10.0.1.0/24"
}
resource "azurerm_public_ip" "example" {
  name                 = "dev-pip"
  location             = azurerm_resource_group.example.location
  resource_group_name  = azurerm_resource_group.example.name
  allocation_method    = "Dynamic"
  sku                  = "Basic"
}

resource "azurerm_network_security_group" "example" {
  name                = "dev-security-group"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "allow-all"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface" "example" {
  name                = "dev-nic111"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
	public_ip_address_id          = azurerm_public_ip.example.id
  }
}
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.example.id
    network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "dev-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  admin_username      = "girish"
  admin_password      = "girishhanu@123"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}