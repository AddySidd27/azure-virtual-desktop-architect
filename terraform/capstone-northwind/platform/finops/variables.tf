############################################
# REMEDIATION: closes the FinOps gap Part B section 2.9 designed and
# section 6 disclosed as deferred, never built across three subsequent
# parts.
############################################

variable "identity_subscription_id" {
  type = string
}

variable "connectivity_subscription_id" {
  type = string
}

variable "management_subscription_id" {
  type = string
}

variable "avd_prod_subscription_id" {
  description = "Added in Part H5, per the master plan's requirement that FinOps rolls up to cover the AVD subscriptions, not just the three platform ones this module originally covered."
  type        = string
}

variable "avd_nonprod_subscription_id" {
  type = string
}

variable "identity_monthly_budget" {
  description = "BUSINESS DECISION REQUIRED: this figure is a placeholder, not a confirmed budget. Part A's cost ceiling (BR-05) is stated relative to Northwind's current on-premises run cost, which this design has never been given a real number for - see Part A section 3 and the implementation tracker's open-gaps section."
  type        = number
  default     = 2000
}

variable "connectivity_monthly_budget" {
  type    = number
  default = 5000
}

variable "management_monthly_budget" {
  type    = number
  default = 1000
}

variable "avd_prod_monthly_budget" {
  description = "BUSINESS DECISION REQUIRED, same placeholder caveat as the platform budgets above - the AVD platform's actual steady-state cost has not yet been measured against a real workload, since Part F's session hosts have never been deployed to a live subscription. This figure is a starting point for the budget mechanism, not a validated number."
  type        = number
  default     = 15000
}

variable "avd_nonprod_monthly_budget" {
  type    = number
  default = 3000
}

variable "budget_alert_email" {
  description = "Email address to notify at 80% and 100% of each budget - [VERIFY BEFORE IMPLEMENTATION] confirm current azurerm_consumption_budget_subscription notification schema before relying on the exact structure below"
  type        = string
}

variable "budget_start_date" {
  description = "Must be the first day of a month, per Azure Consumption Budget requirements"
  type        = string
  default     = "2026-09-01T00:00:00Z"
}
