# KQL Query Library

These queries are starting points for an AVD Log Analytics workspace. Confirm the available tables and columns in the target workspace before using them in alerts. AVD diagnostic tables use the `WVD` prefix, while session-host performance and event data depends on the Data Collection Rule.

## Table inventory

```kusto
search *
| where TimeGenerated > ago(24h)
| summarize Rows = count() by $table
| order by Rows desc
```

## AVD errors by code

```kusto
WVDErrors
| where TimeGenerated > ago(24h)
| summarize Occurrences = count() by CodeSymbolic, Message
| order by Occurrences desc
```

## Connection outcomes

```kusto
WVDConnections
| where TimeGenerated > ago(24h)
| summarize Connections = count() by State
| order by Connections desc
```

## Connection activity by host pool

```kusto
WVDConnections
| where TimeGenerated > ago(7d)
| summarize Connections = count() by _ResourceId, bin(TimeGenerated, 1h)
| order by TimeGenerated desc
```

## Session-host CPU trend

```kusto
Perf
| where TimeGenerated > ago(24h)
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| summarize AverageCPU = avg(CounterValue), P95CPU = percentile(CounterValue, 95)
    by Computer, bin(TimeGenerated, 15m)
| order by TimeGenerated desc
```

## Session-host available memory

```kusto
Perf
| where TimeGenerated > ago(24h)
| where ObjectName == "Memory" and CounterName == "Available MBytes"
| summarize MinimumAvailableMB = min(CounterValue)
    by Computer, bin(TimeGenerated, 15m)
| order by TimeGenerated desc
```

## Query validation checklist

- [ ] The required resource diagnostic settings are enabled.
- [ ] Azure Monitor Agent is installed on every monitored session host.
- [ ] The Data Collection Rule collects the required counters and event logs.
- [ ] The query returns known test activity.
- [ ] User identifiers and exported evidence are handled according to privacy requirements.
- [ ] Alert thresholds are based on a measured baseline, not copied from this repository.

## Official Microsoft references

- [Send AVD diagnostics to Log Analytics](https://learn.microsoft.com/en-us/azure/virtual-desktop/diagnostics-log-analytics)
- [Enable AVD Insights](https://learn.microsoft.com/en-us/azure/virtual-desktop/insights)
- [Monitor connection quality](https://learn.microsoft.com/en-us/azure/virtual-desktop/connection-quality-monitoring)
- [Monitor Autoscale with Insights](https://learn.microsoft.com/en-us/azure/virtual-desktop/autoscale-monitor-operations-insights)
