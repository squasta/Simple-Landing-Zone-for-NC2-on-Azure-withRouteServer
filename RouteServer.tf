

variable "RouteServerVNetName" {
  type = string
  description = "Name of RouteServer VNet"
  default = "routesrv-vnet"  
}

variable "RouteServerName" {
  type = string
  description = "Name of RouteServer"
  default = "RouteServer"  
}
variable "RouteServerPublicIPName" {
  type = string
  description = "Name of RouteServer Public IP"
  default = "RouteServerPIP"  
}

variable "RouteServerVNetCIDR" {
  type = list(string)
  description = "CIDR of RouteServer VNet"
  default = ["10.2.0.0/16"]
}

variable "RouteServerSubnetCIDR" {
  type = list(string)
  description = "CIDR of RouteServer Subnet"
  default = ["10.2.1.0/24"]
}


resource "azurerm_virtual_network" "TF_RouteServer_VNet" {
    name                = var.RouteServerVNetName
    address_space       = var.RouteServerVNetCIDR
    location            = azurerm_resource_group.TF_RG.location
    resource_group_name = azurerm_resource_group.TF_RG.name
}

resource "azurerm_subnet" "TF_RouteServer_Subnet" {
    name                 = "RouteServerSubnet"   # it must be this name
    resource_group_name  = azurerm_resource_group.TF_RG.name
    virtual_network_name = azurerm_virtual_network.TF_RouteServer_VNet.name
    address_prefixes     = var.RouteServerSubnetCIDR
}

# cf. https://learn.microsoft.com/en-us/azure/route-server/route-server-overview
resource "azurerm_public_ip" "TF_RouteServer_PIP" {
    name                = var.RouteServerPublicIPName
    location            = azurerm_resource_group.TF_RG.location
    resource_group_name = azurerm_resource_group.TF_RG.name
    allocation_method   = "Static"
    sku                 = "Standard"
}


# cf. https://learn.microsoft.com/en-us/azure/route-server/route-server-overview
# cf. https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/route_server
resource "azurerm_route_server" "TF_RouteServer" {
    name                  = var.RouteServerName
    location              = azurerm_resource_group.TF_RG.location
    resource_group_name   = azurerm_resource_group.TF_RG.name
    subnet_id             = azurerm_subnet.TF_RouteServer_Subnet.id
    public_ip_address_id  = azurerm_public_ip.TF_RouteServer_PIP.id
    sku                   = "Standard"
}


#### Peering

resource "azurerm_virtual_network_peering" "RouteServerVNet_to_PCVNet" {
    name                      = "RouteServerVNet-to-PCVNet"
    resource_group_name       = azurerm_resource_group.TF_RG.name
    virtual_network_name      = azurerm_virtual_network.TF_RouteServer_VNet.name
    remote_virtual_network_id = azurerm_virtual_network.TF_PC_VNet.id
    allow_forwarded_traffic   = true
    allow_gateway_transit     = false
    use_remote_gateways       = false
}

resource "azurerm_virtual_network_peering" "PCVNet_to_RouteServerVNet" {
    name                      = "PCVNet-to-RouteServerVNet"
    resource_group_name       = azurerm_resource_group.TF_RG.name
    virtual_network_name      = azurerm_virtual_network.TF_PC_VNet.name
    remote_virtual_network_id = azurerm_virtual_network.TF_RouteServer_VNet.id
    allow_forwarded_traffic   = true
    allow_gateway_transit     = false
    use_remote_gateways       = false
}

# resource "azurerm_virtual_network_peering" "ClusterVNet_to_RouteServerVNet" {
#   name                      = "ClusterVNet-to-RouteServerVNet"
#   resource_group_name       = azurerm_resource_group.TF_RG.name
#   virtual_network_name      = azurerm_virtual_network.TF_Cluster_VNet.name
#   remote_virtual_network_id = azurerm_virtual_network.TF_RouteServer_VNet.id
#   allow_forwarded_traffic   = true
#   allow_gateway_transit     = false
#   use_remote_gateways       = false
# }

# resource "azurerm_virtual_network_peering" "RouteServerVNet_to_ClusterVNet" {
#   name                      = "RouteServerVNet-to-ClusterVNet"
#   resource_group_name       = azurerm_resource_group.TF_RG.name
#   virtual_network_name      = azurerm_virtual_network.TF_RouteServer_VNet.name
#   remote_virtual_network_id = azurerm_virtual_network.TF_Cluster_VNet.id
#   allow_forwarded_traffic   = true
#   allow_gateway_transit     = false
#   use_remote_gateways       = false
# }

