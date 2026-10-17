# Independent technical review pack, Chapters 1 to 12 and Chapter 15

> Prepared 17 October 2026 by the author's single reviewer (Claude, in session). **This pack is preparation for an independent review. It is not one.** No independent person has reviewed any chapter. Nothing in the repository has been executed in Azure. No Terraform `plan` or `apply` has ever run. Publication readiness is CONDITIONAL. Implementation readiness is NO.

## How to use this pack

1. Pick a chapter. Read the verified claims and spot-check three against the named Learn page.
2. Read the unverified and judgement items. Decide whether the chapter's wording is honest about each.
3. Answer the reviewer questions.
4. For anything you want upgraded from "documented" to "tested", the required-evidence column says what proof would count.

Evidence vocabulary (strongest last): official-source verified, static check, syntax parsed, Terraform validated (CI schema level only), command executed, Azure behaviour tested, end-to-end tested, independently reviewed. Only the first four apply anywhere in this repository today.

Per-chapter claim logs: `reviews/chNN-review-record.md`. Source list: `SOURCE-VERIFICATION.md`. Recheck history: `reviews/CHAPTER-SOURCE-RECHECK.md`. Open issues: `reviews/UNRESOLVED-ISSUES.md` and `reviews/OPEN-ISSUES-REASSESSMENT.md`.

## Items that cut across chapters

| Item | Status | Required evidence |
|---|---|---|
| U23 private endpoint network policies, Lab 3 `nsg-storage` | Open. Learn behaviour verified. Provider argument found in source, not in a schema dump. Module unchanged | Approve the module change, then `terraform providers schema -json`, plan and apply in a test subscription, plus a connectivity test with a deny rule |
| U24 Lab 3 re-apply and VNet DNS | Open. Source reading suggests no reset, an inference | `terraform plan` output from a real run after Lab 4 |
| U26 resource provider list for AzureRM 5.x | Open. Only `Microsoft.DesktopVirtualization` source verified | Clean-subscription run recording every provider error |
| U27 DC forwarder commands | Open. Parameters confirmed in Learn, commands not executed | Command output from the lab DC and a resolution test |
| U28 manual role assignments for Start VM on Connect and autoscale | Open | Role assignment plus an observed power-state change |
| U35 autoscale role scope conflict between two Learn pages | Open | Test with a narrower scope |
| U36 interactive session on the DC | Open | Bastion Developer or alternative route used successfully |
| U7 Azure Local OS set | Open. Learn pages differ | Azure Local owner confirms against a live instance, or Learn aligns |
| Regional host pool status (Ch1, Ch2, Ch3, Lab 11) | Learn pages disagree on preview or GA. What's new says GA September 2026. The Regional host pools and BCDR pages still say preview. The Labs 11 to 20 plan (outside this scope) carries an older claim that regional pools do not support App Attach | Re-read at review time. Decide whether Labs 11 to 20 should change |
| CI | Structure, links, format and schema only. Does not prove any Azure behaviour | n/a |

## Chapter 1. What AVD actually is

**Verified (official-source).** Service history dates against What's new, as re-read 17 October 2026: ARM integration announced June 2020 and GA July 2020, rename to Azure Virtual Desktop June 2021, hybrid and dynamic autoscaling dates, Classic retirement 30 September 2026, MSIX App Attach deprecation 1 June 2025. Control plane, session host, storage responsibility split. Licensing and per-user pricing limits.

**Unverified or judgement.**
- WVD "2019" year rests on Learn's "Fall 2019 release" wording.
- Classic retirement actually taking effect: no Learn page confirms the effect, only the notice.
- Windows 365 "fixed SKUs" is unverified and flagged.
- Ephemeral OS disk availability: Learn disagrees with itself.
- Regional host pool status: Learn conflict.
- Comparison columns (Citrix DaaS, on-premises), cost thresholds and engineering-time remarks are judgement and labelled.

**Reviewer questions.**
1. Is any date presented as fact that you can falsify from an archived What's new page?
2. Does the comparison table read as neutral, or does it favour AVD?
3. Are the judgement labels enough for a reader to tell opinion from sourced statement?

**Required evidence.** Archived copies of What's new and the Classic retirement notice at your review date. A statement from someone running Windows 365 for the SKU claim.

## Chapter 2. Control, management and data planes

**Verified.** Component list, Traffic Manager and Front Door roles, what the service stores and does not, event 3701 described as listing the agent's endpoints (not blocked ones).

**Unverified or judgement.** The failure table is judgement and labelled. Regional host pool status is a Learn conflict.

**Reviewer questions.** Is the plane model useful or does it hide a distinction (for example the diagnostics location)? Do failure scenarios match your production experience?

**Required evidence.** A production incident review (anonymised) showing which plane failed for the failure-table rows you can match.

## Chapter 3. Object model

**Verified.** Location rule, application group and workspace cardinality, tenant rule, delegated-access roles, host pool type immutability.

**Unverified or judgement.** Session host configuration GA status (indexed text varies). Interview Q7 items 4 to 6 (sync delay, Conditional Access on feed, feed cache) are judgement.

**Reviewer questions.** Is the relationship diagram accurate for a regional host pool? Are interview answers defensible as stated?

**Required evidence.** Portal or CLI output from a test host pool showing the object relationships.

## Chapter 4. Connection flow end to end

**Verified.** Gateway selection by 10 ms latency group then fewest connections, Front Door and Traffic Manager by cloud, TLS 1.2 minimum, endpoint table equals the Azure cloud tab of the required FQDN page, Shortpath ports and ranges, first-found rule, symmetric NAT, TURN.

**Unverified or judgement.** Multipath TCP GA date carried from What's new, not independently re-verified. Chapter 14 is not in scope.

**Reviewer questions.** Is the connection sequence the same as what you see in a network trace? Are the Shortpath failure modes complete?

**Required evidence.** A packet capture or RDP connection information screenshot from a real session showing transport and gateway.

## Chapter 5. Operating systems, multi-session and licensing

**Verified.** Multi-session access limited to Microsoft or Approved Providers (Citrix, Omnissa); no RD IP Virtualization; ProductType 3 behaviour and KMS limit; Azure Local needs 23H2 or later, is not Arc-enabled in this sense, joins AD DS only in the portal; Azure verification activates Windows 11 multi-session and Server 2022 Azure Edition.

**Unverified or judgement.**
- Azure Local OS set (U7).
- Other Arc or third-party setups beyond Azure Local keep a narrower verify flag.
- "8 to 10 users per D8s" is the author's assumption.

**Reviewer questions.** Is the licensing explanation safe for a reader to act on without calling Microsoft? Does the support-boundary text overstate anything?

**Required evidence.** A written licensing confirmation for any design decision, and a live Azure Local test for U7.

## Chapter 6. Clients and the endpoint story

**Verified.** Windows App platform, redirection and Shortpath claims, Store app retirement dates, browser requirements.

**Unverified or judgement.** Meta Quest label (preview versus supported, U9). Intune portal path is typical layout only. Pinning method (U12).

**Reviewer questions.** Is the client support matrix current on the day you review? Are the Intune steps what you see?

**Required evidence.** Current compare-platforms page and a tenant walkthrough for the Intune path.

## Chapter 7. Identity architecture foundations

**Verified (re-read in full 17 October 2026).** Users must exist in Entra ID. UPN or SID must match for hybrid identities. Three join models and Entra join prerequisites. Entra Domain Services joined hosts cannot be managed with Intune. Windows Server cannot be enrolled in Intune with Entra join. Virtual Machine User Login role needed on Entra joined hosts without a session host configuration. Azure Local joins AD DS only.

**Unverified or judgement.**
- The claim that Entra Domain Services removes Domain Admin and schema rights is not sourced and the chapter says so.
- Cloud-only Azure Files with Entra Kerberos: Learn pages conflict, flagged.
- FSLogix Event Viewer path deferred to Chapter 21.

**Reviewer questions.** Is the Entra Kerberos MFA exclusion advice correct in your tenant? Does the cloud-only profile storage conflict warning leave a reader safe?

**Required evidence.** A test tenant run of Entra Kerberos with a Conditional Access policy requiring MFA.

## Chapter 8. Authentication flows

**Verified.** Single sign-on tasks, app IDs, roles, consent prompt limits, Kerberos server object, host pool property, client list.

**Unverified.** RDP properties tab path. KDC proxy with Windows App (U15, U18 related). Event Viewer paths.

**Reviewer questions.** Does the flow diagram match your sign-in logs? Is the Windows App SSO position honest?

**Required evidence.** Entra sign-in logs from a real SSO connection.

## Chapter 9. Conditional Access and MFA

**Verified.** App IDs, two-policy structure, sign-in frequency table, Every time rule, per-user MFA, Security Defaults.

**Unverified.** The SSO troubleshooting page was not fetched.

**Reviewer questions.** Would the policy structure lock out an admin if copied as written?

**Required evidence.** A report-only policy evaluation in a test tenant.

## Chapter 10. RBAC and delegation

**Verified (re-read 17 October 2026).** All 15 built-in role descriptions match the RBAC page. Session host configuration managed identity needs Desktop Virtualization Virtual Machine Contributor on the resource group or subscription. Start VM on Connect role scope. Autoscale role scope (subscription satisfies both pages).

**Unverified or judgement.** Delegation tiers, PIM, locks and naming are design advice. Autoscale scope conflict (U35). Terraform role assignment blocks not run. Scenarios are illustrative.

**Reviewer questions.** Would the delegation model survive an audit? Does the helpdesk role set let a helpdesk user do their job?

**Required evidence.** Role assignment output from a test subscription, and an access test for each delegated role.

## Chapter 11. Egress and DNS

**Verified.** Required endpoint ports and platform addresses, service tags, US Government differences; Private Link: one global endpoint, global DNS zone name, UDP opt-in with public Shortpath disabled, supported clients, ignored private-only setting on the global workspace.

**Unverified or judgement.** DNS and Entra join quotes (source not re-fetched). Scenarios illustrative. Learn's Private Link overview and setup pages disagree on client lists.

**Reviewer questions.** Is the egress design implementable with Azure Firewall as written? Is the Private Link caution proportionate?

**Required evidence.** A Private Link test deployment with DNS resolution output, and a firewall log showing endpoint hits.

## Chapter 12. Enterprise topologies and IP planning

**Verified.** ExpressRoute gateway subnet /27 or larger (/26 for 16 circuits), hub-spoke page recommends /26, Firewall and Bastion subnets /26 minimum, vWAN hub /24 minimum with /23 recommended, five reserved addresses per subnet, Bastion Developer SKU needs no AzureBastionSubnet.

**Unverified or judgement.** The Private Link pricing page was not read, so the private endpoint peering charge statement rests on the Virtual WAN pricing pages. The Cloud Adoption Framework AVD page is deprecated and scheduled for removal 30 October 2026. 70 percent utilisation alert and the hub /22 allocation are judgement. Landing zone accelerator reference is unverified.

**Reviewer questions.** Do the address plans survive a three-region growth case? Is the vWAN versus hub-spoke guidance balanced?

**Required evidence.** Azure pricing calculator output for the peering and endpoint charges, and an IPAM review of the sizing tables.

## Chapter 15. Host pool design decisions

**Verified.** Host pool type cannot change. Load balancing only for pooled pools. Breadth-first and depth-first behaviour, including the half-of-hosts random choice. Drain mode does not stop reconnects to existing sessions. Scaling plan overrides the host pool algorithm and autoscale overwrites drain mode. Cmdlet parameters.

**Unverified or judgement.** The Well-Architected quote was removed as unverifiable. `hostpool list --query` form is not executed. Northwind sizing is illustrative. Autoscale FAQ read from search excerpts only.

**Reviewer questions.** Does the personal pool guidance match current autoscale behaviour? Is the breadth-first correction visible everywhere it should be?

**Required evidence.** A test pool showing breadth-first spread and the drain-mode reconnect behaviour (Lab 10 Step 4).

## Labs touched by Chapters 1 to 12 and 15

Reviewed in full for text, commands, prerequisites, cleanup, expected results and source references on 17 October 2026: Labs 1, 2, 3, 4, 5, 7, 8, 10 and 11. Not run. Not independently reviewed. See the table in `CHAPTER-SOURCE-RECHECK.md`.

| Lab | What a reviewer must run before trusting it |
|---|---|
| 1 | Provider registration and quota commands in a clean subscription (U26) |
| 3 | `terraform plan` and the private endpoint policy change (U23) |
| 4 | Every `az vm run-command` step on a fresh DC, then the forwarder check (U24, U27) |
| 5 | AzFilesHybrid join and NTFS steps with an interactive session (U36) |
| 7, 8 | Registration token flow, domain join and agent registration |
| 10 | Autoscale with the manual role assignment, drain mode test, reviewed destroy plan (U28, U35) |
| 11 | Peering and the regional host pool status question |

## What a reviewer should not conclude

- Do not read "official-source verified" as "tested". It means a Learn page said it on the date recorded.
- Do not read a passing CI run as evidence that any Azure deployment works.
- Do not treat this pack as a review. It was prepared by the same process that wrote the chapters.
