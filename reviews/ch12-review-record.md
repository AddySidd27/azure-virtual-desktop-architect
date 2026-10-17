# Chapter 12 review record

Chapter: `chapters/ch12-enterprise-topologies-ip-planning.md`
Technical pass date: 2026-10-16. Process: single reviewer/process (Claude, in-session) performed both passes, so the passes are NOT independent. No Azure access; no command was executed.

## Sources (retrieved 2026-10-16)

| ID | Page | Mode |
|---|---|---|
| S1 | CAF: AVD network topology and connectivity (scenarios/azure-virtual-desktop/eslz-network-topology-and-connectivity) | Full fetch. Page is marked deprecated, removal announced for 2026-10-30 |
| S2 | CAF: Define an Azure network topology | Full fetch |
| S3 | CAF: Virtual WAN network topology in an Azure landing zone | Full fetch |
| S4 | CAF: Traditional Azure networking topology | Full fetch |
| S5 | Architecture Center: Hub-spoke network topology in Azure (GatewaySubnet, AzureFirewallSubnet) | Search excerpt |
| S6 | ExpressRoute virtual network gateways (gateway subnet size), VPN Gateway settings | Search excerpt |
| S7 | Azure Networking design guide: IP planning (reserved addresses), CAF Plan for IP addressing | Search excerpt |
| S8 | Virtual network peering overview (pricing) | Search excerpt |
| S9 | CAF AVD landing zone accelerator page (enterprise-scale-landing-zone) | Not fetched |

## Claim log

| # | Claim | Outcome | Evidence / action |
|---|---|---|---|
| 1 | AVD deploys into an application (workload) landing zone | Verified | S1 |
| 2 | "Microsoft frames AVD network design foundations as ..." four-point sentence | Unverified, removed | Not present in current S1 text; S1 deprecated. Dropped, currency flag added |
| 3 | Virtual WAN "when you require transit connectivity between many endpoints" | Corrected | S1 now says transit between VPN and ExpressRoute; S2 gives three triggers |
| 4 | Trigger is more than two regions with global transit, not spoke count | Verified, extended | S4 holds the quote. S2 adds 30+ branches or SD-WAN and VPN to ExpressRoute transit; traditional suits one or several regions |
| 5 | Shared services cannot live in the Virtual WAN hub | Verified, re-sourced | S3 item 5. S4 allows DCs and DNS in a traditional hub |
| 6 | Hub and spoke has no transitive routing by default | Verified | S4: peering is not transitive, UDRs and NVAs needed |
| 7 | Azure reserves five addresses per subnet | Verified | S7 |
| 8 | /24 has 251 usable, /23 has 507 | Verified | Arithmetic: 256-5, 512-5 |
| 9 | Worked example: 1,600 / 10 = 160, doubled 320, plus 5 = 325, so /23 | Verified arithmetic | Doubling is Judgement; marked, batch-size caveat added |
| 10 | GatewaySubnet "/26 or larger" | Corrected | S5 recommends /26; S6 says /27 or larger for most configurations, /26 for 16 circuits; platform minimum is /27 for non-Basic SKUs |
| 11 | AzureFirewallSubnet and AzureBastionSubnet /26 | Verified | S5 and Azure Networking hub table |
| 12 | Virtual WAN hub address range | Added | At least /24 (hub-spoke VWAN architecture page excerpt) |
| 13 | Peering charged per GB both directions | Verified | S8: ingress and egress charged; Virtual WAN pricing page examples show inbound and outbound |
| 14 | Scenario 2 arithmetic (118 + 118 + overhead exceeds 251) | Corrected | 236 plus overhead does not exceed 251 usable; changed to 150 + 150 = 300 |
| 15 | Changing VNet address space can force recreation and break peering | Caveated | CAF Plan for IP addressing: adding space is supported without outage, peerings need resync. Removal risk is Judgement |
| 16 | 70 percent subnet utilisation alert | Judgement | Marked; no Learn threshold |
| 17 | Hub /22 is a common allocation | Judgement | Not a Learn figure; left as experience |
| 18 | AVD landing zone accelerator reference | Unverified | S9 not fetched; marker added |
| 19 | Scenarios 1 to 3 | Illustrative | Not real incidents; commands not executed |
| 20 | "Lab 3 builds four subnets" | Verified | `terraform/lab03-network/network.tf`: identity, hosts (/23), storage, mgmt, plus an optional Bastion subnet |

Outcome: Verified with caveats (claims 2, 9, 15 to 19; S5 to S8 excerpt-only; S1 deprecated).
