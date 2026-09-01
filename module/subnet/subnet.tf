variable "subnet" {}

resource "azurerm_subnet" "subnet" {
    for_each = var.subnet
    name = each.value.name
    virtual_network_name = each.value.vnet
    resource_group_name = each.value.rg
    address_prefixes = each.value.prefixes
  
}