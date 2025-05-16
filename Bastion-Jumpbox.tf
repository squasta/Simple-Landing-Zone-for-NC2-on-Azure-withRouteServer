

# An Azure public for Azure Bastion
# cf. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "TF_bastion_public_ip" {
  count               = var.EnableAzureBastion
  name                = var.PublicBastionIPName
  location            = azurerm_resource_group.TF_RG.location
  resource_group_name = azurerm_resource_group.TF_RG.name
  allocation_method   = "Static"
  sku                 = "Standard"
}


# An Azure Bastion Host
# cf. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host
# Azure Bastion documentation : https://learn.microsoft.com/en-us/azure/bastion/configuration-settings 
# Azure Bastion SKU https://learn.microsoft.com/en-us/azure/bastion/configuration-settings 
# Azure Bastion pricing : https://azure.microsoft.com/en-us/pricing/details/azure-bastion/
resource "azurerm_bastion_host" "TF_bastion_host" {
  count               = var.EnableAzureBastion
  name                = var.AzureBastionHostName
  location            = azurerm_resource_group.TF_RG.location
  resource_group_name = azurerm_resource_group.TF_RG.name
  sku                 = var.AzureBastionSKU    
  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.TF_Azure_Bastion_Subnet.id
    public_ip_address_id = azurerm_public_ip.TF_bastion_public_ip[0].id
  }
}


# Subnet Jumpboxes-subnet
# This subnet is for admin/jumbox(es) Azure VM(s)
# This Subnet must associated with an Azure NAT Gateway <=====   TO CONFIRM !!!!
# cf. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "TF_Jumbox_Subnet" {
  name                 = var.JumpboxSubnetName
  resource_group_name  = azurerm_resource_group.TF_RG.name
  virtual_network_name = azurerm_virtual_network.TF_PC_VNet.name
  address_prefixes     = var.JumpboxSubnetCIDR
  # private_endpoint_network_policies_enabled = false
}


# A Network Interface for Azure Windows VM
# cf. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
resource "azurerm_network_interface" "TF_VM_Jumbox_Nic" {
  count               = var.EnableJumboxVM
  name                = var.VMBastionNicName
  location            = azurerm_resource_group.TF_RG.location
  resource_group_name = azurerm_resource_group.TF_RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.TF_Jumbox_Subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


# A Windows Virtual Machine for Bastion
# cf. https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine
resource "azurerm_windows_virtual_machine" "TF_VM_Jumbox" {
  count                 = var.EnableJumboxVM
  name                  = var.VMJumpboxName
  resource_group_name   = azurerm_resource_group.TF_RG.name
  location              = azurerm_resource_group.TF_RG.location
  size                  = var.AzureVMSize    # B2ms or greater is better for good experience
  admin_username        = var.AdminUsername
  admin_password        = var.AdminPassword
  network_interface_ids = [azurerm_network_interface.TF_VM_Jumbox_Nic[0].id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-Datacenter"
    version   = "latest"
  }
  computer_name = var.HostnameVMJumbox
  provision_vm_agent = true
  enable_automatic_updates = true
  timezone = "W. Europe Standard Time"
  tags = {
    usage = "Jumpbox with Azure Bastion"
  }
}
