# Labs 3 to 8 as one guided journey

> **Technical baseline:** Microsoft Learn as retrieved 16 and 17 October 2026 (see [Review register](../REVIEW-REGISTER.md)).
> **Status: implementation validation is pending.** Nothing on this page has been executed in Azure. Commands are copied from the labs or from Learn and are marked `[UNTESTED]` where the lab says so. Where this page gives reasoning rather than a Learn statement, it says "Judgement".

Labs 3 to 8 build one chain: network, domain controller, storage, profile configuration, AVD objects, session host, sign-in. Each lab is readable alone, but the chain only works if the hidden dependencies between them are met. This page lists them in the order you meet them. The [dependency matrix](LAB-DEPENDENCY-MATRIX.md) holds the per-row validation commands. The [test plans](../reviews/TEST-PLANS.md) say what remains to be executed.

## 1. Choose your path before you start

The final step (Lab 8 Step 5, sign in through Windows App) needs users that exist in both AD DS and Microsoft Entra ID. Decide now which of these you can do.

| Path | You have | You can complete | You cannot complete |
|---|---|---|---|
| **A. Full sign-in** | A test Entra tenant you can write to, with a **verified custom domain** | Labs 3 to 8 including the Lab 8 Step 5 sign-in | Nothing, if every step works. The path as a whole is untested |
| **B. Infrastructure only** | An Azure subscription and no usable tenant | Labs 3 to 8 up to host registration (Lab 8 Step 3), the FSLogix configuration, and the storage mechanics test | A user sign-in and a real profile mount |
| **C. Entra-only** | A subscription and a test tenant | The cloud-native variant in [Project 05](../scenarios/project-05-entra-only-cloud-native.md) | It replaces the AD DS steps in Labs 4 and 5 rather than extending them |

Why a verified domain: a `.local` UPN cannot be verified in Entra, so Lab 4 Step 7 adds an alternative UPN suffix. See that step for the Learn sources.

## 2. Accounts, permissions and tools

| Need | Detail | Where it is used |
|---|---|---|
| Azure subscription you may spend in | A disposable lab subscription. Costs are in section 7 | All labs |
| Subscription roles | Contributor, plus the ability to create role assignments (Owner or User Access Administrator). Labs 5 and 7 create role assignments in Terraform. Lab 1 states: Owner, or Contributor plus User Access Administrator | Labs 5, 7. Manual assignments in U28 |
| Resource providers | Registered per [Lab 1](lab-01-azure-prerequisites-and-tooling.md). The full minimum set is not tested (U26) | Terraform applies |
| Entra tenant (Path A) | Hybrid Identity Administrator to configure Cloud Sync, permission to create groups, a verified custom domain | Lab 4 Step 7, Labs 5 and 7 group |
| Domain credentials | A domain admin in `avdlab.local`. See section 3 | Lab 4 Step 7, Lab 5 Steps 4 and 6 |
| Terraform | 1.9.0 or later (`required_version` in every `versions.tf`), `azurerm ~> 5.0`. CI validated the modules on `main`; `plan` never run (U25) | Labs 2, 3, 4, 5, 7, 8 |
| Azure CLI | Signed in to the lab subscription | All labs |
| Windows PowerShell 5.1 on the DC | AzFilesHybrid needs it. Also .NET Framework 4.7.2 or later and Az.Storage 8.1.0 or later (Lab 5 Step 4) | Lab 5 Step 4 |
| A client device | A machine with Windows App or a browser, to sign in | Lab 8 Step 5 |

## 3. Hidden dependency: an interactive session on the domain controller

The labs configure the DC with `az vm run-command` and give it no public IP and no Bastion. That context is the SYSTEM account. Three steps need more:

- **Lab 5 Step 4:** `Join-AzStorageAccount` from AzFilesHybrid. The lab says an interactive session as a domain admin is the Learn-aligned route.
- **Lab 5 Steps 5 and 6:** the permission test must run as a real domain user, not SYSTEM. A SYSTEM test fails for the wrong reason, because the computer account is not in the users group (Judgement from the lab's own ACLs).
- **Lab 6 Steps 2 and 4:** the storage mechanics test is more representative as a domain user (the lab's own caveat).

The labs do not say how to get an interactive session. Options, with what Learn says (retrieved 17 October 2026):

| Option | Learn says | Cost | Status |
|---|---|---|---|
| **Azure Bastion Developer SKU** (suggested) | Free. Shared pool. Connects from the portal to one VM at a time in the same virtual network over RDP 3389. No AzureBastionSubnet or public IP needed. East US 2 is in the supported region list. The resource stays deployed after you disconnect | $0 | `[UNTESTED]`. Whether its traffic passes the DC subnet NSG is not documented here. If the connection times out, inspect the DC NIC's effective security rules |
| Bastion Basic, Standard or Premium | Needs an AzureBastionSubnet of /26 or larger and a public IP (Premium can be private-only). Billed hourly from deployment | Paid. Delete the same day | Lab 3 has `deploy_bastion_subnet`. Not tested |
| Azure Serial Console | Text console through the Special Administration Console. Needs boot diagnostics. Pasting is limited to 2,048 characters | $0 | Not suitable for the AzFilesHybrid or `icacls` sessions. Not recommended |
| Managed Run Command with RunAs | `az vm run-command create` has `--run-as-user` and `--run-as-password`. Learn notes the user must exist on the VM and the Secondary Logon service must be running | $0 | Whether a domain account works is unverified. Test plan: U36 in the [test plans](../reviews/TEST-PLANS.md) |

**Which account to sign in with.** Lab 4 does not say which account to use after promotion. Judgement: create a dedicated lab administrator rather than guess. For example, as a one-off over run-command: `New-ADUser -Name labadmin -SamAccountName labadmin -AccountPassword (ConvertTo-SecureString '<password>' -AsPlainText -Force) -Enabled $true; Add-ADGroupMember -Identity 'Domain Admins' -Members labadmin`, then sign in as `AVDLAB\labadmin`. These are standard ActiveDirectory cmdlets, the same family Lab 4 Step 6 uses. `[UNTESTED]` Delete the account at cleanup.

## 4. How the identity and permission layers fit together

Read bottom to top for the order they are built. Read top to bottom for the order a sign-in meets them.

| Layer | What it decides | Built in | Proof |
|---|---|---|---|
| AVD assignment | Whether the user sees the desktop in Windows App. Needs a user in AD DS **and** Entra | Lab 7 (Desktop Virtualization User on the application group), Lab 4 Step 7 (sync) | Lab 8 Step 5 shows the desktop |
| Session host sign-in | The host is AD DS joined, so the user authenticates to `avdlab.local` | Lab 8 Step 2 | `Domain` returns `avdlab.local` |
| FSLogix configuration | Which share holds the profile container, and the exclusions | Written in Lab 6 Step 1, applied in Lab 8 Step 4 | FSLogix log shows a successful attach |
| NTFS | What the user may do inside the share | Lab 5 Step 6 | A user creates their own folder and cannot open another user's |
| Share-level permission | Whether the user reaches the share. Azure RBAC for a synced Entra group, or the storage account's default share-level permission | Lab 5 Step 3 | Lab 5 Step 5 |
| Azure Files identity source | The storage account is joined to AD DS so Kerberos works | Lab 5 Step 4 | `DirectoryServiceOptions` equals `AD` |
| Name resolution | The storage name resolves to the private endpoint IP from the DC and every host | Lab 4 Steps 5 and 5b, Lab 5 Step 2 | `Resolve-DnsName` returns the private IP |

**Which group to use.** Lab 5 and Lab 7 take an Entra group object ID (`avd_users_group_object_id`). Judgement: use the Entra group that Cloud Sync creates from `AVD-Task-Users`, or add the synced users to a cloud group. A cloud group with no synced members gives nobody access. Not tested.

## 5. Stage gates: do not continue until each one passes

| Gate | After | Pass condition | If it fails |
|---|---|---|---|
| G1 | Lab 4 Step 4 | `Get-ADDomain` returns `avdlab.local`, ADWS, DNS, NTDS running | Directory Service event log. Do not change VNet DNS |
| G2 | Lab 4 Step 5 and 5b | VNet DNS is `10.10.1.4`, VMs restarted, forwarder timeout above four seconds | Set VNet DNS back to empty, restart, fix the DC |
| G3 | Lab 4 Step 7 (Path A) | The three test users appear in the Entra tenant | Cloud Sync provisioning logs. Check the UPN suffix |
| G4 | Lab 5 Step 2 | The storage FQDN resolves to the private endpoint IP from the DC | Private DNS zone link, then the DC forwarder |
| G5 | Lab 5 Step 4 | `DirectoryServiceOptions` equals `AD` | Interactive session, rights to create the computer object |
| G6 | Lab 5 Step 6 | A domain user can create a folder and cannot open another user's | Read both layers independently: role assignment, then `Get-Acl` |
| G7 | Lab 8 Step 3 | Host `Available`, `IsRegistered : 1` | Token expiry, then the WVD-Agent event log |
| G8 | Lab 8 Step 5 | FSLogix log shows a successful attach | Registry values, storage name resolution from the host |

## 6. Re-applying earlier labs after Lab 4 (U24)

Lab 4 sets VNet DNS by CLI. The Lab 3 module has no `dns_servers` argument. Whether a later `terraform plan` on Lab 3 reverts that setting is **not verified**. Rule for this journey: after Lab 4 Step 5, run `terraform plan` in `terraform/lab03-network` and read it before any `apply`. If it shows `dns_servers` changing to empty, stop. See Lab 4 Step 5 for two documented options and [TEST-PLANS U24](../reviews/TEST-PLANS.md).

## 7. Cost and cleanup

Approximate figures come from the labs and were not re-verified in October 2026. Check the Azure pricing calculator.

| Item | Running | Paused |
|---|---|---|
| Lab 3 network | $0 | $0 |
| Lab 4 domain controller (B2s plus 127 GB disk) | about $40 to $70 a month | about $10 a month when deallocated |
| Lab 5 premium file storage (100 GiB) and private endpoint | about $23 to $27 a month | Same. Storage bills while it exists |
| Lab 8 session host (D2s v5) | about $70 to $90 a month | disk only when deallocated |
| Bastion Developer | $0 | $0 (resource remains until you delete it) |

**Deallocate** the DC and every host at the end of each session. Stopping inside Windows does not stop billing.

**Teardown order** (Judgement from the dependencies, not run): Lab 8, Lab 7, Lab 5, Lab 4, Lab 3, with `terraform destroy` in each folder. Things destroy does not remove:

- The Entra Cloud Sync configuration, the provisioning agent, and the synced test objects in your tenant.
- Manual role assignments for the AVD service principal at subscription scope (U28). They survive `terraform destroy`. Remove them with `az role assignment delete`.
- The Bastion Developer resource, and the `labadmin` account if you created it.
- The cloud group, if you created it with `az ad group create`.

## 8. What this page does not prove

No path has been run. `terraform plan` and `apply` were never run. CI passed `fmt`, `init -backend=false` and `validate` on `main` and on this branch at `6a11662` (U25). The Cloud Sync sign-in chain needs a tenant the author could not provision (U30, U32). Treat every "pass condition" above as the intended result, not an observed one.
