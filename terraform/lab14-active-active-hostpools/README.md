# Lab 14 - Active-Active Host Pools, Workspaces and Application Groups

Terraform for [Lab 14](../../labs/lab-14-active-active-hostpools-workspaces.md).

Deploys a second, fully independent host pool in `centralus`: standard host-pool
management (not Session Host Configuration - see
[the ADR](../../appendices/adr-shc-vs-standard-host-pools.md)), Terraform-managed
session hosts, the AVD agent and domain-join VM extensions, a distinct workspace,
and a desktop application group, following exactly the same resource shape as
`terraform/lab07-avd-core/` and `terraform/lab08-session-hosts/`.

**Updated for Lab 17:** `outputs.tf` gained a `host_pool_id` output. If you applied this lab before Lab 17 existed, re-run `terraform apply` once (no infrastructure changes, just populates the new output) before starting Lab 17.

## Cost

Two session hosts (Standard_D2s_v5): ~$140/month running continuously, ~$20/month
if deallocated between lab sessions (disks only). No cost difference from Lab 8's
`eastus2` equivalent.

## Dependency on Labs 11 and 12

Reads Lab 11's state for the `centralus` avd/hosts resource groups and subnet.
Reads Lab 12's state for the `centralus` domain controller's IP, used to set
session host DNS server order (local DC first, `eastus2` DC second).

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit owner, admin_password, avd_users_group_object_id, primary_state_storage_account
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Why standard management, not Automated Host Pools

Session Host Configuration reached general availability on the Azure side in
June 2026, but the tooling to build one does not yet meet this book's bar for a
required lab dependency: no stable Terraform resource exists, the PowerShell
cmdlets are explicitly marked preview by Microsoft, and the ARM API has never
shipped a non-preview version. See
[the ADR](../../appendices/adr-shc-vs-standard-host-pools.md) for the full
reasoning and sources. Lab 14's markdown covers Automated Host Pools as a
clearly labelled optional section, not a required deployment.
