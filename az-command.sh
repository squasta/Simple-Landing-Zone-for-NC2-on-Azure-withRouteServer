Some AZURE CLI commands to manage route server peerings and learned routes.

# List all route server peerings in a resource group
az network routeserver peering list -g "RG-NC2" --routeserver "routesrv-germanywestcentral" -o table

az network routeserver peering list-advertised-routes -g "RG-NC2" --routeserver "routesrv-germanywestcentral" -n "routesrv-germanywestcentral-bgp_conn_38707"

az network routeserver peering list-learned-routes -g "RG-NC2" --routeserver "routesrv-germanywestcentral" -n "routesrv-germanywestcentral-bgp_conn_38707" -o jsonc 
az network routeserver peering list-learned-routes -g "RG-NC2" --routeserver "routesrv-germanywestcentral" -n "routesrv-germanywestcentral-bgp_conn_4d2df" -o jsonc 
az network routeserver peering list-learned-routes -g "RG-NC2" --routeserver "routesrv-germanywestcentral" -n "routesrv-germanywestcentral-bgp_conn_21f83" -o jsonc 
az network routeserver peering list-learned-routes -g "RG-NC2" --routeserver "routesrv-germanywestcentral" -n "routesrv-germanywestcentral-bgp_conn_bcac2" -o jsonc
