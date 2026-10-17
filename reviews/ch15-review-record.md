# Chapter 15 review record

Chapter: `chapters/ch15-host-pool-design-decisions.md`
Technical pass date: 2026-10-16. Process: single reviewer/process (Claude, in-session) performed both passes, so the passes are NOT independent. No runtime execution; no Azure access.

## Sources (retrieved 2026-10-16)

| ID | Page | URL | Mode |
|---|---|---|---|
| S1 | Configure host pool load balancing | https://learn.microsoft.com/en-us/azure/virtual-desktop/configure-host-pool-load-balancing | Full fetch (also returned for the host-pool-load-balancing URL) |
| S2 | Configure personal desktop assignment | https://learn.microsoft.com/en-us/azure/virtual-desktop/configure-host-pool-personal-desktop-assignment-type | Full fetch |
| S3 | Autoscale scaling plans and example scenarios | https://learn.microsoft.com/en-us/azure/virtual-desktop/autoscale-scenarios | Full fetch (obtained when fetching the Well-Architected URL; see claim 9) |
| S4 | Autoscale FAQ; Create and assign a dynamic scaling plan | https://learn.microsoft.com/en-us/azure/virtual-desktop/autoscale-faq | Search excerpts only |
| S5 | Azure Virtual Desktop terminology | https://learn.microsoft.com/en-us/azure/virtual-desktop/terminology | Full fetch (Ch3 review) |
| S6 | Remove-AzWvdUserSession | https://learn.microsoft.com/en-us/powershell/module/az.desktopvirtualization/remove-azwvdusersession | Full fetch |
| S7 | Send-AzWvdUserSessionMessage | https://learn.microsoft.com/en-us/powershell/module/az.desktopvirtualization/send-azwvdusersessionmessage | Full fetch |
| S8 | IUserSession, ISessionHost interfaces | https://learn.microsoft.com/en-us/dotnet/api/microsoft.azure.powershell.cmdlets.desktopvirtualization.models.iusersession | Full fetch |
| S9 | New-AzWvdHostPool / Update-AzWvdHostPool / Deploy article | https://learn.microsoft.com/en-us/powershell/module/az.desktopvirtualization/new-azwvdhostpool | Search excerpts only |
| S10 | Azure Virtual Desktop FAQ (host pool type) | https://learn.microsoft.com/en-us/azure/virtual-desktop/faq | Excerpt this session; full read in Ch1 review |

## Claim log

| # | Claim | Outcome | Evidence / action |
|---|---|---|---|
| 1 | Host pool type cannot change (repeated 6 times in chapter) | Verified, widened | S10. Wording now also names management approach and deployment scope (Ch3 record claims 6-7). Consistent with Ch3. |
| 2 | Load balancing only for pooled | Verified | S1 |
| 3 | Reconnect goes to existing session even in drain mode | Verified | S1. Chapter quoted an `AllowNewConnections` property that is not in S1; replaced with S1 wording. |
| 4 | Breadth-first picks host with fewest sessions, tie to first | Corrected (defect) | S1: random choice among half of available hosts with fewest sessions; not perfectly even. Fixed in section 3, Q42, key takeaways, failure table. |
| 5 | Depth-first selection, tie rule | Verified | S1 |
| 6 | Depth-first needs a session limit; breadth-first default limit | Corrected/added | S1: must set; default 999999 when created with breadth-first. Scenario 1 evidence updated. |
| 7 | Personal host pool: VM allocated regardless, no autoscale saving | Corrected | S5: autoscale supports personal pools (start on schedule/Start VM on Connect; deallocate/hibernate). Diagram, section 1, Q41 reworded. |
| 8 | Personal assignment Automatic/Direct; Direct needs session host assignment | Verified, added | S2 |
| 9 | "Microsoft's Well-Architected guidance" quote about ramp-up/peak/off-peak | Unverified, removed | Fetching `well-architected/azure-virtual-desktop/application-delivery` returned the autoscale scenarios page, not a WAF page; the quoted text could not be located. Replaced with statements verified in S3/S4 (recommend breadth-first ramp-up, depth-first off-peak). WAF reference removed. |
| 10 | Scaling plan overrides host pool algorithm; autoscale overwrites drain mode; exclusion tag | Verified, added | S3, S4 |
| 11 | `LoadBalancerType` values Persistent / MultiplePersistent | Verified | S1, S2. MultiplePersistent: Direct only, cannot be disabled, preview module (5.3.0-preview or later) when retrieved. Currency flag updated. |
| 12 | Broken reference `multi-personal-desktop-assignment` | Corrected | URL returned not-found; replaced with S2. |
| 13 | `Update-AzWvdHostPool -LoadBalancerType -MaxSessionLimit`; `az ... hostpool update --load-balancer-type` | Verified | S1 |
| 14 | `New-AzWvdHostPool` parameters (HostPoolType, LoadBalancerType, PreferredAppGroupType, MaxSessionLimit, Location) | Verified | S9 excerpt of deploy article and cmdlet syntax |
| 15 | `Get-AzWvdSessionHost` properties; `Get-AzWvdUserSession` properties (UserPrincipalName, SessionState, Name) | Verified (property names) | S8 |
| 16 | `Send-AzWvdUserSessionMessage` and `Remove-AzWvdUserSession` parameters | Verified | S6, S7 |
| 17 | `az desktopvirtualization hostpool list --query` | Judgement | JMESPath over documented properties; `hostpool show --query` form is documented in S1. Not executed. |
| 18 | "Autoscale cannot go below one host" | Corrected | S4: minimum percentage can be 0 off-peak; pool at zero needs Start VM on Connect or users see no resources (S3 scenario 4 shows the "No resources available" outcome when hosts cannot start). |
| 19 | Lab 7 reference and Northwind sizing/user counts | Judgement | Illustrative scenario data; Lab 7 content not reviewed here (Phase 4). |

## Outcomes
- Technical pass: Verified with caveats (S4/S9/S10 excerpts only; claim 9 source not located; commands not executed).
- Readability pass: Reviewed with caveats (same process; no reader test).

## Follow-ups
- Locate the Well-Architected AVD page (if any) before re-adding any WAF attribution.
- Lab 7 and Project 07 scaling plan content consistency: Phase 4.
- Learn inconsistency noted for later chapters: autoscale scenarios page labels Dynamic Autoscaling "preview" while What's new (Ch1 review) lists it as available.
