# Resource_Group
module "resource_group" {
  source = "../Modules/azurerm_resource_group"

  resource_group_name     = "faadu-rg"
  resource_group_location = "australiaeast"
}


# VNET
module "virtual_network" {
  depends_on = [module.resource_group]
  source     = "../Modules/azurerm_virtual_network"

  virtual_network_name     = "faadu-vnet"
  virtual_network_location = "australiaeast"
  resource_group_name      = "faadu-rg"
  address_space            = ["10.0.0.0/16"]
}


# Frontend_Subnet
# Dard1 - Backend subnet and frontend subnet do baar repeat ho raha hai...
module "frontend_subnet" {
  depends_on = [module.virtual_network]
  source     = "../Modules/azurerm_subnet"

  subnet_name          = "frontend_subnet"
  resource_group_name  = "faadu-rg"
  virtual_network_name = "faadu-vnet"
  address_prefixes     = ["10.0.1.0/24"]
}


# Backend_Subnet
module "backend_subnet" {
  depends_on = [module.virtual_network]
  source     = "../Modules/azurerm_subnet"

  subnet_name          = "backend_subnet"
  resource_group_name  = "faadu-rg"
  virtual_network_name = "faadu-vnet"
  address_prefixes     = ["10.0.2.0/24"]
}


# frontend_Public_IP
module "frontend_Public_ip" {
  depends_on = [module.frontend_subnet]
  source     = "../Modules/azurerm_public_ip"

  public_ip_name      = "frontend-pip"
  resource_group_name = "faadu-rg"
  location            = "australiaeast"
  allocation_method   = "Static"
}


# backend_Public_IP
module "backend_public_ip" {
  depends_on = [module.backend_subnet]
  source     = "../Modules/azurerm_public_ip"

  public_ip_name      = "backend-pip"
  resource_group_name = "faadu-rg"
  location            = "australiaeast"
  allocation_method   = "Static"
}


module "vm" {
  source              = "../Modules/azurerm_virtual_machine"
  depends_on          = [module.frontend_subnet, module.frontend_Public_ip]
  nic_name = "faadu-nic"
  location = "australiaeast"
  resource_group_name = "faadu-rg"
  vm_name = "frontend-vm"
  vm_size = "Standard_B1s"
  admin_username = "todo"
  admin_password = "Nokia@123"
  image_publisher = "Canonical"
  image_offer = "0001-com-ubuntu-server-focal"
  image_sku = "20_04-lts"
  image_version = "latest"
  frontend_pip_name = "frontend-pip"
  frontend_subnet_name = "frontend_subnet"
  vnet_name = "faadu-vnet"
}
