variable "avd_prod_subscription_id" {
  type = string
}

variable "environment" {
  type    = string
  default = "prd"
}

variable "location" {
  description = "eastus2 or westeurope"
  type        = string
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
  description = "Must match the key used for THIS region's host-pools apply"
  type        = string
}

############################################
# Schedules - genuinely different per region, not copy-pasted, for a
# reason specific to Northwind (not just Lab 17's general teaching
# point about varying numbers): West Europe serves both Amsterdam
# (CET) and Bangalore (IST, internet path, per the Part E ADR) - a
# 4.5-hour timezone gap. Its active window is deliberately wider than
# East US 2's single-timezone (Chicago, Eastern) window, to actually
# cover both populations' business hours, not just to look different.
############################################

variable "eastus2_schedule" {
  type = object({
    ramp_up_time              = string
    ramp_up_min_percent       = number
    ramp_up_threshold_percent = number
    peak_time                 = string
    ramp_down_time            = string
    ramp_down_min_percent     = number
    ramp_down_wait_minutes    = number
    off_peak_time             = string
  })
  default = {
    ramp_up_time              = "07:00"
    ramp_up_min_percent       = 50
    ramp_up_threshold_percent = 80
    peak_time                 = "09:00"
    ramp_down_time            = "18:00"
    ramp_down_min_percent     = 10
    ramp_down_wait_minutes    = 30
    off_peak_time             = "20:00"
  }
}

variable "westeurope_schedule" {
  description = "Wider active window than eastus2 - covers Bangalore's morning IST through Amsterdam's evening CET."
  type = object({
    ramp_up_time              = string
    ramp_up_min_percent       = number
    ramp_up_threshold_percent = number
    peak_time                 = string
    ramp_down_time            = string
    ramp_down_min_percent     = number
    ramp_down_wait_minutes    = number
    off_peak_time             = string
  })
  default = {
    ramp_up_time              = "05:00"
    ramp_up_min_percent       = 60
    ramp_up_threshold_percent = 75
    peak_time                 = "08:00"
    ramp_down_time            = "19:00"
    ramp_down_min_percent     = 15
    ramp_down_wait_minutes    = 45
    off_peak_time             = "21:00"
  }
}

variable "time_zone" {
  description = "[VERIFY BEFORE IMPLEMENTATION] confirm the exact current Windows time zone ID string azurerm_virtual_desktop_scaling_plan expects against the Terraform Registry - these are Windows time zone names, not IANA identifiers, and easy to get subtly wrong"
  type        = string
}

variable "exclusion_tag_name" {
  type    = string
  default = "avd-autoscale-exclude"
}

variable "avdlz_state_resource_group" {
  description = "Resolves this region's AVD resource group via remote state - see remote-state.tf"
  type        = string
  default     = "rg-tfstate-avdlz-01"
}

variable "avdlz_state_storage_account" {
  type    = string
  default = "sttfstatenwavdlz01"
}
