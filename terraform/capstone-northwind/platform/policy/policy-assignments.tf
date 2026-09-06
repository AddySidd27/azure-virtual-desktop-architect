############################################
# Policy: allowed locations
#
# Built-in Azure Policy definition. GUID confirmed directly against
# Microsoft Learn's own tutorial documentation during this capstone's
# research pass (learn.microsoft.com/azure/governance/policy/
# tutorials/create-and-manage) - this one is verified, not a working
# assumption. Traces to Part A constraint C-01.
############################################

resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  display_name         = "Northwind - allowed locations (East US 2, West Europe only)"
  management_group_id  = var.northwind_management_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"

  parameters = jsonencode({
    listOfAllowedLocations = { value = var.allowed_locations }
  })
}

############################################
# Policy: required tags
#
# [VERIFY BEFORE IMPLEMENTATION] The built-in "Require a tag on
# resources" policy definition GUID could not be independently
# confirmed from official Microsoft documentation during this
# capstone's research pass - searches returned at least three
# different candidate GUIDs across sources of varying authority.
# The GUID below (871b6d14-10aa-478d-b590-94f262ecfa99) is the one
# explicitly labelled "Require a tag on resources" in Microsoft's own
# Azure Landing Zones reference implementation
# (azure.github.io/Azure-Landing-Zones), the most directly-labelled
# source found, but it is used here as a working default requiring
# confirmation, not as a verified fact. Confirm via
# `az policy definition list --query "[?displayName=='Require a tag
# on resources']"` before applying. Traces to Part A requirement
# TR-04.
############################################

resource "azurerm_management_group_policy_assignment" "required_tags" {
  for_each = toset(var.required_tags)

  name                 = "require-tag-${lower(each.value)}"
  display_name         = "Northwind - require tag: ${each.value}"
  management_group_id  = var.northwind_management_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/${var.require_tag_policy_definition_id}"

  parameters = jsonencode({
    tagName = { value = each.value }
  })
}

############################################
# Policy: mandatory diagnostic settings to the platform workspace
#
# [VERIFY BEFORE IMPLEMENTATION] Microsoft publishes built-in policy
# initiatives for deploying diagnostic settings to a Log Analytics
# workspace, but the exact initiative name and GUID vary by resource
# type and change over time. Confirm the current initiative at
# https://www.microsoft.com/en-us/download/details.aspx?id=56519
# (the Azure Policy built-in definitions reference) or via
# `az policy set-definition list --query "[?contains(displayName,
# 'Diagnostic')]"` before relying on a specific GUID here. This
# resource is written against the initiative shape, not a hard-coded
# ID, for that reason.
############################################

resource "azurerm_management_group_policy_assignment" "diagnostic_settings" {
  name                 = "mandatory-diagnostics"
  display_name         = "Northwind - mandatory diagnostic settings to platform workspace"
  management_group_id  = var.northwind_management_group_id
  policy_definition_id = var.diagnostic_settings_policy_definition_id

  parameters = jsonencode({
    logAnalytics = { value = var.log_analytics_workspace_id }
  })

  identity {
    type = "SystemAssigned"
  }

  location = "eastus2" # required for DeployIfNotExists assignments with a managed identity
}
