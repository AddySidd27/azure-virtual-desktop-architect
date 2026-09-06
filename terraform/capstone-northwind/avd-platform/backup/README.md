# Capstone Part H - FSLogix Backup

Terraform for [Part H](../../../../capstone/parts/part-h-operations-dr-monitoring-finops.md), section H3.

Azure Backup (Recovery Services vault, daily policy, protected file share)
for the FSLogix storage account built in Part F - the concrete answer to
[Project 14](../../../../scenarios/project-14-disaster-recovery.md)'s core
lesson, applied to a real, specific gap this capstone actually had.

## The gap this closes, stated precisely

Cloud Cache (Part F9) is **redundancy** - it protects against one region's
storage account failing outright. It is **not backup** - it provides no
protection against corruption or accidental/malicious deletion propagating
to both regions' replicated copies, and no point-in-time restore. Before
this module, Northwind's FSLogix estate had redundancy and nothing else -
the same gap Project 14's Corrigan engagement found and corrected for a
different customer, now found and corrected here.

## Schema verified against a real, published example, not assumed

`azurerm_backup_container_storage_account`, `azurerm_backup_policy_file_share`,
and `azurerm_backup_protected_file_share` were checked against a real,
published Terraform configuration specifically for FSLogix profile backup
before use - not assumed from generic Azure Backup familiarity. One real
schema detail this caught: all three resources take the **vault's** resource
group for `resource_group_name`, not the storage account's - an easy detail
to get backwards, corrected before this module was considered complete.

## A business decision this module does not make for you

`retention_daily_count` defaults to 30 days - a general-purpose figure, not
a confirmed SOX-compliant retention period. This is the same open item as
Part D section 6's platform-workspace retention question, now recurring here
for FSLogix backup specifically - both should be confirmed together with
Northwind's compliance function, not decided independently of each other.

## What this does NOT cover

The dedicated finance storage account (ADR-CAP-06, currently gated off by
default) has no backup coverage yet if enabled - a follow-up item, not
silently assumed included by this module.

## Cost

Recovery Services vault storage and backup job execution - confirm current
pricing via the Azure Pricing Calculator, scaled to the FSLogix share's
actual quota (Part F: 5000 GB default, itself only sized from the
task-worker worked example).

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit for eastus2 first
terraform init -backend-config="key=avdplt-backup-eastus2.tfstate"
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> This Terraform has not been run against a live Azure subscription.
