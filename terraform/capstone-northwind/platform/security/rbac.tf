############################################
# SUPERSEDED - see ../rbac/ instead
#
# This file originally built Identity Administrator, Network
# Administrator, and Security Administrator as standing
# azurerm_role_assignment resources, while Part D's own prose
# described all three as "PIM-eligible." The implementation tracker's
# These roles are rebuilt correctly, as azurerm_pim_eligible_role_assignment,
# in terraform/capstone-northwind/platform/rbac/, alongside the
# Platform Engineer, Subscription Owner, and Security Reader roles.
#
# This file is intentionally left as an empty marker, not silently
# deleted, so a reader diffing this module's history can see exactly
# what moved and why, rather than finding three resources missing
# with no explanation.
############################################
