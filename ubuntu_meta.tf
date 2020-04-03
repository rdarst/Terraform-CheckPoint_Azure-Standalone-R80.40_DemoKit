resource "azurerm_network_interface" "ubuntu-external-main" {
  name                = "ubuntu-external-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ubuntuexternalip"
    subnet_id                     = azurerm_subnet.External_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.95.0.100"
    primary = true
		public_ip_address_id = azurerm_public_ip.ubuntupublicip.id
  }
}

resource "azurerm_virtual_machine" "ubuntu-external" {
  name                  = "ubuntu-external-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.ubuntu-external-main.id]
  vm_size               = "Standard_B1ms"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosexternaldisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "Ubuntuexternal"
    admin_username = "chkpuser"
    admin_password = "Cpwins1!"
    custom_data = file("ubuntu_meta_customdata.sh") 
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}