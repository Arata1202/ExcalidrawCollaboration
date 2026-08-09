resource "azurerm_resource_group" "excalidraw_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "excalidraw_vnet" {
  name                = "excalidraw_vnet"
  location            = azurerm_resource_group.excalidraw_rg.location
  resource_group_name = azurerm_resource_group.excalidraw_rg.name
  address_space       = [var.vnet_address_space]
}

resource "azurerm_subnet" "excalidraw_subnet" {
  name                 = "excalidraw_subnet"
  resource_group_name  = azurerm_resource_group.excalidraw_rg.name
  virtual_network_name = azurerm_virtual_network.excalidraw_vnet.name
  address_prefixes     = [var.subnet_address_prefix]
}

resource "azurerm_public_ip" "excalidraw_public_ip" {
  name                = "excalidraw_public_ip"
  location            = azurerm_resource_group.excalidraw_rg.location
  resource_group_name = azurerm_resource_group.excalidraw_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "excalidraw_nsg" {
  name                = "excalidraw_nsg"
  location            = azurerm_resource_group.excalidraw_rg.location
  resource_group_name = azurerm_resource_group.excalidraw_rg.name

  security_rule {
    name                       = "excalidraw_22"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "excalidraw_80"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "excalidraw_443_tcp"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface" "excalidraw_nic" {
  name                = "excalidraw_nic"
  location            = azurerm_resource_group.excalidraw_rg.location
  resource_group_name = azurerm_resource_group.excalidraw_rg.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.excalidraw_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.excalidraw_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "excalidraw_nsg_association" {
  network_interface_id      = azurerm_network_interface.excalidraw_nic.id
  network_security_group_id = azurerm_network_security_group.excalidraw_nsg.id
}
