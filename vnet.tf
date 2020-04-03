resource "azurerm_virtual_network" "vnet" {
  name                = "R80dot40vnet"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.95.0.0/20"]
  location            = azurerm_resource_group.rg.location
}
