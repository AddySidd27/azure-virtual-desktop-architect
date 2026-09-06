############################################
# Regional groups
#
# One group per population per region. A user is placed in EXACTLY ONE
# of the two groups for their population, never both - this is what
# prevents the ERROR_LOCK_VIOLATION failure Lab 15 deliberately
# reproduced. Terraform builds the groups; population membership is a
# deliberate manual/HR-process decision this lab does not automate,
# because who belongs in which region is a business decision, not an
# infrastructure one.
############################################

resource "azuread_group" "region" {
  for_each = local.region_groups

  display_name     = "grp-avdlab-${each.key}"
  description      = "AVD access, ${each.value.population} population, ${each.value.region == "eus2" ? "East US 2" : "Central US"} only. Do not add a user to both the eus2 and cus group for the same population."
  security_enabled = true
}

############################################
# Application group role assignments
#
# eus2 groups scope to Lab 7's application group. cus groups scope to
# Lab 14's. A group named *-eus2 can never reach the centralus desktop,
# and vice versa - the assignment layer itself enforces the boundary,
# not just a naming convention someone could get wrong.
############################################

resource "azurerm_role_assignment" "eus2_assignment" {
  for_each = { for k, v in local.region_groups : k => v if v.region == "eus2" }

  scope                = data.terraform_remote_state.lab07_avd_core.outputs.application_group_id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = azuread_group.region[each.key].object_id
}

resource "azurerm_role_assignment" "cus_assignment" {
  for_each = { for k, v in local.region_groups : k => v if v.region == "cus" }

  scope                = data.terraform_remote_state.lab14_hostpools.outputs.application_group_id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = azuread_group.region[each.key].object_id
}
