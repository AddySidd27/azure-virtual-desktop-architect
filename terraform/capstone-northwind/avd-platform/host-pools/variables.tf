variable "avd_prod_subscription_id" {
  type = string
}

variable "environment" {
  type    = string
  default = "prd"
}

variable "location" {
  description = "eastus2 or westeurope - this module is applied once per region, matching the explicit-repetition pattern established throughout Labs 11-20"
  type        = string
}

variable "location_short" {
  description = "eus2 or weu"
  type        = string
}

############################################
# The following are now sourced via terraform_remote_state
# (remote-state.tf), replacing manual tfvars copy-paste, per Part G's
# G2 remote-state strategy:
#   avd_hosts_subnet_id, avd_resource_group  <- avd-landing-zone/network-spokes
#   eastus2_dc_ip, westeurope_dc_ip           <- platform/identity
#   monitoring_workspace_id                    <- platform/monitoring
############################################

variable "avdlz_state_resource_group" {
  description = "Backend resource group for the avd-landing-zone layer's state - see Part G, section 1"
  type        = string
  default     = "rg-tfstate-avdlz-01"
}

variable "avdlz_state_storage_account" {
  type    = string
  default = "sttfstatenwavdlz01"
}

variable "platform_state_resource_group" {
  description = "Backend resource group for the platform layer's state - see Part G, section 1"
  type        = string
  default     = "rg-tfstate-platform-01"
}

variable "platform_state_storage_account" {
  type    = string
  default = "sttfstatenwplat01"
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

############################################
# BUSINESS DECISION REQUIRED, stated plainly: no source document in
# this book or the capstone establishes how Northwind's 3,200 users
# actually split between East US 2 (Chicago) and West Europe
# (Amsterdam + Bangalore). Chapter 1 gives per-persona TOTALS only.
# This variable defaults to an even 50/50 split as an explicit,
# labelled placeholder - not a researched or confirmed figure. Every
# host count this module computes is downstream of this one number,
# and should be revisited the moment Northwind confirms real site
# headcounts.
############################################

variable "regional_split_percent" {
  description = "BUSINESS DECISION REQUIRED. Percentage of each persona's total headcount assigned to THIS region. Default 50 is an explicit, unconfirmed placeholder, not a researched figure - see the note above."
  type        = number
  default     = 50
}

############################################
# Persona definitions, matching the master plan's fixed table exactly
# (users are TOTALS across both regions, split by regional_split_percent).
# Sizing follows Chapter 17's workload-to-size mapping directly.
############################################

variable "personas" {
  description = "Fixed by the master plan (Part F2) and Chapter 15. Do not add or remove personas here without updating the source-of-truth table."
  type = map(object({
    total_users           = number
    type                  = string # Pooled or Personal
    vm_size               = string
    users_per_host        = number # density assumption - see the per-persona notes in the module README for what's confirmed vs assumed
    max_sessions_per_host = number # AUDIT FINDING, fixed: was previously a single hardcoded value (8) applied to every pooled pool regardless of its own users_per_host density assumption - a real inconsistency, not a placeholder. Task workers assumed 15 users sharing a host would have been capped at 8 concurrent sessions, meaning 7 of those users could not connect during exactly the shift-change burst this persona is defined around. Now set per persona, matching users_per_host - but these specific numbers are STILL UNCONFIRMED, not a solved problem, only a structurally consistent one. BUSINESS DECISION REQUIRED: confirm real per-persona concurrency ratios with Northwind before relying on any of these.
  }))
  default = {
    task = {
      total_users           = 1400
      type                  = "Pooled"
      vm_size               = "Standard_D2s_v5" # Chapter 17: light-to-medium
      users_per_host        = 15
      max_sessions_per_host = 15 # matches users_per_host now, not a smaller unrelated cap
    }
    know = {
      total_users           = 1200 # 1,100 knowledge + 100 executives, folded in per the master plan's stated reasoning
      type                  = "Pooled"
      vm_size               = "Standard_D2s_v5" # Chapter 17: medium
      users_per_host        = 8
      max_sessions_per_host = 8
    }
    fin = {
      total_users           = 250
      type                  = "Pooled"
      vm_size               = "Standard_D4s_v5" # Chapter 17: medium, sized up for isolation/compliance tooling headroom
      users_per_host        = 6
      max_sessions_per_host = 6
    }
    cad = {
      total_users           = 180
      type                  = "Personal"
      vm_size               = "Standard_NV6ads_A10_v5" # [VERIFY BEFORE IMPLEMENTATION] Chapter 17 is explicit: GPU sizing is a vendor conversation, not a size-table choice. This is a placeholder example SKU, not a confirmed decision - see the module README.
      users_per_host        = 1
      max_sessions_per_host = 1 # Personal pools: one user per host, always
    }
    dev = {
      total_users           = 170
      type                  = "Personal"
      vm_size               = "Standard_D8s_v5" # Chapter 17: heavy
      users_per_host        = 1
      max_sessions_per_host = 1
    }
  }
}
