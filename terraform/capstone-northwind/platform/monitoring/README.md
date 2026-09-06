# Capstone Remediation - Monitoring Foundation

Terraform closing the gap named in the [implementation tracker](../../../../capstone/implementation-tracker.md):
Part B designed a tenant-wide Log Analytics workspace (section 2.8) that was
never built as Terraform across three subsequent parts.

## What this closes, and what it does not

Builds the workspace itself. Does **not** re-apply the diagnostic-settings
policy in `../policy/` - that module's `log_analytics_workspace_id` variable
should be set to this module's `workspace_id` output, and that module
re-applied, once both exist. This is stated as a dependency, not silently
assumed to happen automatically.

## A business decision this module does not make for you

`log_retention_days` defaults to 90 - a general-purpose Azure default, **not**
a confirmed SOX-compliant retention period. Part D, section 6, states this
explicitly: the correct figure is Northwind's compliance function's decision,
not an Azure technical fact. Do not treat the default as if that decision has
already been made.

## Cost

Log Analytics: ingestion-based, real cost that scales with actual log volume
once diagnostic settings are pointed at this workspace. Confirm current
pricing via the Azure Pricing Calculator before committing to a retention
period beyond the default.

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
> your own plan output before applying.
