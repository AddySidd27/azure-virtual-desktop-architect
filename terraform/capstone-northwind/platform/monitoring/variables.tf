############################################
# REMEDIATION: this module closes the gap Part B's own section 6
# disclosed and Part D's tracker review confirmed was never actually
# closed: a tenant-wide Log Analytics workspace, designed in Part B
# section 2.8, but never built as Terraform across three subsequent
# parts.
############################################

variable "environment" {
  type    = string
  default = "prd"
}

variable "log_retention_days" {
  description = "BUSINESS/COMPLIANCE DECISION REQUIRED, not an Azure technical fact: the correct retention period for SOX-relevant access evidence is a decision for Northwind's own compliance/audit function, per Part D section 6. This default (90 days) is a general-purpose Azure default, NOT a confirmed SOX-compliant figure - do not treat this default as if that decision has already been made."
  type        = number
  default     = 90
}

variable "owner" {
  type = string
}

variable "cost_centre" {
  type = string
}
