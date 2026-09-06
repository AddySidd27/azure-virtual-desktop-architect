# Lab 12 - Regional Identity

Terraform for [Lab 12](../../labs/lab-12-regional-identity.md).

Deploys a second domain controller into the `centralus` identity subnet, as an
additional domain controller for the existing `avdlab.local` forest, not a new
domain. Promotion, DNS site configuration, and the VNet DNS server changes are
done via `az vm run-command`, matching Lab 4's imperative-steps pattern, for the
same reason Lab 4 used it: Terraform would try to promote the domain controller
in the same apply that creates the VM, before Windows has even booted.

## Cost

Matches Lab 4 exactly: **~$40/month running** (Standard_B2s VM plus a 127 GB
Standard SSD disk), **~$10/month deallocated** between sessions (disk only).

## Dependency on Lab 11

Reads Lab 11's state via `terraform_remote_state` for the `centralus` identity
resource group and subnet ID. Lab 11 must be applied and its peering confirmed
`Connected` in both directions before this lab's domain controller can replicate
against Lab 4's `eastus2` domain controller.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit owner, dc_admin_password, primary_state_storage_account
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Notes

- `computer_name = "AVDLAB-DC02"` keeps the same 15-character NetBIOS limit
  reasoning Lab 4 documents for `AVDLAB-DC01`.
- The static private IP (`10.20.1.4` by default) becomes `centralus`'s VNet DNS
  server. It cannot change once VMs depend on it, for the same reason Lab 4's
  `10.10.1.4` cannot change.
- AD Sites and Services configuration (mapping each region's subnet to its own
  AD site) is not a Terraform-manageable resource. It's applied via
  `az vm run-command` in the lab's Step 3, after both domain controllers exist.
