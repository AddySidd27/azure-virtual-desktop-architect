# Runbook 04 - Slow Sign-In or Shift-Start Logon Storm

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Related:** [Chapter 20](../chapters/ch20-profile-storage-architecture.md), [Project 02](../scenarios/project-02-enterprise-850-users.md), [Project 07](../scenarios/project-07-call-centre-high-density.md), [Lab 10](../labs/lab-10-operations.md)
> **Format:** [Operations and troubleshooting standard](../OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md)

---

## Symptom

Sign-in takes noticeably longer than usual, often specifically at the start of a shift or working day, and returns to normal later.

## Business impact

Every affected user loses real working time, repeatedly, at the same predictable point each day. It is rarely a total outage, which is part of why it persists: it is easy to normalise as "AVD is just a bit slow in the morning" rather than investigated as the storage or host capacity problem it usually is.

## Scope questions

- Is this every user, or a specific host pool / persona?
- Does it happen only at a specific time of day, or throughout?
- Has it always been this way, or did it start after a specific change (headcount growth, a new team onboarded, an image update)?

## Recent-change questions

- Has headcount on this host pool grown recently?
- Was profile storage resized, or has average profile size grown noticeably?
- Was a new team or shift added to an existing host pool?
- Was the session limit or host size changed recently?

## Evidence to collect first

The single most valuable diagnostic step in this runbook is decomposing sign-in time into its parts, rather than treating it as one number.

```kusto
// Logon duration by percentile, for the affected window
WVDCheckpoints
| where TimeGenerated > ago(7d)
| where hourofday(TimeGenerated) between (8 .. 10) // adjust to the affected window
| summarize arg_max(TimeGenerated, *) by CorrelationId, Name
| summarize Duration = max(TimeGenerated) - min(TimeGenerated) by CorrelationId
| summarize p50 = percentile(Duration, 50), p95 = percentile(Duration, 95)
```

```kusto
// Where the sign-in storm actually is, by five-minute bucket
WVDConnections
| where TimeGenerated > ago(7d)
| where State == "Connected"
| summarize Connections = count() by bin(TimeGenerated, 5m)
| order by Connections desc
| take 20
```

```bash
# Storage latency for the same window
az monitor metrics list \
  --resource "$(az storage account show -n <storage_account_name> -g <storage-resource-group> --query id -o tsv)" \
  --metric "SuccessServerLatency" --interval PT5M \
  --start-time <window-start-utc> --end-time <window-end-utc> -o table
```

```bash
# FSLogix container attach time on a sample of hosts during the affected window
az vm run-command invoke -g <hosts-resource-group> -n <vm-name> \
  --command-id RunPowerShellScript \
  --scripts "Get-Content 'C:\ProgramData\FSLogix\Logs\Profile' -Tail 200 | Select-String 'Attach'"
```

`[VERIFY BEFORE IMPLEMENTATION]` confirm current table names in your Log Analytics workspace; AVD diagnostic table names have changed and depend on when diagnostic settings were first configured, as covered in [Lab 10](../labs/lab-10-operations.md).

## Initial hypotheses, ranked by frequency

1. **Storage IOPS ceiling hit during a sign-in burst.** Profile storage sized for steady state, not for the concentrated demand of many people signing in within a short window.
2. **Profile size grown beyond what was originally planned**, making every mount slower regardless of storage tier.
3. **Session host capacity undersized for the burst**, so users queue for a host before profile mount is even reached.
4. **Identity dependency latency** (a distant or overloaded domain controller) adding time before profile mount is reached at all.

## Fast triage decision tree

```
Decompose the sign-in: is the slow phase profile mount, or something before it?
├── Profile mount is slow, other phases normal
│     → Storage-side problem. Check storage latency (step 3) against the
│       burst window (step 2): if they move together, it is storage
│       capacity or profile size, not FSLogix configuration.
├── Time before profile mount is slow (host allocation, authentication)
│     → Check host pool capacity/scaling timing against the burst window,
│       and check identity/DNS latency (see Runbook 01 evidence steps for
│       DC-related checks) before assuming this is a profile issue at all.
└── Slow throughout the day, not specific to a burst window
      → This is not a logon storm. Investigate host sizing/density
        (Chapter 17) or a systemic network issue instead.
```

## Root-cause indicators

| Evidence | Root cause |
|---|---|
| Storage latency rises sharply during the burst window and returns to normal after | Storage IOPS ceiling reached during the sign-in burst |
| Average profile size has grown well beyond the original sizing assumption | Profile bloat, likely missing exclusions: see Chapter 21 |
| Storage latency stays flat, but host CPU is saturated during the burst | Host capacity, not storage: a sizing/scaling problem, not a profile problem |
| Sign-in slow even for users who signed in an hour ago and are reconnecting | Not a logon storm at all; investigate more broadly rather than continuing down this runbook |

## Remediation

**Immediate relief, if profile size is a contributing factor:** apply or verify FSLogix exclusions per [Chapter 21](../chapters/ch21-fslogix-production-implementation.md#4-controlling-profile-size). This stops further growth immediately; it does not shrink existing containers.

**If storage capacity is the root cause:** increase provisioned IOPS/throughput on the share, or move to a higher storage tier, sized from the measured burst rather than from a guess. See the sizing method in [Chapter 20](../chapters/ch20-profile-storage-architecture.md#3-sizing-from-the-sign-in-storm).

**If profile bloat is significant:** schedule compaction to reclaim space from existing containers, understanding this is a separate action from exclusions and carries its own sign-out time cost: pilot it before applying broadly, per [Chapter 22](../chapters/ch22-profile-operations-failure-recovery.md#5-growth-and-compaction).

**If host capacity is the root cause:** review session limit and host count against measured density, following [Chapter 17](../chapters/ch17-session-host-sizing-compute-selection.md#2-a-sizing-method-you-can-defend), and consider whether the scaling plan's ramp-up window ([Lab 10](../labs/lab-10-operations.md)) starts early enough to have capacity ready before the burst, not during it.

## Validation

- Measure sign-in p95 for the same time window for a full week after the change, not for one day: a single good morning is not proof.
- Confirm storage latency stays flat through the burst window after the fix.

## Rollback

A storage tier increase has no meaningful rollback risk beyond cost: reducing it later if the burst pattern changes is safe. A session limit or host count change should be rolled back if it introduces a new problem (for example, raising the session limit and seeing memory pressure) rather than left in place while chasing a second issue.

## Prevention

- Size profile storage from the measured busiest fifteen minutes of sign-ins, not from total user count or average load.
- Configure FSLogix exclusions before go-live, not after profiles are already large.
- Alert on storage latency during known burst windows as a leading indicator, before it becomes a user complaint.
- Re-run the burst sizing calculation whenever headcount on a host pool changes by a meaningful amount.

## Escalation criteria

Escalate to Microsoft support when storage metrics show the platform is healthy and within documented limits, host capacity is confirmed adequate, and sign-in remains slow with no identifiable bottleneck in the decomposed timing.

## Evidence for a Microsoft support case

- The decomposed logon duration query results (step 1) for the affected window.
- Storage account metrics (latency, transactions, throttling if applicable) for the same window.
- Average and maximum profile container size.
- Host pool session limit, host count, and scaling plan configuration.

## Official Microsoft references

- [Storage options for FSLogix profile containers](https://learn.microsoft.com/en-us/azure/virtual-desktop/store-fslogix-profile)
- [Monitor Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/azure-monitor)
- [Autoscale scenarios for Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/autoscale-scenarios)
