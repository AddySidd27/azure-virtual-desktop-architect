# Project 14 - Corrigan Insurance: Business Continuity and Disaster Recovery for AVD

> **Fictional architecture case study:** Corrigan Insurance is not a customer delivery record. Requirements, measurements, costs, tests, and outcomes are worked examples or validation targets unless separate lab evidence is linked.

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Part XI:** Architecture Case Studies
> **Standard:** [PROJECT-STANDARD.md](../PROJECT-STANDARD.md)
> **Technical baseline:** August 2026
> **Concepts introduced here:** Business impact analysis, RTO/RPO for AVD components, backup versus redundancy, DR runbook design and testing

---

## Engagement brief

**What this represents.** An insurance company that has AVD running well in production but has never actually tested what happens if a region fails, a very common gap, because DR is the work that only pays off on the one day nobody wants, and it is therefore the work that gets deferred behind every visible priority until a regulator, a board, or an actual near-miss forces the question.

**The business problem.** Corrigan's cyber insurance renewal (an appropriately on-the-nose detail for an insurance company) now requires evidence of a tested disaster recovery capability for systems handling claims processing, including AVD. "We have backups" is not evidence. The board wants a plan, a tested runbook, and a number: how long would claims processing actually be down if UK South had a real outage.

**Constraints that cannot be designed away.** The existing AVD environment (1,400 users, claims processing and customer service) runs in UK South only, built two years ago without DR consideration. Budget for DR infrastructure is real but bounded, the board will not fund an always-on, fully duplicate second region sitting idle, and asked the engagement to find the cheapest design that meets a defensible recovery target, not the most resilient design possible.

**Previously learned concepts applied.** Profile storage redundancy ([Chapter 20](../chapters/ch20-profile-storage-architecture.md)), golden image and Azure Compute Gallery ([Chapter 23](../chapters/ch23-golden-image-engineering.md)), Terraform infrastructure as code from every prior project, the active/active multi-region reasoning from [Project 13](project-13-multi-region-architecture.md), deliberately not reused unchanged here, because Corrigan's requirement is different, as section 3 explains.

**New concepts introduced here.** Business impact analysis as the thing that actually sets requirements, rather than picking a recovery target first and working backwards. RTO and RPO defined per component, not as one number for "AVD." The real distinction between backup and redundancy, and why Terraform recreates infrastructure but does not recover data. DR testing that produces evidence, not just a completed checklist.

**Architectural decisions to make.** Active/passive DR (a cold or warm standby region) versus the active/active pattern from Project 13, and why these are different problems with different right answers. What actually needs backing up versus what can simply be rebuilt from Terraform and Azure Compute Gallery. How much standby capacity to pre-provision against how much cost the board will accept.

**What could realistically go wrong.** A DR plan that looks complete on paper and has never been executed fails in ways nobody anticipated, exactly like the broken break-glass process in Project 11. The recovery target chosen doesn't match what the business impact analysis actually found, because it was set by gut feel before the analysis was done. Terraform recreates the infrastructure correctly in the DR test but nobody accounted for how long restoring the actual profile and application data takes, which is usually the real bottleneck, not the infrastructure.

**Validation and handover.** A DR test executed against the actual defined runbook, not a tabletop discussion, with a measured, evidenced recovery time compared against the target. A clear, board-presentable answer to "how long would we actually be down," backed by a test, not an estimate.

---

## 1. The situation as found

**Corrigan Insurance.** 1,400 users across claims processing (900, using a claims management system with significant compliance and audit requirements) and customer service (500, using a lighter application set). AVD deployed two years ago in UK South only, well-built for day-to-day operations but with zero DR design, no second region, no documented recovery process, no tested runbook.

**The business impact analysis, run before any technical design decision.** This is the step DR engagements most often skip or shortcut, and it is the step that actually determines what "recovery" needs to mean for this business.

| Function | Impact of 1 hour outage | Impact of 8 hour outage | Impact of 3 day outage |
|---|---|---|---|
| Claims processing | Minor, claims can be logged manually and entered later | Moderate, backlog builds, some claims deadlines (a regulatory 24-hour acknowledgement requirement) at risk | Severe, regulatory breach on acknowledgement deadlines, customer-facing reputational harm |
| Customer service | Minor, calls can be handled with a fallback paper process | Moderate, customer complaints rise, but no regulatory exposure | Moderate, sustained customer dissatisfaction, no hard regulatory deadline |

**What this table actually determined, before any infrastructure was designed.** Claims processing's regulatory 24-hour acknowledgement requirement is the number that matters, not a generic "how fast do we want to recover" instinct, but a specific, externally imposed deadline. This is why the recovery target set in section 2 is what it is, and it is the direct output of this table, not a number chosen first and justified afterward.

---

## 2. RTO and RPO, set per component, not as one number for "AVD"

**Why one number for the whole platform is the wrong starting point.** "AVD's RTO is 4 hours" sounds precise and is actually meaningless, because AVD is not one thing that recovers uniformly: the control plane, the session hosts, the profile data, and the application data all have different recovery characteristics and different acceptable loss windows. Setting one number forces a false choice between over-engineering the easy-to-recover parts and under-engineering the hard ones.

| Component | RTO (time to recover) | RPO (acceptable data loss) | Reasoning |
|---|---|---|---|
| AVD control plane | Not applicable, Microsoft managed | Not applicable | No customer action required or possible; this is Microsoft's SLA, not Corrigan's design problem |
| Session hosts and host pool | 2 hours | Not applicable, stateless, rebuilt from image | Recreated from Terraform and Azure Compute Gallery; no data to lose because none is stored here by design |
| Golden image | 0 hours (already replicated) | 0 | Azure Compute Gallery multi-region replication, set up proactively per section 5, means the image is already present in the DR region before an incident, not recovered during one |
| FSLogix profile data | 4 hours | 24 hours | Matches the claims-processing regulatory deadline from the business impact analysis; profile loss of up to a day's changes is judged acceptable against that deadline, discussed and explicitly signed off by the claims operations lead, not assumed |
| Claims application data | Outside AVD's scope | Outside AVD's scope | Owned by the claims management system's own DR plan, which predates this engagement; AVD's plan explicitly references but does not duplicate it |

**The 4-hour session-host RTO, justified against the regulatory deadline, not chosen arbitrarily.** The business impact analysis flagged the 24-hour regulatory acknowledgement window as the hard constraint. A 4-hour target for the platform to be usable again leaves 20 hours of runway for claims staff to clear any backlog before the regulatory deadline is at risk, a defensible margin, presented to the board with that specific reasoning rather than as a number that simply sounded appropriately urgent.

---

## 3. Active/passive DR, and why this is a different problem from Project 13's active/active design

**The decision.** East US 2 as a warm-standby DR region for UK South, activated only during a declared regional incident, not a second independently-active production region.

**Why this is not the same decision as Project 13, even though both projects involve a second Azure region.** Project 13's business (a trading firm) needed three regions genuinely operating simultaneously, each serving real live users all the time, with no acceptable cross-region failover. Corrigan needs the opposite: one production region, and a recovery capability for when that region fails, that does not need to be independently staffed and operated as its own live environment day to day. Building Project 13's active/active pattern for Corrigan would mean permanently running and paying for a second full production environment that sits unused 99.9% of the time relative to its cost, directly against the board's explicit instruction to find the cheapest design meeting the recovery target, not the most resilient design achievable.

**What "warm standby" means concretely, not just as a label.** The East US 2 region has its network (hub-spoke, matching UK South's pattern), its Azure Compute Gallery image already replicated (see section 5), and its Terraform configuration ready to apply. But it has zero running session hosts and zero live FSLogix storage account provisioned, until a DR event is declared. This is the specific cost lever that makes the design affordable: the standing cost of the DR region between incidents is close to zero (a VNet, a storage account definition not yet provisioned, an image sitting in the gallery), and the 2-hour session-host RTO target is met by standing up compute from Terraform on declaration, not by keeping it running and billing continuously.

---

## 4. Backup versus redundancy, the distinction this engagement is built around

**Redundancy** protects against a component failing while the rest of the system stays healthy: zone-redundant storage protecting against one availability zone going down, which Corrigan's UK South environment already has, correctly, from its original build. **Backup** protects against the primary copy of data being lost, corrupted, or unavailable entirely, including scenarios redundancy does not cover: a ransomware event that encrypts data across all zones simultaneously, or the entire region becoming unavailable, which is exactly the scenario this DR engagement is built for.

**Why this distinction matters concretely for Corrigan.** The original build's zone-redundant FSLogix storage is genuine redundancy and was, before this engagement, being treated by Corrigan's IT team as if it were also a DR solution, a common and understandable confusion, since both sound like "the data is protected." Zone redundancy does nothing if UK South as a whole becomes unavailable; all three zones are still in the same region. This engagement's core technical contribution is adding actual backup, Azure Backup for the FSLogix storage account, replicating profile container snapshots to the East US 2 region on a schedule matching the 24-hour RPO, which the original build genuinely did not have, despite appearing protected.

**Terraform recreates infrastructure. It does not recover data. This is stated explicitly, not implied.** A common and dangerous assumption on DR engagements is that because the environment is built with Terraform, "redeploying from Terraform" is the recovery plan. Terraform will faithfully recreate an empty host pool, empty storage accounts, and correctly configured networking in East US 2 within the 2-hour session-host RTO, and produce a fully functional environment with zero user profiles in it, because Terraform has no knowledge of and no role in recovering the FSLogix profile data that lived in UK South's storage account. The actual recovery sequence is Terraform first (infrastructure), then Azure Backup restore second (data), two different tools solving two different problems, sequenced deliberately, not one tool assumed to cover both.

---

## 5. Azure Compute Gallery replication, proactive not reactive

Following the same mechanism established in [Project 13](project-13-multi-region-architecture.md#5-image-replication-and-the-propagation-time-trade-off), Corrigan's golden image gallery replicates automatically to East US 2 on every publish, but here the reasoning is different. Project 13 needed replication because both regions are live simultaneously. Corrigan needs it so that, on the day of a declared DR event, the image is already present in East US 2 and does not need to be rebuilt or transferred under incident pressure, which would add an unpredictable delay directly onto the 2-hour session-host RTO. This is a small, low-cost, always-on piece of the DR design (gallery replication costs relatively little to keep running continuously) purchased specifically to remove a variable-and-potentially-large delay from the recovery timeline.

---

## 6. Terraform-based infrastructure recovery

**The DR Terraform configuration is a variant of the production module set, not a separately maintained fork.** The same modules used in Project 03's pattern build the DR region's infrastructure, parameterised for East US 2 instead of UK South, version-pinned to the same module release the production environment currently runs, deliberately avoiding a second, independently drifting Terraform codebase that would itself become an untested, unreliable part of the recovery path.

**What is pre-provisioned versus provisioned on declaration.** Pre-provisioned, standing: the East US 2 VNet, subnets, NSGs, and the Azure Compute Gallery image replica. Provisioned only on DR declaration: the session host VMs, the host pool object, the workspace and application groups, and the FSLogix storage account (created empty by Terraform, then populated by the Azure Backup restore step). This split is the direct implementation of the "warm, not hot" standby cost decision from section 3, everything cheap to leave running stays running; everything that costs real money only exists once an incident is actually declared.

**Capacity reservation.** East US 2's regional VM capacity for Corrigan's session host SKU is confirmed, not assumed, via an Azure Capacity Reservation for a baseline number of session hosts (60% of production capacity, matched to the reduced-but-functional headcount the business impact analysis judged acceptable during a declared incident), because discovering during an actual regional outage that the DR region also cannot obtain the needed VM capacity, because every other affected customer is requesting the same SKU in the same region at the same time, would be a DR-plan failure discovered at the worst possible moment.

---

## 7. The DR runbook

A structured, evidence-first runbook, not a narrative document, written so that whoever is on call during an actual incident can execute it under pressure without needing to have memorised it.

1. **Declare.** Confirm UK South is genuinely unavailable (not a single application issue mistaken for a regional one) via Azure Service Health, and get sign-off from the named Incident Commander role before proceeding, a DR declaration is a real cost and business decision, not a default reaction to any alert.
2. **Provision infrastructure.** Run the DR Terraform configuration against East US 2. Target: complete within 90 minutes, leaving margin inside the 2-hour session-host RTO.
3. **Restore data.** Trigger the Azure Backup restore of the most recent FSLogix profile snapshot into the newly provisioned East US 2 storage account. Target: complete within the remaining window to meet the overall 4-hour profile-data RTO.
4. **Validate.** A named validation team (not the same people who ran steps 2-3) signs into a sample of restored profiles and confirms application access, before the "we are recovered" declaration goes to the business.
5. **Communicate.** A pre-written, pre-approved status update template goes to claims and customer service leadership at each stage (declared, infrastructure ready, data restored, validated), so the business side of the house has real-time visibility without needing to ask.
6. **Operate in DR.** Reduced-capacity operation (the 60% capacity reservation) continues until UK South is confirmed recoverable.
7. **Failback.** A separate, deliberately distinct process, not simply running the runbook in reverse. Failback has its own risk (the two regions' data may have diverged during the incident) and its own validation requirements, and is covered as its own runbook, not assumed to be symmetrical with recovery.

---

## 8. DR testing: the step that actually generates evidence

**The test, run against the real runbook, not a tabletop walkthrough.** A full DR test was executed on a Saturday (chosen for minimal business impact, with claims and customer service leadership informed in advance and standing by, not blindsided). It genuinely provisioned the East US 2 environment from Terraform and genuinely restored an FSLogix backup snapshot, not a review of the plan's steps on paper.

**What the test measured, and what it found.**

| Runbook step | Target | Measured | Outcome |
|---|---|---|---|
| Declare |, | 8 minutes | Within expectation |
| Provision infrastructure (Terraform) | 90 minutes | 74 minutes | Better than target |
| Restore data (Azure Backup) | Remaining window to 4-hour total | 3 hours 40 minutes | **Exceeded the 4-hour total RTO by 22 minutes** |
| Validate |, | 25 minutes | Within expectation |

**The finding that mattered, and what was done about it.** The Azure Backup restore step, not the Terraform infrastructure step, was the actual bottleneck, the FSLogix profile data volume (1,400 users' worth of profile containers) took longer to restore than the initial estimate, which had been based on a smaller pilot dataset rather than the full production volume. This is presented honestly as a test finding, not hidden: the first DR test missed the target. The remediation (restructuring the backup to use incremental snapshots with a faster restore path for the most recently modified containers first, prioritising active users over dormant accounts) was implemented, and a second test, run two months later, completed the full sequence in 3 hours 15 minutes, inside the 4-hour target with a real margin.

**Why reporting the failed first test matters more than reporting only the successful second one.** A DR capability that passed its only test on the first attempt, with no adjustment needed, is a suspicious result for a process this complex, it usually means the test wasn't rigorous enough to find the real bottleneck. Finding a genuine gap, understanding why it existed, fixing it, and re-testing to confirm the fix is what makes the second test's result credible to the board and to the cyber insurance underwriter, in a way a single clean test would not have been.

---

## 9. Validation

- Full DR test executed twice, first identifying a genuine RTO miss, second confirming the fix with margin, both results documented and available as evidence for the insurance renewal.
- Capacity reservation confirmed active and covering 60% of production session host capacity in East US 2.
- Azure Backup restore tested against the actual production profile data volume, not a smaller representative sample, after the first test's finding that a smaller dataset had produced a misleadingly optimistic estimate.
- Failback runbook drafted and reviewed, though not yet live-tested, disclosed honestly as a remaining gap in section 11, not claimed as validated alongside the recovery runbook.

## 10. Rollback

DR infrastructure that is provisioned during a test (or a real incident, once resolved) is deliberately torn down afterward via the same Terraform configuration, run in destroy mode, returning East US 2 to its pre-provisioned, standing-cost-only state. This is the direct payoff of the warm-standby design: there is no expensive standing environment to roll back, only the pre-provisioned network shell, which was never changed and needs no rollback of its own.

## 11. Risks accepted, and the one honest gap

**Failback has not been live-tested**, only planned and reviewed on paper. The recovery runbook was tested rigorously because it is the higher-frequency, higher-stakes concern (a region failing is more likely and more urgent than needing to fail back cleanly afterward), but this is a genuine, disclosed gap, not something implied to be equally proven. It is scheduled as the next DR test cycle's focus.

**The 60% capacity reservation is a business-accepted reduction in service during a declared incident**, not a limitation of the technical design, Corrigan's leadership explicitly chose 60% capacity (prioritising claims processing headcount over customer service headcount within that 60%) as an acceptable trade-off against the cost of reserving 100% capacity that would sit unused except during a rare regional failure.

---

## 12. Interview questions from this engagement

### Q1. Your DR test missed its RTO target on the first attempt. How do you handle that?

**30-second answer.** Report it honestly, find the actual bottleneck, fix it, and test again before claiming the target is met. A DR test that always passes on the first attempt is more suspicious than reassuring, it usually means the test wasn't rigorous enough.

**Two-minute senior answer.** The instinct under pressure, especially with a board or an insurance renewal watching, is to want the test to pass. That instinct is exactly backwards for a DR test specifically, because the entire value of testing is finding the gap you didn't know about while it's still safe to find it. Here, the Terraform infrastructure step beat its target comfortably, which could have created false confidence that the whole runbook was fine. It was the data restore step, using a volume estimate from a smaller pilot dataset, that actually missed the target by 22 minutes. Reporting that honestly, understanding why the original estimate was wrong, fixing the actual bottleneck, restructuring the backup for a faster restore path, and then re-testing against the full production data volume is what turned an unverified plan into genuine evidence. A board or underwriter should trust the second test's result more, not less, because they can see the process found and fixed a real problem rather than passing by luck or by testing something easier than the real scenario.

**Deep-dive points.** Why the pilot dataset underestimated restore time (smaller volume, likely different snapshot fragmentation characteristics than 1,400 users' worth of active profile churn). Why the fix prioritised active users' data first rather than a uniform restore approach.

**Expected follow-up.** "How would you present the first failed test to the board?" Directly: with the specific gap, the fix, and the second test's result, not glossed over or omitted from the evidence package.

**Common weak answer.** Treating a failed DR test as something to quietly fix and only report the passing result, without disclosing that a real gap existed and was found.

**What the interviewer is testing.** Whether the candidate understands that DR testing's value comes specifically from finding real gaps, and has the professional honesty to report an inconvenient result rather than only a reassuring one.

### Q2. Why is "we use Terraform, so we can just redeploy" not a complete disaster recovery plan?

**30-second answer.** Terraform recreates infrastructure, empty host pools, empty storage accounts, correct networking. It has no knowledge of and no role in recovering the actual data that lived in that infrastructure, like FSLogix profiles. Redeploying with Terraform alone gets you a perfectly configured environment with nobody's data in it.

**Two-minute senior answer.** This is one of the most common DR misconceptions on Infrastructure-as-Code estates, and it's dangerous because it's half right, Terraform genuinely is the right tool for the infrastructure half of recovery, and it performed well in this engagement's testing. The mistake is assuming infrastructure recovery and data recovery are the same problem, because they get conflated on a healthy day-to-day system where Terraform manages everything you interact with. On the actual DR day, Terraform gives you back a host pool, session hosts, and a storage account, correctly configured. But the storage account is empty. The 1,400 users' FSLogix profiles that lived in the original storage account are a completely separate recovery problem, solved here with Azure Backup, sequenced explicitly after the Terraform step, not assumed to happen automatically because "it's all Terraform." The DR runbook treats these as two distinct steps with two distinct tools for exactly this reason, and the test's real finding, that the data-restore step, not the infrastructure step, was the actual bottleneck, is the concrete proof of why the distinction matters in practice, not just in theory.

**Deep-dive points.** The specific sequencing (Terraform first, then Azure Backup) and why reversing it wouldn't work (nowhere to restore data into until the storage account exists). Why zone-redundant storage, which the original build already had, is not the same protection as cross-region backup.

**Expected follow-up.** "What data, if any, doesn't need a separate backup plan because Terraform genuinely does cover it?" The golden image, which through Azure Compute Gallery replication is already a form of cross-region data protection, distinct from the Terraform *configuration* that deploys it.

**Common weak answer.** Describing Terraform as "the DR plan" without distinguishing infrastructure state from data, or without naming what specific data recovery mechanism handles what Terraform does not.

**What the interviewer is testing.** Whether the candidate understands the actual boundary of what Infrastructure as Code does and does not solve, rather than treating it as a complete answer to disaster recovery.

### Q3. How do you set an RTO when the business hasn't told you what "acceptable downtime" means?

**30-second answer.** You don't guess it and you don't ask that question directly, because most stakeholders can't answer it in the abstract. You run a business impact analysis: what actually happens at 1 hour, 8 hours, 3 days of an outage, per function, and the real target falls out of that table rather than being chosen first.

**Two-minute senior answer.** Asking a business leader "what's your acceptable downtime" tends to produce either an unhelpfully vague answer or a reflexively aggressive one, "zero," that isn't actually load-bearing once you probe it. What worked here was asking instead about consequences at specific time horizons for each business function, separately, which surfaced that claims processing's real constraint wasn't a general sense of urgency, it was a specific, externally imposed 24-hour regulatory acknowledgement deadline. That single fact, found in the business impact table rather than guessed at, is what justified the 4-hour session-host RTO: not because 4 hours felt appropriately urgent, but because it left a defensible 20-hour margin against a deadline that actually mattered. A recovery target with that kind of paper trail survives a board or an underwriter asking "why 4 hours and not 2, or not 8" in a way a gut-feel number doesn't.

**Deep-dive points.** Why customer service, the other function assessed, got a materially different (looser) target, because it lacked claims processing's regulatory deadline, and why that's the correct outcome rather than a compromise.

**Expected follow-up.** "What if two functions on the same platform have very different RTOs?" design and cost the recovery around the tighter one where they share infrastructure, and treat the looser one as recovering incidentally alongside it, rather than trying to justify two different recovery speeds for shared infrastructure.

**Common weak answer.** Picking a recovery target that sounds appropriately serious without tracing it back to a specific, defensible business consequence.

**What the interviewer is testing.** Whether the candidate derives recovery targets from actual business impact analysis rather than intuition, and can defend the specific number chosen with a specific reason.

### Q4. Your board won't fund a fully duplicate always-on second region. How do you still meet a defensible recovery target?

**30-second answer.** Warm standby, not hot: pre-provision the cheap, standing parts (network, replicated image) and stand up the expensive parts (compute, live storage) only on actual declaration. The 2-hour infrastructure RTO comes from Terraform speed, not from keeping a second environment running and billing continuously.

**Two-minute senior answer.** The instinct when a board says "we want this recoverable but we won't pay for a duplicate environment" can be to treat those as contradictory requirements and push back on one of them. They're not contradictory if the design separates what's cheap to leave standing from what's expensive to run, and only pre-provisions the former. Here, the DR region's network, subnets, NSGs, and its replicated golden image cost very little to leave running permanently. The session hosts, the live host pool, and the populated storage account, the genuinely expensive parts, only get created when a DR event is actually declared, and Terraform's speed at doing that reliably is what makes a warm rather than hot standby meet a real recovery target instead of just a theoretical one. The capacity reservation for 60% of production compute is the one piece of that design that does cost something standing, and it's there specifically because discovering you can't get the VM capacity you need during an actual regional outage, when everyone else affected wants the same SKU in the same region, is a failure mode worth paying to prevent.

**Deep-dive points.** The specific pre-provisioned versus provisioned-on-declaration split, and why the capacity reservation was judged worth its standing cost while the compute itself wasn't.

**Expected follow-up.** "What's the actual cost difference between this warm-standby design and a fully duplicate active region?" the warm design's standing cost is close to zero between incidents versus a duplicate environment's near-100%-of-production standing cost, which is the entire basis on which the board approved this design over the alternative.

**Common weak answer.** Either accepting a much looser RTO because "we can't afford proper DR," or quietly proposing a fully duplicate environment anyway and hoping the cost gets approved.

**What the interviewer is testing.** Whether the candidate can find a genuinely cost-proportionate design rather than treating budget constraints and recovery targets as an unresolvable conflict.

### Q5. Your DR runbook has a recovery process. Does it need a separate failback process, or can you just run recovery in reverse?

**30-second answer.** A separate process. Failback has its own risk, the two regions' data may have diverged during the incident, and its own validation requirements, and treating it as symmetrical with recovery is exactly the kind of untested assumption that DR testing exists to catch.

**Two-minute senior answer.** Failback is not simply failover in the opposite direction. Users and applications can change data while the recovery region is active. Before returning service to the primary region, the recovery plan must define how that data is synchronized, checked, and protected from loss or conflict. This case study designs recovery and failback as separate procedures. Neither procedure is presented as live tested. A real implementation requires a timed exercise with recorded results before the recovery capability can be treated as validated.

**Deep-dive points.** The specific data-divergence risk failback has to account for, and why it doesn't exist in the same way for the initial recovery direction (recovering into an empty DR environment has no conflicting data to reconcile).

**Expected follow-up.** "Why prioritise testing recovery over testing failback, given both are part of the DR capability?" recovery is both more frequency-likely to be needed and more time-critical when it is; failback, while still important, has more slack in when it needs to be proven correct.

**Common weak answer.** Assuming failback is symmetrical with recovery and doesn't need its own distinct runbook or its own test.

**What the interviewer is testing.** Whether the candidate recognises failback as a genuinely different problem from recovery, with its own risks, rather than an automatic mirror image of the process that got you into the DR region in the first place.

---

## 13. Official Microsoft references

- [Azure Virtual Desktop business continuity and disaster recovery](https://learn.microsoft.com/en-us/azure/virtual-desktop/disaster-recovery)
- [Azure Backup for Azure Files](https://learn.microsoft.com/en-us/azure/backup/azure-file-share-backup-overview)
- [Azure Compute Gallery replication](https://learn.microsoft.com/en-us/azure/virtual-machines/azure-compute-gallery)
- [On-demand capacity reservation in Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/capacity-reservation-overview)

---

## Project Self-Review

**What this engagement actually taught.** The business impact analysis, done properly before any infrastructure decision, is what made every later choice defensible, the 4-hour RTO, the warm-standby cost model, the 60% capacity reservation all trace back to that table, not to an architect's judgement call. The other genuine lesson is the DR test itself: the infrastructure half of the recovery (Terraform) worked essentially perfectly on the first attempt, and it was the data half (backup restore) that had the real, unglamorous bottleneck nobody had scoped properly because the pilot test data didn't represent production volume. That is a very typical DR-test finding pattern, not specific to this engagement, and worth carrying into every future DR project as a place to look hard, early.

**What would be done differently with more time.** Failback remains untested, which is the honestly disclosed gap in this report. Given the choice to prioritise one test over the other within the engagement's timeline, prioritising the recovery runbook over failback was the right call, but a longer engagement would have scheduled a third test cycle specifically for failback before calling the DR capability complete, rather than handing it over with that gap still open.
