# Chapter 2 review record

Chapter: `chapters/ch02-control-plane-management-plane-data-plane.md`
Technical pass date: 2026-10-16. Process: single reviewer/process (Claude, in-session) performed both passes, so the passes are NOT independent.

## Sources (retrieved 2026-10-16, full page unless noted)

| ID | Page | URL | Mode |
|---|---|---|---|
| S1 | Azure Virtual Desktop service architecture and resilience | https://learn.microsoft.com/en-us/azure/virtual-desktop/service-architecture-resilience | Full fetch |
| S2 | Required FQDNs and endpoints for Azure Virtual Desktop | https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint | Full fetch |
| S3 | Data locations for Azure Virtual Desktop | https://learn.microsoft.com/en-us/azure/virtual-desktop/data-locations | Full fetch |
| S4 | Update-AzWvdSessionHost | https://learn.microsoft.com/en-us/powershell/module/az.desktopvirtualization/update-azwvdsessionhost | Full fetch |
| S5 | Multiregion BCDR for AVD (Azure Architecture Center) | via Learn search | Search excerpt only |
| S6 | Get-AzWvdSessionHost | https://learn.microsoft.com/powershell/module/az.desktopvirtualization/get-azwvdsessionhost | Search excerpt only |

## Claim log

| # | Claim | Outcome | Evidence / action |
|---|---|---|---|
| 1 | Control plane = web, broker, gateway, resource directory, diagnostics | Corrected | S1 lists web, broker, gateway, resource directory and the two databases; the diagnostics wording comes from S5. Attribution fixed in chapter. |
| 2 | Session host holds a persistent outbound connection established before any user connects | Corrected | S1: broker tells the agent to connect to the same gateway as the client. Reworded to connect-time. |
| 3 | Resource directory feeds web service entitlements | Corrected | S1: resource directory locates the database; wording adjusted. |
| 4 | RDP Shortpath bypasses gateway | Verified | S1 |
| 5 | Regional host pools status/regions | Conflict | S3 lists Central US and East US 2 and geographical default; Learn What's new says GA (Sept 2026). Currency flag updated; no GA date asserted. |
| 6 | Deployment scope cannot be changed after creation | Verified | Recorded in Ch1 review (S-host-pool management pages) |
| 7 | `Update-AzWvdSessionHost -AllowNewSession:$true` syntax | Verified | S4 syntax and example |
| 8 | `Get-AzWvdSessionHost` selecting Status, AllowNewSession, Session, UpdateState | Unverified | S6 excerpt confirms output type ISessionHost only; property names not confirmed against the full model page. Not executed. |
| 9 | Stale cross-references to Chapters 30-32 and 36-38 | Corrected | Replaced with pointer to SUMMARY.md (structure-change-03). |
| 10 | Duplicate "Architect lesson" lines | Corrected (readability) | Removed the shorter duplicate in 3 scenarios. |

## Outcomes

- Technical pass: Verified with caveats (claim 5 conflict, claim 8 unverified, no runtime execution).
- Readability pass: Reviewed with caveats (same process; no reader test).

## Follow-ups
- Diagram `diagrams/architecture/ch02-avd-control-plane.svg` text not re-checked against corrected step 4 wording beyond a grep for "persistent" (no match).
- Confirm Get-AzWvdSessionHost property names.
