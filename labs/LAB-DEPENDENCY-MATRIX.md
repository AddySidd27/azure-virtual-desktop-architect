# Lab dependency matrix, Labs 1 to 10

> **Technical baseline:** Microsoft Learn as retrieved 16 and 17 October 2026 (see [Review register](../REVIEW-REGISTER.md)). Evidence level for every row: **static repository check and source verification only**. No row has been executed in Azure. Nothing here is a Terraform, CLI, PowerShell or KQL pass.

This matrix answers one question for a first-time reader: before I start a lab, what must already exist, where was it configured, and how do I know it works? It was built by reading Labs 1 to 10 and their Terraform. Where a lab says something the matrix cannot confirm, the row says so.

## The selected design

Labs 4 to 8 build **AD DS joined session hosts with Azure Files AD DS authentication**. The identity story has two halves that must both exist before a user can sign in through Windows App:

1. **Lab 4 Steps 1 to 6:** a domain controller in `avdlab.local`, with users and groups.
2. **Lab 4 Step 7:** synchronisation of those users to Microsoft Entra ID with Entra Cloud Sync. Learn requires users of AD DS joined session hosts to exist in both AD DS and Entra ID.

Without Step 7, Labs 4 to 8 still complete up to the Lab 8 sign-in step (domain join, storage join, FSLogix configuration and host registration). The Lab 8 Step 5 sign-in cannot succeed. The alternative is the Entra-only path in [Project 05](../scenarios/project-05-entra-only-cloud-native.md), which replaces the AD DS steps rather than extending them.

**Limitations of the selected design.** It needs a test Entra tenant with a verified custom domain. It was not executed. It uses a `.local` forest, so an alternative UPN suffix is required. The Azure Files AD DS join runs interactively from the domain controller (AzFilesHybrid, PowerShell 5.1). The host pool is standard management, not session host configuration (see the [ADR](../appendices/adr-shc-vs-standard-host-pools.md)).

## Matrix

"Test status" uses: **Not tested** (no execution), **Source verified** (Learn page read, not executed).

| # | Prerequisite | Configured in | Needed by | How to validate (as written in the lab) | Typical failure signal | Test status |
|---|---|---|---|---|---|---|
| 1 | Subscription, roles to create resources and role assignments, resource providers registered | [Lab 1](lab-01-azure-prerequisites-and-tooling.md) | All labs. Labs 5 and 7 create role assignments, so the deploying identity needs Owner or User Access Administrator as well as Contributor | `az provider show --namespace Microsoft.DesktopVirtualization --query registrationState` returns `Registered` (Lab 1) | Terraform reports a missing resource provider. Role assignment returns authorization failed | Source verified for `Microsoft.DesktopVirtualization` only. Full list not tested (U26) |
| 2 | Resource groups, tags, remote state | [Lab 2](lab-02-terraform-foundation-and-governance.md) | Labs 3 to 10 | Lab 2 validation checklist | `terraform init` cannot reach backend | CI `validate` passed on `main`; `plan` never run (U25) |
| 3 | VNet, subnets, NSGs | [Lab 3](lab-03-vnet-subnets-nsg-dns.md) | Labs 4, 5, 8 | Lab 3 Step 6, effective NSG rules | NIC has no effective rules, or NSG not associated | Not tested |
| 4 | Outbound path from the hosts subnet to the AVD service (443, UDP 3478 service tag rules, FQDNs) | Lab 3 hosts NSG | Lab 8 agent registration | Lab 8 Step 3 (host `Available`, WVD-Agent event log). Chapter 4 explains event ID 3701, which lists the agent's FQDNs | Host shows Unavailable | Source verified (Ch4, U11) |
| 5 | Domain controller with a static IP, AD DS and DNS roles | [Lab 4](lab-04-identity-integration.md) Steps 1 to 4 | Labs 5, 6, 8 | Lab 4 Step 4 | Promotion errors, DNS role not running | Not tested |
| 6 | VNet DNS set to the DC, then every VM restarted | Lab 4 Step 5 (Azure CLI, outside Terraform) | Labs 5, 8 (domain join needs the DC to resolve) | Lab 4 Step 5 gives no explicit resolution check. Use `Resolve-DnsName avdlab.local` from a restarted VM (not in the lab text). The real test is Lab 8 domain join | Domain join fails with a DNS error. A later Lab 3 re-apply might revert the setting | Not tested (U24) |
| 7 | DC forwarders to Azure DNS (`168.63.129.16`), forwarding timeout above four seconds | Lab 4 Step 5b | Lab 5 Step 2 (the storage name must resolve to the private endpoint IP) | `Get-DnsServerForwarder`, then Lab 5 Step 2 resolution | Storage FQDN resolves to a public IP | Source verified, not tested (U27) |
| 8 | Test users, groups, OU | Lab 4 Step 6 | Lab 5 Step 6 (NTFS ACLs), Lab 8 | Lab 4 validation checklist | Users missing from the OU | Not tested |
| 9 | **Users synchronised to Entra ID** with a verified UPN suffix | **Lab 4 Step 7** (Entra Cloud Sync, test tenant) | Lab 5 Step 3 (share RBAC for an Entra group), Lab 7 (application group assignment), **Lab 8 Step 5 (sign-in)** | Users visible as synced in the tenant | Sign-in rejected. Share RBAC assignment has no effect for unsynced principals | Source verified, not tested (U30, U32) |
| 10 | Storage account, private endpoint, private DNS zone, file share | [Lab 5](lab-05-storage.md) Step 1 | Labs 6, 8 | Lab 5 Step 2, FQDN resolves to the private endpoint IP | Public IP returned. See row 11 | Not tested |
| 11 | NSG on the private endpoint subnet | Lab 3 `nsg-storage` | None. **It does not enforce anything while private endpoint network policies are disabled (the default)** | See [Lab 3 Step 2 caveat](lab-03-vnet-subnets-nsg-dns.md) | No failure. The control is silently absent | Source verified, not tested (U23) |
| 12 | Azure Files AD DS authentication (storage account joined to AD) | Lab 5 Step 4 (AzFilesHybrid `Join-AzStorageAccount`, run interactively on the DC) | Labs 6, 8 | `DirectoryServiceOptions` equals `AD` | Kerberos access to the share fails | Source verified, not tested |
| 13 | Share-level permission | Lab 5 Step 3. RBAC for a synced Entra group, or the default share-level permission when nothing is synced | Labs 6, 8 | Lab 5 Step 5 expects Access Denied until NTFS is set, which proves layer one alone is not enough | RBAC ignored for unsynced principals | Source verified, not tested (U30) |
| 14 | NTFS permissions on the share root | Lab 5 Step 6 | Labs 6, 8 | Lab 6 Step 2, create and mount a VHDX from the DC | Access Denied after share permission is correct | Not tested |
| 15 | FSLogix configuration and exclusions | Produced in [Lab 6](lab-06-fslogix.md), applied in Lab 8 Step 4 | Lab 8 Step 5 | Profile container (VHDX) created for the user | Profile is local, or a temporary profile | Not tested |
| 16 | Host pool, workspace, application group, user role assignment (Desktop Virtualization User) | [Lab 7](lab-07-avd-host-pool.md) | Lab 8 | Lab 7 Step 3 | Empty feed for the user | Not tested |
| 17 | Registration token (short-lived) | Lab 7 Step 2 | Lab 8 Step 1 and 3 | Token present and unexpired | Agent cannot register. Regenerate the token | Not tested |
| 18 | Start VM on Connect role assignment | **Not in Terraform.** Lab 7 Step 2b (manual, Power On Contributor on the AVD service principal at a scope containing the hosts) | Lab 8 once hosts are deallocated | Until assigned, start the host with `az vm start` | Connection fails when the host is deallocated | Source verified, not tested (U28) |
| 19 | Session host VM, current image SKU, `license_type` | [Lab 8](lab-08-session-hosts.md) Step 1 | Lab 8 | SKU exists (`az vm image list`) | Image SKU not found | Not tested |
| 20 | Session host domain join | Lab 8 (domain join extension) Step 2 | Lab 8 Step 3 | `(Get-WmiObject Win32_ComputerSystem).Domain` equals `avdlab.local` | Returns `WORKGROUP` | Not tested |
| 21 | AVD agent registration | Lab 8 Step 3 | Lab 8 Step 5 | Host shows Available | Unavailable, event 3701 | Not tested |
| 22 | **Windows App sign-in and profile mount** | Lab 8 Step 5 | End of chain | Sign in, then confirm the profile container exists | Needs rows 6, 9, 12 to 17, 20 and 21 all in place | Not tested |
| 23 | Autoscale role assignment | **Not in Terraform.** [Lab 10](lab-10-operations.md) Step 0 (Power On Off Contributor at **subscription** scope) | Lab 10 | A power-state change occurs | Scaling plan enabled, no power change | Source verified, not tested (U28) |

## Reading the chain

```
Lab 1 (subscription, roles, providers)
  -> Lab 2 (resource groups, state)
    -> Lab 3 (VNet, NSGs)
      -> Lab 4 (DC, DNS, forwarders, users) -> Step 7 (sync to Entra)
        -> Lab 5 (storage, PE, AD join, share RBAC, NTFS)
          -> Lab 6 (FSLogix config, mechanics test from the DC)
        -> Lab 7 (host pool, app group, user role)
          -> Lab 8 (session host, domain join, agent, FSLogix applied, sign-in)
            -> Lab 9 (application groups) -> Lab 10 (monitoring, autoscale)
```

## What this matrix does not prove

- It does not prove any lab succeeds. No lab was executed.
- It does not prove that the Terraform plans are valid. `plan` and `apply` were never run. `fmt`, `init -backend=false` and `validate` passed in GitHub CI on `main` at `86e083d` and on this branch at `6a11662`, and nothing was run locally (U25).
- Row 9 depends on a tenant and domain the author could not provision here.
- Rows 18 and 23 are documented manual steps. Adding them to Terraform needs explicit approval because they are role assignments.
