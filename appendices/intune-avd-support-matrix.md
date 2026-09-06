# Appendix - Intune and AVD Support Matrix

> **Verified against Microsoft Learn: 6 September 2026**
> `CURRENCY FLAG` - Intune support for AVD has expanded steadily and continues to change. Re-verify every row before writing it into a design document.
>
> Referenced in: Chapter 7 (identity), Chapter 9 (compliance and Conditional Access), Chapter 18 (session host lifecycle), **Chapter 24 (Intune and AVD - endpoint management architecture)**, [Project 06](../scenarios/project-06-byod-remote-workforce.md) and [Project 11](../scenarios/project-11-highly-secure-regulated.md) (security hardening), [Project 02](../scenarios/project-02-enterprise-850-users.md) (day-2 operations), [Project 15](../scenarios/project-15-production-troubleshooting.md) and the [troubleshooting runbooks](../troubleshooting/README.md) (troubleshooting).

This appendix exists because the single biggest cause of failed Intune-on-AVD projects is not architecture. It is assuming that a policy which works on a physical laptop will work on a multi-session session host. Many do. Some silently report **Not applicable**. A few are blocked outright.

Three categories are used throughout:

- ✅ **Supported** - Microsoft documents this as working
- ❌ **Not supported** - Microsoft documents this as unsupported or disabled
- ⚠️ **Scenario-dependent** - works only under stated conditions, or Microsoft advises against it in some designs

---

## 1. Prerequisites for multi-session management

*Source: [Using Azure Virtual Desktop multi-session with Microsoft Intune](https://learn.microsoft.com/en-us/intune/solutions/azure-virtual-desktop-multi-session).*

Confirm all of these before assigning a single production policy. This feature supports Windows Enterprise multi-session VMs which are set up as remote desktops in pooled host pools deployed through Azure Resource Manager, are under the same tenant as Intune, and are running an Azure Virtual Desktop agent version of 1.0.2944.1400 or later.

| Requirement | Detail |
|---|---|
| Host pool type | Pooled, deployed through Azure Resource Manager |
| Tenant | Session hosts and Intune must be in the same tenant |
| AVD agent version | 1.0.2944.1400 or later |
| Join type | Microsoft Entra joined, or Microsoft Entra hybrid joined and enrolled using Active Directory group policy configured to use **device credentials** and to automatically enrol Entra hybrid joined devices |
| Cloud | Azure Public and Azure Government |
| Licensing | Intune licences are included with most Microsoft 365 subscriptions |

**The device-credentials point is the one people get wrong.** If auto-enrollment is configured to use user credentials, enrolment fails - Windows Enterprise multi-session virtual machines must be enrolled using device credentials.

---

## 2. Configuration and policy

*Source: [Using Azure Virtual Desktop multi-session with Microsoft Intune](https://learn.microsoft.com/en-us/intune/solutions/azure-virtual-desktop-multi-session); security baseline row also draws on [Intune security baselines](https://learn.microsoft.com/en-us/intune/protect/security-baselines).*

| Capability | Status | Detail |
|---|---|---|
| Device-scope configuration | ✅ | Device configuration support for Windows Enterprise multi-session is generally available. Policies defined in the OS scope and apps configured to install in the system context can be applied when assigned to **device groups**. |
| User-scope configuration | ✅ | User configuration support is generally available: user-scope policies via the Settings catalog assigned to user groups, user certificates assigned to users, and PowerShell scripts installed in the user context assigned to users. |
| Settings catalog | ✅ | To configure policies for Windows Enterprise multi-session VMs, use the Settings catalog in the Microsoft Intune admin center. Filter the catalog by **Enterprise multi-session** |
| ADMX-backed administrative templates | ⚠️ | Supported, but some policies aren't yet available in the Settings catalog |
| ADMX-ingested administrative templates | ⚠️ | Supported, but some ingested settings won't be applicable to Windows Enterprise multi-session |
| Security baselines | ✅ | Security baselines are available for Windows Enterprise multi-session. Microsoft recommends reviewing the available baselines and configuring the recommended policies and values in the Settings catalog. |
| Windows 10 user-scope configuration | ⚠️ | Requires the March 2023 Cumulative Update Preview (KB5023773) and OS build 19042.2788, 19044.2788, 19045.2788 or later |

**Architect note.** Multi-session is treated as a separate OS edition, and some Windows Enterprise configurations won't be supported for this edition. That single sentence explains most of the "policy shows Not applicable" tickets you will ever receive. Always pilot a policy against one test host before broad assignment.

---

## 3. Compliance and Conditional Access

*Source: [Using Azure Virtual Desktop multi-session with Microsoft Intune](https://learn.microsoft.com/en-us/intune/solutions/azure-virtual-desktop-multi-session), compliance and Conditional Access section.*

| Capability | Status | Detail |
|---|---|---|
| Compliance policies | ⚠️ | A defined subset of compliance policies is supported on Windows Enterprise multi-session VMs; all other policies report as **Not applicable**. You need to create a new compliance policy targeted at the device group containing your multi-session VMs. |
| Conditional Access using device compliance | ✅ | You can secure Windows Enterprise multi-session VMs by configuring compliance and Conditional Access policies in the Microsoft Intune admin center. See Chapter 9 |
| Reusing an existing physical-device compliance policy | ❌ | Create a new policy scoped to the multi-session device group instead |

---

## 4. Applications

*Source: [Using Azure Virtual Desktop multi-session with Microsoft Intune](https://learn.microsoft.com/en-us/intune/solutions/azure-virtual-desktop-multi-session), application deployment section. FSLogix/UWP interaction is Microsoft's own compatibility note in the same page.*

| Capability | Status | Detail |
|---|---|---|
| Apps installed in **system context** | ✅ | Assigned to device groups |
| Apps installed in **user context** | ❌ | App deployment must use system/device context and target devices. User-context PowerShell scripts are a separate supported capability. |
| PowerShell scripts in user context | ✅ | Assigned to users |
| Modern / UWP apps with FSLogix | ⚠️ | Microsoft notes that modern apps such as UWP apps may not work correctly when FSLogix is configured, and recommends not configuring modern apps when FSLogix is in use. Relevant to Chapters 21 and 25 |

**Delivery strategy sits in Chapter 25.** Intune is one of four application delivery routes - image-baked, App Attach, Intune/Configuration Manager, and published RemoteApp - and the decision framework lives there.

---

## 5. Windows Update management

*Source: [Using Azure Virtual Desktop multi-session with Microsoft Intune](https://learn.microsoft.com/en-us/intune/solutions/azure-virtual-desktop-multi-session), Windows Update section.*

This is the row most people get wrong.

| Capability | Status | Detail |
|---|---|---|
| Update rings for Windows | ❌ | Windows update ring policies aren't currently supported |
| Quality (security) updates via Settings catalog | ✅ | Quality updates can be managed via settings available in the Settings catalog. Filter the catalog for **Enterprise multi-session** and expand the **Windows Update for Business** category |
| Feature updates | ⚠️ | For pooled non-persistent hosts, the supported production pattern is image replacement, not in-place feature update. See Chapter 23 |

**Architect position.** For pooled host pools, do not try to run a patching regime on the session hosts at all. Patch the image, publish a new image version, and roll the hosts. Intune's update settings are useful for personal host pools and for closing the gap between image releases - not as the primary patching strategy for non-persistent estates.

---

## 6. Enrolment and lifecycle

*Source: [Using Azure Virtual Desktop multi-session with Microsoft Intune](https://learn.microsoft.com/en-us/intune/solutions/azure-virtual-desktop-multi-session), enrolment and non-persistent VDI sections.*

| Capability | Status | Detail |
|---|---|---|
| Enrolment with device credentials | ✅ | Required for multi-session |
| Enrolment with user credentials | ❌ | Causes enrolment failure on multi-session |
| Out of Box Experience enrolment | ❌ | OOBE enrolment isn't supported for Windows Enterprise multi-session |
| Windows Autopilot | ❌ | Autopilot and Commercial OOBE aren't supported; Autopilot self-deploying and pre-provisioning require a physical TPM |
| Enrollment Status Page | ❌ | Not supported |
| Cloned image of an already-enrolled machine | ❌ | Intune does not support using a cloned image of a computer that is already enrolled. Enrol after deployment, never bake enrolment into the image |
| Non-persistent VDI management | ⚠️ | Microsoft recommends **not** using Intune to manage on-demand, session-host virtual machines (non-persistent VDI). Each VM must be enrolled when created, and regularly deleting VMs creates orphaned device records until cleanup. |
| Orphaned device records | ⚠️ | Deleting VMs from Azure leaves orphaned device records in Intune, cleaned up according to the tenant's cleanup rules. Configure device cleanup rules deliberately |

**This is the most important architectural tension in the whole topic.** Intune is device-centric and assumes devices persist. Pooled AVD is deliberately disposable. Chapter 24 works through how to reconcile the two, and when the honest answer is to manage the *image* rather than the *host*.

---

## 7. Remote actions

*Source: [Using Azure Virtual Desktop multi-session with Microsoft Intune](https://learn.microsoft.com/en-us/intune/solutions/azure-virtual-desktop-multi-session), remote actions section.*

The following actions are greyed out in the Intune UI and disabled in Graph for Windows Enterprise multi-session VMs: Windows Autopilot reset, BitLocker key rotation, Fresh Start, remote lock, reset password, and wipe. The same actions are listed as unsupported or not recommended for AVD VMs generally.

| Remote action | Status |
|---|---|
| Autopilot reset | ❌ |
| BitLocker key rotation | ❌ |
| Fresh Start | ❌ |
| Remote lock | ❌ |
| Reset password | ❌ |
| Wipe | ❌ |
| Sync, restart, collect diagnostics | ✅ (standard actions remain available) |

**Operational consequence.** For a physical laptop, wipe-and-rebuild is a normal last resort. For a pooled session host, the equivalent is: put the host in drain mode, wait for sessions to drain, remove it from the host pool, delete the VM, and redeploy from the current image. Build that runbook per [Project 02](../scenarios/project-02-enterprise-850-users.md) and [Project 15](../scenarios/project-15-production-troubleshooting.md) rather than reaching for a remote action that does not exist here.

---

## 8. Platform and topology exclusions

*Source: [Using Azure Virtual Desktop multi-session with Microsoft Intune](https://learn.microsoft.com/en-us/intune/solutions/azure-virtual-desktop-multi-session) for exclusions; personal VM row from [Using Azure Virtual Desktop single-session with Microsoft Intune](https://learn.microsoft.com/en-us/intune/solutions/azure-virtual-desktop).*

| Scenario | Status |
|---|---|
| Azure Public cloud | ✅ |
| Azure Government (GCC, GCC High, DoD) | ✅ Windows Enterprise multi-session VMs created in Azure Government Cloud in GCC, GCC High and DoD can be managed |
| China Sovereign Cloud | ❌ Not currently supported for Windows Enterprise multi-session managed by Intune |
| Cross-cloud enrolment (public tenant managing a sovereign-cloud VM, or vice versa) | ❌ Cross-cloud enrolments aren't supported |
| Citrix DaaS | ❌ Intune support for AVD multi-session is not currently available for Citrix DaaS - direct questions to Citrix |
| VMware / Omnissa Horizon Cloud | ❌ Not currently available |
| Hosts joined to Microsoft Entra Domain Services | ❌ Microsoft states that these session hosts can't be managed with Intune |
| Personal / single-session AVD VMs | ✅ Intune treats AVD personal VMs the same as Windows Enterprise physical desktops, letting you reuse existing configurations and secure them with compliance policy and Conditional Access |

---

## 9. Coexistence with other management tools

*Source: [Using Windows virtual machines with Microsoft Intune](https://learn.microsoft.com/en-us/intune/solutions/windows-virtual-machines) for Configuration Manager coexistence; multi-session interference statement from [Using Azure Virtual Desktop multi-session with Microsoft Intune](https://learn.microsoft.com/en-us/intune/solutions/azure-virtual-desktop-multi-session).*

| Combination | Status | Notes |
|---|---|---|
| Intune alongside AVD's own management | ✅ | Using Intune doesn't depend on or interfere with Azure Virtual Desktop management of the same VM |
| Configuration Manager | ✅ | Configuration Manager 1906 and later can manage domain-joined and Microsoft Entra hybrid joined session hosts |
| Group Policy alongside Intune | ⚠️ | Works, but you must decide which tool owns which setting. Overlapping ownership produces conflicts nobody can trace. Worked through as a project decision in [Project 04](../scenarios/project-04-hybrid-active-directory.md) |
| Multiple MDM providers in one tenant | ⚠️ | A known issue prevents auto-enrolment when a tenant has more than one MDM provider |

---

## 10. Quick decision guide

| Your environment | Practical recommendation |
|---|---|
| Entra-joined, pooled, non-persistent | Manage the **image**. Use Intune for security baselines, compliance for Conditional Access, and system-context apps. Do not build a host-level patching regime |
| Entra-joined, personal host pools | Intune is a strong fit - treat hosts much like physical Windows Enterprise desktops |
| Hybrid joined, existing AD and GPO | Coexistence. Keep GPO where it already works, move security baselines and compliance to Intune, and document setting ownership explicitly |
| Existing Configuration Manager estate | Configuration Manager remains supported for domain-joined and hybrid-joined hosts. Co-management is a migration path, not a permanent target |
| Citrix or Horizon on Azure | Multi-session Intune management is not available. Use the vendor's tooling |

---

## Official References

- Manage the operating system of session hosts - https://learn.microsoft.com/en-us/azure/virtual-desktop/management
- Using Azure Virtual Desktop multi-session with Microsoft Intune - https://learn.microsoft.com/en-us/intune/solutions/azure-virtual-desktop-multi-session
- Using Azure Virtual Desktop single-session with Microsoft Intune - https://learn.microsoft.com/en-us/intune/solutions/azure-virtual-desktop
- Using Windows virtual machines with Microsoft Intune - https://learn.microsoft.com/en-us/intune/solutions/windows-virtual-machines
- Intune security baselines - https://learn.microsoft.com/en-us/intune/protect/security-baselines
