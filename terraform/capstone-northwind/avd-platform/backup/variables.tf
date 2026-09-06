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

variable "avdplt_state_resource_group" {
  type    = string
  default = "rg-tfstate-avdplt-01"
}

variable "avdplt_state_storage_account" {
  type    = string
  default = "sttfstatenwavdplt01"
}

variable "fslogix_state_key" {
  description = "Must match the key used for THIS region's fslogix apply - see fslogix/backend.tf"
  type        = string
}

variable "retention_daily_count" {
  description = "BUSINESS/COMPLIANCE DECISION REQUIRED: matches the same open item as the SOX log-retention question in Part D section 6 - this default (30 days) is a general-purpose figure, not a confirmed FSLogix-profile-data retention decision from Northwind's compliance function"
  type        = number
  default     = 30
}

variable "backup_time_utc" {
  description = "Daily backup time, UTC, 24-hour HH:MM format"
  type        = string
  default     = "23:00"
}
