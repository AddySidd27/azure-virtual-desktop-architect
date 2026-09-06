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

variable "host_pools_state_key" {
  description = "Must match the key used for THIS region's host-pools apply - see host-pools/backend.tf"
  type        = string
}

variable "log_retention_days" {
  description = "BUSINESS/COMPLIANCE DECISION REQUIRED, same caveat as platform/monitoring: this default (30) is a general AVD-operational-monitoring figure, distinct from and shorter than whatever SOX-relevant retention period Northwind's compliance function eventually confirms for the platform workspace"
  type        = number
  default     = 30
}

variable "owner" {
  type = string
}

variable "cost_centre" {
  type = string
}
