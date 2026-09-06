# Lab 6 - FSLogix Configuration

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Depends on:** Lab 5 (profile storage)
> **Feeds into:** Lab 8 (session hosts, where you apply and validate this configuration)

---

## A sequencing note, stated honestly

Session hosts do not exist until Lab 8. FSLogix is agent software that runs on a session host, so this lab cannot show a live profile mounting for a user session yet. Perform that validation in [Lab 8](lab-08-session-hosts.md#step-5---end-to-end-validation-sign-in-and-confirm-the-profile-mounts), after the AVD agent registers.

What this lab does instead, and it is real work rather than a placeholder: it produces the exact configuration you will apply in Lab 8 (registry values, exclusions, the settings a Settings Catalog policy would carry), and it proves the storage mechanics: that a VHDX can actually be created and mounted from this share with these permissions: using the domain controller as a stand-in Windows machine, since a profile container is, underneath the AVD-specific behaviour, an ordinary VHDX on an ordinary SMB share. That distinction matters for troubleshooting: if the mechanics fail here, the problem is storage or permissions, not FSLogix. If they work here and still fail in Lab 8, the problem is specific to the FSLogix agent or its configuration.

## Objective

Produce and prove the FSLogix configuration from [Chapter 21](../chapters/ch21-fslogix-production-implementation.md): the registry values that matter and why, antivirus exclusions, the `VHDLocations` decision, and (critically) the setting most labs skip, `DeleteLocalProfileWhenVHDShouldApply`, whose absence is the single worst FSLogix failure mode because it fails silently.

## Learning objectives

- Produce a production FSLogix configuration script matching Chapter 21's settings table, with the reasoning for each value
- Configure and document the antivirus/EDR exclusions FSLogix requires, and know why they must apply to every security layer, not just Windows Defender
- Prove the underlying storage mechanics (VHDX creation and mount) work against the Lab 5 share before any AVD-specific troubleshooting is needed
- Deliberately induce a locked-container failure and recover from it, using the exact procedure from [Chapter 19](../chapters/ch19-why-profiles-cause-avd-failure.md#8-production-scenarios)

## Dependency on previous labs

| From | What this lab consumes |
|---|---|
| Lab 4 | Domain controller, used as the mechanics test machine |
| Lab 5 | The profile share, its UNC path (`vhd_location_unc_path` output), and both permission layers already proven working |

## Architecture context

This lab does not change the architecture diagram from Lab 5. It configures behaviour, not infrastructure: a useful distinction to notice, because it is exactly the image-versus-policy distinction from [Chapter 23](../chapters/ch23-golden-image-engineering.md#6-what-goes-in-the-image-and-what-does-not): FSLogix configuration belongs in policy, applied at the point a host exists, not baked into anything ahead of time.

## Prerequisites

- Lab 5 complete and validated
- Domain controller running

## Estimated cost

$0.00 for this lab specifically. No new billable resource is created; this lab configures behaviour and validates mechanics against resources already running from Labs 4 and 5.

---

## Security considerations

- Exclusions in Step 3 are scoped narrowly to the FSLogix paths and processes documented by Microsoft, not broad exclusions that would weaken endpoint protection generally.
- `DeleteLocalProfileWhenVHDShouldApply` is framed here as a security-adjacent setting, not just a convenience one: without it, a failed attach silently falls back to a local profile, and any work done in that session is lost the next time the host is rebuilt. That is a data protection failure, not merely an inconvenience.

---

## Step 1 - Produce the FSLogix registry configuration

This is the configuration you will apply in Lab 8. Save it now so Lab 8 can reference it directly rather than re-deriving it.

```powershell
# Save as: fslogix-profile-config.ps1
# Applied in Lab 8, Step 5, after the AVD agent registers and before user testing.

$VHDLocations = "\\<storage_account_name>.file.core.windows.net\profiles"

New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name Enabled -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name VHDLocations -PropertyType MultiString -Value $VHDLocations -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name VolumeType -PropertyType string -Value "VHDX" -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name SizeInMBs -PropertyType dword -Value 30000 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name FlipFlopProfileDirectoryName -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name DeleteLocalProfileWhenVHDShouldApply -PropertyType dword -Value 1 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name ProfileType -PropertyType dword -Value 0 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name LockedRetryCount -PropertyType dword -Value 3 -Force
New-ItemProperty -Path HKLM:\SOFTWARE\FSLogix\Profiles\ -Name LockedRetryInterval -PropertyType dword -Value 15 -Force
```

**Why `DeleteLocalProfileWhenVHDShouldApply` is not optional in this lab's configuration.** Covered fully in [Chapter 21](../chapters/ch21-fslogix-production-implementation.md#2-the-settings-that-matter) and worth restating here because it is the one setting worth memorising: without it, a container that fails to attach falls back to a local profile silently, the session works normally, and the user's session data is lost the next time the host is replaced. Set it every time, in every lab and every real deployment.

**Why `VolumeType` is `VHDX`, not `VHD`.** There is no reason to choose VHD for a new deployment; VHDX is the current recommendation throughout Chapter 21 and this book.

---

## Step 2 - Prove the storage mechanics from the domain controller

Before any FSLogix agent is involved, confirm the share can actually hold and serve a VHDX: this isolates storage/permission problems from FSLogix-specific ones.

```bash
az vm run-command invoke -g rg-avd-identity-lab-eus2-01 -n vm-avdlab-dc01 \
  --command-id RunPowerShellScript \
  --scripts "
    \$vhdPath = '\\\\<storage_account_name>.file.core.windows.net\\profiles\\test-container.vhdx'
    New-VHD -Path \$vhdPath -SizeBytes 5GB -Dynamic
    Mount-VHD -Path \$vhdPath
    Get-Disk | Where-Object BusType -eq 'File Backed Virtual'
    Dismount-VHD -Path \$vhdPath
    Remove-Item -Path \$vhdPath
  "
```

**Expected output:** the VHDX creates, mounts (visible as a File Backed Virtual disk), dismounts and deletes cleanly. This proves the share supports the exact mechanism FSLogix depends on: creating a VHDX on the share and mounting it as a local disk.

**If this fails:** do not proceed to Lab 8 assuming the problem will resolve itself. Return to Lab 5 and re-check both permission layers, because a mechanics failure here will fail identically once an actual session host is involved, just with a less clear error message.

---

## Step 3 - Document the required exclusions

Exclusions are applied to session hosts in Lab 8 (via Intune, per [Chapter 21](../chapters/ch21-fslogix-production-implementation.md#3-antivirus-and-security-tool-exclusions)). Produce the list now:

| Exclusion type | Path or process |
|---|---|
| Folder (Defender and any EDR/DLP) | `%ProgramFiles%\FSLogix\Apps` |
| Folder | `%TEMP%\*.VHD` and `%TEMP%\*.VHDX` |
| Folder | The profile share UNC path itself: `\\<storage_account_name>.file.core.windows.net\profiles\*` |
| Process | `frxccd.exe`, `frxccds.exe`, `frxsvc.exe` |

`[VERIFY BEFORE IMPLEMENTATION]`: take the current, complete exclusion list from the [Microsoft FSLogix prerequisites page](https://learn.microsoft.com/en-us/fslogix/overview-prerequisites) before applying to any real host; the list above is the core set and has changed as FSLogix has evolved.

**The instruction that matters most, from Chapter 21: apply these in every security layer, not only Windows Defender.** Network scanning appliances and DLP agents inspect this traffic too, and they are usually managed by a different team who has never heard of FSLogix.

---

## Step 4 - Simulate a locked container and recover

This reproduces the most common FSLogix production incident (a container left locked by an abnormal session end) using the mechanics proven in Step 2, so you see the failure and the fix before it happens for real in Lab 8 or beyond.

```bash
# Simulate a lock: mount the container and do not release it
az vm run-command invoke -g rg-avd-identity-lab-eus2-01 -n vm-avdlab-dc01 \
  --command-id RunPowerShellScript \
  --scripts "
    \$vhdPath = '\\\\<storage_account_name>.file.core.windows.net\\profiles\\locktest.vhdx'
    New-VHD -Path \$vhdPath -SizeBytes 1GB -Dynamic | Mount-VHD -Passthru
  "
```

Now, from a second context (or the Azure portal), attempt to identify the open handle: this is the exact diagnostic step from [Chapter 19, Scenario 3](../chapters/ch19-why-profiles-cause-avd-failure.md#8-production-scenarios):

```bash
az storage file handle list \
  --account-name <storage_account_name> \
  --share-name profiles \
  --path "locktest.vhdx" \
  --auth-mode login -o table
```

**Expected output:** an open handle listed, showing the client that holds the lock.

Recover by closing the handle and cleaning up:

```bash
az storage file handle close-all \
  --account-name <storage_account_name> \
  --share-name profiles \
  --path "locktest.vhdx" \
  --auth-mode login

az vm run-command invoke -g rg-avd-identity-lab-eus2-01 -n vm-avdlab-dc01 \
  --command-id RunPowerShellScript \
  --scripts "Dismount-VHD -Path '\\\\<storage_account_name>.file.core.windows.net\\profiles\\locktest.vhdx'; Remove-Item -Path '\\\\<storage_account_name>.file.core.windows.net\\profiles\\locktest.vhdx'"
```

**Warning, carried from Chapter 19 and worth repeating here where it is easy to forget under lab conditions:** in production, only close a handle you have confirmed is stale: one belonging to a session or host that no longer exists. Closing a handle for a live session interrupts that user. This lab's handle is deliberately yours, so closing it is safe here specifically.

---

## Validation checklist

- [ ] `fslogix-profile-config.ps1` produced and reviewed against the Chapter 21 settings table
- [ ] VHDX create/mount/dismount mechanics proven against the Lab 5 share from the domain controller
- [ ] Exclusion list documented, ready to apply via Intune in Lab 8
- [ ] Locked container simulated, identified via `az storage file handle list`, and recovered
- [ ] `DeleteLocalProfileWhenVHDShouldApply` present and set to `1` in the saved configuration script

## Common errors

| Symptom | Likely cause | Fix |
|---|---|---|
| `New-VHD` fails with access denied | NTFS permission from Lab 5 Step 6 not actually applied, or applied to the wrong identity | Re-run `Get-Acl` against the share path and confirm |
| `az storage file handle list` returns nothing for a VHD you just mounted | Handle enumeration can lag briefly behind the mount | Wait a few seconds and retry; if it persists, confirm you are querying the correct account and share |
| Mount succeeds but `Get-Disk` shows nothing | Ran the check in a different session than the mount | Keep create/mount/check/dismount in one script invocation, as written above |

## Troubleshooting

If Step 2's mechanics fail, work the two-layer permission check from Lab 5 again before assuming anything about FSLogix: this lab exists specifically to separate those two failure classes, and skipping back to re-verify Lab 5 at this point is the correct move, not a wasted step.

## Cleanup versus keep

Nothing new was created that costs money. Confirm no stray `.vhdx` test files remain on the share:

```bash
az storage file list --account-name <storage_account_name> --share-name profiles --auth-mode login -o table
```

Delete any `test-container.vhdx` or `locktest.vhdx` left over from Steps 2 or 4.

## Portfolio evidence to capture

- The saved `fslogix-profile-config.ps1`, annotated with why each setting is set the way it is
- The Step 2 mechanics proof (create/mount/dismount succeeding)
- The Step 4 sequence: handle identified, then closed, then cleaned up: this demonstrates real incident response rather than only configuration

## Interview questions from this lab

**Q. What is the one FSLogix setting you would never deploy without, and why?**

`DeleteLocalProfileWhenVHDShouldApply`. Without it, a failed container attach falls back silently to a local profile: the session works, so nobody notices, and the user's work is lost the next time the host is rebuilt. It converts a visible failure into invisible data loss, which is the worst direction to fail in.

**Q. A user's container will not mount. How do you tell whether it is a lock, a permission problem, or a storage problem?**

Check the FSLogix log first for the specific error class. For a suspected lock, list open handles on the container file directly with `az storage file handle list`: a handle from a session or host that no longer exists is the signature of a stale lock, and closing it (after confirming it really is stale) resolves it without deleting any data.

---

## What comes next

[Lab 7 - Core AVD Objects](lab-07-avd-host-pool.md) builds the host pool, workspace and application group this environment has been missing since Lab 1: the pieces that turn a network, an identity, and profile storage into something a user can actually be assigned to.
