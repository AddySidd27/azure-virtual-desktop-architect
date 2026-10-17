# Lab 4 - Identity

Terraform for [Lab 4](../../labs/lab-04-identity-integration.md).

Deploys one Windows Server 2022 VM into the identity subnet with a static private IP
and no public IP. Promotion to a domain controller is done with `az vm run-command`,
which is covered step by step in the lab.

## Cost

| State | Cost |
|---|---|
| Running 24/7 | ~40 to 70 USD per month (approximate, not re-verified) |
| Deallocated | ~10 USD per month, disk only |

**Deallocate at the end of every session.** Stopping Windows from inside the VM does not
stop billing.

```bash
terraform output -raw deallocate_command
```

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # set owner and dc_admin_password
# edit backend.tf with your bootstrapped storage account name
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Notes

- After the VNet points at the domain controller, add DNS forwarding to Azure DNS (Lab 4 Step 5b)
  so private endpoint names still resolve. That step is also done with the CLI and was not executed
  in the October 2026 review.
- The VNet DNS change is done with the CLI in the lab, not here. Terraform would try to
  set it in the same apply that creates the DC, before the DC can resolve anything.
- `computer_name` is set separately from the Azure resource name because Windows computer
  names are limited to 15 characters.
- `ignore_changes` on `source_image_reference` stops a new marketplace image version from
  proposing a VM replacement. Replacing a promoted domain controller destroys the domain.
