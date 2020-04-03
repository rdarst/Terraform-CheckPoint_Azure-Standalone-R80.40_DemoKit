resource "azurerm_network_interface" "ubuntu-main" {
  name                = "ubuntu-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.DMZ1_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.95.11.100"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "ubuntu-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.ubuntu-main.id]
  vm_size               = "Standard_B1s"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "UbuntuCPX2020"
    admin_username = "chkpuser"
    admin_password = "Cpwins1!"
    custom_data = file("ubuntu_web_customdata.sh") 
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}