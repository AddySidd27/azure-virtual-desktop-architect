# Capstone Part B - Policy

Terraform for [Part B, section 2.5](../../../../capstone/parts/part-b-enterprise-landing-zone.md).

Three policies, assigned at the Northwind Intermediate Root management group, each
traced to a specific Part A requirement - see the parent document for the full
traceability table. Deliberately not a large, generic policy set: every assignment
here exists because a stated requirement needs it.

## Dependency

Requires the `northwind_management_group_id` output from the
[management-groups module](../management-groups/). The diagnostic settings policy
requires a Log Analytics workspace resource ID, which does not exist yet - see the
`[VERIFY BEFORE IMPLEMENTATION]` note in `policy-assignments.tf` and
`terraform.tfvars.example`.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit with real values once available
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> This Terraform has not been run against a live Azure subscription. The
> allowed-locations policy definition ID is confirmed directly against Microsoft
> Learn's own documentation during this capstone's research pass. The
> required-tags and diagnostic-settings policy definition IDs are **not**
> independently confirmed - both are marked `[VERIFY BEFORE IMPLEMENTATION]` in
> `variables.tf` and `policy-assignments.tf`, with the required-tags default set
> to the value found in Microsoft's own Azure Landing Zones reference
> implementation as the best available candidate, not a verified fact. Confirm
> both via `az policy definition list` / `az policy set-definition list` before
> applying.

## Cost

**$0.00.** Azure Policy assignments carry no direct charge.
