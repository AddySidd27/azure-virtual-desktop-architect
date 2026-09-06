variable "location" {
  type    = string
  default = "eastus2"
}

variable "location_short" {
  type    = string
  default = "eus2"
}
variable "environment" {
  type    = string
  default = "lab"
}
variable "owner" {
  type = string
}
variable "deletion_date" {
  type    = string
  default = "2026-12-31"
}
variable "monitoring_resource_group_name" {
  type    = string
  default = "rg-avd-monitoring-lab-eus2-01"
}
variable "service_resource_group_name" {
  type    = string
  default = "rg-avd-service-lab-eus2-01"
}
variable "host_pool_name" {
  type    = string
  default = "hp-avd-lab-eus2-01"
}
variable "log_retention_days" {
  description = "Kept short for the lab to control cost. Production guidance (ch02, Project 02) is typically 90 days interactive plus a longer archive tier."
  type        = number
  default     = 30
}
