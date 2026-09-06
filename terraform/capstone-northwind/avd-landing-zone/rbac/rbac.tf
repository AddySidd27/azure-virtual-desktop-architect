############################################
# AVD-specific RBAC, built with the correct resource type from the
# start - the PIM remediation exists because Parts B and D didn't do
# this the first time. See Part E, section 7, for the full reasoning
# per role.
#
# AUDIT FINDING, fixed: the original version of this file used
# "Desktop Virtualization User Session Host Operator" for Service
# Desk - a role name that does NOT exist in Azure. It was an
# accidental fusion of two real, distinct roles: "Desktop
# Virtualization Session Host Operator" (manages session HOSTS -
# remove, drain mode) and "Desktop Virtualization User Session
# Operator" (manages user SESSIONS - disconnect, logoff). Confirmed
# directly against Microsoft's own built-in roles documentation
# during the Part F audit. Both are now looked up by their real,
# confirmed names via data sources, not hardcoded GUIDs.
#
# NOT built here: End User. Its correct scope is Part F's future
# application groups (persona-specific, non-overlapping per the model
# platform/rbac already established), which do not exist yet -
# building it now would mean guessing a scope, the same mistake this
# design has already corrected once.
############################################

data "azurerm_role_definition" "desktop_virtualization_contributor" {
  name  = "Desktop Virtualization Contributor"
  scope = "/subscriptions/${var.avd_prod_subscription_id}"
}

data "azurerm_role_definition" "desktop_virtualization_session_host_operator" {
  name  = "Desktop Virtualization Session Host Operator"
  scope = "/subscriptions/${var.avd_prod_subscription_id}"
}

data "azurerm_role_definition" "desktop_virtualization_user_session_operator" {
  name  = "Desktop Virtualization User Session Operator"
  scope = "/subscriptions/${var.avd_prod_subscription_id}"
}

resource "azurerm_pim_eligible_role_assignment" "avd_platform_engineer" {
  scope              = "/subscriptions/${var.avd_prod_subscription_id}"
  role_definition_id = data.azurerm_role_definition.desktop_virtualization_contributor.id
  principal_id       = var.avd_platform_engineer_principal_id

  schedule {
    start_date_time = var.pim_eligibility_start
    expiration {
      end_date_time = var.pim_eligibility_end
    }
  }
}

resource "azurerm_pim_eligible_role_assignment" "session_host_operator" {
  scope              = "/subscriptions/${var.avd_prod_subscription_id}"
  role_definition_id = data.azurerm_role_definition.desktop_virtualization_session_host_operator.id
  principal_id       = var.session_host_operator_principal_id

  schedule {
    start_date_time = var.pim_eligibility_start
    expiration {
      end_date_time = var.pim_eligibility_end
    }
  }
}

resource "azurerm_role_assignment" "service_desk" {
  scope              = "/subscriptions/${var.avd_prod_subscription_id}"
  role_definition_id = data.azurerm_role_definition.desktop_virtualization_user_session_operator.id
  principal_id       = var.service_desk_principal_id

  # STANDING, deliberately - not a mistake to fix later. See Part E,
  # section 7: high-frequency, low-blast-radius work should not carry
  # PIM activation friction, the same proportionality reasoning
  # Project 03 already established.
}
