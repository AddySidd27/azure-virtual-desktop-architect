# Capstone Part C - Connectivity

Terraform for [Part C](../../../../capstone/parts/part-c-identity-connectivity-foundation.md), sections 2 and 5.

Builds the two regional hubs (East US 2 for Chicago, West Europe for Amsterdam):
VNets, GatewaySubnet, AzureFirewallSubnet, hub-to-hub peering, ExpressRoute
gateways (`ErGwScale`), and Azure Firewall. No Bangalore infrastructure of any
kind - see Part C, section 6, for why that's a decision, not an omission.

## What is NOT in this module

- The ExpressRoute **circuits** themselves. Provisioned jointly with Northwind's
  connectivity provider, outside Terraform's scope. This module's gateways are
  built ready to connect once a circuit exists.
- Any spoke, NSG, or UDR. Hub subnets (`GatewaySubnet`, `AzureFirewallSubnet`)
  cannot take NSGs, and there is no spoke traffic to route at the hub level -
  that logic lives in the [identity module](../identity/), which is an actual
  spoke consuming this hub's Firewall as its egress path.

## Cost

| Resource | Monthly cost (per region, x2 for both) |
|---|---|
| ExpressRoute Gateway (`ErGwScale`, minimum 2 scale units) | Real, ongoing - confirm current pricing via the Azure Pricing Calculator before committing |
| Azure Firewall (`AZFW_VNet`, Standard) | ~$900/month running, matching the figure already established in [Lab 18](../../../../labs/lab-18-regional-security-monitoring.md) - justified here as a platform-shared resource, not a lab convenience; see Part C section 5 |

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit with real values
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> This Terraform has not been run against a live Azure subscription. Confirm
> your own plan output, and confirm `ErGwScale` is still the correct SKU choice
> at the time you apply - gateway SKU changes across the availability-zone
> boundary require deleting and recreating the gateway, which causes downtime.
