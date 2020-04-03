resource "azurerm_network_interface" "mgmtexternal" {
    name                = "mgmtexternal"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_ip_forwarding = "true"
	ip_configuration {
        name                          = "mgmtexternalConfiguration"
        subnet_id                     = azurerm_subnet.External_subnet.id
        private_ip_address_allocation = "Static"
		private_ip_address = "10.95.0.10"
        primary = true
		public_ip_address_id = azurerm_public_ip.mgmtpublicip.id
    }
}

resource "azurerm_network_interface" "mgmtinternal" {
    name                = "mgmtinternal"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    enable_ip_forwarding = "true"
	ip_configuration {
        name                          = "mgmtinternalConfiguration"
        subnet_id                     = azurerm_subnet.Internal_subnet.id
        private_ip_address_allocation = "Static"
		private_ip_address = "10.95.1.10"
    }
}

# Output the public ip of the gateway
output "Public_ip" {
    value = azurerm_public_ip.mgmtpublicip.ip_address
}
