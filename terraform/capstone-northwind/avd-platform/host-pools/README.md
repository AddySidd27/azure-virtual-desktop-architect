# Capstone Part F - Host Pools

Terraform for [Part F](../../../../capstone/parts/part-f-avd-platform-architecture.md).

Builds all five persona host pools (task, knowledge, finance, CAD, developers)
for **one region per apply** - apply this module twice, once per region, with
`location`/`location_short` and the region-specific subnet/resource-group
variables changed, matching the explicit-repetition pattern this book has used
since Labs 11-20 rather than a hidden `for_each` over regions.

Standard host-pool management throughout - **not** Session Host
Configuration, per [the existing ADR](../../../../appendices/adr-shc-vs-standard-host-pools.md).

## A business decision this module does not make for you

`regional_split_percent` defaults to 50 - an **explicit, unconfirmed
placeholder**. No chapter or capstone part has ever stated how Northwind's
3,200 users actually split between East US 2 (Chicago) and West Europe
(Amsterdam + Bangalore). Every session host count this module computes is
downstream of this one number. Confirm the real figure with Northwind before
applying, and re-plan once you do - the host counts will change.

## Resolved

- **Personal host pool `load_balancer_type`** value (`Persistent`) - confirmed
  against Microsoft's own Azure Verified Modules documentation and the
  Terraform Registry directly: "Persistent should be used if the host pool
  type is Personal." No longer a placeholder.

## Disclosed accuracy gaps

- **CAD VM size** (`Standard_NV6ads_A10_v5`) is a placeholder example, not a
  confirmed decision - Chapter 17 is explicit that GPU sizing is a vendor
  conversation, not a size-table choice.
- **The domain name** (`northwind.local`) is a placeholder - no source states
  Northwind's actual on-premises AD domain. This must not be confused with
  `avdlab.local`, the separate Labs 1-20 lab environment's domain - the two
  are deliberately independent.
- **Marketplace image SKU and AVD agent artifact URL** carry the same
  standing caveat as every prior lab since Lab 8 - these strings are not
  guaranteed stable over time.

## Dependency

Requires outputs from `platform/identity` (DC IPs), `platform/monitoring`
(workspace ID), and `avd-landing-zone/network-spokes` (subnet, resource
group) for the region being applied.

## Cost

Ten session host VM types across two regions at the sizes above - a
materially larger cost than any single lab in this book. Confirm current
pricing via the Azure Pricing Calculator before applying, especially for the
CAD pool's GPU-sized placeholder.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit for eastus2 first
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
# then repeat for westeurope with a separate state / workspace
```

> This Terraform has not been run against a live Azure subscription.
