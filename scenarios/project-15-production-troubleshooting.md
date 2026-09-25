# Project 15 - Northgate Retail: Simulated Production Incident

> **Fictional troubleshooting case study:** Northgate Retail is not a real incident or customer delivery record. Events, measurements, tests, and outcomes are worked examples that show the troubleshooting method.

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Part XI:** Architecture Case Studies
> **Standard:** [PROJECT-STANDARD.md](../PROJECT-STANDARD.md)
> **Technical baseline:** August 2026
> **Concepts introduced here:** The 10-layer isolation method, connection/access/identity failure patterns, experience/profile/storage/performance failure patterns, incident command under pressure

---

## Engagement brief

**What this represents.** A simulated retained-operations engagement. The architect joins an ongoing incident in an unfamiliar production AVD estate. The exercise tests the structured response expected from a senior AVD engineer.

**The business problem.** Northgate Retail's head office AVD environment (500 users, order management and merchandising systems) has been degrading over three days: intermittent sign-in failures, some users reporting "slow" sessions, a handful of complete session freezes requiring a forced disconnect. Northgate's own two-person IT team has made four uncoordinated changes trying to fix it, each based on a guess, none of which helped, and the business impact is now serious enough that Northgate has escalated to bring in outside expertise mid-incident.

**Constraints that cannot be designed away.** The incident is live and ongoing when this engagement starts, there is no discovery phase before troubleshooting begins, unlike every other project in this book. Northgate's own team has already changed multiple things, which means the current state does not reflect the original fault condition, and some of their changes may themselves now be contributing to the symptoms. There is no environment documentation beyond a two-year-old architecture diagram that may or may not still be accurate.

**Previously learned concepts applied.** Every troubleshooting runbook in this book ([Runbooks 01-05](../troubleshooting/README.md)), the full concept set from Chapters 1-25, and specifically the evidence-before-action discipline established in Chapter 19's FSLogix failure analysis and Runbook 03.

**New concepts introduced here.** A structured method for isolating a fault to a specific layer when the environment has already been changed by well-meaning but uncoordinated action, and the fault could be identity, network, host, profile, storage, or application. How to run an incident under time pressure without collapsing back into guess-and-change. The specific difference between a connection/access/identity failure pattern and an experience/profile/storage/performance failure pattern, and why misdiagnosing which category you're in wastes the most time.

**Architectural decisions to make.** None. This case has no host-pool sizing, identity-model, or Terraform-module decision. It focuses on diagnosis and remediation during a simulated incident.

**What could realistically go wrong.** The real root cause looks like several plausible root causes at once, and the wrong one gets fixed first, burning time while the actual problem continues. Northgate's own uncoordinated changes actively mislead the diagnosis by introducing new symptoms unrelated to the original fault. Pressure to "just fix it now" leads to a change made without evidence, which either doesn't help or makes things worse.

**Validation and handover.** The actual root cause identified with evidence, not inferred from a plausible story. A single, minimal, evidence-backed fix applied and confirmed to resolve the symptom. Northgate's team walked through the reasoning, not just told the fix, so they could recognise the pattern themselves if it recurs.

---

## 1. The situation as found, on arrival, deliberately messy, because that is how it actually arrives

**What Northgate reported.** "Sign-ins have been slow and sometimes failing for three days, some sessions freeze completely, we've tried a few things and nothing's helped, users are furious, order processing is behind."

**What Northgate's two-person team had already changed, in the three days before this engagement started, each independently and without coordinating with each other.**

1. Restarted all 40 session hosts (day 1, after the first complaints), no improvement.
2. Increased the host pool's maximum session limit, believing the hosts were overloaded (day 2), no measurable improvement, possibly made things marginally worse.
3. Disabled FSLogix cloud cache and reverted to a single storage provider, having read that Cloud Cache "can cause issues" in an unrelated forum post (day 2), unrelated to the actual fault, as later confirmed, and a genuine regression risk introduced with no evidence it addressed anything.
4. Applied a Windows security update that had been pending for two weeks, hoping it might coincidentally help (day 3), unrelated, but now a variable in the environment that has to be accounted for when reading logs from before versus after day 3.

**Why this list matters as much as the original symptom.** A diagnostic approach that starts from "what changed in the last three days" without separating Northgate's own reactive changes from the original fault would waste significant time chasing symptoms of change #2 or #3 rather than the actual root cause. The first job on arrival is not diagnosing the fault, it is establishing an accurate timeline of what is a symptom of the original problem versus what is a side effect of three days of uncoordinated troubleshooting layered on top of it.

---

## 2. The 10-layer isolation method

A structured sequence for isolating a fault to a specific layer, used here for the first time in this book at full scale, though every troubleshooting runbook in this repository has been implicitly following pieces of it. The point of a named, ordered method is that it can be followed under pressure without relying on memory or intuition for what to check next.

| Layer | Question this layer answers | Northgate-specific check |
|---|---|---|
| 1. Identity | Can the user authenticate at all? | Entra sign-in logs for the affected users, checked for a pattern (specific users, specific times, specific Conditional Access policy triggers) |
| 2. Conditional Access | Is a CA policy blocking or adding friction? | CA sign-in log detail for policy evaluation results, not just pass/fail |
| 3. Feed and broker | Does the user see and can they launch a resource? | AVD diagnostics: `WVDErrors` and `WVDConnections` for feed and connection failures |
| 4. Network path | Can the client actually reach the gateway and, once brokered, the session host? | Client-side connection diagnostics, transport type shown (reverse connect vs Shortpath) |
| 5. Session host health | Is the target host itself healthy, CPU, memory, disk? | Perf counters, `WVDAgentHealthStatus` |
| 6. Host pool configuration | Does a recent configuration change explain the timing? | Compared against Northgate's own change log, cross-referenced against symptom onset timing |
| 7. Profile attach | Does FSLogix attach succeed, and how long does it take? | FSLogix logs on affected hosts, specifically checking behaviour before and after Northgate's day-2 Cloud Cache change |
| 8. Storage performance | Is the profile storage backend responding within acceptable latency? | Storage account metrics: latency, throttling, transaction counts |
| 9. Application behaviour | Is the symptom actually the platform, or one specific application? | Cross-check whether "slow sessions" complaints correlate with use of one specific order-management application versus general session use |
| 10. Client-side | Is the symptom actually happening on the server side at all, or is it a client/endpoint issue? | Sampling affected users' client versions and local device resource usage |

**Why this order, not a different one.** Each layer is checked in the order that a failure at that layer would block or distort evidence from every layer after it, there is no point deeply investigating profile attach behaviour (layer 7) if identity (layer 1) is intermittently failing for the same users, because an intermittent identity failure will look like an intermittent everything-failure downstream. The method works top-down specifically so that a genuine upper-layer fault is not missed while chasing a plausible-looking lower-layer symptom.

---

## 3. Working the method: what was actually found, layer by layer

**Layer 1, Identity, clean.** Entra sign-in logs showed no unusual failure pattern for the affected users. Ruled out quickly, which matters: a clean result here is genuine progress, not a wasted check, because it removes an entire category from consideration.

**Layer 2, Conditional Access, clean.** No policy changes in the relevant window, no unusual evaluation results.

**Layer 3, Feed and broker, a pattern found.** `WVDErrors` showed a cluster of `ConnectionFailedClientDisconnected` events, concentrated on a specific subset of 12 of the 40 session hosts, not evenly distributed, the first genuinely useful signal, because it reframes the problem from "the platform is slow" (which had been the assumption driving Northgate's first three days of changes) to "something is specifically wrong with a subset of hosts."

**Layer 4, Network path, clean for the affected hosts specifically.** Ruled out a network-wide explanation; the fault is host-specific, consistent with layer 3's finding.

**Layer 5, Session host health, the actual signal.** The 12 affected hosts showed sustained memory utilisation above 92%, while the other 28 hosts sat comfortably around 55-65% under equivalent user load. Memory pressure this severe, this consistently, on a specific subset of hosts under otherwise normal load is not typical baseline behaviour, worth pursuing specifically, not treating as noise.

**Layer 6, Host pool configuration, the piece that connected it.** Cross-referencing the 12 affected hosts against Northgate's own change log and the golden image build history found that those 12 hosts had been provisioned six weeks earlier from a golden image update that added a new merchandising application, an application not present on the other 28 hosts, which were still running the previous image version because Northgate's rolling update process had stalled partway through (a detail nobody had mentioned, because nobody had thought it relevant until this cross-reference surfaced it).

**Layers 7 and 8, Profile attach and storage, genuinely clean, once separated from Northgate's day-2 change.** FSLogix attach times were normal on both the affected and unaffected hosts. This confirmed Northgate's day-2 Cloud Cache change (reverting to a single storage provider) had addressed nothing, because there had been nothing wrong at this layer to begin with. A useful, if slightly deflating, confirmation: one of the three uncoordinated changes was unnecessary and should be reverted once the real fix is in place, not left as permanent scar tissue from a guess that didn't pan out.

**Layer 9, Application behaviour, root cause confirmed.** The new merchandising application, present only on the 12 affected hosts, had a known memory leak under specific usage patterns (confirmed via the vendor's own release notes for the version six weeks old, which nobody at Northgate had read against their own symptom timeline), each session running that application over several hours consumed memory that was never released, and with several concurrent users per pooled host, memory exhaustion on those 12 specific hosts was the direct, sole cause of the `ConnectionFailedClientDisconnected` pattern from layer 3.

**Layer 10, Client-side, not reached.** The root cause was confirmed at layer 9; layer 10 was unnecessary once a layer-9 finding fully explained every reported symptom, which is itself a feature of working the method in order rather than jumping between layers based on hunches.

---

## 4. The fix: minimal, evidence-backed, and immediately validated

**What was changed.** Two actions, both directly justified by the layer 9 finding and nothing else. First, the vendor's patched version of the merchandising application (released four weeks earlier, unapplied because nobody had been tracking that vendor's release notes against Northgate's own deployed version) was applied to a new golden image version. Second, the 12 affected hosts were drained of active sessions during a low-traffic window and replaced from the patched image, not patched in place, following [Chapter 23](../chapters/ch23-golden-image-engineering.md)'s golden-image discipline of replacing rather than modifying running hosts.

**What was deliberately left unchanged, and why.** The host pool's session limit increase from Northgate's day-2 change was reverted back to its original value once the real fix was confirmed, since it had addressed nothing and unnecessarily increased density on hosts that were, it turned out, already under memory pressure from a completely different cause, leaving it in place risked making a future, unrelated memory issue worse for no offsetting benefit. The Cloud Cache reversion from Northgate's day-2 change was also reverted, restoring the original, correctly-designed dual-provider redundancy that had never been the problem, once its removal was confirmed to have fixed nothing and was itself a small resilience regression.

**Validation, immediate and specific.** Memory utilisation on the 12 rebuilt hosts, monitored for 48 hours post-fix, sat at 58-64% under equivalent load. This matches the previously-unaffected 28 hosts, not just "looking better" subjectively. `WVDErrors`' `ConnectionFailedClientDisconnected` rate for the affected host pool returned to its pre-incident baseline, checked against three weeks of historical data pulled specifically for this comparison, not eyeballed against a vague sense of "before."

---

## 5. Incident command, and what running this under pressure actually required

**Why this section exists as its own topic, not folded into the technical narrative.** The technical diagnosis in sections 3-4 reads cleanly in hindsight. It did not feel clean while it was happening, Northgate's leadership wanted an update every 30 minutes, order processing backlog was visibly growing, and there was real pressure to "just try something" faster than the method allows.

**What held the diagnosis on track.** A single person designated as incident lead, with explicit authority to say "we are not changing anything until we've checked the next layer", the single most useful piece of the incident command structure, because it gave one person the standing to resist pressure for premature action without that resistance looking like stalling to an anxious stakeholder. Status updates to Northgate leadership at a fixed 30-minute cadence regardless of progress, reporting "we have ruled out identity and network, we are now checking host health" even when that update contained no fix, because a stakeholder hearing regular, specific progress updates tolerates the process far better than a stakeholder hearing nothing and assuming nothing is happening.

**The moment the method was nearly abandoned.** After layer 5 found the memory-pressure signal but before layer 6 connected it to the specific application, there was real pressure to immediately restart the 12 affected hosts as an interim fix, which would likely have provided temporary relief (freeing the leaked memory) while destroying the evidence trail needed to find the actual root cause, guaranteeing the same failure would recur once memory pressure rebuilt. The incident lead held the line for the roughly 40 minutes it took to complete layers 6 through 9, explicitly trading a faster-feeling but non-diagnostic action for a slower, evidence-complete one. That was the correct call, confirmed by the fact that the eventual fix has not recurred, versus a restart-based interim fix that would have needed repeating indefinitely.

---

## 6. What Northgate's team was walked through, not just told

**The handover was the reasoning, not the fix.** Northgate's two-person team received a walkthrough of the 10-layer method itself, the specific evidence found at each layer, and (deliberately) an honest review of which of their own three days of changes had helped (none) and why each had seemed like a reasonable guess at the time despite not addressing the actual cause. This is presented without blame: reactive troubleshooting under pressure, without a structured method, reliably produces exactly this pattern of plausible-but-ineffective changes, and the point of the handover is equipping Northgate to recognise that pattern in themselves next time, not making them feel bad about this time.

**What changed in Northgate's own process afterward.** A lightweight change log requirement, any troubleshooting action taken during an incident gets logged with a timestamp and reasoning before it's made, not after, specifically so a future outside responder (or Northgate's own team, reviewing their own history) can reconstruct an accurate timeline the way this engagement had to reconstruct one from memory and inference on arrival. A subscription to the merchandising application vendor's release notes, tied explicitly to Northgate's own image update process, so a known-issue patch does not sit unapplied for four weeks next time.

---

## 7. Validation

- Root cause confirmed with direct evidence (memory utilisation data, application version correlation, vendor release notes) at every layer, not inferred from a plausible narrative.
- Fix validated over 48 hours of post-remediation monitoring against a genuine historical baseline, not a subjective "seems better" assessment.
- Both of Northgate's ineffective day-2 changes reverted and confirmed not to have been masking or contributing to any other issue before removal.
- Northgate's team demonstrated, in a follow-up call one week later, that they could correctly describe the 10-layer method's logic when asked to explain what they'd do if a similar but different symptom occurred.

## 8. Rollback

The golden image replacement for the 12 affected hosts followed the same drain-and-replace pattern as any standard image update, the previous (unpatched) image version remained available in Azure Compute Gallery, un-deleted, for a defined rollback window in case the vendor's patch introduced a new, unanticipated issue. It did not; the rollback path was available but not needed. Reverting Northgate's two ineffective day-2 changes back to their original state was itself the "rollback" for those specific actions.

## 9. Risks accepted

The vendor's four-week-old patch, applied to resolve this specific memory leak, was not independently regression-tested by this engagement beyond the 48-hour post-fix monitoring window. A longer soak period would have been preferable but was balanced against the business cost of continued host instability during a longer validation window, and was judged an acceptable trade given the patch's narrow, well-documented scope in the vendor's own release notes.

---

## 10. Interview questions from this engagement

### Q1. You arrive at a live incident where the customer's own team has already made several changes. How does that affect your approach?

**30-second answer.** The first job is separating symptoms of the original fault from side effects of their own troubleshooting, before diagnosing anything, otherwise you risk chasing a symptom that's actually a side effect of a well-meaning but ineffective change made hours or days earlier.

**Two-minute senior answer.** Every uncoordinated change made before you arrive is a variable now baked into the current state of the system, and none of it was logged with the rigour you'd want as a responder. Northgate's team made four changes over three days, none coordinated with each other, and by the time this engagement started, the environment no longer reflected the original fault condition cleanly. The instinct to just start diagnosing the current symptom is a trap here, because some of what you're seeing is the original problem and some of it is noise introduced by a forum-post fix that seemed reasonable at 11 p.m. on day two. Building an accurate timeline first, what changed, when, and what the team's own theory was for each change, before running any structured diagnostic method is what prevents wasting the first hour chasing the wrong thing. In this case, one of the reverted changes (the Cloud Cache reversion) turned out to be completely unrelated noise; knowing that early, rather than discovering it accidentally halfway through layer 7, would have saved real time.

**Deep-dive points.** The specific 30-minute stakeholder cadence used to buy time for the method to work without stakeholders feeling ignored. Why the eventual fix reverted both ineffective prior changes rather than leaving them in place "since they're not hurting."

**Expected follow-up.** "What if the customer refuses to let you revert their changes while you investigate?", explain the specific risk each change introduces (masked evidence, unnecessary regression) in terms the stakeholder can weigh, rather than simply asserting authority to make the change.

**Common weak answer.** Starting the technical diagnosis immediately without first establishing what the customer has already changed and why, risking a diagnosis built on a confused picture of the current state.

**What the interviewer is testing.** Whether the candidate understands that arriving mid-incident with prior uncoordinated changes already made is a different problem from diagnosing a clean, unmodified fault, and requires a different first step.

### Q2. Walk me through why you use a fixed, ordered layer sequence instead of investigating whichever layer seems most likely first.

**30-second answer.** A plausible-seeming layer can be wrong, and jumping straight to it risks missing an upstream fault that would explain, and be masked by, everything downstream. The fixed order specifically checks layers in the sequence where an upper-layer fault would distort evidence from every layer below it.

**Two-minute senior answer.** The temptation under pressure is to jump to whichever layer your gut says is the problem, in this incident, "slow sessions" strongly suggested storage or profile issues to Northgate's own team, which is exactly why they made a Cloud Cache change on day two based on a forum post, despite storage never actually being the problem. A fixed, ordered method exists specifically to counteract that instinct, because gut instinct is built from whatever symptom is most visible to the user, not from where the fault structurally sits. Working top-down (identity, then Conditional Access, then feed and broker, then network, then host health, and so on) means a genuine upper-layer problem gets found and ruled out (or confirmed) before time is spent deeply investigating a lower layer that would show distorted, confusing evidence *because* of the upper-layer issue, not because of anything wrong at that lower layer itself. In this incident, layers 1 through 4 were all genuinely clean, and confirming that cleanly, in order, is what gave confidence that layer 5's memory-pressure finding was real signal and not noise from something else.

**Deep-dive points.** Why layers 7 and 8 (profile, storage) coming back clean was itself valuable evidence, confirming Northgate's own change three days earlier had addressed nothing. Why layer 10 (client-side) was correctly skipped once layer 9 fully explained the symptom, rather than checked exhaustively regardless.

**Expected follow-up.** "What would you do differently if layer 5 had also come back clean?", continue down the sequence to layer 6, treating a clean result as genuine progress narrowing the search space, not as a dead end requiring a return to guessing.

**Common weak answer.** Describing troubleshooting as "checking the most likely cause first," without articulating why a fixed order specifically protects against symptoms that look like a lower-layer problem but are actually caused by an unconfirmed upper-layer fault.

**What the interviewer is testing.** Whether the candidate has internalised structured troubleshooting as a discipline that works precisely because it resists intuition under pressure, not just as a checklist to recite.

### Q3. How do you hold a structured diagnostic method when the customer is pressuring you to "just try something" faster?

**30-second answer.** A named incident lead with explicit authority to say "we're not changing anything until the next layer is checked," and regular status updates that show progress even without a fix yet, so the pressure has somewhere to go that isn't premature action.

**Two-minute senior answer.** The pressure to act is real and it's not irrational, a growing backlog and an anxious stakeholder asking for updates every few minutes is a genuine business cost accumulating in real time, and simply insisting on "the process" without acknowledging that cost reads as stalling. What actually worked here was two things together: one person with the standing to hold the line on sequencing, so that resistance to a premature fix didn't look like an individual being obstinate, and a fixed update cadence that reported real progress, "we've ruled out identity and network, now checking host health," even when that progress contained no fix. That second part matters more than it sounds: a stakeholder hearing specific, regular updates tolerates the process far better than one hearing silence, even if neither update contains the actual fix yet. The moment this was tested hardest was after layer 5 found the memory-pressure signal but before layer 6 connected it to a cause, when restarting the affected hosts as an interim fix was genuinely tempting and would have destroyed the evidence trail needed to find the real root cause.

**Deep-dive points.** The specific 30-minute update cadence used here and why that interval, not more frequent (which would interrupt the actual diagnosis) or less frequent (which would feel like silence to an anxious stakeholder).

**Expected follow-up.** "What if the incident lead is wrong to hold the line, and the pressure to act sooner was actually justified?" the incident lead's call is a judgement call, not infallible, and should be revisited if a layer check reveals the delay itself is causing measurable additional harm, not held rigidly regardless of new information.

**Common weak answer.** Either caving to pressure and making an unproven change, or holding the line with no communication, leaving the stakeholder to assume nothing is happening.

**What the interviewer is testing.** Whether the candidate can manage the human and business pressure of a live incident without abandoning technical discipline, and specifically whether they understand that visible progress reporting is what makes discipline sustainable under pressure.

### Q4. The customer's own team made changes before you arrived that didn't help. How do you handle that conversation without it feeling like blame?

**30-second answer.** Frame it as a pattern anyone falls into under pressure without a structured method, not a judgement on them specifically, and walk them through *why* each change seemed reasonable at the time it was made, not just that it didn't work.

**Two-minute senior answer.** A defensive customer team is a worse outcome for everyone, including the next incident, than one that's genuinely absorbed what happened and why, and the fastest way to make a team defensive is to make the handover feel like a report card on their mistakes. What worked here was walking through the reasoning behind each of Northgate's three prior changes, not just noting that none of them helped, because every one of those changes was a genuinely reasonable-sounding guess given what was visible to them at the time: hosts might be overloaded, so raise the session limit; Cloud Cache was flagged in a forum post as a known issue, so revert it. Reactive troubleshooting under pressure, without a structured method, reliably produces exactly this pattern of plausible but ineffective changes, in any team, and saying that plainly is what turns a walkthrough into something the team can actually use next time rather than something they feel defensive about.

**Deep-dive points.** The specific process change Northgate adopted afterward, a change log requirement logging the reasoning before a troubleshooting action is taken, not after, and why that specifically addresses the root cause of this incident's confused starting picture.

**Expected follow-up.** "What if the customer team gets defensive anyway?" stay focused on the specific, factual sequence of events and their reasoning rather than characterising their competence, and let the walkthrough's honesty about how common this pattern is do the reassurance work.

**Common weak answer.** Either avoiding any discussion of what the customer's team did wrong, leaving them likely to repeat the pattern, or delivering the finding in a way that reads as criticism rather than a shared lesson.

**What the interviewer is testing.** Whether the candidate can deliver an honest technical finding about a customer's own actions in a way that builds their capability rather than damaging the relationship.

### Q5. The root cause turned out to be an application memory leak the vendor had already patched. Was this really an AVD problem to solve?

**30-second answer.** The root cause was an application issue, but the platform-level work, isolating it to a specific host subset, connecting it to a stalled image rollout, and fixing it through the golden-image pipeline rather than a manual patch, is squarely AVD engineering. The two aren't separable in practice.

**Two-minute senior answer.** It's tempting to draw a hard line between "application problems" and "platform problems" and treat the former as someone else's job, but that line doesn't hold up on a shared, pooled AVD estate the way it might on individual physical desktops. One application's memory leak on 12 shared hosts affected every other session and application running on those same hosts, not just the merchandising application's own users, because pooled hosts share resources. Diagnosing that required platform-level tools and platform-level reasoning, the 10-layer method, host telemetry, image-version cross-referencing, and the actual fix was delivered through platform mechanics, a golden-image update and a controlled host replacement, not a manual patch applied host by host. The vendor owned the bug. The AVD engineering owned finding it, containing its blast radius, and fixing it correctly within the platform's own operating model. Both things are true, and treating this as "not our problem because it's an application bug" would have left Northgate with no path to actually resolving it.

**Deep-dive points.** Why the fix went through a new golden image version and a drain-and-replace, rather than patching the application directly on the 12 running hosts, consistent with the golden-image discipline covered elsewhere in this book.

**Expected follow-up.** "Should Northgate now hold their vendor accountable for the four weeks the patch sat unapplied?" that's a legitimate question for Northgate's own vendor management process, but the more actionable finding for AVD operations was the process gap, no one tracking that vendor's release notes against Northgate's own deployed version, which is what actually changed afterward.

**Common weak answer.** Treating the incident as fully resolved once the vendor's bug is identified, without addressing the platform-level detection and containment work that made the diagnosis and fix possible.

**What the interviewer is testing.** Whether the candidate understands that shared, pooled infrastructure blurs the line between "application problem" and "platform problem," and that platform engineering still owns diagnosis and containment even when the root cause originates elsewhere.

---

## 11. Official Microsoft references

- [Troubleshoot Azure Virtual Desktop client connections](https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-desktop/connection-client)
- [Monitor Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/azure-monitor)
- [Azure Virtual Desktop Insights](https://learn.microsoft.com/en-us/azure/virtual-desktop/insights)
- [Manage the Azure Virtual Desktop Agent](https://learn.microsoft.com/en-us/azure/virtual-desktop/agent-updates)
