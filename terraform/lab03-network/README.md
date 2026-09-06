# Lab 3 - Network

Terraform for [Lab 3](../../labs/lab-03-vnet-subnets-nsg-dns.md).

Creates the AVD lab virtual network, four subnets, the reserved `AzureBastionSubnet`,
and three network security groups with the outbound rules AVD session hosts require.

## Cost

**$0.00/month.** Virtual networks, subnets and NSGs are free.
Azure Bastion is **not** deployed - only its subnet is reserved. See the cost warning in Lab 3.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # then edit owner
# edit backend.tf with your bootstrapped storage account name
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Notes

- NSGs match on service tags, ports and IP ranges - **not FQDNs**. Some required AVD
  endpoints can only be filtered by FQDN in Azure Firewall or an NGFW (Chapter 13).
- The `Allow-AVD-Relayed-RDP-UDP` rule permits the UDP 3478 endpoint published through
  the `WindowsVirtualDesktop` service tag. Keep Shortpath design and validation separate;
  the active transport must be confirmed from session evidence rather than inferred from
  the presence of this NSG rule.
- Service tag names are case-sensitive.
