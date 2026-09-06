# Chapter 21 - FSLogix Production Implementation

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Part V:** FSLogix, Profiles and Storage
> **Technical baseline:** August 2026

---

## Chapter Information

| Item | Detail |
|---|---|
| **Chapter number** | 21 |
| **Objective** | Configure FSLogix the way a production environment needs it, and understand what each setting does rather than copying a list |
| **Prerequisites** | Chapters 1 to 20. Labs 1 to 4 complete |
| **Dependencies** | Uses the profile theory in [Chapter 19](ch19-why-profiles-cause-avd-failure.md) and the storage design in [Chapter 20](ch20-profile-storage-architecture.md) |
| **Estimated lab time** | FSLogix configuration is in Lab 6 |
| **Azure resources required** | None new for the chapter |
| **Cost** | $0.00 for the chapter |

---

## What You Will Learn

- The settings that actually matter in production, and what each one prevents
- Antivirus and security tool exclusions, which are the most common cause of profile corruption
- How to control profile size before it becomes a storage problem
- Where to configure FSLogix, and why the image is usually the wrong answer
- Three production scenarios in the full format

---

## Why This Matters

FSLogix has a long settings reference. Most of it does not matter for a standard AVD deployment. A small number of settings decide whether users lose data, whether profiles corrupt, and whether your storage bill doubles in a year.

This chapter covers those, with the reason for each. Copying a settings list from a blog is how environments end up with values nobody can explain, and that becomes a real problem the first time something breaks.

---

## 1. Where FSLogix Configuration Lives

FSLogix reads its configuration from the registry, under `HKLM\SOFTWARE\FSLogix\Profiles` for profile containers and `HKLM\SOFTWARE\FSLogix\ODFC` for ODFC containers.

You have three ways to set it, and the choice matters more than people expect.

| Method | Good for | Watch out for |
|---|---|---|
| Group Policy | Domain joined estates with existing GPO | Needs the FSLogix ADMX templates installed in the central store |
| Intune Settings catalog | Entra joined and hybrid estates | Multi-session limitations apply. See the [Intune support matrix](../appendices/intune-avd-support-matrix.md) |
| Registry in the image | Quick, and hard to change later | Every change means a new image and a session host update |

**The architect's position.** Put FSLogix configuration in policy, not in the image. A setting baked into an image can only be changed by rebuilding and rolling every host, which turns a five minute correction into a two day operation. This matters even more with session host configuration from [Chapter 16](ch16-automated-host-pools-session-host-configuration.md), where hosts are replaced rather than patched, because a registry value applied by hand disappears at the next update.

The exception is the FSLogix agent itself, which does belong in the image.

---

## 2. The Settings That Matter

Microsoft's own configuration guidance for profile containers sets these values. Each one is here for a reason, and the reason is what you need to remember.

```powershell
$VHDLocations = "\\stavdlabeus201.file.core.windows.net\profiles"

New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name Enabled `
  -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name VHDLocations `
  -PropertyType MultiString -Value $VHDLocations -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name VolumeType `
  -PropertyType string -Value "VHDX" -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name SizeInMBs `
  -PropertyType dword -Value 30000 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name FlipFlopProfileDirectoryName `
  -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name DeleteLocalProfileWhenVHDShouldApply `
  -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name ProfileType `
  -PropertyType dword -Value 0 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name LockedRetryCount `
  -PropertyType dword -Value 3 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name LockedRetryInterval `
  -PropertyType dword -Value 15 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name ReAttachRetryCount `
  -PropertyType dword -Value 3 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name ReAttachIntervalSeconds `
  -PropertyType dword -Value 15 -Force
```

**Prerequisites.** FSLogix agent installed. The share exists and both permission layers are configured, as covered in [Chapter 20](ch20-profile-storage-architecture.md#5-the-two-layer-permission-model).

**Expected result.** After a sign-out and sign-in, the container mounts and the FSLogix log shows a successful attach.

**Common failure.** Setting the values but not restarting or signing out fully. FSLogix reads configuration at profile load, so an existing session is unaffected.

### What each setting is for

| Setting | Value | What it does and why it matters |
|---|---|---|
| `Enabled` | 1 | Required. FSLogix does nothing without it |
| `VHDLocations` | UNC path | Where containers live. See the warning below about multiple entries |
| `VolumeType` | VHDX | VHDX rather than VHD. There is no reason to choose VHD for a new deployment |
| `SizeInMBs` | 30000 | Maximum container size. This is a ceiling, not an allocation. See section 4 |
| `FlipFlopProfileDirectoryName` | 1 | Names folders `username_SID` instead of `SID_username`. Purely a naming change, and it makes the share browsable by a human at 3am |
| `DeleteLocalProfileWhenVHDShouldApply` | 1 | Removes a leftover local profile when a container should be used. Prevents users silently working in a local profile and losing data at sign-out |
| `ProfileType` | 0 | Normal, single session per container. Concurrency is a deliberate exception. See [Chapter 19](ch19-why-profiles-cause-avd-failure.md#4-concurrency-one-user-more-than-one-session) |
| `LockedRetryCount` and `LockedRetryInterval` | 3 and 15 | Retry when the container is locked, rather than failing straight to a temporary profile. Covers a slow release from a previous session |
| `ReAttachRetryCount` and `ReAttachIntervalSeconds` | 3 and 15 | Retry if the container detaches mid-session, for example during a brief storage blip |

Microsoft's own notes on two of these are worth quoting because they explain the intent: `ClearCacheOnLogoff` is recommended to save disk space on the local disk and reduce risk of data loss when using pooled desktops, `DeleteLocalProfileWhenVHDShouldApply` is recommended to ensure users don't use local profiles and lose data unexpectedly, and `FlipFlopProfileDirectoryName` provides an easier way to browse the container directories.

### The VHDLocations warning most people miss

`VHDLocations` accepts multiple entries, and it is tempting to read that as redundancy. It is not.

Microsoft is explicit: use of multiple entries in VHDLocations doesn't provide container resiliency. When multiple entries exist, users try to create or locate their container from the list of locations in order.

So a second path is a fallback location for creating a container, not a replica of the first. If the first share is down, a user does not get their profile from the second one. They get a new empty container on the second one, which looks exactly like data loss to them.

**If you need resilience, that is Cloud Cache or storage level redundancy, not a second path.** Both are covered in [Chapter 22](ch22-profile-operations-failure-recovery.md).

**Official Microsoft reference:** https://learn.microsoft.com/en-us/fslogix/how-to-configure-profile-containers

---

## 3. Antivirus and Security Tool Exclusions

This is the single most common cause of profile corruption, and it is entirely preventable.

A profile container is a virtual disk that is open, being written to, and heavily used for the whole session. Real-time scanning of that file competes with the operating system for it. The results range from slow sign-in to corrupted containers.

Microsoft's instruction is specific about scope: to ensure FSLogix operates reliably, configure your antivirus and security tools to exclude the following items. The most common SMB or UNC paths are in the form of `\\{server-name}.contoso.com\{share-name}` or `\\{storage-account-name}.file.core.windows.net\{share-name}`, adjust the exclusions based on your configuration. `%TEMP%` is the temporary path in the user's profile and `%WINDIR%\TEMP` is the temporary path for the system. If you change the default location of the cache or proxy folder, adjust the exclusions based on your configuration. Apply these exclusions in all layers of security, endpoint antivirus, network scanning and DLP.

**Read that last sentence carefully.** All layers. Not just Defender. Network scanning appliances and DLP agents also inspect this traffic, and they are usually managed by a different team who were never told the share exists.

`[VERIFY BEFORE IMPLEMENTATION]` Take the exclusion list from the current Microsoft prerequisites page rather than from this book or any blog. The list has changed as FSLogix has evolved, and a missing exclusion is a silent problem until it is a corrupted profile.

**How to verify exclusions are actually applied,** which is different from having been requested:

```bash
az vm run-command invoke -g rg-avd-hosts-lab-eus2-01 -n <vm> \
  --command-id RunPowerShellScript \
  --scripts "Get-MpPreference | Select-Object -ExpandProperty ExclusionPath; Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess"
```

**Expected result.** The FSLogix paths and processes appear in the output.
**Common failure.** Exclusions configured in a policy that has not applied to the session hosts, usually because the policy targets a different OU or device group. Checking on the host is the only proof.

**The architect's point.** Exclusions are a security decision as well as an operational one. You are telling the security team to stop scanning a file that contains a user's entire profile. That conversation goes better if you explain what is excluded, why, and what compensating controls exist, rather than sending a list and asking them to apply it.

---

## 4. Controlling Profile Size

Left alone, profiles grow. Browser caches, Teams caches, temporary files and downloaded content all accumulate inside the container, and every gigabyte is storage you pay for and mount time users wait for.

### SizeInMBs is a ceiling, not a target

`SizeInMBs` sets the maximum size of the container. VHDX files are dynamically expanding, so a 30 GB ceiling does not consume 30 GB on day one.

Two mistakes follow from misunderstanding this.

**Setting it too low.** When a container hits its ceiling, the user cannot save anything. This appears as applications failing to save rather than as a storage error, which makes it hard to diagnose from the symptom.

**Assuming it controls cost.** It does not. It caps the worst case. The actual size is driven by what is inside the profile, which is what exclusions manage.

### Redirections

Redirections let you exclude paths from the container. Browser caches and temporary directories are the usual candidates, because they are large, they change constantly, and nobody needs them to roam.

Microsoft documents the mechanism through a custom `redirections.xml`, referenced in the configuration examples guidance. `[VERIFY BEFORE IMPLEMENTATION]` Take the current file format and the recommended exclusion paths from the Microsoft documentation, because application cache locations change with application versions.

**The architect's rule.** Decide exclusions before go-live, not after profiles are already large. Adding an exclusion later does not shrink existing containers. It only stops them growing further, and shrinking them is a separate maintenance job covered in [Chapter 22](ch22-profile-operations-failure-recovery.md).

### What not to exclude

There is a temptation to exclude aggressively to keep containers small. Be careful. If you exclude something users expect to roam, they lose it at every sign-in and they will not report it as a profile problem. They will report that the application keeps forgetting their settings, which is much harder to trace back to a redirection file.

---

## 5. Object Specific Configuration

Sometimes different groups need different settings, most often a different container location.

Microsoft supports this through object specific configuration: the default VHDLocations setting is used for any user or group that isn't matched by the object-specific configuration, with settings placed under a registry path that includes the object SID, for example `HKLM:\SOFTWARE\FSLogix\Profiles\ObjectSpecific\<SID>`.

**Where this is genuinely useful.** Splitting users across multiple shares at scale, which [Chapter 20](ch20-profile-storage-architecture.md#7-how-this-changes-with-scale) established becomes necessary above a few thousand users.

**Where it becomes a problem.** When the mapping is maintained by hand. Every joiner, leaver and reorganisation changes it, and a user mapped to the wrong share gets a new empty profile rather than an error. If you use object specific configuration at scale, the mapping has to be generated from a source of truth and applied through policy, not edited by an administrator.

---

## 6. How This Changes With Scale

**Around 100 users.** One share, default settings plus the recommended values, exclusions configured properly. Configuration by Group Policy or Intune, applied once, rarely revisited.

**Around 1,000 users.** Profile size becomes financially visible, so exclusions earn their place. Antivirus exclusions must be verified on hosts rather than assumed, because a missing exclusion now corrupts profiles regularly enough to be a pattern. Logging matters, because you will be reading FSLogix logs weekly rather than never.

**Around 5,000 users and beyond.** Object specific configuration or multiple policy scopes become necessary to spread users across shares, and the user to share mapping becomes a system that needs automation. Configuration drift between host pools becomes a real risk, so the settings belong in code and should be audited rather than trusted. Profile size management moves from a design decision to an ongoing operational process with its own owner.

---

## 7. Architect's Reality Check

**What engineers commonly get wrong.** They copy a settings list without knowing what each value prevents. The two that hurt most when missed are `DeleteLocalProfileWhenVHDShouldApply`, because users silently work in a local profile and lose it, and the antivirus exclusions, because the damage is corruption rather than a clean failure.

**What I would check first in production.** Whether antivirus exclusions are actually applied on the session host, not whether they were requested. Then whether the container is attaching, from the FSLogix log rather than from the user's description.

**What I would ask the customer.** What their average profile size is today, and what is inside the largest ones. That tells you whether exclusions are a design decision or an urgent problem.

**What I would decide as the architect.** Configuration in policy rather than the image, so a correction takes minutes. Exclusions agreed with the security team with the reasoning written down. `SizeInMBs` set as a sensible ceiling rather than a tight limit. One share until scale forces otherwise, because object specific configuration is a mapping problem you should not take on early.

**What I would say in an interview.** That multiple `VHDLocations` entries do not provide resiliency. It is documented, it is widely misunderstood, and the failure mode is a user getting a new empty profile that looks like data loss.

---

## 8. Production Scenarios

### Scenario 1: Profiles corrupt after a security tool rollout

**Problem.** A new endpoint security agent is deployed across the estate. Over the following two weeks, users start reporting lost settings, and several containers become unusable.

**Symptoms.** Intermittent and increasing. Some users fine, some losing data, a few unable to sign in at all. FSLogix logs show attach failures and container errors rather than permission problems.

**Business impact.** Around 40 users with damaged profiles over two weeks, several with genuine data loss. The service desk is restoring from snapshots, which is slow, and confidence in the platform drops faster than the ticket count suggests.

**Initial assumption.** The new agent is scanning the container files. FSLogix requires exclusions in all security layers, and a new agent arrives without them unless someone explicitly asks.

**Investigation.**

Confirm what is actually excluded on an affected host, rather than what was requested:

```bash
az vm run-command invoke -g rg-avd-hosts-lab-eus2-01 -n <vm> \
  --command-id RunPowerShellScript \
  --scripts "Get-MpPreference | Select-Object -ExpandProperty ExclusionPath"
```

Then check the new agent's own exclusion configuration, which is separate from Defender and usually managed in a different console.

Then read the FSLogix logs under `C:\ProgramData\FSLogix\Logs\Profile` on an affected host, and correlate the first error with the agent deployment date.

**Evidence.** Defender exclusions are present. The new agent has none. The first container errors appear the day after the agent reached that host pool.

**Root cause.** Exclusions were configured for Defender when FSLogix was deployed. The new agent was a different product, deployed by a different team, and the exclusion requirement was never carried across.

**Resolution.** Apply the documented exclusions to the new agent, following its own configuration mechanism. Then repair or restore affected containers, which is covered in [Chapter 22](ch22-profile-operations-failure-recovery.md).

**Validation.** Confirm the exclusions on a host directly, then monitor container errors for a full week. The absence of new errors is the proof, not the presence of the configuration.

**Prevention.** Add FSLogix exclusions to the review checklist for any new security tool destined for session hosts, alongside the network inspection check from [Chapter 13](ch13-hybrid-connectivity-egress-control.md#4-the-failure-mode-inside-the-virtual-machine). Make the AVD architect a required reviewer for endpoint agent rollouts. That is an organisational fix, and it is the only one that works.

**Architect lesson.** Microsoft says to apply exclusions in all layers of security for a reason. Each new tool is a new layer, and the requirement does not travel with it automatically.

**Interview lesson.** Naming the organisational fix, getting into the review path for endpoint tooling, shows you understand that this failure is a process problem wearing a technical costume.

### Scenario 2: Users lose a day of work and nobody can explain it

**Problem.** Several users report that everything they did the previous day is missing. Their desktop and settings are back to how they were two days ago.

**Symptoms.** Affects a small number of users. Their profile is not empty, it is out of date. FSLogix logs on the host they used show the container failing to attach, followed by a successful sign-in.

**Business impact.** A day of work lost for around eight users, including a document nobody had saved elsewhere. Small in numbers and severe for the people affected, and exactly the kind of incident that damages trust in a new platform.

**Initial assumption.** The users were working in a local profile. The container failed to attach, FSLogix allowed sign-in to continue with a local profile, and everything they did was written to a host that was later rebuilt.

**Investigation.**

Check whether `DeleteLocalProfileWhenVHDShouldApply` is set:

```bash
az vm run-command invoke -g rg-avd-hosts-lab-eus2-01 -n <vm> \
  --command-id RunPowerShellScript \
  --scripts "Get-ItemProperty 'HKLM:\SOFTWARE\FSLogix\Profiles' | Select-Object Enabled, VHDLocations, DeleteLocalProfileWhenVHDShouldApply, ProfileType, LockedRetryCount"
```

Then look for local profile folders on hosts that were in use that day, and check the FSLogix log for an attach failure followed by a local profile being used.

**Evidence.** The setting is absent. The FSLogix log shows the container attach failing, and a local profile folder exists on the host from that date.

**Root cause.** Without `DeleteLocalProfileWhenVHDShouldApply`, a failed container attach falls back to a local profile. The session works normally, so nobody reports a problem, and the data is lost when the host is rebuilt.

**Resolution.** Set the value, so a failed attach does not silently fall back. Consider also whether users should be blocked from signing in at all when the container cannot attach, which turns silent data loss into a visible failure. That is a deliberate trade: an outage is better than data loss for most organisations, and it should be a decision the business makes rather than a default.

Recover what can be recovered from any surviving host, quickly, before it is rebuilt.

**Validation.** Deliberately break a container attach for a test account and confirm the behaviour is now a visible failure rather than a working session on a local profile.

**Prevention.** Set the value in policy, alert on temporary and local profile creation, and add the setting to a configuration audit so drift is detected.

**Architect lesson.** The dangerous failure is the one that looks like success. A working desktop that saves to the wrong place is worse than a failed sign-in, because the user only finds out when the data is gone.

**Interview lesson.** Framing this as a choice between an outage and silent data loss, and saying the business should decide, shows you can present a technical setting as a risk decision.

### Scenario 3: Storage cost doubles in eight months

**Problem.** A 1,500 user deployment sees profile storage grow from 18 TB to 38 TB in eight months. User count grew by less than ten percent.

**Symptoms.** No performance complaints. No errors. Steadily rising cost and a share approaching its provisioned capacity.

**Business impact.** Storage cost roughly doubled against the approved model, and the share is heading towards a capacity ceiling that will stop users saving, which turns a cost problem into an outage.

**Initial assumption.** Profile bloat from caches that were never excluded. Browser and Teams caches are the usual sources, and they grow continuously without anyone noticing.

**Investigation.**

Identify the largest containers on the share, then inspect one to see what is inside it. Mount a copy of a large container in an admin session and look at the largest directories, rather than guessing.

Then check whether a redirections configuration is in place at all:

```bash
az vm run-command invoke -g rg-avd-hosts-lab-eus2-01 -n <vm> \
  --command-id RunPowerShellScript \
  --scripts "Get-ItemProperty 'HKLM:\SOFTWARE\FSLogix\Profiles' | Select-Object RedirXMLSourceFolder -ErrorAction SilentlyContinue; Test-Path 'C:\Program Files\FSLogix\Apps\redirections.xml'"
```

`[VERIFY BEFORE IMPLEMENTATION]` Confirm the current setting name and expected file location in the Microsoft documentation for your FSLogix version.

**Evidence.** No redirections configuration exists. The largest containers are dominated by browser and Teams cache directories, and the profile itself is a small fraction of the total.

**Root cause.** Exclusions were never configured, so every cache directory has been roaming and accumulating since go-live.

**Resolution.** Introduce a redirections configuration excluding cache paths. Then run a compaction or shrink process against existing containers, because exclusions only stop future growth. That maintenance work is covered in [Chapter 22](ch22-profile-operations-failure-recovery.md).

Do this in stages and validate that nothing users rely on has been excluded. An aggressive exclusion list produces a different ticket queue, where applications appear to forget settings.

**Validation.** Measure average container size for new sign-ins over two weeks and confirm it has stopped growing. Then confirm total share usage falls after compaction rather than assuming it will.

**Prevention.** Configure exclusions before go-live. Alert on share capacity and on average container size trend, so growth is visible as a trend rather than as a ceiling.

**Architect lesson.** Profile size is an operational cost that grows silently. Nothing fails, so nothing prompts a review until the share fills. Trend alerting is the fix, not a bigger share.

**Interview lesson.** Pointing out that exclusions do not shrink existing containers is a detail that shows you have actually done remediation rather than only design.

---

## 9. The Architect's Four Questions

**What do I check first?** The FSLogix log on the affected host. It states plainly whether the container attached, and that single fact directs everything else.

**What can I safely change now?** Adding an antivirus exclusion. Reading registry values. Testing with a single account. Increasing `SizeInMBs` on a container approaching its ceiling.

**What must not be changed blindly?**
- `VHDLocations`. Changing it orphans every existing profile, and users get new empty containers.
- Reducing `SizeInMBs` below the size of existing containers.
- Aggressive exclusions applied estate wide without a pilot, because users lose settings they expect to keep.
- Removing `DeleteLocalProfileWhenVHDShouldApply` to make sign-in work. That is choosing silent data loss.
- Editing configuration on individual hosts. It disappears at the next image update.

**When do I escalate to Microsoft?** When configuration matches the documented guidance, exclusions are verified on the host, permissions and connectivity are proven, and containers still fail to attach or corrupt. Collect: the FSLogix log files, the registry values in use, the antivirus and security tooling exclusion configuration, the FSLogix agent version, the storage platform and authentication method, and whether it affects one user or all users.

---

## 10. Common Mistakes

- Copying a settings list without understanding what each value prevents.
- Treating multiple `VHDLocations` entries as redundancy. They are not.
- Configuring exclusions for Defender only, and forgetting network scanning and DLP.
- Assuming exclusions are applied because they were requested. Verify on the host.
- Putting FSLogix configuration in the image instead of policy.
- Setting `SizeInMBs` too low, which appears as applications failing to save.
- Leaving exclusions until profiles are already large, then expecting them to shrink.
- Excluding aggressively and causing applications to forget user settings.
- Maintaining an object specific share mapping by hand.

---

## 11. Interview Preparation

### Q60. What are the FSLogix settings you would always configure?

**Simple answer**
Enabled, VHDLocations, VolumeType as VHDX, SizeInMBs as a sensible ceiling, FlipFlopProfileDirectoryName for readable folder names, DeleteLocalProfileWhenVHDShouldApply to prevent silent local profile use, and the locked and reattach retry settings.

**Strong senior architect answer**
"I would rather explain what each one prevents than list them. Enabled and VHDLocations are obvious. VHDX because there is no reason to use VHD now. SizeInMBs as a ceiling rather than a target, because the container is dynamically expanding and setting it too low shows up as applications failing to save rather than as a storage error. FlipFlopProfileDirectoryName because at three in the morning you want to find a user's folder by name rather than by SID. DeleteLocalProfileWhenVHDShouldApply is the one I care about most, because without it a failed attach falls back to a local profile, the session works, and the user loses a day of work when the host is rebuilt. Then the locked and reattach retries, which cover a container that has not been released yet or a brief storage blip. And I would put all of it in policy rather than the image, so a correction takes minutes instead of a full image rebuild and rollout."

**Follow-up you should expect**
"What about multiple VHDLocations for resiliency?" That does not provide resiliency. Multiple entries are searched in order, so if the first share is unavailable the user gets a new empty container on the second one. Resilience is Cloud Cache or storage level redundancy.

### Q61. Why do antivirus exclusions matter so much for FSLogix?

**30 second answer**
"The container is a virtual disk that stays open and busy for the entire session. Real-time scanning competes with the operating system for it, which causes slow sign-ins and corrupted containers. Microsoft's guidance is to apply the exclusions in all layers of security, so endpoint antivirus, network scanning and DLP, not just Defender."

**2 minute answer**
Add the operational reality. The failure mode is corruption rather than a clean error, so it appears as lost settings and unusable profiles rather than as a security alert. The exclusions have to be verified on the session host rather than assumed, because a policy that targets the wrong group looks configured and is not. And the risk is recurring, because every new security tool is a new layer, and the requirement does not travel with it. So the fix is partly technical and partly making sure the AVD architect reviews endpoint tooling before it reaches session hosts.

**Deep dive answer**
There is a security conversation underneath this too. You are asking a security team to stop scanning a file containing a user's entire profile, so present it as a trade rather than a request. Explain what is excluded, why the scanning does not work on an open virtual disk anyway, and what compensating controls exist, such as scanning inside the session and on the endpoint that uploads content. That framing gets agreement. Sending a list of paths does not.

### Q62. How would you stop profiles growing out of control?

**Strong answer**
"Exclusions before go-live, not after. Browser caches and Teams caches are the usual bulk, and none of it needs to roam. The detail people miss is that adding an exclusion later does not shrink existing containers, it only stops them growing, so remediation is a separate compaction job. I would set SizeInMBs as a ceiling so a runaway profile cannot fill the share, and I would alert on average container size as a trend rather than waiting for the share to hit capacity. And I would pilot the exclusion list, because excluding too much is a different problem where applications appear to forget user settings and nobody links it back to profiles."

---

## 12. Key Takeaways

- Put FSLogix configuration in policy, not in the image. The agent belongs in the image.
- `DeleteLocalProfileWhenVHDShouldApply` prevents silent local profile use, which is the worst data loss failure in FSLogix.
- Multiple `VHDLocations` entries do not provide resiliency. They are searched in order.
- Use VHDX. There is no reason to use VHD in a new deployment.
- `SizeInMBs` is a ceiling on a dynamically expanding disk, not an allocation.
- `FlipFlopProfileDirectoryName` makes the share readable by a human, which matters during an incident.
- Antivirus exclusions must be applied in all security layers, including network scanning and DLP, and verified on the host.
- Exclusions stop future growth. They do not shrink existing containers.
- Object specific configuration is useful at scale and becomes a mapping problem if maintained by hand.

---

## 13. Official References

- Configure profile containers - https://learn.microsoft.com/en-us/fslogix/how-to-configure-profile-containers
- Prerequisites for FSLogix, including antivirus exclusions - https://learn.microsoft.com/en-us/fslogix/overview-prerequisites
- FSLogix configuration settings reference - https://learn.microsoft.com/en-us/fslogix/reference-configuration-settings
- Configuration examples - https://learn.microsoft.com/en-us/fslogix/concepts-configuration-examples
- Configure ODFC containers - https://learn.microsoft.com/en-us/fslogix/how-to-configure-odfc-containers
- Tutorial: create and implement redirections.xml - https://learn.microsoft.com/en-us/fslogix/tutorial-redirections-xml

---

## Hands-on Lab

FSLogix configuration, exclusions, and validation steps are in **Lab 6**.

---

## Chapter Close

**What was completed**
You can configure FSLogix for production, explain what each setting prevents, apply exclusions correctly, and control profile size before it becomes a cost problem.

**What you should test**
On any environment you can reach, run the registry query from Scenario 2 and check whether `DeleteLocalProfileWhenVHDShouldApply` is set. If it is not, you have found a real risk.

**What comes next**
Chapter 22 closes Part V with profile operations, failure and recovery. Locked containers, corruption, compaction, backup and what Cloud Cache actually does.

**Interview preparation carried forward**
Q59 rewards explaining what a setting prevents rather than reciting the list. That difference is obvious to an interviewer within one sentence.

---

## Chapter Self-Review

**Pass 1, technical verification.** The registry path, the settings and values in the configuration script, and the stated purpose of `ClearCacheOnLogoff`, `DeleteLocalProfileWhenVHDShouldApply` and `FlipFlopProfileDirectoryName` were verified against the current Microsoft configure profile containers page and the Cloud Cache tutorial settings table. The statement that multiple `VHDLocations` entries do not provide resiliency and the object specific configuration registry path were verified against the configuration examples page. The antivirus exclusion scope, including the instruction to apply exclusions in all layers of security, was verified against the FSLogix prerequisites page. Verification markers are placed on the exclusion list itself, the redirections file format and the redirections registry setting name, because those vary by version and by application. No setting value was invented.

**Pass 2, human readability review.** The settings table explains what each value prevents rather than restating its name, because a list of names is what the reference documentation already provides. The `VHDLocations` warning was given its own subsection because it is widely misunderstood and the failure mode looks like data loss. Sentences kept short, scenario narrative rather than bullets, no long dash characters. Read back as an engineer configuring this for the first time, and the ordering was changed so configuration location comes before settings, because deciding where configuration lives changes how you apply everything after it.

**Pass 3, visual and diagram review.** No diagram in this chapter, and that is deliberate. The content is a settings table, an exclusion list and a size management process. None of those are architecture, and drawing a flowchart of registry values would be exactly the generic diagram the [diagram standard](../DIAGRAM-STANDARD.md) forbids. The architecture that supports this chapter is already drawn in [Chapter 19](ch19-why-profiles-cause-avd-failure.md) and [Chapter 20](ch20-profile-storage-architecture.md), and is cross referenced rather than redrawn.

**Consistency check against earlier chapters.** The configuration in policy rather than image recommendation is consistent with the disposable host model in [Chapter 16](ch16-automated-host-pools-session-host-configuration.md#3-what-a-session-host-update-actually-does), where manual host changes do not survive an update. The `ProfileType` value is consistent with the concurrency discussion in [Chapter 19](ch19-why-profiles-cause-avd-failure.md#4-concurrency-one-user-more-than-one-session). The permission prerequisites reference [Chapter 20](ch20-profile-storage-architecture.md#5-the-two-layer-permission-model) rather than restating them. The security tooling scenario connects to the in-VM failure mode in [Chapter 13](ch13-hybrid-connectivity-egress-control.md#4-the-failure-mode-inside-the-virtual-machine). Storage account and share names match the lab naming convention. No earlier chapter required correction.

| Check | Result |
|---|---|
| Technical accuracy | Verified against current Microsoft FSLogix pages |
| Current capability verified | Yes, August 2026 |
| Supported versus unsupported separated | Yes. The VHDLocations resiliency misconception stated explicitly |
| Commands, registry paths, PowerShell | Exact, with prerequisites, expected results and common failures |
| Production scenarios | Three, in the extended format |
| Architect's Reality Check | Section 7 |
| Architect's four questions | Section 9 |
| Scale behaviour at 100, 1,000 and 5,000 users | Section 6 |
| Diagrams | None, deliberately, with the reason stated |
| Architecture consistency | Consistent with Chapters 13, 16, 19 and 20 |
| Cost statements | Profile growth as an operational cost, covered in Scenario 3 |
| Security implications | Exclusions framed as a security trade rather than a request |
| Interview answers | Read aloud |
| Duplicate content | Permissions referenced to Chapter 20, recovery deferred to Chapter 22 |
| Simple English | Reviewed |
| Long dash characters | None |
