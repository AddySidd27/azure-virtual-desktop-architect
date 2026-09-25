# Project 12 - Falkirk Logistics Group: Citrix to AVD Migration

> **Fictional architecture case study:** Falkirk Logistics Group is not a customer delivery record. Requirements, measurements, costs, tests, and outcomes are worked examples or validation targets unless separate lab evidence is linked.

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Part XI:** Architecture Case Studies
> **Standard:** [PROJECT-STANDARD.md](../PROJECT-STANDARD.md)
> **Technical baseline:** August 2026
> **Concepts introduced here:** Brownfield migration methodology, Citrix-to-AVD component mapping, application assessment at scale, parallel-run design

---

## Engagement brief

**What this represents.** A logistics company running Citrix Virtual Apps and Desktops on-premises, whose datacentre hardware refresh cycle and Citrix licence renewal land in the same quarter, the point at which many Citrix-to-AVD migrations actually get authorised, not because Citrix has failed but because the business case for staying converges with a natural decision point.

**The business problem.** The on-premises hypervisor hardware supporting Citrix is five years old and due for replacement at a cost the CFO has already flagged as hard to justify against a cloud alternative. The Citrix Virtual Apps and Desktops licence renewal is due in the same quarter. 1,650 users, across warehouse operations, dispatch, and back-office finance, depend on this platform daily. A failed migration is not an abstract risk: it stops trucks moving.

**Constraints that cannot be designed away.** The migration must complete before the hardware reaches end of vendor support, which sets a hard six-month deadline. Warehouse operations run three shifts and there is no maintenance window that doesn't affect someone actively working. 40 published applications exist in Citrix Studio; nobody currently has a complete, accurate list of which are still used, by whom, and how often. That discovery work is itself part of this engagement, not a precondition someone else has already done.

**Previously learned concepts applied.** Host pool design ([Chapter 15](../chapters/ch15-host-pool-design-decisions.md)), application delivery strategy ([Chapter 25](../chapters/ch25-application-delivery-remoteapp-design.md)), App Attach in practice from [Project 10](project-10-remoteapp-line-of-business.md), profile design ([Chapters 19-22](../chapters/ch19-why-profiles-cause-avd-failure.md)), scaling from [Project 07](project-07-call-centre-high-density.md).

**New concepts introduced here.** How to discover and assess a live Citrix estate rather than take its documentation at face value, the concrete component-by-component mapping from Citrix to AVD and Intune, migrating FSLogix from Citrix Profile Management, planning a parallel run that doesn't double the operational burden, and running migration waves that fail safely.

**Architectural decisions to make.** Whether every published application migrates as-is or whether this is also the moment to retire the ones nobody uses. Persistent versus non-persistent workload mapping, Citrix's PVS/MCS non-persistent model does not map onto AVD in one obvious way. Migration wave sequencing: by department, by application, or by risk.

**What could realistically go wrong.** An application that works in Citrix fails silently in AVD because of a driver, a licensing check tied to a hardware fingerprint, or a printing dependency nobody documented. The parallel run becomes permanent because cutting over the last stubborn group of users keeps getting deferred. A migration wave goes wrong during a live shift because the wave boundary didn't account for shift patterns.

**Validation and handover.** Every one of the retained applications proven working in AVD by the actual users who depend on it, not by IT alone. Citrix fully decommissioned on schedule, not left running "just in case" past its supported hardware life. An operations team trained on AVD's genuinely different day-2 model, not assuming Citrix habits transfer unchanged.

---

## 1. The situation as found

**Falkirk Logistics Group.** 1,650 users across a distribution centre (900 warehouse and dispatch staff, three shifts) and a head office (750 back-office and management staff, standard hours). Citrix Virtual Apps and Desktops 7 2402, on-premises, two hypervisor hosts (VMware) running MCS-provisioned non-persistent desktops for warehouse staff and PVS-provisioned desktops for head office.

**What the discovery phase found, not what Citrix Studio's published-application list claimed.**

| Citrix component | Documented state | Actual state, discovered |
|---|---|---|
| Published applications | 40 in Citrix Studio | 40 published, but usage telemetry (pulled from Citrix Director's historical reporting) showed only 27 launched in the past 90 days |
| Delivery Groups | 6, one per department | 6 documented, but two had been manually edited outside the documented change process and no longer matched their original design intent |
| StoreFront | Single site | Single site, but with a legacy secondary store still configured and unused, left over from a prior migration that was never fully cleaned up |
| Profile management | Citrix Profile Management, on-premises file server | Confirmed working, but profile sizes for warehouse staff averaged 40 MB (mostly printer and application settings) versus 380 MB for back-office staff (Outlook cache, mapped drives cached locally) |

**The 13 unused applications.** Confirmed unused via 90-day launch telemetry, then individually verified with each department head before being marked for retirement rather than migration, telemetry alone can be wrong (a quarterly-use application with a 90-day window that missed its one use case), so this was a two-step confirmation, not a single data point acted on alone.

---

## 2. Business and technical requirements

**Business requirements.** Migration complete before Citrix hardware reaches end of vendor support, in six months. No warehouse shift disrupted by a migration cutover during active hours. Licence cost reduction is expected but is not the primary driver, hardware refresh avoidance is.

**Technical requirements.** Every retained application (27, after the discovery-phase retirement decision) working in AVD, validated by real users. FSLogix replacing Citrix Profile Management with no user-visible profile loss. A parallel-run period long enough to catch problems, short enough not to become permanent.

**The persistent-versus-non-persistent mapping decision, stated as a requirement up front.** Warehouse staff's MCS non-persistent desktops map to AVD pooled host pools with FSLogix profiles, the same "identity plus profile, disposable compute" pattern AVD pooled pools already provide natively. Head office's PVS-provisioned desktops, in practice, were provisioned non-persistently but used somewhat persistently (staff kept personal shortcuts and local file copies that Citrix Profile Management wasn't fully capturing), this mismatch between Citrix's provisioning model and actual usage pattern becomes an explicit AVD design decision, not something to replicate unexamined.

---

## 3. Component mapping, Citrix to AVD

| Citrix component | AVD/Microsoft equivalent | What changes, not just what maps |
|---|---|---|
| Delivery Controller | AVD control plane (Microsoft managed) | No infrastructure to patch or maintain, this is the single biggest operational change for the Citrix admin team |
| StoreFront | Workspace + Windows App | Feed discovery model is materially different; see section 4 |
| Citrix Policies | Intune configuration profiles + host pool RDP properties | Not a 1:1 mapping, Citrix policies conflate settings that AVD splits across two different control planes, covered in [Chapter 24](../chapters/ch24-intune-and-avd-endpoint-management.md) |
| MCS / PVS provisioning | Azure Compute Gallery + host pool scaling | Golden image discipline from [Chapter 23](../chapters/ch23-golden-image-engineering.md) replaces Citrix's machine catalog update mechanism |
| Citrix Profile Management | FSLogix | Migration approach in section 6 |
| NetScaler Gateway | AVD reverse connect (Microsoft managed) | No inbound gateway infrastructure to maintain; see the specific dependency check in section 5 |
| Delivery Groups | Host pools + application groups | Not a direct rename, AVD's application-group model is more granular than a Citrix Delivery Group, covered in section 4 |

**The mapping that genuinely has no clean equivalent.** Citrix's application-level policies that vary by Delivery Group membership (a common Citrix pattern) map onto AVD as a combination of Intune configuration profile targeting and RDP properties per host pool, because AVD's model separates "what the session host allows" (RDP properties, host-pool-scoped) from "what the user's device and session behaviour is" (Intune, user- or device-scoped) in a way Citrix's single policy engine does not. Falkirk's migration plan documents this split explicitly for each of the 27 retained applications' policy requirements, rather than assuming a search-and-replace of Citrix policy names onto AVD equivalents.

---

## 4. Delivery Groups to host pools and application groups

**The Citrix structure.** Six Delivery Groups: Warehouse-Shift1, Warehouse-Shift2, Warehouse-Shift3, Dispatch, Finance, Management. Each had its own published application set, built this way originally so shift-specific policies (screen timeout, printer defaults) could differ.

**The AVD structure, not a direct copy.** Two host pools, not six: Warehouse (pooled, all three shifts share the same pool since AVD's autoscaling and RDP properties don't need a separate pool per shift the way the original Citrix policy design assumed) and Office (pooled, covering Dispatch, Finance, and Management). Shift-specific and department-specific differences that justified six Delivery Groups are handled instead by application group membership and Intune policy targeting by Entra security group, a narrower, more precisely scoped mechanism than a whole separate host pool per shift.

**Why this is fewer pools, not a like-for-like six.** Citrix's Delivery Group was the only unit of policy differentiation available, so six policy variations meant six Delivery Groups. AVD separates policy (Intune, application groups) from compute placement (host pools), so the same six policy variations need only two pools, each with several application groups layered on top. Fewer host pools means fewer things to size, patch, and scale independently. That is a genuine simplification, not just a renaming exercise, and one worth calling out explicitly to the Falkirk operations team who will otherwise expect to manage six of everything out of habit.

---

## 5. NetScaler and network dependency discovery

**What discovery found.** Beyond the documented NetScaler Gateway function (external access), two internal applications had hard-coded a NetScaler internal load-balancing virtual IP address as their backend connection string, a dependency invisible in Citrix Studio's published-application list and found only by inspecting each application's actual configuration during the assessment.

**Why this matters for a Citrix-to-AVD migration specifically.** AVD's reverse-connect model removes the need for gateway infrastructure entirely for the remote-access function NetScaler served, but it does nothing about internal load-balancing dependencies baked into individual applications, which is a separate problem that migrating the desktop platform does not automatically solve. Both affected applications' backend connection strings were updated to point at Azure Application Gateway-fronted addresses as part of application remediation, tracked as its own line item in the migration plan rather than assumed to be handled by the platform migration.

---

## 6. Profile migration: Citrix Profile Management to FSLogix

**The approach: rebuild, not lift-and-shift.** Citrix Profile Management's on-premises profile store is not directly compatible with FSLogix's VHDX container format, there is no supported one-step conversion. Profiles are rebuilt: each user's first AVD sign-in creates a new FSLogix container, and application-specific settings that matter (not everything does) are migrated selectively via a scripted extraction of key registry paths and AppData folders from the Citrix profile, run once per user during their migration wave.

**Why not attempt a full byte-for-byte profile carry-over.** Warehouse staff's 40 MB average profile size is almost entirely printer defaults and a handful of application settings, not worth the engineering effort of a complex migration path for data this small and this easily regenerated. Back-office staff's 380 MB profiles are mostly Outlook OST cache, which is intentionally excluded from FSLogix profile containers per [Chapter 21](../chapters/ch21-fslogix-production-implementation.md)'s guidance and rebuilds automatically against Exchange Online regardless of migration approach, carrying over the old cached copy would provide no benefit and would inflate the new profile container for no reason.

**What is selectively migrated.** A short, named list per department: warehouse staff's saved printer defaults (extracted from a specific registry path, reapplied via a first-logon script) and back-office staff's Outlook signature and a small number of application-specific settings files identified during application assessment as genuinely disruptive to lose. Everything not on this list is treated as acceptable loss, reset to application default on first AVD sign-in, communicated to users in advance rather than discovered as a surprise.

---

## 7. Application assessment and remediation

**The 27 retained applications, triaged by migration complexity.**

| Complexity tier | Count | Characteristic | Approach |
|---|---|---|---|
| Straightforward | 19 | Standard Win32 install, no hardware dependency, no hard-coded infrastructure reference | Packaged via App Attach where the vendor's install supports it (per [Project 10](project-10-remoteapp-line-of-business.md)'s packaging chain), otherwise baked into the golden image |
| Needs remediation | 6 | Hard-coded NetScaler dependency (2), licensing tied to a hardware fingerprint that changes on any rebuild (3), one requiring a specific legacy .NET Framework version incompatible with the target Windows 11 multi-session baseline | Individually remediated, see below |
| High-risk, dedicated pilot | 2 | A warehouse scanning application with a USB-attached hardware dependency, and a finance application whose vendor has not certified any virtual desktop platform, Citrix included | Piloted in isolation before being included in any migration wave |

**The licensing-fingerprint problem, worked through concretely.** Three applications activate against a hardware fingerprint derived in part from the machine's disk serial number, stable in Citrix's PVS model (base image regenerated infrequently, machine identity persistent across reboots within a catalog's lifecycle) but directly at odds with AVD's golden-image-and-rebuild pattern, where session hosts are recreated from the gallery image regularly. Resolved by working with each vendor: two moved to a subscription-based licence key activation that isn't hardware-bound, and one required a documented exception where that specific host pool's image update cadence was slowed from Chapter 23's normal monthly pattern to quarterly, specifically to reduce the licence re-activation burden until the vendor's own roadmap delivers a non-hardware-bound licensing option.

**The USB-scanning application, piloted separately.** AVD's USB redirection works, but was validated against the actual warehouse scanning hardware in a two-week pilot with five real warehouse users before being included in any migration wave. A USB redirection failure discovered during a live warehouse shift, rather than during a controlled pilot, would stop physical goods movement, not just inconvenience a desk-based user.

---

## 8. Migration waves and parallel run

**Wave sequencing, by risk, not by convenience.** Four waves over the six-month window: (1) a 40-user pilot drawn from Finance, the lowest-risk population with the simplest application set and no shift-pattern complexity, (2) the remainder of Finance and Management (710 users), (3) Dispatch (150 users, moderate complexity from the NetScaler-dependent applications), (4) Warehouse (900 users across three shifts, sequenced last specifically because it carries the highest business-continuity risk and the team wanted three waves of AVD operational experience before touching it).

**Cutover mechanics per user, not per department, wherever shift patterns allow it.** Within Wave 4, warehouse staff cut over individually as their shift starts, over a two-week window, rather than all 900 users switching platforms in one event. This spreads the cutover risk and gives the support team a manageable daily volume of first-day issues rather than 900 simultaneous ones.

**Parallel run, deliberately time-boxed.** Citrix remains available, read-only for application access (no new users onboarded to it, existing sessions permitted to continue) for two weeks after each wave's cutover, giving a fallback path for anyone hitting a migration issue without reverting the whole wave. The two-week window is enforced, not indefinite, extending it wave by wave was explicitly identified as the failure pattern to avoid (a parallel run with no hard end date tends to never end, because the last few stragglers are always easier to leave on the old platform than to chase down), and the hardware end-of-support deadline gave a real forcing function that made the two-week limit stick in practice.

---

## 9. Terraform and Azure Compute Gallery for the target environment

The target AVD environment is built with the same Terraform module pattern established in [Project 03](project-03-global-enterprise-governance.md), Falkirk is a single business unit, so the module reuse here is simpler (one subscription, one root module) but follows the identical pattern, avoiding the temptation to build a one-off Terraform structure for what is, underneath the migration complexity, a fairly standard two-host-pool AVD environment.

Golden images for Warehouse and Office pools are built and versioned in Azure Compute Gallery from day one of the target environment build, not migrated from Citrix's MCS/PVS master images, which have accumulated 18 months of undocumented manual changes discovered during the same assessment that found the unused applications. Rebuilding clean, per [Chapter 23](../chapters/ch23-golden-image-engineering.md)'s discipline, was judged less risky than attempting to carry forward an image with unknown drift.

---

## 10. Validation

- All 27 retained applications individually validated by real users from the department that uses them, not signed off by IT alone, each application has a named validator and a recorded confirmation.
- USB scanning application validated in a dedicated two-week pilot with real warehouse hardware before being included in Wave 4.
- Parallel run for each wave closed on schedule at two weeks, confirmed by checking Citrix Director session logs show zero active sessions from that wave's users before decommissioning their Citrix access.
- Citrix Delivery Controllers and hypervisor hosts fully decommissioned before the hardware's vendor-support end date, with a decommissioning date that beat the deadline by three weeks.

## 11. Rollback

Each wave's rollback path is the parallel-run Citrix environment itself, available for exactly the two-week window, a user hitting a blocking issue in AVD is moved back to their still-functioning Citrix account for that window while the issue is fixed, then re-migrated, rather than the whole wave being rolled back. No wave-level rollback was required in practice; the closest case was two Dispatch users kept on Citrix for an extra eight days past their wave's window while the NetScaler-dependency remediation for their specific application was finished, an explicitly approved, time-boxed extension rather than an open-ended one.

## 12. Risks accepted

The quarterly (rather than monthly) image update cadence for the hardware-licence-bound application's host pool is an accepted reduction in patch currency for that specific pool, mitigated by that pool's smaller user population and by monitoring specifically for that application's licence-activation failures as an early signal if the vendor's fingerprint sensitivity changes. The two applications remediated by moving to subscription-based licensing depend on those vendors' continued support of that licensing model, a vendor-relationship risk noted for Falkirk's software asset management team to track, outside this engagement's scope to control directly.

---

## 13. Interview questions from this engagement

### Q1. How do you handle an application that depends on a hardware fingerprint for licensing, when moving from a persistent Citrix model to AVD's disposable-host model?

**30-second answer.** Work with the vendor first, subscription licensing without hardware binding is increasingly available and is the clean fix. Where that's not possible yet, slow that specific pool's image update cadence as a documented, time-boxed compensating measure, not a silent workaround.

**Two-minute senior answer.** This is a genuine mismatch between two provisioning philosophies, not just a technical setting to change. Citrix's PVS model kept machine identity reasonably stable across a catalog's life, which is exactly what hardware-fingerprint licensing assumes. AVD's golden-image discipline assumes hosts get rebuilt regularly, which breaks that assumption by design, rebuilding regularly is a feature, not a bug, for security and consistency. The right fix is upstream: push the vendor toward a licensing model that doesn't depend on hardware identity, because more of them support this now than five years ago. Where a vendor genuinely can't move quickly, the compensating measure has to be documented as exactly that: an accepted, time-boxed reduction in image currency for one specific pool, with monitoring for the failure mode it's accepting, not a quiet exception nobody tracks.

**Deep-dive points.** Why the exception was scoped to that one host pool rather than slowing the update cadence for every pool to accommodate the one application. The specific monitoring signal (licence-activation failure rate) chosen to catch drift in the vendor's fingerprint sensitivity.

**Expected follow-up.** "What if the vendor never moves to a better licensing model?", the exception becomes a permanent, reviewed risk acceptance rather than an open assumption it will resolve itself, revisited at each image-update cycle.

**Common weak answer.** Suggesting the application simply can't be migrated, without exploring vendor engagement or a scoped compensating control first.

**What the interviewer is testing.** Whether the candidate treats a platform-migration blocker as something to solve pragmatically with the right scope, rather than either ignoring it or treating it as a project-blocking dead end.

### Q2. Your Citrix estate has six Delivery Groups. How many AVD host pools do you build, and why?

**30-second answer.** Fewer than six, likely two here. Citrix used Delivery Groups as its only policy differentiation unit, but AVD separates policy (Intune, application groups) from compute placement (host pools), so shift and department differences don't each need their own pool.

**Two-minute senior answer.** The instinct is to map Delivery Groups to host pools one-for-one because that's the familiar unit from Citrix. It's usually the wrong instinct. Citrix's Delivery Group conflates "which users get which applications" with "what policy applies to them" with "which compute pool they land on," because that's the only lever Citrix gives you. AVD gives you three separate levers, application group membership, Intune/RDP-property policy targeting, and host pool placement, so the six-way split that made sense under Citrix's constraints usually collapses into far fewer host pools once you separate those concerns properly. Fewer host pools is a genuine operational simplification: fewer things to size, patch, and scale independently, not just a renaming exercise.

**Deep-dive points.** The specific example of collapsing three shift-based Delivery Groups into one Warehouse host pool with shift differentiation handled by Intune policy targeting instead.

**Expected follow-up.** "When would you actually need separate host pools, not just separate application groups?", genuinely different compute requirements (GPU versus non-GPU), different scaling schedules that can't share one plan, or a hard data-residency or network-segmentation boundary between the groups.

**Common weak answer.** Mapping Delivery Groups to host pools one-to-one by default, without questioning whether the underlying reason for six groups still applies under AVD's different policy model.

**What the interviewer is testing.** Whether the candidate understands AVD's object model well enough to recognise when a Citrix-era structure should not be carried forward unchanged.

### Q3. Your discovery finds that Citrix Studio's published-application list doesn't match what's actually used. How does that change your migration plan?

**30-second answer.** It becomes the plan's first real decision point, not a footnote. Confirm usage with real telemetry, verify with the actual department heads, then migrate only what's confirmed, retiring the rest deliberately rather than migrating everything the documentation claims exists.

**Two-minute senior answer.** Migrating an application nobody uses costs real engineering time, testing time, and long-term maintenance for zero business value, and it's a surprisingly common failure mode precisely because migrating "what's documented" feels safer than making a retirement call. The right sequence here was telemetry first, 90 days of Citrix Director launch data, which found 13 of 40 applications unused, and then a second confirmation step with each department head before finalising any retirement, because telemetry alone can be wrong: a quarterly-use application with a 90-day measurement window that happened to miss its one use case would look identically unused to something genuinely dead. That two-step check, data plus human confirmation, is what let this migration retire real dead weight with confidence rather than either migrating everything defensively or retiring something still quietly needed.

**Deep-dive points.** Why a single data source (telemetry) wasn't treated as sufficient on its own. The specific risk of a false-negative retirement (a rarely-used but still-needed application) versus the cost of over-migrating.

**Expected follow-up.** "What if a department head disputes the telemetry and insists an application is still needed?" their word is treated as sufficient to retain it; the cost of migrating one extra application is far lower than the cost of retiring something a business function genuinely depends on.

**Common weak answer.** Migrating every documented application as a safe default, without investing discovery time in confirming actual usage first.

**What the interviewer is testing.** Whether the candidate treats platform documentation as a starting hypothesis to verify rather than ground truth, especially on a brownfield estate that's drifted for years.

### Q4. How do you sequence migration waves for an estate with three shifts and no acceptable downtime window?

**30-second answer.** By risk, not by convenience, and save the highest-risk, highest-continuity-impact population for last, after the team has real AVD operational experience from earlier waves. Cut over individuals within a wave, not the whole population simultaneously, wherever shift patterns allow it.

**Two-minute senior answer.** The instinct is often to sequence by what's administratively easiest, alphabetically, or by whichever department asks first. That ignores the actual risk gradient. Here, warehouse operations across three shifts carried the highest business-continuity risk of any population, so it went last deliberately, after three prior waves had already proven the target environment and given the team real operational muscle memory with AVD specifically. Within that final wave, cutover happened shift by shift, over two weeks, rather than switching all 900 warehouse users at once, which turned a single high-stakes event into a series of smaller, more manageable ones with a bounded daily volume of first-day issues the support team could actually absorb. The parallel-run window, deliberately capped at two weeks per wave, existed specifically so problems found during a wave had a safe fallback without that fallback becoming permanent.

**Deep-dive points.** Why the two-week parallel-run cap was enforced rather than open-ended, and what specific pattern (parallel runs that never end) it was designed to prevent.

**Expected follow-up.** "What would you do if Wave 4 uncovered a serious, unanticipated problem?" pause that wave's remaining cutovers, use the parallel-run fallback for affected users, fix the root cause, and resume, rather than rolling back waves already successfully completed.

**Common weak answer.** Sequencing by administrative convenience or department size rather than by actual business-continuity risk.

**What the interviewer is testing.** Whether the candidate can build a wave plan around risk tolerance and available fallback capacity, not just logistics.

### Q5. A vendor's application predates SMB signing, or in this case, ties its licence to a hardware fingerprint that AVD's rebuild model breaks. How is this different from a technical bug to fix?

**30-second answer.** It's a mismatch between two different infrastructure philosophies, not a bug: the vendor's licensing assumes machine identity stability that AVD's golden-image rebuild pattern deliberately doesn't provide. The fix is either vendor engagement toward non-hardware-bound licensing, or a documented, scoped, time-boxed compensating measure, not a workaround to hide.

**Two-minute senior answer.** Treating this as a bug to patch around leads to fragile, undocumented workarounds that break again at the next image update. Treating it as what it actually is, a genuine philosophical mismatch between Citrix's PVS provisioning model (which kept machine identity fairly stable) and AVD's deliberate rebuild-from-image discipline, leads to a better answer: engage the vendor first, because more vendors support non-hardware-bound subscription licensing now than a few years ago, and where that's not immediately possible, slow that one specific host pool's image update cadence as an explicit, scoped, monitored exception rather than a silent one applied everywhere. The three applications with this exact problem in this engagement got two different resolutions, subscription licensing for two, a documented cadence exception for the third, precisely because the right fix depends on what the vendor can actually offer, not a single universal workaround.

**Deep-dive points.** The specific monitoring signal (licence-activation failure rate) put in place to catch drift in the vendor's fingerprint sensitivity over time, so the exception doesn't silently become worse.

**Expected follow-up.** "Would you accept this exception indefinitely?" no; it's reviewed at each image-update cycle and tracked as an open risk with an owner, not treated as permanently resolved once documented.

**Common weak answer.** Treating the licensing conflict as purely a technical problem to route around, without engaging the vendor or scoping the compensating measure to just the affected pool.

**What the interviewer is testing.** Whether the candidate can distinguish a genuine architectural mismatch from a simple bug, and choose a proportionate, scoped, monitored response instead of either ignoring it or over-engineering around it.

---

## 14. Official Microsoft references

- [Citrix to Azure Virtual Desktop migration guidance](https://learn.microsoft.com/en-us/azure/virtual-desktop/migrate-citrix)
- [Azure Virtual Desktop application groups](https://learn.microsoft.com/en-us/azure/virtual-desktop/manage-app-groups)
- [FSLogix profile container overview](https://learn.microsoft.com/en-us/fslogix/overview-prerequisites)
- [Universal Print and USB redirection for Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/rdp-properties)
