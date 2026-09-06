# Lab 13 - Regional Storage

Terraform for [Lab 13](../../labs/lab-13-regional-storage-foundation.md).

Creates the `centralus` FSLogix storage account, file share, private endpoint,
and private DNS zone, mirroring Lab 5's `eastus2` build exactly. This is a
separate storage account, not a replica or extension of Lab 5's - the two
accounts are independently created here, and Lab 15 configures FSLogix Cloud
Cache to replicate profile data between them.

## Cost

Matches Lab 5: Premium file share billed on provisioned capacity
(~$20-30/month for the default 100 GiB quota at this lab's scale), private
endpoint ~$7/month. No compute cost - this lab deploys no VMs.

## Dependency on Labs 11 and 12

Reads Lab 11's state for the `centralus` storage resource group, subnet, and
VNet ID. Reads no state from Lab 12 directly, but the share-level and NTFS
permission validation in this lab's Step 5 and 6 requires Lab 12's domain
controller (`vm-avdlab-dc02`) to be promoted and reachable, since the storage
account's `azure_files_authentication` block is set to `directory_type = "AD"`.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit owner, avd_users_group_object_id, primary_state_storage_account
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Notes

- `account_replication_type = "ZRS"` - Premium file shares support LRS or ZRS
  only, never GRS or GZRS, the same constraint Lab 5 documents. Cross-region
  redundancy for this data comes from FSLogix Cloud Cache (Lab 15), not from
  the storage account's own replication setting.
- The private DNS zone created here (`privatelink.file.core.windows.net`) is
  a separate zone from Lab 5's zone of the same name, scoped to the
  `centralus` storage resource group and linked only to the `centralus` VNet.
  Azure private DNS zone names are not globally unique; each region resolves
  its own storage account through its own zone.
