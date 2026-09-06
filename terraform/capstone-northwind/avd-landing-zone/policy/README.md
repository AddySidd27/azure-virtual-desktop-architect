# Capstone Part E - AVD-Specific Policy

Terraform for [Part E](../../../../capstone/parts/part-e-avd-landing-zone.md), section 6.

A custom Azure Policy definition enforcing the `hp-<persona>-<env>-<region>-<instance>`
host pool naming pattern already fixed across four existing chapters, assigned
at `sub-northwind-avd-prod` - narrower than Part B's tenant-wide policies, per
Part B's own stated boundary for where AVD-specific policy belongs.

## A disclosed accuracy gap, not a confident claim

Azure Policy's `match` condition uses `#`/`?` wildcards, not full regex. The
pattern in `naming-policy.tf` is a simplified approximation, marked
`[VERIFY BEFORE IMPLEMENTATION]` - confirm the exact match syntax against
current Azure Policy documentation before relying on this to correctly
enforce the five-persona naming rule.

## Cost

**$0.00.** No resource exists yet to evaluate this policy against - Part F
builds the first host pool.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit with a real subscription ID
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> This Terraform has not been run against a live Azure subscription.
