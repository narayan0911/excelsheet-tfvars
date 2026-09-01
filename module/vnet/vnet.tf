variable "vnets" {}

resource "azurerm_virtual_network" "vnets" {
    for_each = var.vnets
    name = each.value.name
    resource_group_name = each.value.rg
    location = each.value.location
    address_space = each.value.space
  
}