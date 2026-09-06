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

variable "hosts_resource_group_name" {
  type    = string
  default = "rg-avd-hosts-lab-eus2-01"
}

variable "network_resource_group_name" {
  type    = string
  default = "rg-avd-network-lab-eus2-01"
}

variable "vnet_name" {
  type    = string
  default = "vnet-avd-lab-eus2-01"
}

variable "hosts_subnet_name" {
  type    = string
  default = "snet-hosts-lab-eus2-01"
}

variable "host_count" {
  description = "Number of session hosts. Kept small for the lab; production sizing is a measured decision, see Chapter 17."
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Lab default is deliberately small. Standard_D2s_v5 is enough for one or two test sign-ins; do not use this size for a real sizing exercise."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  type    = string
  default = "avdlabadmin"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "host_pool_name" {
  description = "Host pool created in Lab 7"
  type        = string
  default     = "hp-avd-lab-eus2-01"
}

variable "registration_token" {
  description = "Registration token from Lab 7. Pass with -var, never commit. See the lab README for the exact retrieval command."
  type        = string
  sensitive   = true
}

variable "dns_servers" {
  description = "Domain controller IP from Lab 4, used so session hosts resolve AD and the storage private endpoint correctly"
  type        = list(string)
  default     = ["10.10.1.4"]
}
