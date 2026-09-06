# Capstone Part C - Identity

Terraform for [Part C](../../../../capstone/parts/part-c-identity-connectivity-foundation.md), section 4.

Builds two domain controllers per region (four total), each in its own spoke
VNet peered to that region's hub (from the [connectivity module](../connectivity/)),
with NSGs scoped to the actual AD replication path and a UDR routing spoke
egress through the regional Firewall.

## What is NOT in this module

- `Install-ADDSDomainController` and Microsoft Entra Connect Sync installation.
  Imperative post-deployment steps, matching Lab 4/Lab 12's pattern - not
  Terraform-declarable actions. See Part C, sections 3-4, and [ADR-CAP-01](../../../../capstone/adr/adr-cap-01-identity-sync-method.md)
  for why Connect Sync, not Cloud Sync.
- A new AD forest or domain. These VMs join Northwind's **existing** on-premises
  forest - Part A's TR-01 requirement.

## Dependency

Requires the [connectivity module](../connectivity/)'s outputs (hub VNet IDs,
resource groups, names, and Firewall private IPs) - apply that module first.

## Cost

Four VMs (Standard_D2s_v5, matching Lab 4/Lab 12's sizing): approximately four
times a single lab domain controller's cost. Confirm current pricing via the
Azure Pricing Calculator - this is production identity infrastructure, not a
lab environment, and should not be deallocated between sessions the way a lab
VM would be.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit with real values, including connectivity module outputs
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> This Terraform has not been run against a live Azure subscription. Confirm
> your own plan output before applying - this builds production identity
> infrastructure that the AVD platform (Part F) will depend on directly.
