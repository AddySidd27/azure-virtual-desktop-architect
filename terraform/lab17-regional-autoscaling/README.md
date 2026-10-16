# Lab 17 - Regional Autoscaling with Power Management Autoscale

Terraform for [Lab 17](../../labs/lab-17-regional-autoscaling.md).

Deploys two independent `azurerm_virtual_desktop_scaling_plan` resources, one per
region, each with its own schedule, time zone, and capacity thresholds, attached
to that region's host pool only. This is the required, production-safe
implementation for this book - see
[the ADR](../../appendices/adr-shc-vs-standard-host-pools.md) for why Dynamic
Autoscaling is covered as an optional upgrade path in the lab markdown instead.

## This lab replaces Lab 10's scaling plan for the active-active design

Lab 10 built a single scaling plan assuming one region. This lab's `eastus2`
scaling plan (`sp-avd-lab-eus2-01`) supersedes it with a plan scoped for the
two-region design; if you still have Lab 10's original plan applied, remove it
(`terraform destroy` in `terraform/lab10-operations`, targeting only the scaling
plan resource) before applying this lab, so `eastus2`'s host pool isn't associated
with two conflicting scaling plans at once.

## Cost

No direct charge for the scaling plan objects. Cost impact is a *reduction*
against Lab 14's always-on baseline, since Power Management Autoscale deallocates
idle session hosts during ramp-down and off-peak windows rather than leaving them
running. The saving has not been measured, so no percentage is claimed here.
Before quoting one, compare the compute hours or cost data for Lab 14's
always-on hosts with this lab's hosts over the same period.

## Dependency on Labs 7, 11, and 14

Reads Lab 7's state for the `eastus2` host pool ID (a new output - see the note in
`terraform/lab07-avd-core/README.md`), Lab 11's state for the `centralus` avd
resource group, and Lab 14's state for the `centralus` host pool ID (also a new
output - see `terraform/lab14-active-active-hostpools/README.md`).

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit owner, primary_state_storage_account
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## How the two regions' schedules differ

`centralus`'s schedule isn't `eastus2`'s schedule with the region name changed.
It uses its own minimum-hosts and capacity-threshold percentages, a longer
ramp-down wait time and a later off-peak start. Its local times look an hour
earlier (06:00 versus 07:00), but Central is one hour behind Eastern, so
ramp-up, peak and ramp-down fall at the same moment in both regions. In
absolute time only off-peak differs, starting two hours later in `centralus`.
This is clock arithmetic and assumes both time zones follow the same
daylight-saving rules; how a scaling plan behaves across a daylight-saving
change is not verified here. The percentages and wait times are deliberate
placeholders for different demand assumptions per user cohort, and copying one
region's schedule into the other would be exactly the kind of unexamined
default this book avoids elsewhere.
