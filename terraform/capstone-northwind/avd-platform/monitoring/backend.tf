terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-avdplt-01"
    storage_account_name = "sttfstatenwavdplt01"
    container_name       = "tfstate"
    # PARTIAL config, deliberately - applied per region, matching
    # host-pools/workspace-appgroups/fslogix's pattern. Run:
    #   terraform init -backend-config="key=avdplt-monitoring-eastus2.tfstate"
  }
}
