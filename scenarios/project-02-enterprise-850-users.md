# Project 02 - Calderbank Group: 850-User Enterprise Operating Model

> **Fictional architecture case study:** Calderbank Group is not a customer delivery record. Requirements, measurements, costs, tests, and outcomes are worked examples or validation targets unless separate lab evidence is linked.

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Part XI:** Architecture Case Studies
> **Standard:** [PROJECT-STANDARD.md](../PROJECT-STANDARD.md)
> **Technical baseline:** August 2026
> **Concepts introduced here:** monitoring architecture, AVD Insights, KQL for AVD, alerting thresholds, day-2 operations

---

## Engagement brief

**What this represents.** A mid-sized business that already runs AVD badly and has asked for help. This is the most common AVD engagement in the market. Not greenfield, not a migration from another platform, just an environment that was deployed by a project team, handed to nobody, and has quietly degraded.

**The business problem.** Users complain. The IT director cannot say whether the complaints are justified, because there is no data. They have been asked by the board to either fix it or move to something else, and they have four months.

**Constraints that cannot be designed away.** The platform is live and 850 people use it daily. There is no maintenance window longer than four hours. The existing host pools cannot simply be deleted and rebuilt during business hours. Budget for change is capped at 20 percent above current run cost.

**Previously learned concepts applied.** Host pool design and load balancing ([Chapter 15](../chapters/ch15-host-pool-design-decisions.md)), sizing ([Chapter 17](../chapters/ch17-session-host-sizing-compute-selection.md)), profiles and storage ([Chapters 19 to 22](../chapters/ch19-why-profiles-cause-avd-failure.md)), images ([Chapter 23](../chapters/ch23-golden-image-engineering.md)), management approaches ([Chapter 16](../chapters/ch16-automated-host-pools-session-host-configuration.md)).

**New concepts introduced here.** Monitoring architecture and what to collect, AVD Insights, the KQL an AVD engineer actually uses, alert thresholds that mean something, and the day-2 operating model that turns a deployment into a service.

**Architectural decisions to make.** Whether to fix in place or rebuild alongside. Whether to keep one host pool or split by persona. What to measure before changing anything. Who owns the platform afterwards.

**What could realistically go wrong.** Changing things before measuring, and fixing the wrong problem. Rebuilding host pools during business hours. Discovering that the complaints are about one application and not the platform at all.

**Validation and handover.** Every change proven with the same measurement that identified the problem, and an operations team that can run the platform without the consultant.

---

## 1. The situation as found

**Calderbank Group.** An 850 person insurance broker across four UK offices. AVD deployed eighteen months ago by a partner who has since left the account.

What the assessment found in week one.

| Finding | Detail |
|---|---|
| Host pools | One pooled host pool for all 850 users |
| Session hosts | 60 hosts, Standard D4s v3, 4 vCPU, 16 GB, running continuously |
| Load balancing | Depth-first, max session limit 15 |
| Image | Built once, eighteen months ago, never rebuilt |
| Profiles | Azure Files Standard, LRS, no exclusions configured |
| Monitoring | Diagnostic settings not configured. No Log Analytics workspace |
| Scaling | None. All 60 hosts on, 24 hours a day, 7 days a week |
| Ownership | Nobody. The service desk resolves tickets by asking users to reconnect |

**Monthly run cost.** Roughly £41,000, almost all of it compute.

**The complaint pattern.** "It is slow in the morning." "It logs me out." "Word takes ages to open." Nobody had written any of it down.

**The first thing to say to the customer.** We are not changing anything for two weeks. That is uncomfortable and it is correct, because every change made now would be a guess, and a guess that appears to help is worse than no change at all.

---

## 2. Business and technical requirements

| ID | Requirement | Source |
|---|---|---|
| BR1 | Stop the complaints, measurably | Board |
| BR2 | Reduce run cost or justify it | Finance director |
| BR3 | Be able to answer "is the platform healthy" at any time | IT director |
| BR4 | An operations team that can run it without external help | IT director |
| TR1 | Sign-in under 40 seconds at the 95th percentile | Derived from complaints |
| TR2 | No user disconnected by the platform during working hours | Derived from complaints |
| TR3 | Session host CPU below 80 percent sustained at peak | Standard target |
| TR4 | Alerting on every failure class that has caused a ticket | Ticket analysis |
| TR5 | Patch level current within 45 days | Security review finding |

**TR1 and TR2 came from reading eight months of tickets**, not from a standard. That exercise took two days and it was the most valuable two days of the engagement, because it turned "users complain" into two numbers.

---

## 3. Personas, discovered rather than assumed

Nobody had documented who used the platform. Two weeks of connection data gave this.

| Persona | Users | Peak concurrent | Pattern | Applications |
|---|---|---|---|---|
| Claims handlers | 410 | 380 | 08:30 sharp start, steady all day | Policy system, Office, document viewer |
| Brokers | 260 | 180 | Staggered, in and out, some client sites | Policy system, Office, quoting tools, Teams heavy |
| Finance and back office | 120 | 95 | Fixed hours | Finance system, Office, Excel heavy |
| Management and support | 60 | 30 | Irregular | Office, reporting tools |

**Total peak concurrency 685, against 850 named users.** The platform was sized for 850, which is part of why it cost £41,000 a month.

**The Excel finding.** Finance users run large models. On a 4 vCPU host shared with fourteen others, one recalculation degrades everyone. That single fact explained a disproportionate share of the complaints and it did not appear in any ticket, because the people complaining were the claims handlers sitting next to them on the same host.

---

## 4. Concept introduced: monitoring architecture

Nothing else in this engagement is possible without this, so it comes first.

### What to collect, and what not to

Monitoring an AVD estate means four data sources, and the mistake is either collecting nothing or collecting everything.

| Source | What it gives you | Cost shape |
|---|---|---|
| AVD diagnostics | Connections, errors, checkpoints, host registration | Low volume, high value |
| Session host performance counters | CPU, memory, disk, user count | Volume depends entirely on which counters and how often |
| Storage metrics | Latency, transactions, throttling | Free, in Azure Monitor metrics |
| Entra sign-in logs | Authentication and Conditional Access outcomes | Moderate volume |

**AVD diagnostics are opt in.** Nothing arrives until diagnostic settings are configured on each host pool, workspace and application group. This is the single most common monitoring gap in AVD, and it was the situation here. Eighteen months of an estate with no connection history.

**Performance counters are where cost gets away from people.** Collecting every counter at 15 second intervals from 60 hosts produces a large monthly ingestion bill for data nobody queries. Collect the counters that map to a decision.

For an AVD estate that is: processor time, available memory, logical disk queue length and free space, plus the terminal services session counts.

### Setting it up

```bash
# Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group rg-cbg-monitoring-prd-uks-01 \
  --workspace-name log-cbg-avd-prd-uks-01 \
  --location uksouth \
  --retention-time 90

# Diagnostic settings on the host pool
az monitor diagnostic-settings create \
  --name diag-hostpool \
  --resource $(az desktopvirtualization hostpool show \
      --name hp-cbg-general-prd-uks-01 \
      --resource-group rg-cbg-avd-prd-uks-01 --query id -o tsv) \
  --workspace $(az monitor log-analytics workspace show \
      --resource-group rg-cbg-monitoring-prd-uks-01 \
      --workspace-name log-cbg-avd-prd-uks-01 --query id -o tsv) \
  --logs '[{"category":"Checkpoint","enabled":true},{"category":"Error","enabled":true},{"category":"Management","enabled":true},{"category":"Connection","enabled":true},{"category":"HostRegistration","enabled":true}]'
```

**What this does.** Creates the workspace and starts sending host pool diagnostics to it.
**Prerequisites.** Contributor on both resource groups.
**Expected result.** Connection data appears within about fifteen minutes. Not instantly, which causes people to think it failed.
**Common failure.** Configuring diagnostics on the host pool and forgetting the workspace and application groups. You then have connection data with no feed data, and empty feed problems become invisible.

`[VERIFY BEFORE IMPLEMENTATION]` Diagnostic log category names have changed over time. Confirm the current categories for each resource type before scripting this.

**Do it in Terraform, not by hand**, so a new host pool cannot exist without diagnostics:

```hcl
resource "azurerm_monitor_diagnostic_setting" "hostpool" {
  name                       = "diag-hostpool"
  target_resource_id         = azurerm_virtual_desktop_host_pool.general.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.avd.id

  enabled_log { category = "Checkpoint" }
  enabled_log { category = "Error" }
  enabled_log { category = "Management" }
  enabled_log { category = "Connection" }
  enabled_log { category = "HostRegistration" }
}
```

### AVD Insights

Azure Monitor provides a built-in AVD workbook. Turn it on, use it, and know its limits.

**What it is good for.** Connection counts, host availability, logon duration breakdown, and the input errors that map to user-visible failures. It is the fastest way to see the shape of an estate.

**What it is not.** A replacement for alerting, and not a substitute for knowing KQL. Insights answers the questions its authors anticipated. An incident asks a question they did not.

`[VERIFY BEFORE IMPLEMENTATION]` Insights requires specific counters and event logs to be collected. Confirm the current prerequisite list before relying on any panel, because a panel with missing data looks like a healthy estate rather than a broken configuration.

---

## 5. Concept introduced: the KQL an AVD engineer actually uses

Six queries cover most of the work. `[VERIFY BEFORE IMPLEMENTATION]` confirm table names in your workspace, because AVD table naming has changed and depends on when diagnostics were configured.

**Where the sign-in storm actually is.** This is the query that sized the storage decision in this engagement.

```kusto
WVDConnections
| where TimeGenerated > ago(14d)
| where State == "Connected"
| summarize Connections = count() by bin(TimeGenerated, 5m)
| order by Connections desc
| take 20
```

**Logon duration by percentile.** The number in TR1.

```kusto
WVDCheckpoints
| where TimeGenerated > ago(7d)
| summarize arg_max(TimeGenerated, *) by CorrelationId, Name
| summarize Duration = max(TimeGenerated) - min(TimeGenerated) by CorrelationId
| summarize p50 = percentile(Duration, 50), p95 = percentile(Duration, 95)
```

**Which hosts users actually land on.** This is how the depth-first imbalance was proven.

```kusto
WVDConnections
| where TimeGenerated > ago(7d)
| where State == "Connected"
| summarize Sessions = count() by SessionHostName
| order by Sessions desc
```

**Errors by type, ranked.** Start every investigation here.

```kusto
WVDErrors
| where TimeGenerated > ago(7d)
| summarize Count = count() by CodeSymbolic, ServiceError
| order by Count desc
```

**Disconnects, and whether they cluster.** TR2 came from this.

```kusto
WVDConnections
| where TimeGenerated > ago(7d)
| where State == "Completed"
| summarize Disconnects = count() by SessionHostName, bin(TimeGenerated, 1h)
| where Disconnects > 5
| order by Disconnects desc
```

**Users per host over time**, to see whether load balancing is doing what you set.

```kusto
Perf
| where TimeGenerated > ago(1d)
| where ObjectName == "Terminal Services" and CounterName == "Active Sessions"
| summarize AvgSessions = avg(CounterValue) by Computer, bin(TimeGenerated, 1h)
| order by TimeGenerated desc
```

**How to use them.** Not one at a time. Run the error query and the disconnect query together, and if disconnects cluster on the hosts with the most errors you have a host problem. If they spread evenly you have a network or client problem. That comparison takes a minute and removes half the possibilities.

---

## 6. What the data said

Two weeks of measurement, before any change.

| Measurement | Result | Conclusion |
|---|---|---|
| Peak concurrency | 685 | Platform sized for 850 |
| Sign-in p95, 08:25 to 08:45 | 2 minutes 50 seconds | TR1 badly missed |
| Sign-in p95, rest of day | 22 seconds | Storm problem, not a platform problem |
| Storage latency during the storm | Elevated, sustained | Storage is the bottleneck |
| Host session distribution | Top 12 hosts at 15 sessions, bottom 20 at fewer than 3 | Depth-first with an unmeasured limit |
| CPU on the busiest hosts | Above 90 percent at peak | Session limit too high for the host size |
| Disconnects | Clustered on 6 hosts, all with agent errors | Six broken hosts, not a platform fault |
| Profile size, average | 34 GB | No exclusions, eighteen months of cache |

**The diagnosis in one sentence.** Undersized hosts with an unmeasured session limit, an untuned storage tier, oversized profiles and six broken hosts, on a platform that ran at full capacity around the clock.

**None of that was guessable.** Every plausible theory offered in week one, including "we need bigger hosts" and "Azure is slow", was partly wrong.

---

## 7. Architecture decisions

### AD1: Fix in place, or build alongside

**Requirement.** Fix a live platform serving 850 people with no maintenance window longer than four hours.

**Option A, fix in place.** Change the session limit, add exclusions, replace broken hosts, retune storage on the existing pool.

**Option B, build alongside.** New host pools with the correct design, migrate users by persona, retire the old pool.

| Dimension | Fix in place | Build alongside |
|---|---|---|
| Risk to live users | Every change affects everyone | Contained. Migrate a persona at a time |
| Speed to first improvement | Days | Weeks |
| Ability to roll back | Limited | Complete. Users go back to the old pool |
| Cost during transition | None | Both estates running for six weeks |
| Fixes the image problem | No. Eighteen month old image stays | Yes |

**Decision. Both, in sequence.**

Fix in place first, for the things that are safe and immediate: session limit, exclusions, replacing broken hosts. Those relieve the pain within a week and buy credibility.

Then build alongside for the structural changes: new host pools, current image, session host configuration, persona split. Migrate by persona over six weeks.

**Reason.** The customer needed a visible improvement quickly, and the structural problems could not be fixed safely in place. Doing only the second would have meant six weeks of continued complaints while a better platform was built, which is technically correct and politically fatal.

**The cost of the decision.** Six weeks of double running, roughly £14,000. Presented up front as the price of a safe migration, and accepted.

### AD2: One host pool or split by persona

**Decision.** Three pooled host pools plus one personal pool.

| Pool | Persona | Users | Host size | Session limit |
|---|---|---|---|---|
| `hp-cbg-claims-prd-uks-01` | Claims handlers | 410 | D8as v5 | 9 |
| `hp-cbg-brokers-prd-uks-01` | Brokers, management | 320 | D8as v5 | 8 |
| `hp-cbg-finance-prd-uks-01` | Finance and back office | 120 | D16as v5 | 6 |
| `hp-cbg-power-prd-uks-01` | Six heavy Excel users | 6 | Personal, D8as v5 | Not applicable |

**Reason.** Finance were degrading everyone else. Separating them was the single highest-value structural change, and it came from data rather than from a persona workshop.

**Why not one pool per office.** Four offices, four capacity floors, no technical difference between them. Geography is not a sizing driver ([Chapter 15](../chapters/ch15-host-pool-design-decisions.md#4-how-many-host-pools)).

**The decision against the obvious answer.** Brokers and management share a pool despite very different job roles, because their sizing and application profile are the same and management is only 30 concurrent users.

### AD3: Session limit, from measurement

Old limit 15 on a 4 vCPU host. New limits set from pilot measurement on the new host size.

| Persona | Assumed | Measured | Set | Binding resource |
|---|---|---|---|---|
| Claims | 10 | 9 | 9 | Memory |
| Brokers | 10 | 8 | 8 | Memory, Teams |
| Finance | 8 | 6 | 6 | CPU, Excel recalculation |

**Finance is the only CPU bound persona in this estate.** Everywhere else memory binds first, which is the usual pattern ([Chapter 17](../chapters/ch17-session-host-sizing-compute-selection.md#2-a-sizing-method-you-can-defend)).

### AD4: Storage

Existing Azure Files Standard LRS moved to Premium, ZRS.

**Sizing from the burst**, using the measured storm rather than an assumption.

| Input | Value | Source |
|---|---|---|
| Users signing in during the busiest 5 minutes | 240 | Measured |
| Burst window used for sizing | 15 minutes, 390 users | Measured |
| IOPS for the burst at 50 per user | 19,500 | Calculation |
| Users already working at 10 IOPS | 295 | Calculation |
| Peak requirement | Approximately 19,800 | Calculation |
| Profile size after exclusions | Target 12 GB from 34 GB | Decision |

**LRS to ZRS is not optional here.** 850 users depending on one share in one zone, in a business that stops working without it.

**The 34 GB profiles are a cost problem and a performance problem.** Exclusions were applied in week two as part of the safe changes, and compaction ran over the following month ([Chapter 22](../chapters/ch22-profile-operations-failure-recovery.md#5-growth-and-compaction)).

---

## 8. Concept introduced: alert thresholds that mean something

An alert nobody acts on is noise, and noise is worse than no alerting because it teaches people to ignore the channel.

Every alert here maps to a ticket class that actually occurred in the eight months of history.

| Alert | Condition | Why this threshold | Action |
|---|---|---|---|
| No host accepting sessions | Any host pool, any occurrence | Total outage. Happened twice, both after maintenance | Page immediately |
| Host unavailable | More than 2 hosts for 15 minutes | Capacity risk. One host is normal churn | Ticket, same day |
| Sign-in p95 above 40 seconds | Sustained 15 minutes in the 08:00 to 09:30 window | TR1 | Ticket, investigate storage first |
| Storage latency elevated | Sustained above baseline during the storm | Leading indicator of the above | Ticket, capacity review |
| Host CPU above 80 percent | Sustained 15 minutes | TR3 | Ticket, density review |
| Disconnects on one host | More than 5 in an hour | The six broken hosts pattern | Drain and rebuild that host |
| Temporary profile created | Any occurrence | Earliest signal of a profile failure | Ticket, immediate |
| Image version age | Older than 45 days | TR5 | Ticket to the image owner |

**Two deliberate omissions.** No alert on individual connection errors, because users retry and the noise would swamp everything. No alert on memory, because in this estate memory pressure shows up as sign-in duration first and the duration alert fires earlier.

**The alert that mattered most.** Temporary profile creation. It is the earliest possible warning of a storage or identity problem, and it fires before users work out what is wrong and call.

---

## 9. Concept introduced: the day-2 operating model

The technical fix was the easy half. BR4 was the hard half, because a platform with no owner degrades again within a year.

### Who does what

| Role | Responsibility | Access |
|---|---|---|
| Service desk | Sign out stuck sessions, message users, clear locked profiles | User Session Operator, Reader |
| Platform operations | Drain and rebuild hosts, respond to alerts, monthly image rollout | Session Host Operator, VM Contributor on the hosts resource group |
| Platform engineering | Configuration changes, capacity decisions, Terraform | Desktop Virtualization Contributor, PIM for privileged actions |
| Service owner | Cost, capacity forecast, monthly report to the board | Reader plus cost management |

**The service owner role did not exist before this engagement.** It is a named person with two hours a week, and it is the reason the platform will still be healthy in a year.

### The operating calendar

| Cadence | Activity |
|---|---|
| Daily | Review alerts from the previous 24 hours |
| Weekly | Sign-in p95, host CPU trend, profile size trend |
| Monthly | Image build, rollout, cost review, capacity forecast |
| Quarterly | Density re-measurement, restore test, DR test |
| Annually | Architecture review against current Microsoft guidance |

**Quarterly density re-measurement is the one that gets dropped**, and it is the one that prevents this whole engagement happening again. It went in the calendar with the service owner's name against it.

### The monthly report

One page, four numbers, to the IT director and the board.

- Sign-in p95 during the morning window
- Peak concurrency against capacity
- Run cost against forecast
- Patch level age

**Four numbers, monthly, is enough.** More than that and nobody reads it, which is how a platform becomes unowned in the first place.

---

## 10. Scaling and cost

Scaling was not deployed until the persona split was complete, because scaling a badly balanced pool amplifies the imbalance.

| Phase | Time | Behaviour |
|---|---|---|
| Ramp-up | 07:00 to 08:20 | Breadth-first, full capacity available by 08:20 |
| Peak | 08:20 to 17:30 | Depth-first |
| Ramp-down | 17:30 to 19:00 | Depth-first, consolidate and deallocate, forced logoff 19:30 with warning |
| Off-peak | 19:00 to 07:00 | Two hosts per pool |

**Weekends.** Two hosts per pool. Brokers work Saturday mornings.

### Cost outcome

`[VERIFY BEFORE IMPLEMENTATION]` indicative shapes, UK South, priced at design time.

| Line | Before | After |
|---|---|---|
| Session host compute | £38,500 | £19,200 |
| Storage | £900 | £2,400 |
| Log Analytics | £0 | £850 |
| Networking and other | £600 | £700 |
| **Total** | **£41,000** | **£23,150** |

**A 43 percent reduction while fixing the performance problem.** That combination is unusual and it happened because the original estate was both oversized and misconfigured. Most engagements trade cost against performance. This one did not, and it is worth being honest that the saving came from correcting a bad deployment rather than from clever architecture.

**Storage cost went up and that is correct.** Moving from Standard LRS to Premium ZRS nearly tripled it. It bought the sign-in improvement and the zone resilience, and against a £19,000 compute saving it is not a difficult conversation.

**Log Analytics is a new cost line that did not exist before.** £850 a month for the ability to answer BR3. The IT director signed that off in one sentence.

---

## 11. Deployment and migration

Six weeks, persona by persona, with the old pool available as rollback throughout.

| Week | Activity | Gate |
|---|---|---|
| 0 | Measurement only. No changes | Baseline recorded |
| 1 | Safe fixes: session limit to 10, exclusions applied, six broken hosts rebuilt | Sign-in p95 improves measurably |
| 2 | Monitoring, alerting, new image build | Alerts fire on induced conditions |
| 3 | New host pools created, 20 pilot users across personas | Pilot sign-in under 40 seconds |
| 4 | Storage migrated to Premium ZRS, profiles copied | Profile mount confirmed for pilot users |
| 5 | Claims handlers migrated, 410 users in two waves | Ticket volume flat per wave |
| 6 | Brokers, finance and management migrated | All personas on new pools |
| 7 | Old pool drained, hosts deleted, scaling enabled | Cost drops as forecast |
| 8 | Handover. Operations complete each runbook unaided | BR4 evidenced |

**Week 0 was the hardest to sell and the most valuable.** Two weeks of no visible action while people complain requires the IT director to hold the line. The way to make that possible is to show them the data arriving daily, so the absence of change does not look like the absence of work.

**Profile migration.** Containers copied rather than recreated, so users keep their data. Done per wave, overnight, with the old share retained read-only for two weeks.

---

## 12. Validation

| Requirement | Test | Result |
|---|---|---|
| TR1 | Sign-in p95 in the 08:00 to 09:30 window, one week | 31 seconds, from 2 minutes 50 |
| TR2 | Platform-caused disconnects during working hours | Zero over two weeks |
| TR3 | Host CPU 95th percentile at peak | 71 percent |
| TR4 | Each alert fired on an induced condition | All eight confirmed |
| TR5 | Image version age | 12 days at handover |
| BR3 | IT director answers "is it healthy" from the dashboard | Demonstrated in the handover meeting |
| BR4 | Operations complete all runbooks unaided | Signed off |

**TR2 needed care.** Zero disconnects over two weeks does not prove the fault is gone, it proves it has not recurred. The honest position given to the customer was that the six hosts causing it were rebuilt, the alert now catches the pattern within an hour, and if it recurs they will know before users call.

---

## 13. Failure scenarios, induced before handover

| Induced | Expected experience | Alert |
|---|---|---|
| Drain every host in one pool | New connections fail, existing continue | No host accepting sessions |
| Stop the agent on one host | Users move to other hosts | Host unavailable, after threshold |
| Break storage permissions for one user | Temporary profile for that user | Temporary profile created |
| Saturate one host with synthetic load | Users on that host degrade | Host CPU |
| Delete diagnostic settings | Nothing user-visible, data stops | None, and this is the gap |

**That last row is deliberate.** There is no alert for monitoring itself failing. It was pointed out at handover, and the mitigation is that the weekly review would notice missing data. That is a real limitation stated rather than hidden.

---

## 14. Troubleshooting, from this engagement

### Six hosts causing most of the disconnects

**Problem.** Users report being disconnected at random. It is not tied to a person, a time or an office.

**Symptoms.** Disconnects across the estate. Users reconnect and continue. No pattern visible from tickets.

**Business impact.** Roughly 40 disconnects a day across 685 concurrent users. Individually minor, collectively the loudest complaint in the business, and for a claims handler mid-call it is a customer-facing failure.

**Initial assumption.** Not a network problem, because it is not tied to an office. More likely a subset of hosts.

**Investigation.** Run the disconnect clustering query from section 5. Then the error query for the same window. Then check agent status and version on the hosts that appear in both.

**Evidence.** Six hosts account for 71 percent of disconnects. All six show agent errors. All six were built from a failed deployment batch fourteen months earlier and had been reporting Available throughout.

**Root cause.** Six partially broken hosts that reported healthy. Available means the agent is reporting, not that the host can carry a session ([Chapter 18](../chapters/ch18-session-host-lifecycle-hybrid.md#2-session-host-status-and-health-checks)).

**Resolution.** Drain, remove, rebuild. No repair attempted. All six replaced in one evening.

**Validation.** Disconnects fell by roughly 70 percent the following day and stayed down.

**Prevention.** Alert on disconnects per host per hour, which is now in the alert set. The pattern is visible within an hour rather than fourteen months.

**Architect lesson.** Without monitoring, a defect affecting seven percent of hosts is invisible for over a year. The cost of no monitoring is not the incidents you cannot solve, it is the ones you never see.

**Interview lesson.** Explaining that you found the fault by clustering disconnects by host, rather than by investigating individual tickets, demonstrates how an engineer uses data rather than anecdote.

### Sign-in slow only between 08:25 and 08:45

**Problem.** Sign-in takes almost three minutes at the start of the day and 22 seconds an hour later.

**Symptoms.** Time-of-day pattern. No errors. Host CPU moderate during the window.

**Business impact.** 685 users losing over two minutes each, every working day. In a business that measures claims handling time, that is a directly quantifiable number and it is how the project was funded.

**Initial assumption.** Storage IOPS during the sign-in storm, given the time-of-day pattern and the absence of errors.

**Investigation.** Storm shape from the connection query. Storage latency for the same window from Azure Monitor metrics. Container attach time from the FSLogix logs.

**Evidence.** 240 sign-ins in the busiest five minutes. Storage latency elevated for exactly that window. Attach time tracks it. Profiles averaging 34 GB, so each mount is far larger than it should be.

**Root cause.** Standard tier storage sized for capacity, with oversized profiles, meeting a concentrated storm.

**Resolution.** Two changes with different timescales. Exclusions immediately, which stopped growth and helped new profiles. Premium ZRS in week four, which fixed the burst. Compaction over the following month reclaimed the space.

**Validation.** Sign-in p95 in the same window measured for a week after each change, not the day after.

**Prevention.** Storage latency alert as a leading indicator, and the burst calculation re-run whenever headcount changes by more than ten percent.

**Architect lesson.** Profile storage is sized by burst. Capacity sizing looks fine and fails at 08:30.

**Interview lesson.** The two-timescale fix, immediate exclusions and a later tier change, shows you can separate relief from resolution under pressure.

---

## 15. Runbooks handed over

Four, each completed by the operations team unaided during week 8.

```
Runbook: Session host showing repeated disconnects
Trigger:        Disconnect alert for a single host
Owner:          Platform operations
Prerequisites:  Session Host Operator, VM Contributor on the hosts resource group
Impact:         Users on that host are signed out during the rebuild
Rollback:       Not applicable. The host is replaced
Steps:
  1. Confirm from the disconnect query that the host is an outlier
  2. Put the host into drain mode
  3. Check for disconnected sessions and message affected users
  4. Sign out remaining sessions after the warning period
  5. Remove the host from the host pool
  6. Delete the VM and deploy a replacement from the current image
  7. Confirm the replacement reports Available with a recent status timestamp
Validation:     No disconnects on the replacement host over 48 hours
Escalation:     If more than three hosts show the pattern in a week, raise to engineering
```

Plus: **monthly image rollout**, **clear a locked profile container**, and **respond to a sign-in duration alert**. The last one is a decision tree rather than a procedure, because the answer depends on whether storage latency moved with it.

---

## 16. Trade-offs

| Trade-off | Given up | Why | What would change it |
|---|---|---|---|
| Six weeks double running | £14,000 | Safe migration with rollback for 850 live users | A longer maintenance window, which did not exist |
| Fixed in place first | Architectural purity | Credibility. The business needed visible improvement in week one | A customer with more patience, which is rare |
| Three pools, not four | Per-office tuning | Geography is not a sizing driver | Genuine regional application or latency differences |
| Premium storage cost | £1,500 a month | It bought the sign-in fix and zone resilience | Lower concurrency or a flatter sign-in curve |
| No alert on monitoring failure | A blind spot | No clean signal available. Weekly review is the mitigation | A synthetic check, which is on the roadmap |
| 90 day log retention | Longer trend analysis | Ingestion cost against a constrained budget | A compliance requirement for longer retention |

**The one that will be challenged.** Fixing in place before rebuilding is not what a purist would do. It changed a live platform based on two weeks of data rather than waiting for the full design. The defence is that the changes made in week one were low risk and reversible, and the alternative was six weeks of unresolved complaints while the business decided whether to abandon AVD entirely.

---

## 17. Interview questions from this engagement

### Q. You inherit an AVD platform with unhappy users and no monitoring. What do you do first?

**Strong answer**
"Nothing, for two weeks, except measure. That is uncomfortable and it is the right call, because every change made before you have data is a guess, and a guess that appears to help is worse than no change because it stops the investigation. I would configure diagnostic settings, which are opt in and are the most common gap, stand up a workspace, and read the ticket history in parallel. In the environment I am describing, that gave four findings nobody had predicted: peak concurrency was 685 against 850 named users, the estate was sized for the wrong number, six hosts caused 70 percent of disconnects, and profiles had grown to 34 GB. None of the theories offered in week one were right. Then I would sequence the fixes, safe and reversible first for credibility, structural changes second."

### Q. How would you know whether an AVD estate is healthy?

**Strong answer**
"Four numbers, and I would put them in front of the business monthly. Sign-in duration at the 95th percentile during the morning window, peak concurrency against capacity, run cost against forecast, and patch level age. Those four cover experience, capacity, money and risk. Underneath them I would alert on the failure classes that have actually caused tickets, not on everything that can be alerted on, because an alert nobody acts on trains people to ignore the channel. The one I would not skip is temporary profile creation, because it is the earliest signal of a storage or identity failure and it fires before users work out what is wrong."

### Q. Users complain about slow sign-in. Where do you start?

**Strong answer**
"With whether it is time-of-day specific, because that single fact splits the problem. Slow only at the start of the day is a sign-in storm hitting storage, and I would check storage latency against sign-in duration for the same window and expect them to move together. Slow all day is more likely host sizing or profile size. In this engagement it was the first, and the fix had two timescales: exclusions immediately, which stopped profile growth and helped new profiles, then a storage tier change in week four which fixed the burst properly. I would separate relief from resolution deliberately and tell the customer which is which, because otherwise the first improvement gets mistaken for the fix."

### Q. How would you measure and explain a reduction in platform cost?

**Honest answer**
"By correcting a bad deployment, not by clever architecture, and I would say that plainly. The estate was sized for 850 named users when peak concurrency was 685, ran 60 hosts continuously with no scaling, and used an undersized host with an unmeasured session limit so nobody had ever checked whether 15 users per host worked. Right-sizing, splitting personas so finance stopped degrading everyone, and enabling scaling took compute from £38,500 to £19,200. Storage went up because Standard LRS was wrong for the workload, and that increase bought the sign-in fix. Most engagements trade cost against performance. This one improved both, and only because it started from a poor baseline."

### Q. How do you stop it degrading again?

**Strong answer**
"Ownership, which was the actual root cause. The platform had no owner, so nothing was measured, nothing was patched and nothing was reviewed. I created a service owner role with two hours a week, an operating calendar with daily, weekly, monthly, quarterly and annual activities, and a one page monthly report with four numbers. The quarterly item that matters is density re-measurement, because that is what prevents the same engagement happening again in two years. And handover is a gate, not a document: the operations team completed every runbook unaided before I left."

---

## Project Self-Review

**Pass 1, technical verification.** Diagnostic settings, log categories and Insights prerequisites carry verification markers because category names and requirements have changed over time. KQL carries a verification marker for table naming. The Azure CLI and Terraform examples use documented resource types and arguments. All architectural positions trace to chapters where they were verified: session host status semantics ([Chapter 18](../chapters/ch18-session-host-lifecycle-hybrid.md)), sizing method and the memory-before-CPU pattern ([Chapter 17](../chapters/ch17-session-host-sizing-compute-selection.md)), storage burst sizing and premium redundancy limits ([Chapter 20](../chapters/ch20-profile-storage-architecture.md)), exclusions and compaction ([Chapters 21](../chapters/ch21-fslogix-production-implementation.md) and [22](../chapters/ch22-profile-operations-failure-recovery.md)), load balancing behaviour ([Chapter 15](../chapters/ch15-host-pool-design-decisions.md)). Costs are indicative shapes with a verification marker.

**Pass 2, human readability review.** Written as an engagement in the order the work happened: assess, measure, diagnose, decide, fix, hand over. New concepts appear where the engineer needs them rather than in a block. No section repeats a concept chapter. Sentences kept short. No long dash characters. Read back as a consultant handed this account, and section 4 was moved ahead of the decisions because nothing in the engagement is possible before monitoring exists.

**Pass 3, structure review against the revised standard.** No diagram in this project, deliberately. The architecture is three pooled host pools and a personal pool in one region, which is structurally the same as Project 01 and already drawn there. Drawing it again would be repetition, and the standard says depth is set by the engagement. What is unique here is the operating model and the measurement approach, and both are better expressed as tables and queries. This decision is recorded rather than left as an apparent omission.

**Concepts introduced, for the coverage map.** Monitoring architecture and what to collect. Diagnostic settings as an opt-in gap. AVD Insights and its limits. Six working KQL queries. Alert thresholds tied to real ticket classes. The day-2 operating model, roles, calendar and monthly report.

| Standard check | Result |
|---|---|
| Engagement brief answering all eight questions | Yes |
| Real numbers throughout | Yes. Concurrency, host counts, IOPS, latency, cost |
| Competing requirements resolved | Speed of relief against architectural correctness. Cost against storage tier |
| Constraints that cannot be designed away | Live platform, no long maintenance window, 20 percent budget cap |
| Decision against the obvious answer | Fixing in place before rebuilding, and brokers sharing with management |
| Problems that actually happen | Six silently broken hosts, sign-in storm, profile bloat, no ownership |
| Operational ownership addressed | Yes. Roles, calendar, report, handover gate |
| New concepts taught practically, not as theory | Yes |
| No repetition of concept chapters | Checked. All referenced |
