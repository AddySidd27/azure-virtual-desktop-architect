> **Part of:** [Azure Virtual Desktop - Architect to Hands-on Implementation](../README.md)
> **Chapter:** [Chapter 22 - Profile Operations and Failure Recovery](../chapters/ch22-profile-operations-failure-recovery.md)
> **Technical baseline:** August 2026
> **Plan:** [Labs 11-20 plan](../appendices/labs-11-20-plan.md)

# LAB 15 - FSLogix Cloud Cache Active-Active Replication and User Affinity

> **LAB ARCHITECTURE** - the environment you build across Labs 1-20. Not a Microsoft reference design.

## Objective

Connect the two independent storage accounts from Lab 13 using FSLogix Cloud Cache, so a profile created in one region replicates to the other. Then deliberately reproduce the failure Microsoft's own documentation describes when the same profile is accessed from both regions concurrently, before Lab 16 builds the control that prevents it. Seeing the failure once, on purpose, is worth more than being told about it.

This lab is primarily PowerShell and registry configuration, not Terraform. FSLogix behaviour is host-level configuration, not an Azure Resource Manager object, exactly the same reasoning Lab 6 gives for why its own configuration isn't Terraform-managed either.

## No new Terraform in this lab

This lab configures FSLogix registry settings on the session hosts Lab 14 already created, pointing at the storage accounts Lab 13 already created. Nothing new is deployed. If you're looking for the Terraform side of storage, see [`terraform/lab13-regional-storage`](../terraform/lab13-regional-storage/).

## Prerequisites

- Lab 13 complete: both regions' storage accounts, private endpoints, and both permission layers validated
- Lab 14 complete: both regions' session hosts registered and `Available`
- A test user account that exists in `avdlab.local` and is assigned to both regions' application groups (the same temporary assignment Lab 14 Step 4 used - if you already removed it during Lab 14 cleanup, re-add it for this lab, then remove it again before Lab 16)

---

## Step 1 - Understand `CCDLocations` before writing any configuration

Cloud Cache's read and write behaviour, from [Chapter 22](../chapters/ch22-profile-operations-failure-recovery.md#1-what-cloud-cache-actually-does): `CCDLocations` supports up to four remote container locations. **The first location listed is the primary provider and the only one used for reads**, unless it becomes unhealthy. **All listed providers are used for writes.** This is why the order matters, and why this lab reverses the order per region rather than using an identical list in both places.

**Configuration rule that breaks silently if missed:** `CCDLocations` and `VHDLocations` must not both be present. Moving to Cloud Cache means removing `VHDLocations` from Lab 6's original configuration entirely, not adding `CCDLocations` alongside it.

## Step 2 - Write the `centralus` FSLogix configuration

```powershell
# Save as: fslogix-cloudcache-centralus.ps1
# Applied to vm-avdlab-cus-h1 and vm-avdlab-cus-h2 (Lab 14's centralus session hosts)

# centralus is primary here - reads come from the local storage account first.
$CCDLocations = "type=smb,connectionString=stfslogixlabcus01.file.core.windows.net\profiles;type=smb,connectionString=stfslogixlabeus201.file.core.windows.net\profiles"

New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name Enabled -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name CCDLocations -PropertyType MultiString -Value $CCDLocations -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name VolumeType -PropertyType string -Value "VHDX" -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name SizeInMBs -PropertyType dword -Value 30000 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name FlipFlopProfileDirectoryName -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name DeleteLocalProfileWhenVHDShouldApply -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name ProfileType -PropertyType dword -Value 0 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name LockedRetryCount -PropertyType dword -Value 3 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name LockedRetryInterval -PropertyType dword -Value 15 -Force

# Explicitly NOT present: VHDLocations. CCDLocations and VHDLocations must never coexist.
```

## Step 3 - Write the `eastus2` FSLogix configuration, providers reversed

```powershell
# Save as: fslogix-cloudcache-eastus2.ps1
# Applied to vm-avdlab-h1 and vm-avdlab-h2 (Lab 8's eastus2 session hosts)

# eastus2 is primary here - the exact opposite order from centralus.
# This is deliberate, not a typo: each region reads from its own local
# storage account first, and only falls back to the remote one if the
# local provider is unhealthy.
$CCDLocations = "type=smb,connectionString=stfslogixlabeus201.file.core.windows.net\profiles;type=smb,connectionString=stfslogixlabcus01.file.core.windows.net\profiles"

New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name Enabled -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name CCDLocations -PropertyType MultiString -Value $CCDLocations -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name VolumeType -PropertyType string -Value "VHDX" -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name SizeInMBs -PropertyType dword -Value 30000 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name FlipFlopProfileDirectoryName -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name DeleteLocalProfileWhenVHDShouldApply -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name ProfileType -PropertyType dword -Value 0 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name LockedRetryCount -PropertyType dword -Value 3 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name LockedRetryInterval -PropertyType dword -Value 15 -Force
```

**Why remove Lab 6's original `VHDLocations` configuration first, not just add `CCDLocations` on top.** They are mutually exclusive settings, and having both present is exactly the kind of configuration drift this book's diagram remediation work found repeatedly elsewhere: technically two settings exist, and FSLogix's actual behaviour with both present simultaneously is undefined territory you don't want to debug in production. Explicitly remove `VHDLocations` as part of applying this lab's configuration:

```powershell
Remove-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name VHDLocations -ErrorAction SilentlyContinue
```

## Step 4 - Apply both configurations

```bash
# centralus hosts
az vm run-command invoke -g rg-avd-hosts-lab-cus-01 -n vm-avdlab-cus-h1 \
  --command-id RunPowerShellScript \
  --scripts @fslogix-cloudcache-centralus.ps1

az vm run-command invoke -g rg-avd-hosts-lab-cus-01 -n vm-avdlab-cus-h2 \
  --command-id RunPowerShellScript \
  --scripts @fslogix-cloudcache-centralus.ps1

# eastus2 hosts
az vm run-command invoke -g rg-avd-hosts-lab-eus2-01 -n vm-avdlab-h1 \
  --command-id RunPowerShellScript \
  --scripts @fslogix-cloudcache-eastus2.ps1

az vm run-command invoke -g rg-avd-hosts-lab-eus2-01 -n vm-avdlab-h2 \
  --command-id RunPowerShellScript \
  --scripts @fslogix-cloudcache-eastus2.ps1
```

**Expected output:** each command completes without error. Restart all four session hosts so the registry change is picked up cleanly by the FSLogix driver, matching the same restart discipline Lab 12 uses after a DNS change.

## Step 5 - Confirm replication, one direction

```bash
# Sign in as the test user against the eastus2 desktop first, then sign out.
# Then check whether the profile container appears in the centralus share.

az vm run-command invoke -g rg-avd-identity-lab-cus-01 -n vm-avdlab-dc02 \
  --command-id RunPowerShellScript \
  --scripts "Get-ChildItem -Path '\\stfslogixlabcus01.file.core.windows.net\profiles' | Select-Object Name, LastWriteTime"
```

**Expected output:** a profile container folder matching the test user's SID, with a `LastWriteTime` shortly after their `eastus2` sign-out. Replication to `centralus` happens as part of Cloud Cache's normal write behaviour, which writes to every listed provider, not only the primary. Allow a few minutes if it doesn't appear immediately - Cloud Cache flushes on sign-out, and network conditions between regions affect how quickly that completes.

## Step 6 - Reproduce the lock-violation failure, deliberately

**Do not skip this step.** This is the specific, documented failure mode active-active FSLogix has if nothing prevents it, and Lab 16 exists to solve exactly this problem.

1. Sign in as the test user to the `eastus2` desktop entry. Leave the session active - do not sign out.
2. While that session is still active, sign in as the **same test user** to the `centralus` desktop entry, using a second device or a second Windows App profile.

**Expected result: the second sign-in fails**, or falls back to a temporary local profile depending on your `DeleteLocalProfileWhenVHDShouldApply` and retry settings. Check the FSLogix log on the `centralus` host for the specific error:

```powershell
Get-Content "C:\ProgramData\FSLogix\Logs\Profile\*.log" -Tail 50 | Select-String "ERROR_LOCK_VIOLATION"
```

**Expected output:** a line containing `ERROR_LOCK_VIOLATION` (error code 33, hex `0x21`). This is the exact, documented failure Microsoft's Azure Architecture Center describes for concurrent cross-region access to the same profile container. It is not a bug in this lab's configuration - it is Cloud Cache correctly refusing to let two hosts write to the same VHDX simultaneously, since doing so would corrupt the profile.

3. Sign out of the `eastus2` session. Wait a minute for the lock to release, then retry the `centralus` sign-in.

**Expected result:** the second sign-in now succeeds, confirming the lock was the `eastus2` session, not a permanent fault.

---

## Validation Checklist

- [ ] `centralus` session hosts show `CCDLocations` with `stfslogixlabcus01` listed first
- [ ] `eastus2` session hosts show `CCDLocations` with `stfslogixlabeus201` listed first - the reversed order confirmed on both sides
- [ ] `VHDLocations` is absent from every session host's FSLogix registry keys, in both regions
- [ ] A profile created via sign-in in one region is confirmed present in the other region's storage account, via a direct share listing, not assumed
- [ ] The `ERROR_LOCK_VIOLATION` failure reproduced deliberately, with the exact log line captured as evidence
- [ ] The failure resolves once the conflicting session signs out, confirming it's a lock, not data loss

## Common errors

| Error | Cause | Fix |
|---|---|---|
| Profile doesn't replicate at all | `VHDLocations` still present alongside `CCDLocations` | Confirm `Remove-ItemProperty` for `VHDLocations` actually ran; the two settings coexisting produces undefined behaviour, not a clean failure |
| `CCDLocations` syntax rejected | Missing `type=smb,connectionString=` prefix, or a stray space | Copy the exact string format from Step 2/3 - FSLogix's parser for this value is strict |
| Lock violation never reproduces, second sign-in just succeeds | The first session actually signed out before the second sign-in attempt, releasing the lock naturally | Confirm the first session is genuinely still active (check `Get-AzWvdUserSession`) before attempting the second sign-in |

## Troubleshooting

If replication seems to work in the `centralus → eastus2` direction but not the reverse, re-check that both configuration scripts were actually applied to the correct hosts - it's an easy mistake to apply the `centralus` script to an `eastus2` host by accident during Step 4, since the two scripts differ only in provider order, not structure.

## Cleanup

**Keep the configuration.** Labs 16-20 depend on Cloud Cache being active in both regions. No new Azure resources were created in this lab, so there's nothing extra to deallocate beyond what Labs 13 and 14 already established.

**Remove the temporary dual-region assignment** from your test user before starting Lab 16, if you haven't already - Lab 16 builds the correct, non-overlapping version of this assignment from a clean starting state.

## Interview questions from this lab

**Q. Why does `centralus`'s configuration list its own storage account first in `CCDLocations`, while `eastus2`'s configuration lists its own storage account first too, rather than both regions using an identical provider order?**
Because the first entry in `CCDLocations` is the only one used for reads under normal conditions, and reads are the majority of profile I/O during a session. If both regions used the same order, one region's session hosts would be reading across the region pair for every normal profile operation, adding real latency for no benefit, while the other region would enjoy fast local reads. Reversing the order per region means both regions get fast local reads under normal conditions, and both still get the resilience of a second provider if the local one becomes unhealthy - the reversal is what makes "each region is independently fast" actually true, not just claimed.

**Q. You reproduced `ERROR_LOCK_VIOLATION` deliberately in this lab. What does that error actually tell you, and what would a production incident involving it look like?**
It tells you two hosts, in this case one in each region, are trying to write to the same profile container's VHDX file at the same time, which Cloud Cache correctly refuses to allow, because permitting it would risk corrupting the profile. In production, this would show up as a user complaining their session on one device is fine but a second device or a second sign-in attempt fails or falls back to a temporary profile - and the fix is never to loosen the lock; it's to find why the same user has two live sessions in two regions at once, which usually traces back to exactly the gap Lab 16 closes: nothing stopping a user from being assigned to both regions' application groups simultaneously.

**Q. Given that the lock-violation failure is expected and documented, why not just tell users "don't sign in from two regions at once" instead of building Lab 16's group-based prevention?**
Because relying on users to self-police a technical constraint they don't know exists, and have no way to check before it's too late, is not a real control - it's hoping. A user has no visibility into which region their previous session landed in, especially if they're using Start VM on Connect or haven't thought about it at all; they just see two desktop icons and might reasonably click whichever one loads faster that day. Lab 16's non-overlapping group assignment removes the possibility at the access layer, before FSLogix is ever involved, which is a categorically more reliable control than a policy nobody can actually verify compliance with in the moment.

---

## What comes next

[Lab 16 - User-to-Region Assignment and Routing Strategy](lab-16-user-region-assignment.md) builds the non-overlapping Entra group structure that gives each user access to exactly one region's application group at a time, the concrete control that prevents the failure this lab just reproduced.
