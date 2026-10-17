# Chapter 11 review record

Chapter: `chapters/ch11-network-fundamentals-required-connectivity.md`
Technical pass date: 2026-10-16. Process: single reviewer/process (Claude, in-session) performed both passes, so the passes are NOT independent. No Azure access; no command was executed.

## Sources (retrieved 2026-10-16)

| ID | Page | Mode |
|---|---|---|
| S1 | Required FQDNs and endpoints (virtual-desktop/required-fqdn-endpoint) | Full fetch |
| S2 | Azure fabric communication IPs (virtual-desktop/azurecommunicationips) | Full fetch |
| S3 | Azure Private Link with AVD (virtual-desktop/private-link-overview) | Full fetch |
| S4 | Private Link setup, proxy guidelines, Agent URL Tool page, CAF network topology, private endpoint DNS | Not fetched |

## Claim log

| # | Claim | Outcome | Evidence / action |
|---|---|---|---|
| 1 | Required list unsupported if blocked; optional examples | Verified | S1 |
| 2 | Entra endpoint IDs 56, 59, 125 | Corrected | S1 lists 46, 56, 59, 125 |
| 3 | Public-cloud only | Caveated | Gov table differs (S1); flag added |
| 4 | Platform addresses: ports, fabric protection | Verified, extended | S1/S2: ports, service tags AzurePlatformIMDS/DNS, in-VM causes, cannot proxy or tunnel |
| 5 | "Need nothing at all" in diagram text | Corrected | S2 |
| 6 | Service tags, no IP list, wildcard for service traffic, 3701 for agent FQDNs | Verified | S1 |
| 7 | UDP 3478 to 51.5.0.0/16 | Added | S1 (Q29 and flag) |
| 8 | Intermittent failures from TLS inspection | Reworded | Learn says unsupported; intermittent is judgement |
| 9 | DNS and Entra join quotes | Unverified | Source not re-fetched (S4); marker added |
| 10 | Private Link: three workflows | Corrected | S3: connection sub-resource per host pool; global endpoint optional (four scenarios) |
| 11 | Global endpoint single, dedicated workspace, access cannot be restricted | Verified | S3 |
| 12 | Agent loader restart | Verified | S3 |
| 13 | DNS zone change | Extended | S3: privatelink-global.wvd.microsoft.com |
| 14 | Added: TCP 1 to 65535 to connection endpoint, UDP opt-in, VPN/ExpressRoute need | Verified | S3 |
| 15 | Scenario 2 evidence (agent on old path) | Inference flagged | Not a Learn statement; commands not executed |
| 16 | Scenarios 1 and 3 | Illustrative | Not real incidents |
| 17 | Lab 3 UDP rule | Doc fixed | Table now cites WindowsVirtualDesktop tag and the 1024 to 65535 direct-Shortpath gap. Terraform rule (tag + 3478) matches S1; not modified |

Outcome: Verified with caveats (claims 9, 15, 16; S4 pages not fetched).

## Close-out pass, 2026-10-16

Issue dispositions affecting this chapter (details and Learn URLs in [UNRESOLVED-ISSUES.md](UNRESOLVED-ISSUES.md)): U22 closed with caveat, U33 closed with caveat.

Changes: Private Link CURRENCY FLAG replaced with setup-page evidence and client-support note; CAF deprecation note retained.

Checks rerun on the final local state are listed in [ASSET-VERIFICATION.md](ASSET-VERIFICATION.md). Source verification only; no Azure, Terraform, CLI, PowerShell or KQL execution.

## Learn re-check, 17 October 2026

Full re-read of [Required FQDNs and endpoints for Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint). Ports and the platform address rows match. Error corrected: the chapter (and Lab 3) said `oneocsp.microsoft.com` and `catalogartifact.azureedge.net` had no service tag, but Learn lists `AzureFrontDoor.FirstParty` and `AzureFrontDoor.Frontend`; `azkms.core.windows.net` carries only the generic `Internet` tag. Private Link section not re-read. Details in [CHAPTER-SOURCE-RECHECK](CHAPTER-SOURCE-RECHECK.md).
