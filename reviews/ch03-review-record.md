# Chapter 3 review record

Chapter: `chapters/ch03-avd-object-model.md`
Technical pass date: 2026-10-16. Process: single reviewer/process (Claude, in-session) performed both passes, so the passes are NOT independent. No runtime execution; no Azure access.

## Sources (retrieved 2026-10-16)

| ID | Page | URL | Mode |
|---|---|---|---|
| S1 | Azure Virtual Desktop terminology | https://learn.microsoft.com/en-us/azure/virtual-desktop/terminology | Full fetch |
| S2 | Preferred application group type behavior for pooled host pools | https://learn.microsoft.com/en-us/azure/virtual-desktop/preferred-application-group-type | Full fetch |
| S3 | Host pool management approaches | https://learn.microsoft.com/en-us/azure/virtual-desktop/host-pool-management-approaches | Full fetch |
| S4 | Azure Virtual Desktop FAQ (location restrictions; changing host pool type) | https://learn.microsoft.com/en-us/azure/virtual-desktop/faq | Search excerpts this session; full page read earlier in the Chapter 1 review |
| S5 | Deploy Azure Virtual Desktop (deployment scope, workspace/app group scope, SHC not on Azure Local, role assignment) | https://learn.microsoft.com/en-us/azure/virtual-desktop/deploy-azure-virtual-desktop | Search excerpts only (not a full fetch) |
| S6 | Delegated access in Azure Virtual Desktop | https://learn.microsoft.com/en-us/azure/virtual-desktop/delegated-access-virtual-desktop | Search excerpt only |
| S7 | Get-AzWvdApplicationGroup | https://learn.microsoft.com/en-us/powershell/module/az.desktopvirtualization/get-azwvdapplicationgroup | Full fetch |
| S8 | IApplicationGroup interface (properties) | https://learn.microsoft.com/en-us/dotnet/api/microsoft.azure.powershell.cmdlets.desktopvirtualization.models.iapplicationgroup | Full fetch |
| S9 | Get-AzRoleAssignment | https://learn.microsoft.com/en-us/powershell/module/az.resources/get-azroleassignment | Search excerpts (description of -Scope and -ResourceGroupName) |
| S10 | Data locations for Azure Virtual Desktop | https://learn.microsoft.com/en-us/azure/virtual-desktop/data-locations | Full fetch |

## Claim log

| # | Claim | Outcome | Evidence / action |
|---|---|---|---|
| 1 | Four objects and definitions | Verified | S1 |
| 2 | Cardinality: app group to one host pool, one workspace; one desktop group per host pool; many RemoteApp groups | Verified | S1, S2 |
| 3 | RemoteApp pooled only; desktop pooled or personal | Verified | S1, S2 |
| 4 | App group cannot exist without host pool; location rule; workspace same location as app groups | Verified | S4 (excerpt) |
| 5 | Host pool type (pooled/personal) cannot change; VMs can be moved to the other type | Verified | S4 (excerpt) |
| 6 | Management approach set at creation and cannot change | Verified, added | S3. Chapter had conflated this with host pool type; now separate rows and wording. |
| 7 | Deployment scope immutable; workspace only takes app groups of same scope | Verified, added | S5 (excerpt) |
| 8 | Preferred app group type: portal default Desktop, auto `-DAG`, not created by PowerShell/CLI | Verified | S2 |
| 9 | Preferred type can be changed after creation | Added | S2 |
| 10 | Client shows only the preferred type when both assigned; unset treated as Desktop (rolling out) | Corrected | Chapter implied a user "could open both"; S2 says client shows only preferred type, `ms-avd:connect` bypasses. Section 4 and Scenario 2 root cause reworked. |
| 11 | Consequences of two sessions (overload, stuck sign-in, black screen, crashes) | Verified | S2. "Profile conflicts" retained as labelled inference. |
| 12 | SHC pooled only; not supported on Azure Local | Verified | S3, S5 (excerpt). Standard "Azure or Azure Local" wording removed (not stated in S3). |
| 13 | SHC GA status | Unverified | Some indexed text of S5 still says preview; What's new (Ch1 review) lists availability without a GA label. Flag rewritten. |
| 14 | Regional host pool status | Conflict | See Ch2 record; flag updated. |
| 15 | Diagram vs prose: prose described three app groups and a host pool `hp-office-prd-eus2-01` not in the diagram | Corrected | Prose now matches the two-group diagram. |
| 16 | Scenario 1: `Get-AzRoleAssignment -ResourceGroupName ... \| Where RoleDefinitionName` | Corrected (defect) | S9: -ResourceGroupName filters assignments effective at the resource group; app group assignments sit at app group scope (S6). Command rewritten to use `-Scope $ag.Id`. Not executed. |
| 17 | `Get-AzWvdApplicationGroup \| Select Name, ApplicationGroupType, HostPoolArmPath, WorkspaceArmPath` | Verified (property names) | S7 (cmdlet and -ResourceGroupName), S8 (properties). Not executed. |
| 18 | Role name `Desktop Virtualization User` | Verified | S6 |
| 19 | Interview Q7 items 4-6 (sync delay, Conditional Access on feed, feed cache) | Judgement | Not tested against a Learn statement; presented as troubleshooting practice. |
| 20 | Section numbering duplicated (two 9s and two 10s) | Corrected (readability) | Renumbered to 11 and 12. |
| 21 | Duplicate "Architect lesson" lines | Corrected (readability) | Shorter duplicate removed in 3 scenarios. |

## Outcomes
- Technical pass: Verified with caveats (S5 and S4 excerpts only, claim 13 unverified, claim 14 conflict, commands not executed, Lab 2 content not reviewed here).
- Readability pass: Reviewed with caveats (same process; no reader test).

## Follow-ups
- Lab 2 and Terraform content tied to this chapter: Phase 4.
- Fetch the Deploy article in full for a stronger S5 record.

## Close-out pass, 2026-10-16

Issue dispositions affecting this chapter (details and Learn URLs in [UNRESOLVED-ISSUES.md](UNRESOLVED-ISSUES.md)): U1 closed with caveat, U2 closed with caveat.

Changes: Regional host pool CURRENCY FLAG rewritten.

Checks rerun on the final local state are listed in [ASSET-VERIFICATION.md](ASSET-VERIFICATION.md). Source verification only; no Azure, Terraform, CLI, PowerShell or KQL execution.
