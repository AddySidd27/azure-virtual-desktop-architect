# Runbook 03 - FSLogix Profile Fails to Attach, or a Temporary/Local Profile Is Created

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Related:** [Chapter 19](../chapters/ch19-why-profiles-cause-avd-failure.md), [Chapter 20](../chapters/ch20-profile-storage-architecture.md), [Chapter 21](../chapters/ch21-fslogix-production-implementation.md), [Chapter 22](../chapters/ch22-profile-operations-failure-recovery.md), [Lab 5](../labs/lab-05-storage.md), [Lab 6](../labs/lab-06-fslogix.md)
> **Format:** [Operations and troubleshooting standard](../OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md)

---

## Symptom

A user signs in and gets a desktop with none of their files, settings, or application configuration: a temporary or new local profile rather than their real one.

## Business impact

This is the most severe common AVD failure from the user's point of view, because it looks like data loss even when the real profile is untouched. If it affects every user at once, it is a full outage of the desktop service even though every session host is technically healthy. If it affects one user repeatedly, it is a smaller but recurring loss of their working time.

## Scope questions

- Does this affect one user, several, or everyone signing in right now?
- Does it happen on every host, or only specific hosts?
- Is it consistent for the affected user (fails every time) or intermittent?

One user, consistent, points at that user's identity or permissions. Everyone, at once, points at storage or an identity dependency such as Kerberos. Intermittent for one user, on specific hosts, points at a locked container.

## Recent-change questions

- Was there a Windows update applied to session hosts recently that could have changed Kerberos encryption defaults?
- Was a storage account's identity configuration (AD authentication, Entra Kerberos) changed?
- Was a new user or group added without being included in existing share or NTFS permissions?
- Did a session host crash or get forcibly removed while users were signed in recently?

## Evidence to collect first

```bash
# 1. Confirm this is actually a temporary profile, not a slow-loading real one
az vm run-command invoke -g <hosts-resource-group> -n <vm-name> \
  --command-id RunPowerShellScript \
  --scripts "Get-ChildItem 'C:\Users' | Sort-Object CreationTime -Descending | Select-Object -First 5 Name, CreationTime"
```

A freshly created profile folder (created moments ago) is the signature of a temporary profile.

```bash
# 2. Read the FSLogix log on the affected host: this is the single most
#    important piece of evidence in this runbook
az vm run-command invoke -g <hosts-resource-group> -n <vm-name> \
  --command-id RunPowerShellScript \
  --scripts "Get-ChildItem 'C:\ProgramData\FSLogix\Logs\Profile' | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | Get-Content -Tail 60"
```

```bash
# 3. Test raw connectivity to the storage account from the host
az vm run-command invoke -g <hosts-resource-group> -n <vm-name> \
  --command-id RunPowerShellScript \
  --scripts "Test-NetConnection <storage_account_name>.file.core.windows.net -Port 445"
```

```bash
# 4. Confirm share-level RBAC for the affected user's group
az role assignment list \
  --scope "$(az storage account show -n <storage_account_name> -g <storage-resource-group> --query id -o tsv)/fileServices/default/fileshares/profiles" \
  -o table
```

```bash
# 5. If a lock is suspected, list open handles on the specific container
az storage file handle list \
  --account-name <storage_account_name> \
  --share-name profiles \
  --path "<user_sid>_<username>" \
  --recursive --auth-mode login -o table
```

## Initial hypotheses, ranked by frequency

1. **Kerberos authentication to the storage account is failing.** Often caused by a Windows update changing the default Kerberos encryption type on session hosts to something the storage account is not configured to accept.
2. **A permissions gap for a specific identity type.** New cloud-only or contractor accounts not covered by a synced group used for share or NTFS permissions.
3. **A locked container** from a session that ended abnormally (host crash, forced removal).
4. **Storage account or network path unreachable** (connectivity, DNS, or private endpoint misconfiguration).
5. **Configuration not applied at all**: `Enabled` registry key missing or FSLogix agent not installed on this specific host.

## Fast triage decision tree

```
Does this affect everyone signing in right now, or a subset?
├── Everyone, right now
│     → Test connectivity (step 3) and Kerberos/auth in the FSLogix log
│       (step 2) first. This is almost certainly a shared dependency:
│       storage reachability or an identity/Kerberos change, not a
│       per-user permission issue.
│       DO NOT delete or recreate any containers. The data is intact;
│       the authentication or network path is broken.
└── One user, or a specific subset
      → Compare that user's identity type and group membership against a
        working user (step 4). If different identity types (cloud-only
        vs synced) are in play, suspect the permission model was built
        before those identity types existed.
      → If it is the SAME user repeatedly, check for a locked container
        (step 5) before assuming a permissions problem.
```

## Root-cause indicators

| Evidence | Root cause |
|---|---|
| FSLogix log shows an authentication error, affects all users, storage otherwise reachable | Kerberos/identity path broken: check recent Windows updates and storage account authentication configuration |
| FSLogix log shows access denied, affects specific users only, those users are cloud-only or newly created | Permission model built for one identity type does not cover another: check both share RBAC and NTFS layers for the affected identity type specifically |
| FSLogix log shows the container is in use / locked | Stale handle from an abnormal session end: see remediation below |
| `Test-NetConnection` on port 445 fails | Network path or DNS problem, not FSLogix-specific: escalate to a network/storage investigation |
| No FSLogix log entries at all for this sign-in | FSLogix not installed or `Enabled` registry key not set on this host: configuration gap, not a runtime failure |

## Remediation

**Do not delete or recreate containers as a first response.** The container almost always still holds the user's real data; the problem is nearly always the path to it, not the data itself. Deleting a container is data loss and should only be considered after confirming the container itself is corrupted, per [Chapter 22](../chapters/ch22-profile-operations-failure-recovery.md#4-corruption).

**If it is a Kerberos/authentication problem affecting everyone:** restore the storage account's authentication configuration to its working state, or complete a pending encryption compatibility upgrade if a Windows update is the cause. See [Chapter 19](../chapters/ch19-why-profiles-cause-avd-failure.md#5-the-kerberos-encryption-change).

**If it is a permission gap for a specific identity type:** update the share-level RBAC and NTFS permissions to cover the missing identity type, ideally by moving to a group whose membership is driven from the actual identity source of truth rather than maintained by hand.

**If it is a locked container:**

```bash
# Confirm the handle is stale (the session/host it belongs to no longer
# exists) before closing it: closing a live session's handle interrupts
# that user.
az storage file handle close-all \
  --account-name <storage_account_name> \
  --share-name profiles \
  --path "<user_sid>_<username>" \
  --auth-mode login
```

Then have the affected user sign in again.

## Validation

- The affected user signs in and the FSLogix log shows a successful attach, not a failure or a temporary profile.
- Confirm the user's actual data (recent documents, application settings) is present, not just that a profile loaded.
- If the fix was for an everyone-affected issue, validate with at least two users on two different hosts before considering it resolved.

## Rollback

If a storage authentication configuration change was made and it does not resolve the issue, revert to the previous known-working configuration rather than layering further changes on top of an unconfirmed fix.

## Prevention

- Keep a documented list of dependencies external to AVD that FSLogix relies on (Kerberos encryption configuration, DNS, network path), with an owner for each, so a change to one of them is recognised as a risk before it happens.
- Drive profile-share group membership from the same identity source of truth used for onboarding, so new identity types are automatically covered.
- Alert on temporary profile creation: it is the earliest possible signal of this exact failure class, and catching it early prevents it becoming a mass event.
- Set a disconnected-session sign-out policy so abandoned sessions do not accumulate stale locks indefinitely.

## Escalation criteria

Escalate to Microsoft support when connectivity, authentication configuration, and permissions are all confirmed correct, and containers still fail to attach or corrupt with no identifiable pattern.

## Evidence for a Microsoft support case

- FSLogix log files from at least one affected host.
- Storage account authentication configuration (AD or Entra Kerberos) and its current state.
- Share-level RBAC and NTFS permission listings for the affected identity.
- Whether the issue affects all users or a specific subset, with the identity types involved.
- FSLogix agent version.

## Official Microsoft references

- [FSLogix overview and prerequisites](https://learn.microsoft.com/en-us/fslogix/overview-prerequisites)
- [Configure profile containers](https://learn.microsoft.com/en-us/fslogix/how-to-configure-profile-containers)
- [Storage options for FSLogix profile containers](https://learn.microsoft.com/en-us/azure/virtual-desktop/store-fslogix-profile)
