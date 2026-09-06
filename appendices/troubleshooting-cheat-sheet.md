# Troubleshooting Cheat Sheet

Use this page for triage. Use the linked runbook before making a broad or destructive change.

## First five checks

1. Check Azure Service Health and the affected scope.
2. Confirm whether the problem affects one user, one host, one pool, one region, or everyone.
3. Record the start time and the last known good time.
4. List recent image, policy, network, identity, storage, application, and scaling changes.
5. Collect evidence before restarting, reinstalling, resizing, or changing shared configuration.

## Symptom map

| Symptom | First check | Likely layers | Runbook |
|---|---|---|---|
| Session host missing or Unavailable | Host-pool health status and agent services | Network, agent, registration, image | [01](../troubleshooting/runbook-01-session-host-registration-failure.md) |
| Desktop or RemoteApp missing | Application-group assignment and preferred group type | Entitlement, group membership, workspace | [02](../troubleshooting/runbook-02-desktop-remoteapp-not-visible.md) |
| Temporary profile or profile attach failure | FSLogix log and storage reachability | Identity, DNS, RBAC, NTFS, locked VHDX | [03](../troubleshooting/runbook-03-fslogix-profile-attach-failure.md) |
| Slow sign-in | Break the sign-in into connection, profile, policy, shell, and application stages | Storage, profile, policy, host capacity | [04](../troubleshooting/runbook-04-slow-signin-logon-storm.md) |
| Lag, high latency, or Teams media issue | Confirm active transport and round-trip time | Client, UDP path, Shortpath, endpoint security | [05](../troubleshooting/runbook-05-connection-quality-shortpath-teams.md) |

## Safe actions during triage

- Put one affected host in drain mode before maintenance.
- Test with one known user and one known-good endpoint.
- Compare one affected host with one healthy host from the same pool.
- Refresh a targeted policy or restart one identified service after evidence points to it.
- Preserve logs and timestamps before replacement.

## Do not change blindly

- VNet DNS servers or shared routes
- Host-pool RDP properties
- Storage authentication method, keys, RBAC, or NTFS inheritance
- Conditional Access exclusions
- Image assignment across an entire pool
- Mass logoff or deletion of session hosts
- FSLogix handles that may belong to active users

## Escalate to Microsoft when

- Service Health identifies a relevant platform incident.
- The problem is isolated to a Microsoft-managed component.
- Behavior contradicts current Microsoft documentation and is reproducible.
- The required diagnostics, correlation IDs, timestamps, affected users, host and client versions, network evidence, and recent-change record are ready.

Microsoft reference: [Troubleshoot Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/troubleshoot)
