# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.rg.name
    location                    = azurerm_resource_group.rg.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

}
