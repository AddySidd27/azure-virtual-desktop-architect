# Capstone Part H - AVD Regional Monitoring

Terraform for [Part H](../../../../capstone/parts/part-h-operations-dr-monitoring-finops.md), section H1.

One AVD-specific Log Analytics workspace per region, additional to
`platform/monitoring`'s tenant-wide workspace - not a replacement. A second
diagnostic setting is added to each existing host pool (via remote-state
read, not by editing Part F's `host-pools` module), sending AVD-specific
telemetry here without touching Part F's own diagnostic setting pointed at
the platform workspace.

## What this does NOT build - disclosed, not implied complete

Full AVD Insights also requires Azure Monitor Agent and a Data Collection
Rule deployed to every session host (for performance counters and Windows
Event Logs), plus specific RBAC roles (Desktop Virtualization Reader,
Log Analytics Reader) for anyone viewing the Insights workbook. **Neither is
built here.** This module gets host-pool-level diagnostic data flowing to a
dedicated workspace - a real, necessary precondition for Insights, not
Insights itself fully configured and operational.

## Cost

Log Analytics ingestion, per region - confirm current pricing via the Azure
Pricing Calculator once real host pool activity exists to generate volume.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit for eastus2 first
terraform init -backend-config="key=avdplt-monitoring-eastus2.tfstate"
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> This Terraform has not been run against a live Azure subscription.
