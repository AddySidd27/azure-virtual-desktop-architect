# Capstone Part B Remediation + Part H5 - FinOps Budgets

Terraform closing two gaps: Part B designed per-subscription budgets (section
2.9) never built across three subsequent parts (remediated for the three
platform subscriptions before Part E began), and Part H5's explicit
requirement that FinOps "roll up" to cover the AVD subscriptions too - added
here for `sub-northwind-avd-prod` and `sub-northwind-avd-nonprod`, which had
no budget at all until this pass despite being where Part F and E actually
built billable resources.

## What this closes, and what it honestly does not

Builds the budget **mechanism** - one `azurerm_consumption_budget_subscription`
per subscription (five total: three platform, two AVD), with 80%/100% email
alerts. Every budget figure is a **placeholder**, not a real number: this
engagement has never been given Northwind's actual current on-premises VDI
run cost, which is the figure Part A's cost ceiling (BR-05) is stated
relative to - and the AVD budgets specifically have never been checked
against real measured spend, since Part F's session hosts have never been
deployed to a live subscription. See Part A's open-gaps disclosure. Building
the mechanism now, with honest placeholders, means Northwind can correct the
numbers later without building the governance capability from scratch when
they do - it does not mean a real budget has been agreed for any of the five
subscriptions.

## Cost

The budgets themselves carry no charge. What they alert against - actual
platform subscription spend - is real and already accruing from every
resource this capstone has built so far.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit with real subscription IDs and a real alert email; budget figures remain placeholders until Northwind confirms real ones
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

> This Terraform has not been run against a live Azure subscription. The
> exact `azurerm_consumption_budget_subscription` notification schema should
> be confirmed against the current Terraform Registry documentation before
> applying - marked `[VERIFY BEFORE IMPLEMENTATION]` in `variables.tf`.
