# Capstone Part B - Management Groups

Terraform for [Part B, section 2.1-2.2](../../../../capstone/parts/part-b-enterprise-landing-zone.md).

Builds the minimal management group hierarchy (Northwind, Platform, Identity,
Management, Connectivity, Landing Zones, Corp, Decommissioned) and associates
three existing platform subscriptions into it. Does **not** create subscriptions,
does **not** create an Online landing zone or a Sandbox management group, and does
**not** associate any AVD subscription into Corp - see Part B section 4 for why the
first three are absent and section 2.2 for why the fourth is deliberately deferred
to Part E.

## Prerequisites

Three Azure subscriptions must already exist, created through Northwind's billing
agreement (Enterprise Agreement or Microsoft Customer Agreement), not by this
module: `sub-northwind-identity`, `sub-northwind-management`,
`sub-northwind-connectivity`.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit with your real subscription IDs
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> This Terraform has not been run against a live Azure subscription. Confirm your
> own plan output, and confirm your subscription IDs are correct, before applying -
> management group changes affect governance scope for every subscription
> underneath them.

## Cost

**$0.00.** Management groups and subscription associations carry no direct Azure
charge.
