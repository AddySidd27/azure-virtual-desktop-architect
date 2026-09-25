# Capstone Remediation - Platform RBAC and PIM

Terraform for the [implementation tracker](../../../../capstone/implementation-tracker.md)'s
headline finding: every role Parts B and D described as "PIM-eligible" was
actually built - or in Part B's case, never built at all - as a standing
assignment. This module is the single, correct, consolidated home for all six
platform-wide roles.

## What changed from the original design

- **Platform Engineer, Subscription Owner, Security Reader** (Part B):
  never had any Terraform. Built here for the first time - the first two as
  genuinely PIM-eligible, Security Reader as standing, matching the original
  design intent exactly.
- **Identity Administrator, Network Administrator** (Part D): previously
  `azurerm_role_assignment` (standing) in `platform/security/rbac.tf`. Rebuilt
  here as `azurerm_pim_eligible_role_assignment`. **The two standing
  assignments in the security module are superseded by this module and should
  be removed** - see `platform/security/README.md`.
- **Security Administrator** (Part D): previously a standing Key Vault
  Administrator assignment. Rebuilt here as PIM-eligible, same role, same
  scope.

## A real, disclosed tooling risk, not hidden

`azurerm_pim_eligible_role_assignment` is a genuine, current Terraform
Registry resource, confirmed against the registry. Historical GitHub
issues against the `hashicorp/azurerm`
provider report "Role Management Policy... couldn't find resource" errors on
first apply in some tenants. This is noted here as a real risk to test
carefully - ideally against `sub-northwind-avd-nonprod` once it exists, not
production identity infrastructure - not a reason to avoid fixing the
underlying design gap.

## Cost

**$0.00.** PIM eligibility and role assignments carry no direct Azure charge.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit with real values
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> This Terraform has not been run against a live Azure subscription. Given
> the historical provider issues noted above, plan and apply this module
> carefully, ideally in a non-production tenant first.
