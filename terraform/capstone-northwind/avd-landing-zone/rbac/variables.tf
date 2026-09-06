variable "avd_prod_subscription_id" {
  type = string
}

variable "avd_platform_engineer_principal_id" {
  type = string
}

variable "session_host_operator_principal_id" {
  type = string
}

variable "service_desk_principal_id" {
  type = string
}

variable "pim_eligibility_start" {
  description = "[VERIFY BEFORE IMPLEMENTATION] Matches the same fixed-placeholder pattern as platform/rbac, for the same reason: stable, reviewable plans rather than a timestamp() that changes every run."
  type        = string
  default     = "2026-09-01T00:00:00Z"
}

variable "pim_eligibility_end" {
  type    = string
  default = null
}
