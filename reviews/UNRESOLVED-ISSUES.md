# Consolidated unresolved issues

Maintained during the 2026-10-16 chapter review. Each item lists what is in conflict or unverified so it is not re-investigated without new evidence. Process note: all reviews so far were single-process, not independent.

| ID | Topic | Detail | Affected | Status |
|---|---|---|---|---|
| U1 | Regional host pools | What's new says GA; data-locations page lists Regional scope only in Central US and East US 2; an article still says preview | Ch2, Ch3, ADRs | Conflict recorded |
| U2 | Session host configuration / SHC GA status | SHC is pooled only and not for Azure Local; GA unlabelled; some deploy-article variants say preview | Ch3, ADR | Unverified |
| U3 | Dynamic autoscaling | Autoscale scenarios page says preview; What's new says available | Ch15 | Conflict recorded |
| U4 | Ephemeral OS disks | Prerequisites lists as unsupported; other Learn pages describe use | Ch1, Ch5 | Conflict recorded |
| U5 | Windows 10 ESU on AVD | AVD ESU page says explicit policy enablement/manual install; cloud-VM ESU excerpt says none needed (excerpt only) | Ch5 | Conflict, unresolved |
| U6 | Azure verification for VMs, newer Azure Edition | Page not fetched | Ch5 | Unverified |
| U7 | Multi-session on Azure Local/Arc/hybrid | Not covered by pages reviewed | Ch5 | Unverified |
| U8 | Legacy client end dates after 28 Sep 2026 (Gov, 21Vianet, Classic) | Learn page unchanged after date passed | Ch6 | Unverified |
| U9 | Meta Quest preview vs listed platform | Overview vs get-started pages differ | Ch6 | Conflict |
| U10 | WVDConnections State values | Not enumerated on table reference | Ch4 | Unverified |
| U11 | Event 3701 / URL checker tool page | Page not fetched | Ch4 | Unverified |
| U12 | Intune version pinning for Windows App | Not verified | Ch6 | Unverified |
| U13 | Cloud-only identities with Azure Files/FSLogix: status | Entra joined page says fully supported; same page's profile section says hybrid; Entra Kerberos intro says Preview; Azure Files/FSLogix pages say public cloud only | Ch7, Ch20, Ch21 | Conflict |
| U14 | Cloud-only profile permissions | Entra Kerberos intro says Azure RBAC with no NTFS ACLs; FSLogix page configures permissions via Manage access tab | Ch7, Ch20 | Unresolved |
| U15 | VM User Login role with session host configuration | Learn says not required for SHC pools; reason not stated | Ch5, Ch7, Ch8 | Unverified mechanism |
| U16 | Entra Domain Services limits (Domain Admin, schema) | Not checked | Ch7 | Unverified |
| U17 | Ch8 identity architecture SVG/drawio | Draws Conditional Access at first sign-in only; with SSO, Windows Cloud Login is also a CA target. Caption note added | Ch8, Ch9 | Partly resolved 2026-10-16: flow 6 now reads Windows App -> Conditional Access -> Windows Cloud Login in both SVG and drawio; the diagram still shows no arrows, only a numbered list |
| U18 | KDC proxy with Windows App | Learn's KDC proxy page names the Windows Desktop client only | Ch8 | Unverified |
| U19 | Microsoft Remote Desktop app (a4a365df) as CA target | Removed from Ch9 because current Learn set-up-mfa page lists only AVD and Windows Cloud Login; `appendices/audit-01-chapter-contract.md` still lists it | Ch9, appendices | Unverified, cross-doc follow-up |
| U20 | Who requests the session host SSO token | Learn set-up-mfa says the gateway initiates SSO via Windows Cloud Login; Ch8 mermaid shows client requesting RDP token | Ch8 | Unverified, diagram wording |
| U21 | Per-feature scope guidance for AVD service roles (Power On, Power On Off, DV VM Contributor) not independently fetched | Role definitions verified on rbac page only | Ch10 | Unverified |
| U22 | Private Link setup page, private endpoint DNS and Entra join private-connectivity statements not fetched in Ch11 review | Overview page verified only | Ch11 | Unverified |
| U23 | Storage subnet NSG and private endpoints | Lab 3 attaches nsg-storage (allow TCP 445 from hosts) to the subnet that holds private endpoints. Whether NSG rules apply to private endpoint traffic depends on the subnet's private endpoint network policy setting, which the module does not set and this review did not check | Ch11, Lab 3, Lab 5 | Unverified |
| U24 | Lab 3 re-apply after Lab 4 DNS change | Lab 4 sets VNet DNS by CLI. The Lab 3 module has no dns_servers argument. Whether a later Lab 3 plan reverts it was not checked | Lab 3, Lab 4 | Unverified |
| U25 | Terraform execution | Terraform and OpenTofu cannot be installed in this environment (registry and release downloads blocked), so no fmt, init, validate or plan was run on any module. Only HCL syntax parsing (python-hcl2) and static reading were done | All terraform/ modules | Not tested |
| U26 | Resource provider list for AzureRM 5.0 | Lab 1 list derived by reading resource types; not tested on a clean subscription | Lab 1, all labs | Not tested |
| U27 | Lab 4 Step 5b DNS forwarders | Based on Learn guidance for VM-based custom DNS; the exact commands were not run | Lab 4, Lab 5 | Not tested |
| U28 | Lab 7 Start VM on Connect role | `start_vm_on_connect = true` but no Desktop Virtualization Power On Contributor assignment in the module, and Learn's portal flow says the setting cannot be enabled at host pool creation. Whether the provider create path accepts it was not tested. Lab 7 Step 2b and Lab 8 now tell the reader to `az vm start` manually | Lab 7, Lab 8, Lab 14 | Documented, not fixed in code, not tested |
| U29 | Lab 5 `azure_files_authentication` and join cmdlet | Provider behaviour for `directory_type = "AD"` without an `active_directory` block is from provider documentation knowledge, not run. Module now ignores that block and Step 4 uses AzFilesHybrid `Join-AzStorageAccount` per Learn. Running it via `az vm run-command` (SYSTEM) is unverified. `Join-AzStorageAccountForAuth` also remains in Lab 13 (out of scope until Ch13) | Lab 5, Lab 13 | Fixed in text/code, not tested |
| U30 | Lab 5 share-level RBAC vs unsynced AD users | Learn: granular RBAC needs Entra-synced identities; Lab 4 does not sync. Lab 5 now documents a default share-level permission as the lab path. The Terraform role assignment remains and will not match AD-only users | Lab 4, Lab 5, Lab 6 | Documented, not tested |
| U31 | Lab 8 image SKU and other labs | Lab 8 now uses `win11-25h2-avd` (Learn lists 23H2/24H2/25H2 SKUs). Labs 14, 19 and the capstone still use `win11-23h2-avd` (23H2 Enterprise multi-session ends 2026-11-10); out of scope until Ch13+ | Lab 14, Lab 19, capstone | Open for later batch |
| U32 | Lab chain 4 to 8: unsynced AD users cannot sign in via AVD | Lab 4 does not sync `.local` to Entra; Lab 8 joins hosts to AD only (no Entra hybrid join), and Learn requires AD DS session host users to be synced. Lab 8 Step 5 (end-to-end sign-in) therefore cannot be completed with the lab as written; prerequisite note added. A lab design decision is needed (add optional sync lab, or an Entra-only path) | Lab 4, Lab 8, Project 04 | Documented, design decision open |
