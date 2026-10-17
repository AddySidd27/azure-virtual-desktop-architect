# Chapter source recheck, 17 October 2026

> Single reviewer, no independent pass. Microsoft Learn read through the Learn fetch and search tools on 17 October 2026. Nothing was executed in Azure. This page records **what was and was not re-read**. A chapter that is not listed under "Re-read" has **not** been freshly verified in this pass and still rests on the 16 October 2026 review in its own review record.

## Re-read on 17 October 2026

| Chapter | Learn page | Scope of the check | Result |
|---|---|---|---|
| 4 | [RDP Shortpath](https://learn.microsoft.com/en-us/azure/virtual-desktop/rdp-shortpath) (full page) | Managed and public network modes, ports, ranges, TURN range, first-found rule, security statement, symmetric NAT | Four wording corrections, symmetric NAT added. See the [Ch4 record](ch04-review-record.md) |
| 8 | [Configure single sign-on](https://learn.microsoft.com/en-us/azure/virtual-desktop/configure-single-sign-on) (full page) | Five tasks, app ID, roles, KB minimums, consent prompt limits, Kerberos server object, host pool property, client list | Client list and external identity requirement added. See the [Ch8 record](ch08-review-record.md) |
| 9 | [Enforce MFA with Conditional Access](https://learn.microsoft.com/en-us/azure/virtual-desktop/set-up-mfa) (full page) | App IDs (`9cdead84-...`, `270efc09-...`, `50e95039-...`, `0af06dc6-...`), two-policy structure, sign-in frequency table, Every time rule, per-user MFA, Security Defaults, authentication flow | Matches, except the sign-in frequency table in the chapter still named the Microsoft Remote Desktop app beside Windows Cloud Login. Learn's table lists only Windows Cloud Login. Corrected |
| 11 | [Required FQDNs and endpoints](https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint) (full page) | Required and optional endpoint tables, service tags, platform addresses and ports, US Government differences | Ports and platform addresses match. **Error found and fixed:** the chapter and Lab 3 named `oneocsp.microsoft.com` and `catalogartifact.azureedge.net` as endpoints without a service tag. Learn lists service tags for both (`AzureFrontDoor.FirstParty`, `AzureFrontDoor.Frontend`), and lists `azkms.core.windows.net` only with the generic `Internet` tag. The Chapter 4 table was already correct |
| 10 | [Configure Start VM on Connect](https://learn.microsoft.com/azure/virtual-desktop/start-virtual-machine-connect), [Create and assign a scaling plan](https://learn.microsoft.com/azure/virtual-desktop/autoscale-create-assign-scaling-plan), [Azure built-in roles](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles) (search excerpts, not full pages) | Power On and Power On Off role purposes, Start VM on Connect scope and prerequisites, autoscale scope sentence | Matches. Learn now calls the older "lower scope breaks Start VM on Connect" guidance incorrect, which the chapter already reflects. The autoscale scope conflict (U35) is unchanged |
| 7 | [Introduction to Microsoft Entra Kerberos](https://learn.microsoft.com/entra/identity/authentication/kerberos), Azure Files Entra Kerberos and the two FSLogix Entra pages (search excerpts, not full pages) | Cloud-only identity support wording, Settings catalog note for multi-session, `LoadCredKeyFromProfile`, no line-of-sight requirement, RC4 to AES-SHA1 notice, six-month service principal password note | Consistent with the chapter. Learn's Entra Kerberos introduction still labels the cloud-only scenario "(Preview)", which the chapter's existing currency flag covers (U13) |

## Second pass, 17 October 2026 (later the same day)

Pages were read in full through the Learn fetch tool unless marked otherwise. "Full" means the whole fetched page, not a search excerpt. A partial review is not a complete chapter verification, so the scope column is the claim.

| Chapter | Learn pages read | Scope of the check | Result |
|---|---|---|---|
| 1 | Azure Virtual Desktop service architecture and resilience (full), Business continuity and disaster recovery (full), Data locations (full), Licensing (full), Windows 365 Flex and Dedicated modes, Remote Desktop client overview (full), What's new (read through grep and sed over the saved page), Prerequisites | Control plane component list, outage behaviour, region and data-location claims, licensing rules (per-user pricing, contractors, hybrid), Windows 365 modes, client retirement row | Several corrections (listed in the [ch01 record](ch01-review-record.md). Not covered: the full history table dates, which rely on What's new and were spot-checked only |
| 2 | Service architecture and resilience (full), BCDR (full), Required FQDNs (3701 and Agent URL Tool text) | Component list, Traffic Manager and Front Door, instance counts, what is and is not stored, failure table sourcing, event 3701 | Failure table labelled as judgement. Gateway row and 3701 wording corrected. Scenario 2 rewritten |
| 3 | AVD FAQ (full), Delegated access (read during the pass; not recorded as a full-page read), Prerequisites | Location rule, app group to workspace cardinality, tenant rule, delegated-access roles | "Exactly one workspace", "must share a location" and the missing tenant rule corrected |
| 4 and 11 | Same 3701 sources | Event 3701 wording only | Seven lines reworded so 3701 is not described as listing blocked FQDNs. Rest of Chapters 4 and 11 was not re-read in this pass |
| 5 | Licensing (full), Azure Local overview (full), Azure verification for VMs (full; `azure-stack/hci/deploy/azure-verification` after the `azure-local/manage` path failed), Understanding ESU on AVD (full), Intune multi-session (full), Troubleshoot activation | Activation on Azure and Azure Local, ESU, per-user pricing limits, session-host-only licence scope, Intune enrolment prerequisites | Azure verification page confirms the chapter's Windows 11 and Server 2022 Azure Edition statements. Four additions. Not re-read: Windows multi-session FAQ ProductType wording and the Azure Local support boundaries flagged `[VERIFY BEFORE IMPLEMENTATION]`, which stay flagged |
| 6 | Windows App compare-platforms (full), Remote Desktop client overview (full), What is Windows App (full), Get started with Windows App (full, searched for requirements) | Platform and redirection claims, Shortpath and Multipath versions, token protection version, browser requirements, MSI and Store dates, Quest status | All platform claims match. Store app wording made precise (downloads to 27 May 2025, support ended September 2025, both stated by Learn). Stale "as of August 2026" header replaced. U8 and U9 stay open: Learn still shows 28 September 2026 unchanged and still labels Quest preview on get-started only |
| 12 | Define an Azure network topology (full), Traditional Azure networking topology (full), Virtual WAN network topology (full), AVD network topology and connectivity (CAF, full, deprecated), Virtual hub settings (search excerpt), reserved addresses (search excerpt, several pages), peering pricing (search excerpts) | Hub and spoke versus Virtual WAN triggers, shared-services placement, CAF deprecation date, hub /24 minimum, five reserved addresses, peering billing | Triggers, deprecation date (30 October 2026) and shared-services statements match. Added the /23 recommendation and /22 for Azure Firewall hubs. Added a caveat that private endpoint traffic is excluded from peering charges per Learn's Virtual WAN pricing pages. Gateway subnet sizes were not re-read in this pass |

Labs checked for contradiction by text search: `labs/LAB-DEPENDENCY-MATRIX.md` (corrected), Labs 3 and 11 (no conflicting statements found). Labs were not re-read in full.

## Third pass, 17 October 2026 (documentation only)

Single reviewer, no independent pass. Pages read in full through the Learn fetch tool unless marked. Nothing was executed in Azure and no Terraform command was run.

| Chapter | Learn pages read | Scope of the check | Result |
|---|---|---|---|
| 1 | What's new in Azure Virtual Desktop (full), Classic retirement notices, Windows App and MSIX App Attach notices | Every row of the history table | Dates now match What's new. ARM integration announced June 2020 and GA July 2020 (previously tied to 2021). The 2019 WVD year rests on Learn's "Fall 2019 release" wording, now stated in the chapter |
| 4 | Understanding AVD network connectivity (full), Required FQDNs and endpoints (full, Azure cloud tab) | Gateway selection (10 ms groups, then fewest connections), Front Door and Traffic Manager, TLS 1.2 minimum, endpoint table | No change needed. The chapter endpoint table matches the Azure cloud tab |
| 5 | Windows Enterprise multi-session FAQ (full), Azure Local overview (full), Azure verification for VMs (full) | Who may provide multi-session access (Microsoft or Approved Providers), no RD IP Virtualization, KMS activation, Azure Local OS set, AD DS-only join, support boundary | Support-boundary sentence replaced with sourced statements. U7 (Azure Local OS set) stays open |
| 6 | Windows App pages (full) | Platform, redirection, Shortpath claims | No new change. Quest still "(preview)" on one page only (U9) |
| 7 | Prerequisites (full), Microsoft Entra joined session hosts (full), Entra Kerberos pages read earlier this day | One-identity rule, three join models, hybrid UPN or SID rule, Entra Domain Services hosts cannot be managed with Intune, Windows Server cannot be enrolled in Intune, role requirement for Entra joined hosts without a session host configuration, Azure Local AD DS-only | All matched. The Entra join prerequisite wording in the chapter is consistent with both pages. Cloud-only Azure Files conflict (CURRENCY FLAG) remains |
| 10 | Built-in Azure RBAC roles for AVD (full), Deploy AVD with session host configuration (search excerpts of prerequisites), Configure managed identity (search excerpt) | All 15 role descriptions, session host configuration role scope | Table matches. The unresolved session host configuration role scope is now sourced: the host pool managed identity needs Desktop Virtualization Virtual Machine Contributor on the resource group or subscription |
| 11 | Set up Private Link (full, read from the saved page by search), Private Link overview (search excerpt) | One global endpoint, global DNS zone name, UDP opt-in with public Shortpath disabled, supported clients, ignored private-only setting on the global workspace | Matched. The Learn overview page and setup page disagree on client lists, so the chapter's client caution stays |
| 12 | Define an Azure network topology, Virtual WAN topology, ExpressRoute gateway pages, Azure Firewall and Bastion subnet pages, Bastion SKU page (all read earlier this day) | Gateway subnet sizes, Firewall and Bastion /26 minimum, Bastion Developer SKU | Sizes confirmed. Bastion Developer note added. The Private Link pricing page was not read, so the private endpoint peering-charge statement rests on the Virtual WAN pricing pages only |

### Labs read in full this pass

Labs 1, 2, 3, 4, 5, 7, 8, 10 and 11, with the dependency matrix. Terraform for Labs 3 and 5 was read for names, tags and variables. Nothing was run.

| Lab | Finding | Action |
|---|---|---|
| 1 | Validation checklist required capstone-only providers that the text says to skip. Cost note said Lab 8 was the first expensive lab but Lab 4 starts compute. Tag table showed six tags while the modules apply seven | Checklist split into required, check-only and optional. Cost note and tag table corrected |
| 2 | Expected resource count presented as fact | Marked as not observed |
| 3 | Validation said four subnets while the module also creates `AzureBastionSubnet` by default | Checklist and expected output corrected |
| 4 | Interview answer priced Bastion at about $140 for setup while the lab elsewhere recommends free Bastion Developer. U24 note did not reflect the provider source reading | Both corrected. U24 stays open |
| 5 | Storage account name in the errors list did not match the Terraform default (`stfslogixlabeus201`). A Step 4 error entry described a managed identity that the procedure does not use. A Step 4 entry told readers to install AzFilesHybrid from the Gallery. The interview answer said the lab uses a group-wide Modify grant, which Step 6 does not | All four corrected |
| 7 | No contradictions found | None |
| 8 | Cost warning said it was the first compute cost, contradicting Lab 4 | Corrected |
| 10 | Teardown used `terraform destroy -auto-approve`, which skips plan review. No warning about VNet DNS pointing at a deleted domain controller | Replaced with a reviewed destroy plan and a DNS reset note |
| 11 | Stated regional host pools are preview only and do not support App Attach. Learn now documents regional App Attach packages and What's new lists regional host pools as GA, while two other pages still say preview. Validation required both VNets to have empty DNS, but Lab 4 sets `eastus2` DNS. Prerequisite said Labs 1 to 3 only | Note rewritten as a disagreement between Learn pages, validation and prerequisites corrected. The Labs 11 to 20 plan still holds the older claim |

Earlier text in this file said Lab 11 had no conflicting statements. That was a text search and it missed the items above.

## Not re-read in this pass

Chapter 4 and 11 sections beyond those in the table, the Azure Local activation edge cases, the Private Link pricing page, and Labs 6, 9 and 12 onward (Lab 6 and 9 are outside the Chapter 1 to 12 and 15 scope, and Labs 12 onward belong to the held part of the book). They keep their earlier status and caveats from [REVIEW-REGISTER](../REVIEW-REGISTER.md).

## Follow-up outside Chapters 1 to 12

Chapter 13 is on hold and was not changed. It states that several required endpoints have no service tag. That is true for the entries Learn marks N/A, but it should be re-read against the table when Chapter 13 is reviewed.
