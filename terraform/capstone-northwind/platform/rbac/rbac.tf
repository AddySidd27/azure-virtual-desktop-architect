############################################
# PIM-eligible roles - five of six platform roles
#
# azurerm_pim_eligible_role_assignment confirmed as a real, current
# Terraform Registry resource (hashicorp/azurerm, checked directly
# against the registry). Historical GitHub
# issues (2023) reported "Role Management Policy... couldn't find
# resource" errors on first apply in some tenants - noted here as a
# known rough edge to test carefully in non-production first, not
# hidden. This is the actual, structural difference from
# azurerm_role_assignment: eligibility requires activation before the
# role is usable, which a standing assignment never did.
############################################

resource "azurerm_pim_eligible_role_assignment" "platform_engineer" {
  scope              = var.northwind_management_group_id
  role_definition_id = "${var.northwind_management_group_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c" # Contributor - [VERIFY BEFORE IMPLEMENTATION] confirm whether a narrower custom role better matches Platform Engineer's intended scope than the built-in Contributor role
  principal_id       = var.platform_engineer_principal_id

  schedule {
    start_date_time = var.pim_eligibility_start
    expiration {
      end_date_time = var.pim_eligibility_end
    }
  }
}

resource "azurerm_pim_eligible_role_assignment" "subscription_owner_identity" {
  scope              = "/subscriptions/${var.identity_subscription_id}"
  role_definition_id = "/subscriptions/${var.identity_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635" # Owner
  principal_id       = var.subscription_owner_principal_id

  schedule {
    start_date_time = var.pim_eligibility_start
    expiration {
      end_date_time = var.pim_eligibility_end
    }
  }
}

resource "azurerm_pim_eligible_role_assignment" "identity_administrator" {
  scope              = "/subscriptions/${var.identity_subscription_id}"
  role_definition_id = "/subscriptions/${var.identity_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c" # Contributor - [VERIFY BEFORE IMPLEMENTATION] confirm whether a narrower custom role would fit better than the built-in Contributor role
  principal_id       = var.identity_administrator_principal_id

  schedule {
    start_date_time = var.pim_eligibility_start
    expiration {
      end_date_time = var.pim_eligibility_end
    }
  }
}

resource "azurerm_pim_eligible_role_assignment" "network_administrator" {
  scope              = "/subscriptions/${var.connectivity_subscription_id}"
  role_definition_id = "/subscriptions/${var.connectivity_subscription_id}/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7" # Network Contributor
  principal_id       = var.network_administrator_principal_id

  schedule {
    start_date_time = var.pim_eligibility_start
    expiration {
      end_date_time = var.pim_eligibility_end
    }
  }
}

resource "azurerm_pim_eligible_role_assignment" "security_administrator" {
  scope              = var.key_vault_id
  role_definition_id = "${var.key_vault_id}/providers/Microsoft.Authorization/roleDefinitions/00482a5a-887f-4fb3-b363-3b7fe8e74483" # Key Vault Administrator
  principal_id       = var.security_administrator_principal_id

  schedule {
    start_date_time = var.pim_eligibility_start
    expiration {
      end_date_time = var.pim_eligibility_end
    }
  }
}

############################################
# The one role that remains standing, correctly, by design
############################################

resource "azurerm_role_assignment" "security_reader" {
  scope                = "/providers/Microsoft.Management/managementGroups/${split("/", var.northwind_management_group_id)[4]}"
  role_definition_name = "Reader"
  principal_id         = var.security_reader_principal_id

  # Standing, not PIM-eligible - unchanged reasoning from Part B:
  # visibility should never require activation friction. This is the
  # one role in this module that was ALREADY correctly described in
  # prose as standing, and remains standing here deliberately, not by
  # oversight.
}
