# Terraform - Lab 7: Core AVD Objects

Host pool, workspace, desktop application group, association, and the Desktop Virtualization User assignment. See [Chapter 3](../../chapters/ch03-avd-object-model.md) and [Chapter 15](../../chapters/ch15-host-pool-design-decisions.md).

**Depends on:** Lab 2 (resource groups). Does not depend on Labs 3-6 directly (host pool/workspace/application group are control-plane objects with no network dependency), but the registration token this module outputs is consumed in Lab 8, which does depend on the network and identity built in Labs 3-4.

**Sensitive output:** `registration_token` is marked sensitive and expires in 24 hours by design (`azurerm_virtual_desktop_host_pool_registration_info`). Retrieve it just before Lab 8 with `terraform output -raw registration_token`, never commit it, and regenerate with `terraform apply -replace=azurerm_virtual_desktop_host_pool_registration_info.lab` if it expires before you use it.

**Updated for Lab 16 and Lab 17:** `outputs.tf` gained `application_group_id` and `host_pool_id` outputs. If you applied this lab before those labs existed, re-run `terraform apply` once (no infrastructure changes, just populates the new outputs) before starting either.

```bash
cd terraform/lab07-avd-core
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```
