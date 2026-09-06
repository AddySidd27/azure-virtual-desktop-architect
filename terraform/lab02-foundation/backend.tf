# Bootstrap the storage account with Azure CLI first - see Lab 2, Step 1.
# Replace storage_account_name with the globally unique name you created.
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-lab-eus2-01"
    storage_account_name = "REPLACE_WITH_YOUR_STORAGE_ACCOUNT"
    container_name       = "tfstate"
    key                  = "avd-lab.tfstate"
  }
}
