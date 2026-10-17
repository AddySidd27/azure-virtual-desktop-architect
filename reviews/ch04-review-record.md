# Chapter 4 review record

Chapter: `chapters/ch04-connection-flow-end-to-end.md`
Technical pass date: 2026-10-16. Process: single reviewer/process (Claude, in-session) performed both passes, so the passes are NOT independent. No runtime execution; no Azure access.

## Sources (retrieved 2026-10-16, full fetch unless noted)

| ID | Page | URL |
|---|---|---|
| S1 | Understanding AVD network connectivity | https://learn.microsoft.com/en-us/azure/virtual-desktop/network-connectivity |
| S2 | RDP Shortpath | https://learn.microsoft.com/en-us/azure/virtual-desktop/rdp-shortpath |
| S3 | Required FQDNs and endpoints | https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint |
| S4 | Proxy server guidelines | https://learn.microsoft.com/en-us/azure/virtual-desktop/proxy-server-support |
| S5 | WVDConnections table reference | https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/wvdconnections |
| S6 | Check access to required FQDNs (URL tool, event 3701) | https://learn.microsoft.com/en-us/azure/virtual-desktop/check-access-validate-required-fqdn-endpoint (not fetched; event 3701 appears in S3 only) |

## Claim log

| # | Claim | Outcome | Evidence / action |
|---|---|---|---|
| 1 | Host registers with the gateway before any user connects | Corrected (defect) | S1: Agent Loader opens a persistent channel to the broker at startup; host connects to the gateway only at connect time. Diagram, prose, interview answers and takeaways fixed. |
| 2 | Order: broker selects, then client opens gateway | Corrected (defect) | S1: client reaches gateway first, gateway asks broker, broker initializes host via persistent channel, host connects to the same gateway. Diagram and steps 5-9 reordered. |
| 3 | Gateway selection (latency groups, fewest connections, Front Door) | Added, Verified | S1 |
| 4 | FQDN table service tags | Corrected | S3: AzureActiveDirectory, AzureMonitor, Storage, AzureFrontDoor.FirstParty; added aka.ms, service traffic wildcards. |
| 5 | Fabric IPs and ports | Corrected | S3: must not be intercepted/proxied; 53 only with Azure DNS. |
| 6 | Entra endpoints via Office 365 IDs 46, 56, 59, 125 | Verified | S3 |
| 7 | Shortpath "best path wins" | Corrected | S2: first-found algorithm. |
| 8 | Public Shortpath port requirements | Corrected | S2: host subnet outbound UDP 1024-65535 (default 49152-65535, 65330 ignored) and 51.5.0.0/16:3478. |
| 9 | UDP success drops TCP; TURN regional, relay-update drops; Gov preview 20.140.236.0/22 | Added, Verified | S2 |
| 10 | Proxy/TLS inspection guidance | Corrected | S4: bypass proxies, no SSL termination, authenticated proxies unsupported. |
| 11 | Scenario 3 KQL (`State == "Completed"`) | Corrected | S5 gives no State value list (Unverified). Query replaced with PredecessorConnectionId reconnect count; column names from S5; query not executed. |
| 12 | Multipath GA July 2026 | Conflict-free, not re-verified | What's new lists GA; chapter flag retained. Chapter 14 to review. |
| 13 | Event 3701 / URL tool | Partially verified | 3701 in S3; URL tool page not fetched (S6). Unverified. |
| 14 | Lab 3 UDP rule | Follow-up | Phase 4: Lab 3 rule should include 51.5.0.0/16:3478 and port range. |

Outcome: Verified with caveats (claims 12-14).

## Close-out pass, 2026-10-16

Issue dispositions affecting this chapter (details and Learn URLs in [UNRESOLVED-ISSUES.md](UNRESOLVED-ISSUES.md)): U10 closed with caveat, U11 closed.

Changes: URL tool caveats added (.NET 4.6.2, RDAgent 1.0.2944.400, no wildcard check); Multipath flag updated with GA, macOS beta and Azure Government statuses.

Checks rerun on the final local state are listed in [ASSET-VERIFICATION.md](ASSET-VERIFICATION.md). Source verification only; no Azure, Terraform, CLI, PowerShell or KQL execution.

## Editorial and Learn re-check, 17 October 2026

Source re-read: [RDP Shortpath for Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/rdp-shortpath), retrieved 17 October 2026. Confirmed unchanged: port 3390 default for the managed-network listener, STUN/TURN for public networks, `51.5.0.0/16` and UDP 3478, ephemeral range 49152-65535 with 65330 reserved, first-found selection, Azure Government range `20.140.236.0/22` in public preview, and security equal to TCP reverse connect.

Corrections: the opening now says Shortpath is set up alongside the reverse connect connection and replaces it when it succeeds (Learn's connection sequence); the client firewall row now gives the destination Learn states (public IPs of the NAT gateway or Azure Firewall); "Learn expects the managed path to win" changed to Learn's "likely"; symmetric NAT (Azure Firewall, Azure NAT Gateway) and TURN added; two unsupported frequency claims reworded or marked as judgement. Inline source link added. First-use acronym expansions added.

Not verified: the RDP Multipath statements (unchanged from the 16 October flag). No Azure, CLI, PowerShell or KQL execution.
