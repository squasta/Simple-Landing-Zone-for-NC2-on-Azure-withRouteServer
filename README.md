## Nutanix Cloud Cluster (NC2) on Azure - Simple Landing Zone for POC with RouteServer and Scale-out Flow Gateways

## Scenario interconnection with an Azure ExpressRoute on a Hub and Spoke topology (with Route Server)

This repo contains Terraform files to deploy all Azure network components needed to deploy Nutanix Cloud Cluster(NC2) on Azure Baremetal with an additional VNet that contains an Azure Route Server.

Azure Route Server is mandatory if you want to use a Scale-Out Flow Gateway deployement (2 to 4 Azure VMs that are Gateways between Azure VNet and Nutanix Flow Networking)

<img width='400' src='./images/PlaneLZ.png'/> 

## Prerequisites

- All prerequisites for NC2 : https://portal.nutanix.com/page/documents/details?targetId=Nutanix-Cloud-Clusters-Azure:nc2-clusters-azure-getting-ready-for-deployment-c.html

- An Azure Subscription with enough privileges (create RG, AKS...)
- Azure CLI 2.57 or >: <https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest>
   And you need to activate features that are still in preview and add extension aks-preview to azure CLI (az extension add --name aks-preview)
- Terraform CLI 1.5 or > : <https://www.terraform.io/downloads.html>

You can also clone this repo in your [Azure Cloud Shell](https://shell.azure.com) (that has all tools installed)

## What this terraform project will deploy ? Global architecture

<img width='800' src='./images/NC2AzureLZ-ER-Route2.png'/> 



## Step by step operations

Read the code and comments to understand what Azure resources will be created.

Edit [configuration.tfvars](configuration.tfvars) to define your Azure resources names.
 

1. Terraform Init phase  

```bash
terraform init
```

2. Terraform Plan phase

```bash
terraform plan --var-file=configuration.tfvars
```

3. Terraform deployment phase (add TF_LOG=info at the beginning of the following command line if you want to see what's happen during deployment)

```bash
terraform apply --var-file=configuration.tfvars
```

4. Wait until the end of deployment (It should take less than 15 minute, the longuest resource to deploy is Azure Route Server)

<img width='800' src='./images/NC2AzureLZ-ER-Route.png'/> 

If you want to connect to Prism Element or Prism Central through Internet, there is an option to enable an Azure Bastion instance and a Windows Server 2025 Virtual Machine Jumbox

5. Go to Nutanix [NC2 Portal](https://cloud.nutanix.com) https://cloud.nutanix.com and start your Nutanix Cluster deployment wizard. In steps 4 (Network), 5 (Prism Central) and 6 (Flow Networking) select the Virtuals Networks and Subnets created in step 3 using terraform

<img width='600' src='./images/Step4.png'/> 

<img width='600' src='./images/Step5.png'/> 

<img width='600' src='./images/Step6-1.png'/> 

<img width='600' src='./images/Step6-2.png'/> 

<img width='600' src='./images/Step6-3.png'/> 

6. After the deployment is successfull, you can add connectivity with on-premises or other Azure VNet or services by peering an Hub Vnet or Virtual vWAN vHub. If you enabled AzureBastion and Jumpbox VM, you can login to the Jumbox VM and connect Prism Element or Prism Central through a web browser.

7. Use the solution and configure Nutanix features like [Flow VPC](https://squasta.github.io/configurationvpcazure.html), categories...

8. When you want to destroy the Nutanix Cluster, use the NC2 Portal (https://cloud.nutanix.com) to terminate it.

9. After cluster terminaison, you can destroy the landing zone using the following command : 
```bash
terraform destroy --var-file=configuration.tfvars
```

## How much does it cost to test this landing zone ?

It's very cheap to test and customize this simple landing zone.

You can use **infracost** (available on https://www.infracost.io/) to check the estimate price for 1 month. Here is an exemple for Azure Germany West Central region

 :exclamation: Important : this landing zone cost estimation does not include the cost of Azure Baremetal instance(s) used as node(s) in the Nutanix Cluster. 

<img width='800' src='./images/InfracostNC2LDZAzure.png'/> 

 Please have a look of metal instances prices here : https://azure.microsoft.com/en-us/pricing/details/nutanix-on-azure/ . Pricing is per instance-hour consumed for each instance, from the time an instance is launched until it is terminated or stopped. 

 Note : you don't need Azure Bastion or Jumbox 24/7. You can simply enable or disable these resources in configuration.tfvars file (0= disabled , 1=enabled) 