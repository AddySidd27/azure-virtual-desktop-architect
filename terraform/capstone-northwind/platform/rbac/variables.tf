############################################
# This module is the REMEDIATION for the headline finding in
# capstone/implementation-tracker.md: every role Parts B and D
# described as "PIM-eligible" was actually built (or not built at
# all) as a standing assignment. This module is the single, correct
# home for all six platform-wide roles, superseding the two standing
# assignments (Identity Administrator, Network Administrator)
# previously in platform/security/rbac.tf, which are removed as part
# of this remediation - see that module's README for the note.
############################################

variable "northwind_management_group_id" {
  description = "Output from the management-groups module (Part B)"
  type        = string
}

variable "identity_subscription_id" {
  type = string
}

variable "connectivity_subscription_id" {
  type = string
}

variable "key_vault_id" {
  description = "Output from the security module (Part D) - Security Administrator's PIM-eligible scope"
  type        = string
}

variable "platform_engineer_principal_id" {
  type = string
}

variable "subscription_owner_principal_id" {
  type = string
}

variable "security_reader_principal_id" {
  type = string
}

variable "identity_administrator_principal_id" {
  type = string
}

variable "network_administrator_principal_id" {
  type = string
}

variable "security_administrator_principal_id" {
  type = string
}

variable "pim_eligibility_start" {
  description = "[VERIFY BEFORE IMPLEMENTATION] Start time for PIM eligibility windows. Defaulted to a fixed placeholder rather than timestamp() so plans are stable and reviewable - replace with your actual intended start before applying. See the module README for the eligibility-window design decision."
  type        = string
  default     = "2026-09-01T00:00:00Z"
}

variable "pim_eligibility_end" {
  description = "Null means permanent eligibility, appropriate for standing platform team roles rather than time-boxed project assignments - see the module README."
  type        = string
  default     = null
}
