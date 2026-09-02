rgs = {
  rgvm1 = "centralindia"
  rgvm2 = "southindia"
  rgvm3 = "centralindia"
  rgvm4 = "southindia"
}

vnets = {
  vnet1 = {
    name     = "dlink"
    rg       = "rgvm1"
    location = "centralindia"
    space    = ["10.123.0.0/16"]
  }
  vnet2 = {
    name     = "elink"
    rg       = "rgvm2"
    location = "southindia"
    space    = ["10.124.0.0/16"]
  }
}

subnets = {
  subnet1 = {
    name     = "linux1subnet"
    vnet     = "dlink"
    rg       = "rgvm1"
    prefixes = ["10.123.0.0/24"]
  }
  subnet2 = {
    name     = "linux2subnet"
    vnet     = "elink"
    rg       = "rgvm2"
    prefixes = ["10.124.0.0/24"]
  }
}

vms = {
  vm1 = {
    vm_name  = "linux1"
    rg       = "rgvm1"
    location = "centralindia"
    username = "adminuser"
    password = "adminuser@123"

    subnet_name = "linux1subnet"
    vnet_name   = "dlink"

    pip_name = "pip1"

    nic_name = "nic1"
  }
  vm2 = {
    vm_name  = "linux2"
    rg       = "rgvm2"
    location = "southindia"
    username = "adminuser"
    password = "adminuser@123"

    subnet_name = "linux2subnet"
    vnet_name   = "elink"

    pip_name = "pip2"

    nic_name = "nic2"
  }
}
