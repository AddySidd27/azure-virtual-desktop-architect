# Runbook 02 - User Cannot See the Assigned Desktop or RemoteApp

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Related:** [Chapter 3](../chapters/ch03-avd-object-model.md), [Chapter 25](../chapters/ch25-application-delivery-remoteapp-design.md), [Lab 7](../labs/lab-07-avd-host-pool.md), [Lab 9](../labs/lab-09-application-groups.md), [Project 10](../scenarios/project-10-remoteapp-line-of-business.md)
> **Format:** [Operations and troubleshooting standard](../OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md)

---

## Symptom

A user signs in to Windows App and their feed is empty, or is missing one specific application or desktop they expect to see.

## Business impact

The user cannot start work. If it affects one user, it looks like a permissions ticket. If it affects everyone assigned to a specific application group, it is a platform issue with no error anywhere in the AVD service telling anyone what happened: this class of failure is silent by design, which is what makes it worth a dedicated runbook.

## Scope questions

- Does this affect one user, a group of users, or everyone assigned to a specific application or desktop?
- Is it a full desktop that is missing, a RemoteApp, or both?
- Did the user ever see it before, or is this a new assignment that has never worked?

## Recent-change questions

- Was the user's group membership changed recently?
- Was an application group's host pool association changed?
- Was the host pool's preferred application group type changed or set at creation?
- Was a role assignment removed or modified on the application group?

## Evidence to collect first

```bash
# 1. Confirm the host pool's preferred application group type
az desktopvirtualization hostpool show \
  --name <host-pool-name> \
  --resource-group <service-resource-group> \
  --query "preferredAppGroupType" -o tsv
```

```bash
# 2. Confirm which application groups exist and their type
az desktopvirtualization applicationgroup list \
  --resource-group <service-resource-group> \
  --query "[].{name:name, type:applicationGroupType, hostPool:hostPoolArmPath}" -o table
```

```bash
# 3. Confirm role assignment on the application group scope specifically,
#    not the host pool and not an individual user
az role assignment list \
  --scope "$(az desktopvirtualization applicationgroup show -n <app-group-name> -g <service-resource-group> --query id -o tsv)" \
  -o table
```

```bash
# 4. Confirm the user's actual group membership
az ad group member check \
  --group "<avd-users-group>" \
  --member-id "$(az ad user show --id <user-upn> --query id -o tsv)"
```

## Initial hypotheses, ranked by frequency

1. **Preferred application group type mismatch.** The application group's type does not match the host pool's `preferredAppGroupType`, so the user is assigned but sees nothing of that type. This is documented Microsoft behaviour, not a bug, and it produces no error anywhere.
2. **Assignment made on the wrong object.** Assignment lives on the application group, not the host pool and not the workspace. A role assigned at the wrong scope has no effect.
3. **Group membership change has not propagated**, or the user was added to the wrong group.
4. **Workspace and application group association missing or removed.**
5. **Client-side feed cache.** The user's client has not refreshed since the assignment changed.

## Fast triage decision tree

```
Is ANYTHING visible in the feed for this user?
├── No, feed is completely empty
│     → Check group membership first (evidence step 4), then role
│       assignment scope (step 3). Most likely: user not in any
│       group with a role on any application group.
└── Yes, but one specific item (a RemoteApp or a desktop) is missing
      → Check the preferred application group type on that specific
        host pool (step 1) against the missing item's group type (step 2).
        Mismatch here explains it completely, with no further
        investigation needed.
```

## Root-cause indicators

| Evidence | Root cause |
|---|---|
| Host pool `preferredAppGroupType` is `Desktop`, missing item is from a `RemoteApp` group associated with that same pool | Type mismatch. The RemoteApp group needs its own host pool, or the pool's preferred type needs to match: see the design note below |
| Role assignment exists on the host pool or workspace, not the application group | Assignment made at the wrong scope. Has no effect regardless of how correct it looks in the portal |
| User confirmed a member of the correct group, but the role assignment references a different (similarly-named) group's object ID | Wrong group targeted at assignment time |
| Everything checks out correctly in Azure, but the user still sees nothing | Client feed cache. Have the user fully sign out and back in, not just reconnect |

**Design note on the type mismatch.** Do not "fix" this by changing the host pool's `preferredAppGroupType` if other users are already relying on the current setting: that change affects every assigned user on that pool, silently. The correct fix is almost always to move the mismatched application group to a host pool with the matching preferred type, as demonstrated in [Lab 9](../labs/lab-09-application-groups.md) and [Project 10](../scenarios/project-10-remoteapp-line-of-business.md#8-l3-incident-application-missing-for-everyone-on-four-hosts).

## Remediation

1. Confirm the actual root cause from the evidence above before changing anything.
2. If it is a type mismatch: create or use a host pool whose preferred type matches, move the application group's host pool association, and reassign users. Do not change a live pool's preferred type as the fix.
3. If it is a wrong-scope assignment: add the role assignment at the application group scope. Do not remove the incorrect one until the correct one is confirmed working, in case removing it has an effect you did not anticipate.
4. If it is group membership: correct the membership, allow time for directory replication, and have the user sign out fully and back in.

## Validation

- The specific user (not a different test account) signs in and sees the expected item in their feed.
- If it was a group-wide fix, validate with at least two users from the affected group, not one, since a single success can be misleading if the fix was itself scoped too narrowly.

## Rollback

Role assignment changes are low risk to roll back: remove the newly added assignment if it has an unexpected effect. Host pool association changes for an application group are more disruptive; if a group was moved to a new host pool and that causes a different problem, moving it back is the rollback, but confirm no users have already been re-pointed at the new pool's specific hosts before doing so.

## Prevention

- Set `preferred_app_group_type` deliberately at host pool creation, in code, and document the decision.
- Never mix Desktop and RemoteApp application groups on the same host pool unless every assigned user is meant to receive only the preferred type.
- Assign through groups only, never individual users, and keep a single source of truth for group membership.
- Add a check to any publishing runbook that confirms the target pool's preferred type matches the application group being published, before making the change.

## Escalation criteria

Escalate to Microsoft support only after confirming the object model (host pool type, application group type, association, and role assignment scope) is correct and the user still cannot see an item they are genuinely assigned. This is rare: the vast majority of these tickets resolve from the object model check alone.

## Evidence for a Microsoft support case

- Host pool `preferredAppGroupType` value.
- Application group type and its host pool association.
- Role assignment listing at the application group scope.
- Confirmation of the user's group membership and the group's object ID used in the role assignment.
- Client version and a screenshot of the user's actual feed.

## Official Microsoft references

- [Manage app groups](https://learn.microsoft.com/en-us/azure/virtual-desktop/manage-app-groups)
- [Preferred application group type behavior for pooled host pools](https://learn.microsoft.com/en-us/azure/virtual-desktop/preferred-application-group-type)
- [Publish applications with RemoteApp](https://learn.microsoft.com/en-us/azure/virtual-desktop/publish-applications-stream-remoteapp)
