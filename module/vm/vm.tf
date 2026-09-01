variable "vms" {}


data "azurerm_subnet" "subnet" {
  for_each = var.vms
  name = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.rg
}

resource "azurerm_public_ip" "pip" {
    for_each = var.vms
    name = each.value.pip_name
    resource_group_name = each.value.rg
    location = each.value.location
    allocation_method = "Static"
  
}

resource "azurerm_network_interface" "nic" {
    for_each = var.vms
    name = each.value.nic_name
      location            = each.value.location
  resource_group_name = each.value.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet[each.key].id
    public_ip_address_id = azurerm_public_ip.pip[each.key].id
    private_ip_address_allocation = "Dynamic"
  }
}
  
resource "azurerm_linux_virtual_machine" "vm" {
    for_each = var.vms
    name = each.value.vm_name
    resource_group_name = each.value.rg
    location = each.value.location
      size                = "Standard_D2s_v3"
  admin_username      = each.value.username
  admin_password = each.value.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
  ]

 

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
