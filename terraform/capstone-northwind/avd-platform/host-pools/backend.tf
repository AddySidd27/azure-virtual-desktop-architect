############################################
# PARTIAL backend configuration, deliberately.
#
# This module is applied TWICE - once per region - from the same
# code, matching the explicit-repetition pattern used since Labs
# 11-20. Terraform backend blocks cannot use variables, so the state
# KEY (which must differ per region, or a West Europe apply would
# silently overwrite East US 2's state) cannot be hardcoded here.
#
# Run terraform init with -backend-config to supply the key per
# region-instance, e.g.:
#
#   terraform init -backend-config="key=avdplt-host-pools-eastus2.tfstate"
#   terraform init -backend-config="key=avdplt-host-pools-westeurope.tfstate"
#
# Omitting this, or reusing the same key for both regions, is the
# specific mistake this partial-config pattern exists to force you to
# avoid - Terraform will refuse to init without a key, rather than
# silently defaulting to one that could collide.
############################################

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-avdplt-01"
    storage_account_name = "sttfstatenwavdplt01"
    container_name       = "tfstate"
    # key intentionally omitted - supply via -backend-config at init time
  }
}
