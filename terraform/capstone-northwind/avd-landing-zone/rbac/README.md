# Capstone Part E - AVD-Specific RBAC

Terraform for [Part E](../../../../capstone/parts/part-e-avd-landing-zone.md), section 7.

Three AVD-specific roles, each built with the resource type its actual
purpose requires, decided deliberately rather than defaulted:

| Role | Type | Why |
|---|---|---|
| AVD Platform Engineer | PIM-eligible | Real blast radius over host pool configuration |
| Session Host Operator | PIM-eligible | Day-2 operational access, not permanent |
| Service Desk | **Standing** | High-frequency, low-blast-radius work - PIM activation friction here creates workaround pressure, the same reasoning Project 03 already established |

**End User is deliberately not built here** - its correct scope is Part F's
future, persona-specific application groups, which do not exist yet.

## Why this module exists as proof the PIM lesson was learned

The [implementation tracker](../../../../capstone/implementation-tracker.md)'s
headline finding was roles described as PIM-eligible with no PIM Terraform
behind them. Every role in this module is built with its actual, considered
resource type from the moment it's created - not retrofitted after a review
found the gap, the way `platform/rbac/` had to be.

## Fixed during the Part F audit: a fabricated role name

The original version of this module used `"Desktop Virtualization User
Session Host Operator"` for Service Desk - a role name that **does not exist
in Azure**. It was an accidental fusion of two real, distinct built-in roles,
confirmed directly against Microsoft's own documentation:

- **Desktop Virtualization Session Host Operator** (GA, not preview) -
  manages session *hosts* (remove, drain mode) - now correctly used for
  Session Host Operator, replacing a generic `Contributor` placeholder.
- **Desktop Virtualization User Session Operator** - manages user *sessions*
  (disconnect, logoff) - now correctly used for Service Desk. **Microsoft's
  own documentation marks this role "in preview and subject to change"** -
  a real, disclosed maturity risk for a role this design uses for standing,
  everyday access. Confirm current status before relying on it in production.

Both roles, plus **Desktop Virtualization Contributor** for AVD Platform
Engineer (also confirmed real, replacing generic `Contributor`), are now
looked up via `data "azurerm_role_definition"` by name, not hardcoded GUIDs -
avoiding the exact class of typo/fabrication error this audit found.

## Remaining accuracy gap

The `role_definition_id` construction in `rbac.tf` (concatenating a
subscription path in front of each data source's `.id` output) is marked
`[VERIFY BEFORE IMPLEMENTATION]` - confirm the actual ID format via a real
`terraform plan` before applying, since an incorrect assumption here would
produce an invalid, malformed role definition path. The Service Desk role's
preview status (above) is a separate, disclosed risk.

## Cost

**$0.00.** No resource exists yet to test these roles against - Part F.

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
