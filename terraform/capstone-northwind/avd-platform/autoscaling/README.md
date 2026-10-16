# Capstone Part H - Regional Autoscaling

Terraform for [Part H](../../../../capstone/parts/part-h-operations-dr-monitoring-finops.md), section H4.

Six independent Power Management Autoscale scaling plans (task, knowledge,
finance x East US 2, West Europe) - not Dynamic Autoscaling, per the same
SHC reconciliation as Part F8 and the existing ADR. Personal pools (CAD,
developers) are not scaled this way - they use Start VM on Connect, already
set on the host pool in Part F.

## Schema corrections

Earlier drafts of this module (and of Lab 17, which it followed) did not match
the AzureRM v5.10.0 schema for `azurerm_virtual_desktop_scaling_plan`. They
used a `host_pool_association` block and a `host_pool_type` argument; the
resource defines a `host_pool` block (`hostpool_id`, `scaling_plan_enabled`)
and no `host_pool_type` argument. They also omitted the required
`ramp_down_notification_message` and `ramp_down_stop_hosts_when` arguments.
`terraform validate` failed for this module before the correction (diagnostic
run 38843347683, 15 October 2026). The module now uses the `host_pool` block,
has no `host_pool_type`, and sets both required ramp-down arguments
(`ramp_down_stop_hosts_when = "ZeroSessions"`). Separately, `peak_start_time`
is a genuinely later, distinct value than `ramp_up_start_time`.

Repository CI runs `terraform validate` on this module as part of the check
recorded in [TERRAFORM-VALIDATION.md](../../../../TERRAFORM-VALIDATION.md).
That is a schema check, not a plan, an apply or an observed scaling result.

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
