# ============================================
# CSV to terraform.tfvars
# Nested Map Generator
# ============================================

$csvPath = ".\resource.csv"
$outputPath = ".\terraform.tfvars"

# CSV Import
$data = Import-Csv $csvPath

# Helper function: blank values remove karne ke liye
function Get-Value {
    param($value)

    if ($null -eq $value) {
        return ""
    }

    return $value.ToString().Trim()
}


# ============================================
# 1. RESOURCE GROUPS
# ============================================

$rgs = $data |
    Where-Object {
        $_.resource_type -eq "azurerm_resource_group"
    }

$rgContent = @()

foreach ($rg in $rgs) {

    $rgName = Get-Value $rg.resource_name
    $location = Get-Value $rg.location

    $rgContent += "  $rgName = `"$location`""
}

$rgBlock = @"
rgs = {
$($rgContent -join "`n")
}
"@



# ============================================
# 2. VIRTUAL NETWORKS
# ============================================

$vnets = $data |
    Where-Object {
        $_.resource_type -eq "azurerm_virtual_network"
    }

$vnetContent = @()

$vnetCounter = 1

foreach ($vnet in $vnets) {

    $vnetName = Get-Value $vnet.vnet_name
    $rg = Get-Value $vnet.resource_group
    $location = Get-Value $vnet.location
    $space = Get-Value $vnet.address_space

    $vnetContent += @"
  vnet$vnetCounter = {
    name     = "$vnetName"
    rg       = "$rg"
    location = "$location"
    space    = ["$space"]
  }
"@

    $vnetCounter++
}

$vnetBlock = @"
vnets = {
$($vnetContent -join "`n")
}
"@



# ============================================
# 3. SUBNETS
# ============================================

$subnets = $data |
    Where-Object {
        $_.resource_type -eq "azurerm_subnet"
    }

$subnetContent = @()

$subnetCounter = 1

foreach ($subnet in $subnets) {

    $subnetName = Get-Value $subnet.subnet_name
    $vnetName = Get-Value $subnet.vnet_name
    $rg = Get-Value $subnet.resource_group
    $prefix = Get-Value $subnet.address_prefix

    $subnetContent += @"
  subnet$subnetCounter = {
    name     = "$subnetName"
    vnet     = "$vnetName"
    rg       = "$rg"
    prefixes = ["$prefix"]
  }
"@

    $subnetCounter++
}

$subnetBlock = @"
subnets = {
$($subnetContent -join "`n")
}
"@



# ============================================
# 4. VMs
# ============================================

$vms = $data |
    Where-Object {
        $_.resource_type -eq "azurerm_linux_virtual_machine"
    }

$vmContent = @()

$vmCounter = 1

foreach ($vm in $vms) {

    $vmName = Get-Value $vm.vm_name
    $rg = Get-Value $vm.resource_group
    $location = Get-Value $vm.location
    $username = Get-Value $vm.username
    $password = Get-Value $vm.password

    $subnetName = Get-Value $vm.subnet_name
    $vnetName = Get-Value $vm.vnet_name

    $pipName = Get-Value $vm.public_ip_name
    $nicName = Get-Value $vm.nic_name

    $vmContent += @"
  vm$vmCounter = {
    vm_name  = "$vmName"
    rg       = "$rg"
    location = "$location"
    username = "$username"
    password = "$password"

    subnet_name = "$subnetName"
    vnet_name   = "$vnetName"

    pip_name = "$pipName"

    nic_name = "$nicName"
  }
"@

    $vmCounter++
}

$vmBlock = @"
vms = {
$($vmContent -join "`n")
}
"@



# ============================================
# FINAL terraform.tfvars
# ============================================

$finalContent = @(
    $rgBlock
    $vnetBlock
    $subnetBlock
    $vmBlock
) -join "`n`n"

$finalContent | Out-File `
    -FilePath $outputPath `
    -Encoding utf8

Write-Host ""
Write-Host "========================================"
Write-Host "terraform.tfvars generated successfully"
Write-Host "========================================"
Write-Host "Output File: $outputPath"
Write-Host ""