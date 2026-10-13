# Post 7: Azure Files profile storage

Terraform configuration for the storage design in Post 7. Provider validation passes. Azure deployment and user-access validation remain pending.

## Scope

Creates a new Premium/ZRS provisioned-v2 account, configurable SMB shares,
a file private endpoint, a zone group referencing an existing central private
DNS zone, and share-scoped user data role assignments. It does not create a
VNet, change the existing profile account, configure Windows ACLs, grant
Entra app consent, change Conditional Access, configure cloud-group support,
or configure clients/FSLogix.

AzureRM handles the account, endpoint and RBAC. AzAPI manages shares through
Microsoft.Storage's management plane with explicit capacity, IOPS and
throughput. The new Microsoft.FileShares NFS resource model is not used.

## Prerequisites

- Enabled Azure subscription and an existing resource group.
- Approved region supporting Premium provisioned v2 and ZRS.
- Existing private endpoint subnet and central private DNS zone.
- Existing DNS links/resolver paths from clients to the central zone.
- Approved Entra Kerberos identity/client configuration and user groups.
- Deployment permissions for storage, private endpoints and role assignments.
- Approved provisioning values checked against GetFileServiceUsage limits.

The inspected tenant currently has Disabled subscriptions. Its existing
account returns AccountIsDisabled on file-share operations.

## Workflow

Supply inputs in an uncommitted terraform.tfvars. Do not replace the existing
account's state with this new-account configuration. Use protected remote
state for retained resources; never commit state, saved plans or secrets.

Run terraform init, terraform fmt -check, terraform validate and terraform
plan -out=storage.tfplan. Review changes, particularly any deletion or
replacement. Apply only the approved saved plan. Record the actual versions
and retain the generated dependency lock file with the module.

Inspect resources in the portal. Complete the separate identity/application,
client and ACL work. Validate DNS, TCP 445 and actual user access. Verify user
A cannot access user B's profile. A successful infrastructure apply is not a
successful FSLogix profile test.

## Cleanup

Storage account and shares have prevent_destroy enabled. After confirming
that only disposable test data exists, remove that protection in a deliberate
cleanup change, review the destroy plan and remove only module-owned test
resources. The shared DNS zone and subnet are inputs and are not owned here.
Never use this cleanup on a production profile share.

## Sources

- https://learn.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/fileservices/shares/2025-06-01
- https://learn.microsoft.com/en-us/azure/storage/files/create-classic-file-share
- https://learn.microsoft.com/en-us/azure/storage/files/storage-files-identity-auth-hybrid-identities-enable
- https://learn.microsoft.com/en-us/azure/storage/files/storage-files-networking-endpoints
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account

## Verification

Cloud Shell Terraform 1.16.4 successfully initialized AzureRM 5.9.0 and AzAPI
2.13.0, passed terraform fmt -check and returned "Success! The configuration
is valid." for the complete module. This is provider validation, not an Azure
plan/apply or a user-access result. The target subscription is Disabled.
