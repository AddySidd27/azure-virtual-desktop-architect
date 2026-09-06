# Project 13 - Solheim Trading: Multi-Region AVD Architecture

> **Fictional architecture case study:** Solheim Trading is not a customer delivery record. Requirements, measurements, costs, tests, and outcomes are worked examples or validation targets unless separate lab evidence is linked.

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Part XI:** Architecture Case Studies
> **Standard:** [PROJECT-STANDARD.md](../PROJECT-STANDARD.md)
> **Technical baseline:** August 2026
> **Concepts introduced here:** HA within a region, multi-region design, active/active versus active/passive, hub-spoke versus Virtual WAN at multi-region scale

---

## Engagement brief

**What this represents.** A commodities trading firm expanding from a single-region AVD deployment to three regions as the business opens new trading desks, where latency to the trading platform is not a comfort issue but a measurable cost, a trader with 40ms of extra round-trip latency to their session is a trader operating at a real disadvantage against the market. This is a greenfield multi-region build, not a migration, but it inherits real constraints from the existing single-region estate it extends.

**The business problem.** Solheim currently runs 600 traders and support staff from a single UK South AVD deployment. The business is opening a New York desk (140 traders) and a Singapore desk (90 traders), both trading different market hours against different exchanges, and both need AVD sessions with latency low enough that trading application responsiveness is not a competitive disadvantage against firms with infrastructure physically closer to those exchanges.

**Constraints that cannot be designed away.** Market data licensing for the New York and Singapore desks is region-specific, the Bloomberg and exchange data feeds each desk needs are contracted and priced per region, which effectively forces session hosts to sit in the same region as the data feed they consume, not just near it. Trading compliance requires that a trader's session data does not leave the region their desk is licensed to operate in. There is no acceptable trading-hours downtime window, the three regions' trading hours overlap enough that there is no global quiet period to do maintenance in.

**Previously learned concepts applied.** Session host placement across availability zones ([Chapter 17](../chapters/ch17-session-host-sizing-compute-selection.md)), profile storage redundancy ([Chapter 20](../chapters/ch20-profile-storage-architecture.md)), hub-spoke networking (Hero diagram 4), monitoring architecture from [Project 02](project-02-enterprise-850-users.md).

**New concepts introduced here.** The distinction between high availability within one region (zone redundancy, already covered) and true multi-region design, where regions are independent enough to survive one failing without the others noticing. Image replication strategy across regions. Profile locality trade-offs, Cloud Cache versus a genuinely regional, non-shared profile design. Hub-spoke against Virtual WAN as the multi-region networking backbone. User assignment and routing so a New York trader's session actually lands in New York, not wherever a load balancer happens to send it.

**Architectural decisions to make.** Whether the three regions run active/active (each independently primary for its own users, no cross-region failover expectation) or active/passive (one region as a DR target for another). Whether the existing UK South hub-spoke pattern extends to three regions or gets replaced with Azure Virtual WAN. How much regional independence to build given the operational cost of running three of everything against the benefit of true regional isolation.

**What could realistically go wrong.** A shared component (identity, a central monitoring workspace) becomes an unplanned single point of failure across all three regions, defeating the purpose of building them independently. Image replication lag means a security patch reaches UK South before it reaches Singapore, creating an inconsistent security posture across regions for longer than acceptable. A New York trader's session gets routed to UK South during a UK South capacity event, adding exactly the latency penalty the regional build was meant to eliminate.

**Validation and handover.** Measured, not assumed, latency for each desk to its regional session host, compared against the pre-migration baseline. Confirmation that a full regional outage in one region does not affect the other two regions' trading. A documented, honest statement of what does and does not fail over automatically, this project is explicit that it does not claim automatic regional failover unless it is genuinely built and tested.

---

## 1. The situation as found

**Solheim Trading.** 600 users in UK South today, expanding to 830 total across three regions. The existing UK South deployment (built two years ago, broadly following this book's Chapter 1-25 patterns) is not being rebuilt, it is extended, and its design choices are the baseline the two new regions are measured against, not a blank slate.

**Regional requirements, as specified by the business.**

| Region | Desk | Users | Trading hours (local) | Data residency requirement |
|---|---|---|---|---|
| UK South | London desk (existing) | 600 | 07:00-17:00 GMT | None beyond existing UK data protection scope |
| East US 2 | New York desk (new) | 140 | 08:00-17:00 EST | Session and market data must stay in-region |
| Southeast Asia | Singapore desk (new) | 90 | 09:00-18:00 SGT | Session and market data must stay in-region |

**The latency requirement, made concrete.** The business's own trading-platform vendor specifies that round-trip latency above 80ms between the trading session and the exchange connectivity point measurably affects order execution timing in a way traders notice and complain about. A New York trader connecting to a UK South session, even on a well-connected network path, sits well above that threshold, this is the technical justification underpinning the entire regional expansion, not a general "cloud regions are good practice" argument.

---

## 2. Business and technical requirements

**Business requirements.** Each regional desk operates independently enough that an incident in one region does not affect trading in the others, this is a genuine business continuity requirement for a trading firm, not a nice-to-have. Latency from each desk to its regional session host must be measured and must meet the vendor's 80ms threshold.

**Technical requirements.** Data residency enforced technically, not just by policy documentation, session hosts, profile storage, and application data for each region's desk must not be reachable from outside that region in the normal operating path. A consistent security and golden-image baseline across all three regions, with a defined, bounded propagation time for updates.

**The active/active decision, stated as a requirement, not left open.** The business explicitly does not want automatic cross-region failover for trading sessions. A London trader accidentally landing on a New York session host during a UK South incident would put them on infrastructure without the market data feeds their desk needs, which is worse than an outage, because it looks like it's working while producing wrong or missing data. This single requirement shapes nearly every decision in this project and is why "multi-region" here means three independent regional deployments, not one deployment with cross-region failover.

---

## 3. Active/active, not active/passive, and what that actually means

**The decision.** Three independent, active/active regional AVD deployments. Each region is fully primary for its own desk's users, all the time. No region is a standby or DR target for another region's trading sessions.

**Why, given that active/passive sounds more resilient on paper.** Active/passive implies a failover path, if UK South fails, London traders' sessions move to a standby region. For Solheim specifically, that failover path is actively undesirable: London traders need UK-licensed market data feeds that East US 2's infrastructure is not contracted or configured to provide. A "successful" failover would put traders in front of a working-looking desktop with no usable market data, which is a worse outcome than a clear outage, because it delays the moment traders and management realise something is wrong and switch to their documented manual fallback process (phone-based order execution, used rarely but drilled quarterly). Active/active, with each region genuinely independent and a clear, honest "this region is down, use the manual process" signal, is the safer design for this specific business, even though it means an outage in one region is a real outage for that region's desk, not something the platform silently absorbs.

**What "independent" means concretely, and what stays shared.** Identity (Microsoft Entra ID) is necessarily shared, it is a global service, not something Solheim can regionalise, and this is disclosed as the one dependency all three regions genuinely share. Everything else, host pools, profile storage, golden images (see section 5 on replication), monitoring workspaces, network paths to market data, is built per region, independently, with no runtime dependency on another region's infrastructure being healthy.

---

## 4. Regional network architecture: hub-spoke per region, not Virtual WAN

**The decision.** Each region gets its own hub-spoke VNet pair, matching the existing UK South pattern, connected to Solheim's on-premises trading infrastructure via region-specific ExpressRoute circuits, not a single global Azure Virtual WAN hub-and-spoke fabric spanning all three regions.

**Why, against Virtual WAN's more centralised, arguably more modern-sounding alternative.** Virtual WAN's core value is simplifying routing and connectivity *between* regions and sites at scale, exactly the connectivity Solheim's active/active, deliberately-independent design does not want. Building a Virtual WAN hub that makes it easy for East US 2 traffic to reach UK South resources would work against the isolation the business requirement in section 3 explicitly asked for. Three separate, unconnected-to-each-other hub-spoke pairs are a better structural match for "these regions must not depend on each other" than a global fabric optimised for making cross-region connectivity easy. This would be the wrong call for a business wanting an active/passive design with region-to-region failover traffic, it is the right call here because that traffic is specifically unwanted.

**What is NOT built between regions.** No VNet peering between UK South, East US 2, and Southeast Asia's spoke networks. No shared route table. A session host in East US 2 has no network path to UK South's profile storage or session hosts under normal operation, verified during validation by attempting (and confirming failure of) exactly that connection.

---

## 5. Image replication and the propagation-time trade-off

**The setup.** One Azure Compute Gallery, defined once, with the gallery's replication configuration set to replicate every new image version to all three regions automatically on publish, not three independently maintained galleries with a manual process to keep them in sync.

**Why one gallery with automatic replication, not three independent ones.** Three independently maintained golden images would drift, exactly the security-baseline inconsistency risk the requirements explicitly called out. One gallery, one image definition, with Azure's native multi-region replication, keeps the three regions' images provably identical by construction rather than by discipline someone has to maintain.

**The propagation-time trade-off.** Azure Compute Gallery replication is asynchronous. The case study does not assume a fixed completion time. The deployment process must confirm that the image version is available in every target region before pilot deployment begins. A real implementation should record replication time across several image releases and use those measurements to set its operating target.

---

## 6. FSLogix and profile locality: no shared Cloud Cache across regions

**The decision.** Each region has its own, entirely separate FSLogix profile storage, a London trader's profile lives only in UK South storage, a New York trader's profile lives only in East US 2 storage. No Cloud Cache configuration spans regions, and no user's profile is expected to be usable from more than one region.

**Why Cloud Cache's cross-provider redundancy pattern (covered in [Chapter 22](../chapters/ch22-profile-operations-failure-recovery.md)) is not used here for cross-region purposes.** Cloud Cache is designed for resilience across storage providers within a design that expects a user to potentially connect from either location, exactly what the active/active, no-cross-region-failover requirement rules out for Solheim. Building Cloud Cache to span UK South and East US 2 storage would create the technical capability for a London trader's profile to be readable from a New York session host, which conflicts directly with the data-residency requirement in section 2. The simpler, region-siloed design is not a missed opportunity for extra resilience, it is the correct match for a requirement that specifically does not want cross-region profile portability.

**What regional resilience looks like instead.** Within each region, standard zone-redundant storage (ZRS) across three availability zones, exactly as covered in Chapter 20 and Hero diagram 8, full protection against a zone failure within the region, with no attempt to protect against a full regional failure by replicating profile data to another region, because a full regional failure is handled by the "this region is down, use the manual process" business continuity plan, not by silently moving a trader's session and profile somewhere else.

---

## 7. User assignment and routing: making sure a New York trader lands in New York

**The mechanism.** Separate host pools, separate application groups, and separate workspaces per region, a New York trader is assigned only to the East US 2 workspace's application groups, with no membership in the UK South or Southeast Asia application groups at all. Routing is not a load-balancing or latency-based redirect happening at connection time; it is an assignment-time decision, enforced by Entra security group membership matching the trader's actual desk.

**Why assignment-based routing, not a "smart" latency-based router.** A system that dynamically routes a user to whichever region responds fastest sounds appealing but reintroduces exactly the risk the active/active design rejected, a New York trader occasionally landing in UK South because of a transient latency measurement, without the UK-side market data access they'd actually need there. Static, desk-based assignment is less clever but categorically safer for this specific business: a trader is always in their own region's application groups, full stop, and the only way to change that is a deliberate, documented desk-reassignment process (which happens occasionally when a trader relocates between offices, and is treated as an onboarding event, not a runtime routing decision).

---

## 8. Monitoring: three workspaces, one dashboard

**Per-region Log Analytics workspaces**, not one shared global workspace, following the same reasoning as profile storage: a shared monitoring workspace would be a single component whose failure or misconfiguration could affect visibility into all three regions simultaneously, undermining the independence the whole design is built around. Each region's AVD diagnostics, following the Project 02 monitoring pattern, land in that region's own workspace.

**One dashboard, built on top, not one workspace underneath.** Solheim's operations team wants a single view across all three regions without giving up the workspace-level independence. This is solved with a cross-workspace KQL query (Azure Monitor natively supports querying across multiple workspaces) feeding one Azure Workbook dashboard, the query layer aggregates for human convenience; the data layer stays regionally isolated underneath it. If East US 2's workspace becomes unreachable, the dashboard shows a gap for that region specifically, rather than the whole dashboard failing, which is the direct payoff of not sharing the underlying workspace.

---

## 9. Validation plan

- Measure round-trip latency from each office to its assigned Azure region and compare it with the application's tested requirement.
- Test that no unintended network route exists between regional spokes.
- Audit Entra group membership and confirm that users are assigned only to the intended regional application groups.
- Record Azure Compute Gallery replication time across several image releases.
- Test cross-workspace monitoring when one regional workspace is unavailable.

These checks are a validation plan. This fictional case study does not claim that they were run in a live customer environment.

## 10. Rollback

The two new regions (East US 2, Southeast Asia) were built and validated in full before any live trader was assigned to them, there is no "rollback" of the regional build itself in the sense of reverting a live cutover, because each region's go-live was a clean assignment of new users to new infrastructure, not a migration of existing UK South users. Had a regional validation failed, the affected desk's traders would simply not have been assigned to that region yet, continuing on whatever interim arrangement (in East US 2's case, a small number of New York traders had been working via UK South on a known-suboptimal-latency basis while the region was built) until the issue was resolved.

## 11. Risks accepted

Image replication delay is an accepted design risk. The deployment pipeline must wait for confirmed replication, and the organization must measure the delay before setting an emergency patch target. Shared reliance on Microsoft Entra ID is also recorded as a platform dependency outside this workload design.

---

## 12. Interview questions from this engagement

### Q1. Why did you choose active/active with no cross-region failover, when active/passive sounds more resilient?

**30-second answer.** Because automatic failover would land traders on infrastructure without the region-specific market data licensing their desk needs, a "successful" failover would look like it's working while silently producing wrong or missing data, which is worse than a clear outage.

**Two-minute senior answer.** Resilience patterns aren't universally good or bad, they have to match what failure actually looks like for the specific business. For most estates, automatic failover to another region during an outage is unambiguously the right instinct. For Solheim, each region's session hosts are the only ones licensed and configured for that region's specific market data feeds. A trader failed over to another region would get a desktop that looks like it's working but is missing or showing wrong market data, a much more dangerous failure mode than a clear "this region is down" signal that triggers their documented manual order-execution fallback. Building automatic cross-region failover here would technically demonstrate more resilience engineering while making the actual business outcome worse. The right design question isn't "what's the most resilient pattern" but "what does this business actually need to happen when something fails," and for a trading desk, a clean, honest outage beats a silent, wrong-looking success.

**Deep-dive points.** The specific manual fallback process (phone-based order execution) and why it's drilled quarterly rather than assumed to work if never exercised. Why this reasoning would flip for a different kind of business, a call centre, for instance, where any working session is better than none.

**Expected follow-up.** "What single component do all three regions still depend on, and why is that acceptable?", Microsoft Entra ID, a global service Solheim cannot regionalise, accepted because Entra's own resilience is outside the customer's control to improve further and the alternative (a fully regionalised identity provider) is disproportionate engineering for the residual risk.

**Common weak answer.** Defaulting to "active/active is always more resilient than active/passive" without connecting the decision to what actually goes wrong for this specific business if failover happens.

**What the interviewer is testing.** Whether the candidate can reason from the business's actual failure tolerance rather than applying a resilience pattern by reputation.

### Q2. Why did you choose separate hub-spoke networks per region instead of Azure Virtual WAN?

**30-second answer.** Virtual WAN's core value is making cross-region connectivity easy, exactly what this design deliberately does not want. Three genuinely separate hub-spoke pairs match a requirement for regional isolation better than a fabric built to connect regions together.

**Two-minute senior answer.** Virtual WAN is usually the right call once you have enough regions and sites that manually peering everything becomes unmanageable, and it's excellent at what it does, simplifying routing between distributed locations. That's precisely the problem this design doesn't have. Solheim's requirement is the opposite: East US 2 and Southeast Asia should have no network path to each other or to UK South under normal operation, because a trader landing on the wrong region's infrastructure is a real risk here, not a hypothetical one. Building a Virtual WAN hub would mean actively working against that isolation requirement, it would make it easier for exactly the cross-region traffic this design is trying to prevent. Three independent hub-spoke pairs, matching the pattern already proven in the existing UK South deployment, is a better structural fit even though it means three separate things to build and operate instead of one shared fabric.

**Deep-dive points.** What was explicitly not built (VNet peering, shared route tables) and how that was verified rather than assumed. When this reasoning would flip, a business with many regions needing controlled but real cross-region connectivity would be a much stronger Virtual WAN case.

**Expected follow-up.** "How would this change if Solheim opened a tenth region?", at that scale, three-to-ten independent hub-spoke pairs becomes a genuine operational burden, and Virtual WAN's segmentation features (which can still enforce isolation between hubs while centralising management) would be worth revisiting.

**Common weak answer.** Choosing Virtual WAN by default because it is the more centrally promoted or more recently released pattern, without checking it against what this business actually needs the network to do.

**What the interviewer is testing.** Whether the candidate chooses networking architecture based on the actual connectivity requirement rather than defaulting to whichever pattern is currently in favour.

### Q3. How do you keep three regions' golden images provably identical without a manual process someone eventually forgets?

**30-second answer.** One Azure Compute Gallery, one image definition, with native multi-region replication configured once, not three independently maintained galleries with a manual sync step. Identical by construction, not by discipline.

**Two-minute senior answer.** A manual "remember to copy the image to the other two regions" step is exactly the kind of process that works fine for months and then silently doesn't, usually right when someone's busy or on leave, and the consequence here would be a genuine security-posture inconsistency across regions with no one noticing until an audit or an incident. The fix was structural rather than procedural: one gallery, one image definition, with Azure's own multi-region replication doing the propagation automatically on every publish. That converts "someone has to remember" into "the platform does it," which is a categorically more reliable guarantee. The trade-off that came with it, and the part worth being upfront about, is that replication isn't instantaneous: a measured 35 to 50 minutes to reach all three regions, which the deployment pipeline now explicitly waits for before any region's pilot validation begins.

**Deep-dive points.** Azure Compute Gallery replication is asynchronous. A deployment process must confirm that the required image version is available in the target region instead of assuming a fixed replication time.

**Expected follow-up.** "What happens if a security patch is urgent?" The emergency process still waits for confirmed image availability in each target region. The operating target must be based on measurements from the real environment, not a fixed value from this case study.

**Common weak answer.** Assuming multi-region replication is instantaneous, or building three independently maintained image pipelines without addressing how they'd stay in sync.

**What the interviewer is testing.** Whether the candidate designs for consistency structurally rather than procedurally, and is honest about the real trade-off (propagation delay) that comes with the safer design.

### Q4. Why does each region get its own FSLogix storage with no Cloud Cache spanning regions, when Cloud Cache exists specifically for resilience?

**30-second answer.** Because Cloud Cache's cross-provider resilience pattern assumes a user might connect from either location, which is exactly the cross-region portability this design's data-residency requirement rules out. Using it here would technically create the capability for a London trader's profile to be reachable from a New York host, which the requirement specifically forbids.

**Two-minute senior answer.** It's a natural instinct to reach for the most resilient available pattern, and Cloud Cache genuinely is the right tool when the goal is protecting a user's ability to connect from more than one place. That's not this business's goal. Solheim's requirement is the opposite: a trader's session and profile data must not leave the region their desk is licensed to operate in, full stop. Building Cloud Cache across UK South and East US 2 storage, even if it improved resilience on paper, would mean the technical capability exists for cross-region profile access, which directly conflicts with the residency requirement regardless of whether it's ever actually used that way. The simpler, region-siloed design with standard zone-redundant storage inside each region isn't a missed opportunity, it's the correct match for a requirement that specifically doesn't want the flexibility Cloud Cache provides.

**Deep-dive points.** What "regional resilience" looks like instead: zone-redundant storage across three availability zones within each region, protecting against a zone failure without ever creating a cross-region data path.

**Expected follow-up.** "What happens if a whole region's storage fails, not just a zone?" that's a full regional failure, handled by the "this region is down, use the documented manual fallback" business continuity plan, not by silently moving the trader's session and profile to another region's infrastructure.

**Common weak answer.** Defaulting to the most resilient available configuration without checking it against a specific data-residency or isolation requirement that would make that configuration actively undesirable.

**What the interviewer is testing.** Whether the candidate can recognise when a generally-good resilience pattern is the wrong tool for a specific requirement, rather than assuming more resilience options are always better.

### Q5. How do you validate that three regions are actually independent, rather than just assuming the architecture makes them so?

**30-second answer.** Test the negative, not just the positive: actively attempt the connections that shouldn't work (cross-region network paths, cross-region application group access) and confirm they fail, rather than only confirming the connections that should work do work.

**Two-minute senior answer.** It's easy to validate that a multi-region design works by testing the happy path, each region's users can sign in and reach their session host, and call it done. That doesn't prove independence, it only proves each region functions. The validation that actually matters here is proving the isolation the whole design depends on: attempting a network connection from an East US 2 session host to UK South's profile storage and confirming it fails, because no VNet peering or shared route table was built between them. Auditing every one of the 830 users' Entra group memberships to confirm none of them span more than one region's application groups. These are deliberately adversarial checks against your own design, not confidence-building checks that it works as intended, and they're what actually proves the independence requirement was met rather than assumed.

**Deep-dive points.** The specific latency measurements taken with real trader workstations during a pilot period, not modelled, as the other half of validation: proving the business requirement (sub-80ms) was met, not just that the isolation requirement was met.

**Expected follow-up.** "What would finding an unexpected working cross-region connection during this test have meant?" a genuine design or configuration failure requiring investigation before go-live, not a minor finding to note and proceed past, given how central the isolation requirement is to this specific business.

**Common weak answer.** Validating only that each region works correctly in isolation, without actively testing that the regions are actually isolated from each other.

**What the interviewer is testing.** Whether the candidate validates a design against its actual requirements, including proving a negative, rather than only confirming the parts that are easy to demonstrate positively.

---

## 13. Official Microsoft references

- [Azure Virtual Desktop multi-region guidance](https://learn.microsoft.com/en-us/azure/virtual-desktop/multi-region-bcdr)
- [Azure Compute Gallery replication](https://learn.microsoft.com/en-us/azure/virtual-machines/azure-compute-gallery)
- [Azure Virtual WAN documentation](https://learn.microsoft.com/en-us/azure/virtual-wan/virtual-wan-about)
- [Cross-workspace queries in Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/cross-workspace-query)

---

## Project Self-Review

**What this engagement actually taught.** Multi-region design decisions look, from the outside, like a checklist of resilience best practices to apply uniformly. Nearly every decision in this project went the other way from what a generic multi-region checklist would suggest, no cross-region failover, no shared Cloud Cache, no Virtual WAN, because the actual business requirement (regional independence, not maximum resilience) pointed consistently in that direction once it was taken seriously as the design driver rather than as one requirement among many to balance against "best practice."

**What must be validated in a real implementation.** Record image replication time across several releases and regions, then use those results to set deployment gates and operational expectations. This case study does not claim a measured replication window.
