variable "avd_prod_subscription_id" {
  type = string
}

variable "environment" {
  type    = string
  default = "prd"
}

variable "location" {
  type = string
}

variable "location_short" {
  type = string
}

############################################
# avd_resource_group and avd_hosts_subnet_id are now resolved via
# terraform_remote_state (remote-state.tf), per Part G section 2.
############################################

variable "avdlz_state_resource_group" {
  type    = string
  default = "rg-tfstate-avdlz-01"
}

variable "avdlz_state_storage_account" {
  type    = string
  default = "sttfstatenwavdlz01"
}

variable "file_share_quota_gb" {
  description = "Sized per the task-worker worked example in Chapter 20 (32,000 peak IOPS at the sign-in burst); the other four personas do not yet have a published worked example - see the module README"
  type        = number
  default     = 5000
}

############################################
# RBAC split per ADR-CAP-06: finance gets its own share-level RBAC
# group, separate from the other four personas' combined group -
# adopted unconditionally, effective immediately, regardless of
# whether finance ends up on shared or dedicated storage.
############################################

variable "non_finance_users_group_object_id" {
  description = "Combined Entra group for task, knowledge, CAD, and developer personas - THIS region only. Finance is deliberately excluded, per ADR-CAP-06."
  type        = string
}

variable "finance_users_group_object_id" {
  description = "Finance-specific Entra group, THIS region only - per ADR-CAP-06's adopted RBAC split, independent of whether finance ends up on shared or dedicated storage."
  type        = string
}

############################################
# Dedicated finance storage, per ADR-CAP-06 - BUSINESS/COMPLIANCE
# DECISION REQUIRED. Default false: the shared account already
# provides equivalent file-level isolation via Chapter 20's two-layer
# permission model. Set true only once Northwind's compliance
# function confirms storage-account-level segregation is required
# beyond what this book's established SOX scope (Part D, section 6)
# technically mandates.
############################################

variable "enable_finance_dedicated_storage" {
  description = "BUSINESS/COMPLIANCE DECISION REQUIRED. See ADR-CAP-06. Default false preserves the current shared-storage design, which already isolates individual profiles at the file level."
  type        = bool
  default     = false
}

variable "finance_file_share_quota_gb" {
  description = "Only used if enable_finance_dedicated_storage = true. Sized to finance's own 250-user share, not a full duplicate of the combined regional quota - no worked sizing example exists for this persona (see the module README), this is a placeholder."
  type        = number
  default     = 1000
}
