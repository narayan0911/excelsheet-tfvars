module "rg" {
  source = "../../module/rg"
  rgs    = var.rgs
}


module "vir" {
  depends_on = [module.rg]
  source     = "../../module/vnet"
  vnets      = var.vnets
}

module "sub" {
  depends_on = [module.vir]
  source     = "../../module/subnet"
  subnet     = var.subnets
}

module "vm" {
  depends_on = [module.sub]
  source     = "../../module/vm"
  vms        = var.vms

}