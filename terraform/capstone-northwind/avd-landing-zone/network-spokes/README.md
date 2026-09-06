# Capstone Part E - AVD Landing Zone Network Spokes

Terraform for [Part E](../../../../capstone/parts/part-e-avd-landing-zone.md), sections 3 and 5.

Associates the two AVD subscriptions into Part B's reserved, empty `Corp`
management group node, and builds one AVD-specific spoke VNet per region,
peered to that region's platform hub from
[`platform/connectivity`](../../platform/connectivity/).

## What this does NOT do

Create the AVD subscriptions themselves - assumed to exist as billing
entities, matching `platform/management-groups`'s exact boundary for the
three platform subscriptions. No AVD workload resource (host pools, session
hosts) is created here - that's Part F.

## Dependency

Requires `platform/management-groups`'s `corp_management_group_id` output and
`platform/connectivity`'s hub VNet outputs.

## Cost

VNets, subnets, peering: **$0.00** direct charge, peering data transfer only.
No compute in this module.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit with real values
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> This Terraform has not been run against a live Azure subscription.
