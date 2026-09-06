# Runbook 01 - Session Host Cannot Register With the Host Pool

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Related:** [Chapter 18](../chapters/ch18-session-host-lifecycle-hybrid.md), [Lab 8](../labs/lab-08-session-hosts.md)
> **Format:** [Operations and troubleshooting standard](../OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md)

---

## Symptom

A session host is deployed and running in Azure, but it does not appear in the host pool, or it appears with a status other than `Available`.

## Business impact

Capacity that was planned is not there. If this happens during a scaling event or a deployment expanding the pool, users queue or fail to connect at the exact moment capacity was needed. A host that is running and billing but not serving anyone is also a direct cost with no return.

## Scope questions

Ask these before touching anything:

- Is this one host, or every host in a recent deployment batch?
- Is it a brand new host, or one that was previously registered and working?
- Was this host built from a new image version?
- Did anything change on the network path (firewall, NSG, DNS) recently?

One host failing points at that host or its build. Every host in a batch failing points at the deployment process itself, most often the registration token.

## Recent-change questions

- Was a new image published recently? (See [Chapter 23](../chapters/ch23-golden-image-engineering.md): an image captured from an already-registered machine is a documented cause of this exact symptom.)
- Was the registration token generated more than a short window before this deployment ran?
- Did a network or firewall change happen on the session host subnet?
- Was the host pool recently switched between session host configuration and standard management?

## Evidence to collect first

Do this before attempting any fix. All of it is read-only.

```bash
# 1. Confirm the host's actual status from the service side
az desktopvirtualization sessionhost list \
  --host-pool-name <host-pool-name> \
  --resource-group <service-resource-group> \
  --query "[].{name:name, status:status, updateState:updateState}" -o table
```

```bash
# 2. Confirm the registration token is still valid
az desktopvirtualization hostpool show \
  --name <host-pool-name> \
  --resource-group <service-resource-group> \
  --query "registrationInfo.{expirationTime:expirationTime, token:token}" -o json
```

```bash
# 3. On the host itself: agent state and the IsRegistered flag
az vm run-command invoke -g <hosts-resource-group> -n <vm-name> \
  --command-id RunPowerShellScript \
  --scripts "Get-Service RDAgentBootLoader, RDAgent | Select-Object Name, Status; Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent' -Name IsRegistered -ErrorAction SilentlyContinue"
```

```bash
# 4. Event log evidence
az vm run-command invoke -g <hosts-resource-group> -n <vm-name> \
  --command-id RunPowerShellScript \
  --scripts "Get-WinEvent -LogName 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin' -MaxEvents 20 -ErrorAction SilentlyContinue | Select-Object TimeCreated, Id, Message; Get-EventLog -LogName Application -Source 'RDAgentBootLoader' -Newest 20 -ErrorAction SilentlyContinue"
```

`[VERIFY BEFORE IMPLEMENTATION]` confirm the exact WVD-Agent event log path for your agent version; Microsoft has adjusted logging channel names across agent releases.

## Initial hypotheses, ranked by frequency

1. **Registration token expired** before the agent attempted to use it. This is the most common cause by a wide margin.
2. **Image captured from an already-registered host.** The agent and an old registration state were baked into the image.
3. **Outbound network path blocked.** The agent cannot reach the required AVD service endpoints.
4. **DNS resolution failure** for the required endpoints, distinct from a network block.
5. **Boot loader service not starting.** Often a symptom of one of the above, not an independent cause.

## Fast triage decision tree

```
Is the host visible in `sessionhost list` at all?
├── No  → Registration never happened. Check token validity (step 2) first.
│         Token expired?
│         ├── Yes → Regenerate the token, re-run the registration extension/script.
│         └── No  → Check network path to AVD service endpoints (see below).
└── Yes → Host is visible but status is not Available.
          Is IsRegistered = 1 on the host?
          ├── No  → Same as above: token, then network.
          └── Yes → Agent registered but host still unavailable.
                     This points at the side-by-side network stack, not
                     registration. Check RDAgentBootLoader vs the actual
                     RDP listener state, and consider this may need
                     Runbook 05 (connection quality) instead.
```

## Root-cause indicators

| Evidence | Root cause |
|---|---|
| `IsRegistered` absent or `0`, boot loader service starts then stops within seconds | Expired or invalid registration token |
| `IsRegistered = 1` on a host built from an image, but the image was known to be captured from a live host | Registration state baked into the image; the token in it is stale and the agent identity conflicts with an existing registration |
| Boot loader service will not start at all | Corrupted agent install, often from an interrupted image build |
| Agent running, `IsRegistered = 1`, but host still shows Unavailable | Not a registration problem: check the RDP listener / side-by-side stack instead |
| No outbound connectivity in NSG flow logs to AVD service IP ranges | Network path blocked, check NSG and any firewall/UDR changes |

## Remediation

**If the token expired:**

```bash
az desktopvirtualization hostpool update \
  --name <host-pool-name> \
  --resource-group <service-resource-group> \
  --registration-info expiration-time="$(date -u -d '+1 day' '+%Y-%m-%dT%H:%M:%SZ')" registration-token-operation=Update
```

Then re-trigger registration on the host. For a Terraform-managed host, re-apply the agent extension:

```bash
terraform apply -replace=azurerm_virtual_machine_extension.avd_agent
```

For a host that was not Terraform-managed, or where the extension itself is corrupted, uninstall and reinstall the agent and boot loader manually, then register with the new token.

**If the image was captured from a registered host:** do not try to fix the running host. Rebuild the image from a clean, never-registered source, per [Chapter 23](../chapters/ch23-golden-image-engineering.md#3-the-rule-that-breaks-deployments), and redeploy affected hosts from the corrected image.

**If it is a network path problem:** confirm the NSG and any firewall rules allow outbound HTTPS to the AVD required endpoints. Do not open the path wider than the documented required FQDNs; add specifically what is missing.

## Validation

- `az desktopvirtualization sessionhost list` shows the host as `Available`.
- `IsRegistered : 1` and both agent services `Running` on the host.
- A test sign-in reaches a working desktop or application from this specific host, not just any host in the pool: confirm by checking which host the test session landed on.

## Rollback

If a token regeneration or extension re-apply does not resolve it within one attempt, do not keep retrying the same action. Roll back to redeploying the host from a known-good image rather than repeatedly patching a host in an unknown state: in a pooled, disposable host model this is faster and safer than continued diagnosis on the same VM.

## Prevention

- Generate registration tokens as part of the deployment pipeline, immediately before use, not in advance.
- Never build an image from a session host that has been added to a host pool.
- Alert on any host remaining outside `Available` status for more than a defined threshold after deployment.
- For estates using session host configuration ([Chapter 16](../chapters/ch16-automated-host-pools-session-host-configuration.md)), prefer the service-managed registration path, which removes manual token handling entirely.

## Escalation criteria

Escalate to Microsoft support when: the token is confirmed valid, outbound connectivity to required endpoints is confirmed working, the agent installs and starts cleanly, and the host still will not register or remains stuck in a transitional state for more than 30 minutes.

## Evidence to attach to a Microsoft support case

- Host pool name, region, and resource ID.
- The exact `IsRegistered` registry value and agent service states from the host.
- The relevant event log entries (WVD-Agent, RDAgentBootLoader) with UTC timestamps.
- The registration token's expiration time at the moment registration was attempted.
- Confirmation of outbound connectivity test results to the required AVD endpoints.
- Agent version installed on the host.

## Official Microsoft references

- [Session host status and health checks](https://learn.microsoft.com/en-us/azure/virtual-desktop/session-host-status-health-checks)
- [Troubleshoot common Azure Virtual Desktop Agent issues](https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-desktop/troubleshoot-agent)
- [Required URL list for Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint)
