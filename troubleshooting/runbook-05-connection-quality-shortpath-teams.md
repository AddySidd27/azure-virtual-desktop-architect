# Runbook 05 - Poor Connection Quality, RDP Shortpath Failure, or Teams Optimisation Fallback

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Related:** [Chapter 14](../chapters/ch14-protocol-optimisation-network-performance.md), [Chapter 13](../chapters/ch13-hybrid-connectivity-egress-control.md)
> **Format:** [Operations and troubleshooting standard](../OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md)

---

## Symptom

Users describe the session as laggy, choppy, or generally poor quality, with no connection failure and no error message. Teams calls specifically may sound like a phone call rather than a clear VoIP call, with the local camera/microphone feeling disconnected from the shared window.

## Business impact

This is a silent-degradation problem: it produces complaints without tickets, because nothing has technically failed. Users tolerate it, work around it, or lose confidence in the platform, and it rarely reaches an engineer with the same urgency as an outage even though the cumulative cost across many users can be larger than a short outage would be.

## Scope questions

- Is this specific users, specific locations, or specific host pools?
- Home network users, office network users, or both?
- Teams calls specifically, or the whole session in general?

## Recent-change questions

- Was outbound UDP recently blocked or restricted on the session host subnet, the user's network, or a security tool rollout?
- Was a new endpoint security agent (VPN, EDR, secure web gateway) deployed to session hosts or client devices recently?
- Was the Teams client or WebRTC redirector version changed?

## Evidence to collect first

The transport type is the single fastest diagnostic in this runbook, and it should be checked before anything else.

**From the client, in an active session:** open the connection information panel (in Windows App or the Remote Desktop client, this shows the transport protocol in use).

From the session host, run the Microsoft Azure Virtual Desktop Agent URL Tool and confirm that required endpoints pass. Do not use `Test-NetConnection` as proof of UDP 3478 reachability; its port test is TCP-based. Use the active session's connection information and network or firewall logs to confirm UDP transport and any denied UDP traffic.

Official reference: https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint

```bash
# Check whether the Teams WebRTC redirector is present and its version
az vm run-command invoke -g <hosts-resource-group> -n <vm-name> \
  --command-id RunPowerShellScript \
  --scripts "Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' | Where-Object DisplayName -like '*Remote Desktop WebRTC*' | Select-Object DisplayName, DisplayVersion"
```

```kusto
// Host CPU during known call-heavy hours: a symptom of media falling back
// to non-optimised processing on the session host rather than the endpoint
Perf
| where TimeGenerated > ago(1d)
| where ObjectName == "Processor" and CounterName == "% Processor Time"
| where hourofday(TimeGenerated) between (9 .. 17)
| summarize avg(CounterValue) by Computer, bin(TimeGenerated, 15m)
| order by avg_CounterValue desc
```

## Initial hypotheses, ranked by frequency

1. **Outbound UDP blocked**, forcing Shortpath to fall back to TCP-based reverse connect. Sessions still work; they simply lose the lower-latency transport.
2. **Teams media optimisation not engaging**, so audio/video processes on the session host rather than at the endpoint: sessions work, host CPU rises, and call quality degrades under load.
3. **A newly deployed endpoint security agent inspecting or blocking media traffic** it does not recognise.
4. **Genuine network path latency or loss** between the user and the session host region, unrelated to any AVD-specific configuration.

## Fast triage decision tree

```
Check the transport type shown in the client's connection info.
├── TCP, when UDP/Shortpath was expected
│     → Check outbound UDP 3478 reachability from the host (evidence
│       step 2). If blocked, this explains the whole symptom on its own.
│       Check for a recent security tool deployment to session hosts or
│       client devices as the likely cause.
└── UDP/Shortpath is active, but quality is still poor
      → This is not a Shortpath problem. Check for genuine network path
        issues (loss, latency) between the user and the region, and check
        whether Teams optimisation specifically is engaging (are calls
        the only symptom, or everything?).

Is this specific to Teams calls?
├── Yes → Confirm the WebRTC redirector is installed and current version
│         (evidence step 3). Check host CPU during call hours (KQL query);
│         rising CPU during calls with no other explanation is the
│         signature of optimisation not engaging, meaning media is being
│         processed on the host instead of redirected to the endpoint.
└── No, general session quality → Broader network path issue, likely
          outside AVD-specific configuration entirely.
```

## Root-cause indicators

| Evidence | Root cause |
|---|---|
| Client shows TCP transport, UDP 3478 unreachable from the host | Outbound UDP blocked somewhere on the path |
| UDP reachable, but the client still shows TCP | Client-side network (home router, ISP) blocking UDP, not the Azure side |
| WebRTC redirector missing or an old version | Teams optimisation not installed correctly, likely an image issue |
| Redirector present and current, but host CPU spikes specifically during calls | Optimisation not engaging despite being installed: check Teams client and redirector version compatibility |
| Transport is optimal and redirector is current, quality still poor | Genuine network path issue, not an AVD configuration problem |

## Remediation

**If outbound UDP is blocked:** identify what changed (NSG rule, firewall policy, a newly deployed endpoint security agent) and restore the required outbound path. Do not open outbound access more broadly than the documented required endpoints and ports.

**If a security agent is the cause:** this is the same class of problem as an antivirus tool blocking FSLogix: apply the vendor's documented exclusions for AVD/Teams media traffic, and add the AVD architect to the review process for any future endpoint agent rollout to session hosts, per the pattern in [Chapter 13](../chapters/ch13-hybrid-connectivity-egress-control.md#4-the-failure-mode-inside-the-virtual-machine).

**If the redirector is missing or outdated:** this is an image problem, not a live-host fix. Update the golden image with the current Teams client and WebRTC redirector version, and roll the update per [Chapter 23](../chapters/ch23-golden-image-engineering.md).

## Validation

- Client connection info shows UDP/Shortpath transport where it is expected to be available.
- Host CPU during call hours returns to baseline, not just "better," compared to before the fix.
- Get direct user confirmation on a real call, not just a technical metric: the metric can look fixed while the subjective experience has not actually improved.

## Rollback

If restoring an outbound UDP rule conflicts with a security requirement that caused it to be blocked in the first place, do not silently re-open it: raise the conflict with the security team explicitly rather than choosing one side unilaterally, since both AVD performance and the security control have legitimate owners.

## Prevention

- Document UDP 3478 (and the current Shortpath/STUN requirements) as a required rule with a comment explaining what breaks without it, so it is not accidentally removed during a future firewall cleanup.
- Add a transport-type dashboard so silent fallback to TCP is visible as a trend, not only discovered through user complaints.
- Require the AVD architect's review before any new endpoint security agent is deployed to session hosts.
- Include the Teams redirector version in post-build image validation.

## Escalation criteria

Escalate to Microsoft support when UDP connectivity is confirmed open end to end, the redirector is current, and Shortpath still consistently fails to establish or Teams optimisation still fails to engage.

## Evidence for a Microsoft support case

- Client connection information showing the transport in use, with timestamps.
- Confirmation of outbound UDP reachability testing from the affected host.
- WebRTC redirector version installed.
- Host CPU trend during the affected calls.
- Any recent change to network security configuration or endpoint agents on the affected hosts.

## Official Microsoft references

- [RDP Shortpath for managed networks](https://learn.microsoft.com/en-us/azure/virtual-desktop/shortpath-managed-networks)
- [RDP Shortpath for public networks](https://learn.microsoft.com/en-us/azure/virtual-desktop/shortpath-public-networks)
- [Teams media optimization for Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/teams-supported-features)
- [Required URL list for Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint)
