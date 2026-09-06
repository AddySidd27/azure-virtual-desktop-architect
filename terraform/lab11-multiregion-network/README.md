# Lab 11 - Multi-Region Network

Terraform for [Lab 11](../../labs/lab-11-multiregion-network-foundation.md).

Creates the `centralus` resource group set, virtual network, four subnets, three
network security groups mirroring Lab 3's `eastus2` rule set, and bidirectional
VNet peering between `eastus2` and `centralus`.

## Cost

**Under $1.00/month.** Virtual networks, subnets, resource groups and NSGs are free.
Peering itself has no hourly charge; only data transferred across the peering link is
billed, which is negligible for lab validation traffic. No compute is deployed in this lab.

## Dependency on Lab 3

This lab reads Lab 3's state via a `terraform_remote_state` data source to get the
`eastus2` VNet's ID, name and resource group name. Lab 3's `outputs.tf` was extended
with a `resource_group_name` output to support this; if you built Lab 3 before this
addition existed, re-run `terraform apply` in `lab03-network` first so the new output
is populated in state.

**Updated for Lab 19's correction:** `nsg-identity-storage.tf` gained a new inbound
rule (`Allow-Auth-From-Westus2-DR`) permitting DR session hosts in `westus2` to
authenticate against this domain controller during an eastus2 outage. If you applied
this lab before Lab 19's correction, re-run `terraform apply` once to add the rule.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # then edit owner and primary_state_storage_account
# edit backend.tf with your bootstrapped storage account name
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Notes

- Address space is `10.20.0.0/16`, deliberately non-overlapping with Lab 3's
  `10.10.0.0/16`. Peered VNets cannot have overlapping address ranges; if you changed
  Lab 3's address space, change this lab's `vnet_address_space` and `subnet_prefixes`
  variables to a non-overlapping range before applying.
- Peering is not transitive and each side is a separate resource. This module creates
  both directions in one `terraform apply`, which means this lab's Terraform identity
  needs write access to both the `centralus` and `eastus2` resource groups.
- DNS resolution across regions is deliberately **not** configured in this lab. It
  depends on the `centralus` domain controller that Lab 12 builds. Configuring VNet
  DNS server settings here, before that DC exists, would either fail or point at
  nothing. See Lab 11's markdown for the full reasoning.
