variable "northwind_management_group_id" {
  description = "Output from the management-groups module - the scope this initiative is assigned to"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the platform Log Analytics workspace (built in a follow-up Terraform pass, per Part B section 6). Required for the diagnostic-settings policy's DeployIfNotExists effect."
  type        = string
}

variable "diagnostic_settings_policy_definition_id" {
  description = "[VERIFY BEFORE IMPLEMENTATION] The built-in policy initiative ID for deploying diagnostic settings to a Log Analytics workspace. Not hard-coded as a default because Microsoft's exact initiative name and GUID for this vary by resource type and change over time - confirm the current one via `az policy set-definition list` before applying. See the note in policy-assignments.tf."
  type        = string
}

variable "require_tag_policy_definition_id" {
  description = "[VERIFY BEFORE IMPLEMENTATION] GUID for the built-in 'Require a tag on resources' policy. Defaulted to the value found in Microsoft's own Azure Landing Zones reference implementation, but not independently confirmed against the official Azure Policy built-in definitions reference - confirm via `az policy definition list` before relying on it. See the note in policy-assignments.tf."
  type        = string
  default     = "871b6d14-10aa-478d-b590-94f262ecfa99"
}

variable "allowed_locations" {
  description = "The only two Azure regions Northwind's platform permits by default. Matches Part A constraint C-01. A workload needing a third region requires a documented, reviewed policy exception, not a change to this default."
  type        = list(string)
  default     = ["eastus2", "westeurope"]
}

variable "required_tags" {
  description = "Tag names enforced on every resource, per Part B section 2.4"
  type        = list(string)
  default     = ["BusinessUnit", "Environment", "CostCentre", "DataClassification", "Owner"]
}
