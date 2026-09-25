# Capstone Part D - Security

Terraform for [Part D](../../../../capstone/parts/part-d-governance-security-foundation.md).

Builds the platform Key Vault (closing the credential-storage gap Part C's
`terraform.tfvars.example` files left open), Azure Bastion Premium per regional
hub (consuming Part C's connectivity module outputs), and the two break-glass
emergency-access accounts. **RBAC role assignments originally built here have
been superseded and moved** - see the note below and `rbac.tf`'s marker
comment.

## Superseded: RBAC roles moved to `platform/rbac/`

This module originally built Identity Administrator and Network Administrator
as standing `azurerm_role_assignment` resources, while Part D's own prose
described both as "PIM-eligible" - a real gap the [implementation
tracker](../../../../capstone/implementation-tracker.md) found and closed.
All platform RBAC, including these two roles and Security Administrator's Key
Vault access, now lives in [`platform/rbac/`](../rbac/) as genuine
`azurerm_pim_eligible_role_assignment` resources, alongside the platform
engineer, subscription owner, and security reader roles.
`rbac.tf` in this module is kept as an empty marker file, not deleted, so the
history is visible.

## What is NOT in this module, and why

- **Session recording configuration for Bastion.** The SKU choice (Premium) is
  confirmed against Microsoft Learn; whether `azurerm_bastion_host` currently
  exposes session-recording configuration directly, or whether it requires a
  separate step, is marked `[VERIFY BEFORE IMPLEMENTATION]` in `bastion.tf`.
- **Conditional Access exclusion and sign-in alerting for break-glass accounts.**
  Portal/Graph API configuration, not modelled here - see Part D, section 4.4.
- **A custom RBAC role definition for policy-exemption rights.** The Security
  Administrator role, now built in `platform/rbac/`, is granted Key Vault
  Administrator only in that pass; the specific permission for creating
  policy exemptions (`Microsoft.Authorization/policyExemptions/write`) needs a
  custom role definition, marked `[VERIFY BEFORE IMPLEMENTATION]` there.
- **An automated policy-exemption expiry control.** A disclosed, deliberate
  gap - see Part D, section 8.

## A disclosed design tension

This module stores break-glass account credentials in the same Key Vault as
every other platform secret, for consistency - but Key Vault's RBAC
authorization depends on Entra ID, which is exactly what might be degraded
when break-glass access is actually needed. See `break-glass.tf`'s comments
and Part D, section 4.4, for the full disclosure. The credential split
Microsoft's guidance calls for is an operational control this Terraform
cannot enforce.

## Dependency

Requires Part B's subscription IDs and Part C's connectivity module outputs
(hub resource group names and VNet names).

## Cost

| Resource | Monthly cost |
|---|---|
| Key Vault (Standard tier) | Negligible at this transaction volume |
| Azure Bastion Premium, x2 (one per region) | Confirm current pricing via the Azure Pricing Calculator - Premium carries a real premium over Standard, chosen deliberately for session recording (Part D, section 3.5) |
| Break-glass accounts | $0 - Entra ID user objects carry no direct charge |

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
> your own plan output before applying - this includes Key Vault and Bastion
> configuration protecting production identity infrastructure, and creates
> emergency-access accounts that require careful, documented handling of the
> resulting credentials outside this Terraform's scope.
