# Terraform - Lab 8: Session Hosts

Deploys session host VMs, domain-joins them, and registers them into the Lab 7 host pool via the same DSC mechanism the Azure portal's own deployment flow uses.

**Depends on:** Lab 2 (resource groups), Lab 3 (network, DNS design), Lab 4 (domain controller), Lab 7 (host pool and registration token).

**Sensitive inputs:** `admin_password` and `registration_token` are both marked sensitive and must come from `terraform.tfvars` (gitignored) or `-var`, never committed. The registration token expires 24 hours after Lab 7 created it — regenerate it there if it has expired.

**Post-apply manual steps:** none required for registration itself (the DSC extension handles it), but see [labs/lab-08-session-hosts.md](../../labs/lab-08-session-hosts.md) for the FSLogix configuration from Lab 6, which is applied here as a manual `az vm run-command` step rather than a Terraform resource, consistent with the image-versus-policy distinction in Chapter 23.

```bash
cd terraform/lab08-session-hosts
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars — set owner, admin_password, and registration_token
# (retrieve the token: cd ../lab07-avd-core && terraform output -raw registration_token)
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```
