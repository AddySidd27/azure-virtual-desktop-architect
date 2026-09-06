# Capstone Part H - Regional Autoscaling

Terraform for [Part H](../../../../capstone/parts/part-h-operations-dr-monitoring-finops.md), section H4.

Six independent Power Management Autoscale scaling plans (task, knowledge,
finance x East US 2, West Europe) - not Dynamic Autoscaling, per the same
SHC reconciliation as Part F8 and the existing ADR. Personal pools (CAD,
developers) are not scaled this way - they use Start VM on Connect, already
set on the host pool in Part F.

## Schema corrected against Lab 17's own proven pattern, not memory

Building this surfaced three real errors, caught by checking against this
book's own already-validated Lab 17 Terraform rather than trusting recall:
a wrong block name (`host_pool_association`, not `host_pool`), a missing
required `host_pool_type` argument, and `peak_start_time` incorrectly set
equal to `ramp_up_start_time` instead of a genuinely later, distinct value.
All three fixed before this module was considered complete.

## West Europe's schedule is genuinely different, not just varied for teaching

West Europe serves both Amsterdam (CET) and Bangalore (internet path, per
the Part E ADR) - a 4.5-hour timezone gap. Its active window (05:00-19:00
CET) is deliberately wider than East US 2's single-timezone window
(07:00-18:00 ET), specifically to cover both populations' business hours.

## Cost

Scaling plans carry no direct charge - they reduce Part F's baseline compute
cost by deallocating idle hosts during ramp-down and off-peak windows.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit for eastus2 first
terraform init -backend-config="key=avdplt-autoscaling-eastus2.tfstate"
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> This Terraform has not been run against a live Azure subscription. The
> `time_zone` value for West Europe (`W. Europe Standard Time`) has not been
> independently re-verified in this pass - confirm before applying.
