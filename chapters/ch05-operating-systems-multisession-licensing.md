# Chapter 5 - Operating Systems, Multi-session and Licensing

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Part I:** AVD Fundamentals and the Architect's Mental Model
> **Technical baseline:** Microsoft Learn as retrieved 16 October 2026 (see [Review register](../REVIEW-REGISTER.md))

---

## Chapter Information

| Item | Detail |
|---|---|
| **Chapter number** | 5 |
| **Objective** | Choose the right session host operating system for a workload, and explain the licensing consequences of that choice without hedging |
| **Prerequisites** | Chapters 1-4 |
| **Dependencies** | Extends the licensing section of [Chapter 1](ch01-what-avd-actually-is.md#5-licensing-explained-simply); feeds [Chapter 17](ch17-session-host-sizing-compute-selection.md) sizing and [Chapter 24](ch24-intune-and-avd-endpoint-management.md) endpoint management |
| **Estimated lab time** | None. Lab 4 begins in [Chapter 7](ch07-identity-architecture-foundations.md) |
| **Azure resources required** | None. Reading only |
| **Cost** | **$0.00** |

---

## What You Will Learn

- What multi-session actually is, and why it is a separate Windows edition rather than a setting
- Single-session versus multi-session as an architecture decision, not a preference
- When Windows Server is the right session host, and what it costs you in licensing
- How session density is really determined
- The activation rules that differ between Azure and Azure Local
- The three licensing questions, applied to real OS choices

---

## Why This Matters

The OS choice looks like a small decision on a deployment form. It is not. It determines your licensing model, your density economics, your management tooling, your application compatibility story, and whether half your Intune policies will silently report *Not applicable*.

It is also difficult to reverse. Changing session host OS means a new image, a new host pool in most cases, application retesting, and a migration for users. Get it right at design time.

---

## 1. Single-session and Multi-session

**Single-session** means one interactive user at a time on a VM. This is normal Windows behaviour - Windows 11 Enterprise on a desktop, or Windows 11 Enterprise on an Azure VM. In AVD this is used for personal host pools where each user has their own machine.

**Multi-session** means several users have their own interactive Windows session on the same VM at the same time.

Microsoft's own framing is the clearest: Windows 10 Enterprise multi-session and Windows 11 Enterprise multi-session allow multiple concurrent interactive sessions - previously only Windows Server could do this (Windows Enterprise multi-session FAQ). This gives users a familiar Windows experience for session hosts in a pooled host pool, and IT gets the cost advantages of multi-session while using existing per-user Windows licensing instead of RDS Client Access Licenses.

That sentence contains the entire business case. Before multi-session Windows client existed, high-density VDI (virtual desktop infrastructure) meant giving users a Windows Server desktop that looked and behaved differently from the Windows their organisation actually ran - and it meant buying RDS CALs.

### Multi-session is a distinct edition, not a feature

This is the single most important technical point in the chapter, and it explains a large share of the problems people hit later.

Windows 11 Enterprise multi-session is not standard Windows 11 with a checkbox enabled. It is a separate edition, licensed and deployed differently, and Windows treats it as such. The Intune documentation states that Windows Enterprise multi-session VMs are treated as a separate OS edition and some Windows Enterprise configurations won't be supported for this edition. The Windows Enterprise multi-session FAQ calls it a virtual edition of Windows Enterprise, and notes that it reports `ProductType` as 3, the same value as Windows Server, which keeps it compatible with RDSH tooling but can make some installers refuse to run.

The consequences show up everywhere:

- Intune policies that work on physical laptops may report **Not applicable**. Learn says only the Settings catalog, certificate templates and a device-tunnel VPN (virtual private network) template are supported, and unsupported templates show as Not applicable ([Chapter 24](ch24-intune-and-avd-endpoint-management.md) and the [Intune support matrix](../appendices/intune-avd-support-matrix.md))
- Windows Update ring policies are not supported. Quality updates are managed through settings available in the Settings catalog
- Some application installers check `ProductType` and refuse to install. Learn's advice is to ask the vendor for an updated version
- Windows Autopilot, the enrollment status page and some remote actions (such as wipe) are not supported
- Some vendor support statements may not cover it (check with each vendor; Learn does not make a general statement)

It is also constrained to one place. The FAQ says customers are not allowed to run Windows Enterprise multi-session in production outside the Azure Virtual Desktop service, that doing so is against the licensing agreement, and that it will not activate against on-premises KMS. You cannot upgrade an existing Pro or Enterprise VM to multi-session; you redeploy. In-place OS upgrades (for example Windows 10 to 11) are not supported for session hosts in a pooled host pool. `[VERIFY BEFORE IMPLEMENTATION]` - this review did not verify support boundaries for multi-session on Azure Local, Arc-enabled or hybrid deployment models beyond the activation wording in section 4. Confirm on Microsoft Learn before designing around them.

---

## 2. The OS Options

> **BOOK REFERENCE ARCHITECTURE** - original decision diagram.
> Microsoft's supported-OS guidance: https://learn.microsoft.com/en-us/azure/virtual-desktop/prerequisites

```mermaid
---
title: Session host OS decision
---
flowchart TB
    Q1{"Shared desktop?"}
    Q2{"Requires Windows Server?"}

    Q1 -->|"Yes"| MS["Windows 11 multi-session"]
    Q1 -->|"No"| SS["Windows 11 single-session"]
    Q1 -->|"App constrained"| Q2
    Q2 -->|"Yes"| WS["Windows Server"]
    Q2 -->|"No"| MS

    MS --> L1["Per-user Windows or M365 licence, no RDS CAL"]
    SS --> L1
    WS --> L2["RDS CAL with SA or RDS user subscription licence"]

    classDef ok fill:#dbe7f3,stroke:#2b6cb0,color:#12304f
    classDef warn fill:#f5e6d3,stroke:#b7791f,color:#5c3d0d
    class MS,SS,L1 ok
    class WS,L2 warn
```

> This is a decision flow diagram, so it uses the reduced explanation set defined in the [diagram standard](../DIAGRAM-STANDARD.md): what it shows, step by step, architect's interpretation, and the official reference. Failure points do not apply to a decision tree.

### What the diagram shows

Three viable paths, chosen by workload characteristics, not by preference. Each carries a different licensing consequence, and that consequence is the thing most people forget until deployment.

### Step-by-step reasoning

1. **Does the user need a machine to themselves?** Local admin rights, persistent installed software, unpredictable resource consumption, or a GPU workload that does not share well - that is single-session on a personal host pool.
2. **If not, can the workload share?** Task workers, knowledge workers, call centre staff. Multi-session on a pooled host pool, and this is where AVD's cost advantage lives.
3. **Is there a hard requirement for Windows Server?** An application that only supports Server, a vendor support statement that requires it, or an existing estate the organisation is not ready to move. Choose it deliberately, and put the RDS CAL cost in the business case on day one. A Remote Desktop Services license server must also be reachable from the Server session hosts.

### Architect's view

Default to **Windows 11 Enterprise multi-session** for shared desktops and justify anything else. It gives users the Windows they recognise, it avoids RDS CALs, and it is where Microsoft's investment in AVD is concentrated.

Choose **Windows Server** only for a stated requirement. "We've always used Server" is not a requirement. Server session hosts bring a different user experience, a different support matrix, and a licensing line item that is easy to forget when you are comparing costs against Windows 365 or a Citrix estate.

**Official reference:** https://learn.microsoft.com/en-us/azure/virtual-desktop/prerequisites

Learn also lists what is not supported for session hosts: 32-bit operating systems, N, KN, LTSC and other editions not in the supported table, Ultra disks for the OS disk, ephemeral OS disks (on this page), Virtual Machine Scale Sets and Arm64-based Azure VMs. Supported Windows Server versions in the table are 2016, 2019, 2022 and 2025. `CURRENCY FLAG - 16 October 2026. The ephemeral OS disk entry conflicts with the dedicated ephemeral OS disks page, which supports them for pooled host pools with session host configuration on Azure. Unresolved on Learn (U4). [VERIFY BEFORE IMPLEMENTATION]`

---

## 3. Density: What Actually Determines It

People want a number. Microsoft, correctly, will not give one: how many interactive sessions can be active at the same time relies on your system's hardware resources (vCPU, memory, disk, and vGPU), how your users use their apps while signed in, and how heavy your system's workload is.

That is not evasion - it is the truth. Density is a measured outcome, not a specification.

**What drives it:**

| Factor | Effect |
|---|---|
| vCPU count and generation | The primary constraint for most workloads |
| Memory | Often the real limit before CPU, especially with browser-heavy users |
| Disk IOPS | Logon storms are an IO problem before they are a CPU problem |
| Profile storage performance | A slow profile share caps density regardless of host size |
| Application mix | One badly behaved LOB (line-of-business) app can halve density |
| User behaviour | Number of browser tabs is a genuine engineering input, unfortunately |

**The honest method** (developed properly in [Project 07](../scenarios/project-07-call-centre-high-density.md)):

1. Start from a defensible assumption for the persona, and label it clearly as an assumption.
2. Deploy a small pilot with real users and real applications.
3. Measure CPU, memory, disk and logon duration under genuine peak load.
4. Adjust the max session limit from measurement, not from a blog post.
5. Re-measure after any significant application or image change.

**Interview framing.** If asked "how many users per host?", never answer with a bare number. Say: *"It depends on the persona and the application mix, so I'd start from an assumption, pilot it, and set the session limit from measured data. For a task worker on a D8s-class host I'd start around 8-10 as an assumption of mine, not a Microsoft figure, and expect to adjust. What I won't do is publish a number I haven't measured, because that's how you end up with a host pool that falls over at 9am."* That answer scores far better than a confident guess.

---

## 4. Activation

Activation differs by where the session host runs, and it is a common source of confusion in hybrid designs.

**Session hosts on Azure.** Marketplace images activate against Azure's KMS infrastructure. This is why `azkms.core.windows.net` on TCP (Transmission Control Protocol) 1688 appears in the required outbound list ([Chapter 4](ch04-connection-flow-end-to-end.md#3-what-session-hosts-actually-need-outbound)). Learn's activation troubleshooting page lists region-specific KMS endpoints: `azkms.core.windows.net:1688` for Azure public cloud and `kms.core.usgovcloudapi.net:1688` for Azure US Government. Block the endpoint and activation fails (typically error 0xC004F074, "No Key Management Service (KMS) could be contacted").

**Azure license benefit.** Separately from activation, the Windows license entitlement is applied to the VM. Creating session hosts in the Azure portal or the ARM (Azure Resource Manager) template applies it automatically. To apply or check it manually, Learn shows `LicenseType = "Windows_Client"` on the VM for client OS (`Get-AzVM` shows `LicenseType`). Learn also records a known limitation: a Windows Server session host created by the host pool process can be assigned an incorrect license type and may need to be converted with the Azure Hybrid Benefit procedure.

**Session hosts on Azure Local.** The rules are explicit: for session hosts on Azure Local you must license and activate the VMs before using them with AVD. For activating Windows 10 and Windows 11 Enterprise multi-session, and Windows Server 2022 Datacenter: Azure Edition, use Azure verification for VMs. For all other OS images - such as Windows 10 and Windows 11 Enterprise, and other editions of Windows Server - continue to use existing activation methods. Verified against [Azure verification for VMs](https://learn.microsoft.com/azure/azure-local/manage/azure-verification) (retrieved 16 October 2026, U6): Windows 11 multi-session activates automatically with the 9 April 2024 (4B) update or later, Windows 10 multi-session needs legacy OS support, and only Windows Server 2022 Datacenter: Azure Edition is listed, so Server 2025 Azure Edition is Unverified. Azure verification cannot be used outside Azure Local. Azure Local itself requires version 23H2 or later, and the Azure Connected Machine agent. It is not an Arc-enabled service and is not supported on other Arc-enabled servers or multicloud. A host pool cannot mix Azure and Azure Local hosts. Learn's two pages list slightly different OS sets (the Architecture Center page omits Server 2025), so confirm against the Azure Local overview (U7).

**Architect's note.** Two activation paths in one estate is a real operational burden. If a customer runs both Azure and Azure Local session hosts, document which hosts use which method and who owns it, or it will be discovered during an audit rather than during design.

---

## 5. Entra Joined Session Hosts Change the Prerequisites

Worth flagging here because the OS choice and the join model interact.

Learn's prerequisites page itself only says Entra-joined session hosts need Entra tenant membership and that account permissions to join devices are required; the additional sign-in steps (single sign-on or earlier authentication protocols, an RBAC (role-based access control) role for users, and a review of MFA (multifactor authentication) policies) are documented in the Entra-joined session hosts articles, which Chapters 7 and 8 verify. Chapter 7's review adds that Learn requires the Virtual Machine User Login role only for Entra joined pools without a session host configuration, and says the additional role assignment is not required when a session host configuration is used.

That RBAC requirement catches people out. On a domain-joined host, being assigned to the application group is enough. On an Entra-joined host, the user also needs an Azure RBAC role - Virtual Machine User Login or Virtual Machine Administrator Login - on the session hosts. Miss it and the user connects and is then rejected at Windows logon, which looks like an authentication fault rather than a missing role assignment.

Full treatment in [Chapter 7](ch07-identity-architecture-foundations.md) and [Chapter 8](ch08-authentication-flows-in-detail.md).

---

## 6. Licensing, Applied to the OS Choice

[Chapter 1](ch01-what-avd-actually-is.md#5-licensing-explained-simply) established the three questions. Here is how the OS answers the second one.

| Session host OS | Eligible licence for internal commercial use (Learn) | RDS CAL | Notes |
|---|---|---|---|
| Windows 11 Enterprise multi-session | Microsoft 365 E3, E5, A3, A5, F3, Business Premium or Student Use Benefit; Windows Enterprise E3, E5; Windows Education A3, A5; Windows VDA per user | Not required | The default choice for pooled |
| Windows 11 Enterprise single-session | Same as above | Not required | Personal host pools |
| Windows 10 Enterprise multi-session | Same as above | Not required | Support lifecycle - see below |
| Windows Server 2016, 2019, 2022, 2025 | RDS CAL with Software Assurance (per user or per device), or RDS User Subscription Licenses | **Required** | The M365/Windows per-user licences in the rows above are not the eligible licence for Server. A Remote Desktop Services license server must be reachable |

External commercial use is different: Windows client session hosts use per-user access pricing (enrolled Azure subscription), and Learn says per-user access pricing is not available for Windows Server. Per-user access pricing is not a way to license internal users or contractors.

`CURRENCY FLAG - reviewed 16 October 2026. Windows 10 reached end of support on 14 October 2025. Learn's [Understanding Extended Security Updates for Windows 10 on AVD](https://learn.microsoft.com/azure/virtual-desktop/understanding-extended-security-updates) says AVD Windows 10 22H2 session hosts are automatically entitled to ESU at no additional cost, with no key or purchase. The Windows 10 22H2 multi-session image with Microsoft 365 Apps was retired from Azure Marketplace on 14 April 2026. The image without Microsoft 365 Apps remains until 2028 and needs the ESU updates installed manually. ESU requires KB5066791 and KB5072653 on the device. **Resolved (U5):** the generic explicit-policy section (the `EnableESUSubscriptionCheck` flag) applies to local Windows 10 devices that access Windows 365 Cloud PCs, not to AVD session hosts. Non-persistent VDI steps use `slmgr /upk` with the Activation IDs. Learn's own best practice is to prioritise Windows 11. For greenfield work, deploy Windows 11. [VERIFY BEFORE IMPLEMENTATION] confirm KB numbers and image availability at build time.`

**The mistake to avoid.** Comparing an AVD design against Windows 365 or Citrix on compute cost alone, having quietly chosen Windows Server session hosts and left the RDS CALs out of the model. Someone will find it, usually in front of a finance stakeholder.

---

## 7. Northwind Applied

Applying this to the [capstone customer](ch01-what-avd-actually-is.md#4-meet-the-capstone-customer-northwind-global-manufacturing):

| Persona | Users | OS choice | Reason |
|---|---|---|---|
| Task workers | 1,400 | Windows 11 Enterprise multi-session | Density is the whole business case |
| Knowledge workers | 1,100 | Windows 11 Enterprise multi-session | Same, with a larger host size |
| Finance / regulated | 250 | Windows 11 Enterprise multi-session | Separate host pool for isolation, same OS |
| Engineers (CAD) | 180 | Windows 11 Enterprise single-session | GPU, large working sets, personal pool |
| Developers | 170 | Windows 11 Enterprise single-session | Local admin, unpredictable resource use |
| Executives | 100 | Windows 11 Enterprise multi-session | Joins the knowledge worker pool |

**Result: no RDS CALs anywhere in the design.** That is a real number in the business case, and it is worth stating explicitly in the architecture document rather than leaving it implicit.

**The decision to document.** If Northwind's SAP or CAD vendor later requires Windows Server for a specific component, that becomes a scoped exception - one small Server-based RemoteApp host pool with its own CAL line - not a reason to move the whole estate to Server.

---

## 8. Common Mistakes

- **Treating multi-session as a setting.** It is a distinct edition with distinct behaviour and distinct support boundaries.
- **Choosing Windows Server out of habit.** It carries an RDS CAL cost and a different user experience. Choose it for a stated requirement.
- **Publishing a density number before measuring.** Density is measured, then adjusted.
- **Forgetting KMS egress.** Blocking TCP 1688 produces activation failures that appear long after deployment.
- **Assuming physical-desktop policies transfer to multi-session.** They partly do. The gap is where your incidents come from.
- **Deploying Windows 10 for new work in 2026.** Check the lifecycle position first, and default to Windows 11.
- **Forgetting the RBAC role on Entra-joined hosts.** It looks like an authentication failure and it is a missing role assignment.

---

## 9. Interview Preparation

### Q11. What is Windows Enterprise multi-session and why does it matter?

**Simple answer**
It is a Windows client edition that allows multiple users to have their own interactive session on one VM at the same time. Before it existed, only Windows Server could do that. It means users get a familiar Windows desktop, and you use existing per-user licensing instead of RDS CALs.

**Strong senior architect answer**
"It's what makes pooled AVD economically viable. Multiple concurrent interactive sessions on one host, with a client OS experience, covered by the per-user Microsoft 365 or Windows Enterprise licence rather than RDS CALs. The important architectural point is that it's a *separate OS edition*, not a feature of Windows 11 - so Windows treats it differently. That's why some Intune policies report Not applicable, why update rings aren't supported on it, and why you have to check vendor support statements rather than assume. It also may only run in production as part of the AVD service, so it isn't a general-purpose Windows edition."

**Follow-up you should expect**
"So when would you use Windows Server instead?" - a stated requirement only: an application that requires Server, or a vendor support statement. And you immediately raise the RDS CAL cost, because that is the thing that gets missed in comparisons.

---

### Q12. How many users can you put on a session host?

**30-second answer**
"It depends on the persona and the application mix, so I won't give you a number I haven't measured. I'd start from an assumption for the persona, pilot with real users and real apps, and set the max session limit from measured CPU, memory, disk and logon time. For a task worker on a D8s-class host I'd start around 8-10 and expect to adjust."

**Why this scores well**
The question is a trap for people who memorise sizing tables. Microsoft's own guidance is that density depends on hardware, application behaviour and workload. Refusing to give a number *and then explaining exactly how you'd get one* demonstrates method rather than recall.

**Deep-dive answer**
Explain the constraint order: memory usually binds before CPU for browser-heavy users, disk IO binds during logon storms, and profile storage performance can cap density no matter how large the host is - so sizing the host without sizing the storage is meaningless. Mention that density interacts with the load balancing algorithm: breadth-first spreads users and improves experience, depth-first packs them and improves cost, and the right choice depends on whether the customer is optimising for experience or spend. Finish by noting that density is not a one-time exercise - it has to be re-measured after image and application changes.

---

### Q13. A customer wants Windows Server session hosts. How do you respond?

**Strong answer**
"First I'd ask why, because the answer changes the design. If it's an application that genuinely requires Server, or a vendor support statement, that's a legitimate requirement and I'd scope it - often as a small Server-based RemoteApp host pool rather than moving the whole estate. If the answer is that they've always used Server, I'd walk through the trade-offs: Server means RDS CALs, which is a real cost line that's easy to leave out of a comparison, and it gives users a desktop that doesn't look like the Windows they use elsewhere, which generates support calls. Windows 11 multi-session gives the same density with a familiar experience and no CALs. But I'd present it as a decision with a cost attached rather than telling them they're wrong."

**Why this works**
It shows you can push back without being combative, you quantify the trade-off, and you offer a scoped compromise instead of an all-or-nothing answer. That is what senior means in practice.

---

## 10. Key Takeaways

- Multi-session allows several concurrent interactive sessions on one host, and is covered by per-user licensing rather than RDS CALs.
- It is a **separate OS edition**, which is why some policies, tools and applications behave differently on it.
- Windows Server session hosts require RDS CALs. Choose Server for a stated requirement, and put the CAL cost in the business case immediately.
- Density depends on hardware, application mix and user behaviour. Measure it; do not quote it.
- Activation differs between Azure and Azure Local. Azure hosts need TCP 1688 outbound to KMS.
- Entra-joined session hosts need an Azure RBAC role for users in addition to application group assignment.
- For greenfield work in 2026, deploy Windows 11 and verify the Windows 10 lifecycle position before considering it.

---

## 11. Official References

- Prerequisites for Azure Virtual Desktop - https://learn.microsoft.com/en-us/azure/virtual-desktop/prerequisites
- Windows Enterprise multi-session FAQ - https://learn.microsoft.com/en-us/azure/virtual-desktop/windows-multisession-faq
- Add session hosts to a host pool - https://learn.microsoft.com/en-us/azure/virtual-desktop/add-session-hosts-host-pool
- Manage the operating system of session hosts - https://learn.microsoft.com/en-us/azure/virtual-desktop/management
- Licensing Azure Virtual Desktop - https://learn.microsoft.com/en-us/azure/virtual-desktop/licensing
- Apply Windows license to session host virtual machines - https://learn.microsoft.com/en-us/azure/virtual-desktop/apply-windows-license
- Understanding Extended Security Updates for Windows 10 on AVD - https://learn.microsoft.com/en-us/azure/virtual-desktop/understanding-extended-security-updates
- Windows Enterprise multi-session remote desktops (Intune) - https://learn.microsoft.com/en-us/mem/intune/fundamentals/azure-virtual-desktop-multi-session
- Troubleshoot Azure Windows VM activation problems - https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/windows/troubleshoot-activation-problems

---

## 12. Production Scenarios

> The scenarios below are illustrative composites written for this knowledgebase, not documented customer engagements. User counts, costs and timings are assumptions chosen to make the reasoning concrete.

### Scenario 1: Intune policies report Not applicable on multi-session

**Problem.** A security team applies its standard Windows hardening policies to a new multi-session host pool. Around a third report Not applicable and the compliance dashboard shows the hosts as unmanaged.

**Symptoms.** Policies apply cleanly to physical laptops. Same policies, same tenant, different result on session hosts. No error, just Not applicable.

**Business impact.** No user impact. The security team cannot evidence compliance for the session host estate, which blocks sign off.

**Initial hypothesis.** Multi-session is a separate OS edition and some Windows Enterprise configurations are not supported on it. This is documented behaviour rather than a fault.

**Investigation.** Portal path (as written in Learn's Intune multi-session article): *Microsoft Intune admin center > Devices > By platform > Windows > Manage devices > Configuration*, then open the policy and its assignment status, and compare a session host against a laptop. Also check that the session hosts were enrolled with device credentials, that the profile is a Settings catalog or supported template, and that device-scoped policies are assigned to device groups (Learn: assigning device configuration to users, or user configuration to devices, is reported as Error or Not applicable). Then filter the Settings catalog by **Enterprise multi-session** to see which settings are actually available for the edition. Cross check against the [Intune and AVD support matrix](../appendices/intune-avd-support-matrix.md).

**Evidence.** The unsupported settings do not appear when the catalog is filtered for multi-session.

**Root cause.** The policies were built for a different OS edition, or used unsupported templates, or were assigned with the wrong scope (device versus user).

**Fix.** Rebuild the baseline using settings available for Enterprise multi-session, and accept that a small number of controls have to be met another way, through the image or through host pool settings.

**Validation.** Policy status shows Succeeded for the intended settings on a test host, and the compliance policy targeting the multi-session device group evaluates correctly.

**Prevention.** Maintain two baselines, one for physical endpoints and one for multi-session, and state clearly which controls are delivered by the image instead. Pilot every policy on one host before broad assignment.

**Architect's lesson.** Multi-session being a separate edition is not trivia. It changes management tooling, and the gap is where the incidents come from.

**Interview lesson.** Explaining Not applicable as documented behaviour rather than a bug shows real Intune experience.

### Scenario 2: The RDS CAL nobody budgeted for

**Problem.** Two weeks before go live, licensing review flags that the RemoteApp host pool uses Windows Server session hosts. No RDS CALs were purchased.

**Symptoms.** Nothing technical. A procurement and compliance problem discovered late.

**Business impact.** Unbudgeted licence cost two weeks before go live, and a compliance exposure until it is resolved.

**Initial hypothesis.** The OS choice was made by the application team for compatibility, and the licensing consequence never reached the business case.

**Investigation.** Confirm the session host OS for every host pool, then check whether each pool genuinely requires Server or was chosen by default.

**Evidence.** One pool of eight hosts serving a single legacy application requires Server. The other four pools do not.

**Root cause.** A technical decision with a licensing consequence, made without the licensing conversation.

**Fix.** Purchase RDS CALs for the affected user group only, and scope the Server pool as narrowly as possible. Move every other workload to Windows 11 multi-session.

**Validation.** Licensing position documented and accepted, with the CAL count matched to the assigned user group rather than the whole estate.

**Prevention.** Add "does any host pool use Windows Server" to the design review checklist, and require the licensing line in the business case before OS selection is signed off.

**Interview lesson.** Raising RDS CALs unprompted in an OS discussion signals commercial awareness, which senior roles look for.

**Architect's lesson.** OS selection is a licensing decision as much as a technical one. Raise it at design time, when it is a cost line, rather than at go live, when it is a problem.

### Scenario 3: Activation failures three weeks after deployment

**Problem.** Users start seeing Windows activation warnings on session hosts that were working fine.

**Symptoms.** Delayed onset. Only affects newly built hosts and hosts that were rebuilt. Original hosts are unaffected.

**Business impact.** Activation warnings visible to users on newly built hosts, which erodes confidence even though nothing has actually stopped working.

**Initial hypothesis.** Outbound access to Azure KMS on TCP 1688 is blocked. Existing hosts and newly built hosts behave differently because activation is attempted at build and on renewal. The exact grace and renewal timings were not verified in this review.

**Investigation.** Check outbound rules for TCP 1688 from the session host subnet. Then from a host:

```bash
az vm run-command invoke -g rg-avd-hosts-lab-eus2-01 -n <vm> \
  --command-id RunPowerShellScript \
  --scripts "Test-NetConnection -ComputerName azkms.core.windows.net -Port 1688; cscript //nologo C:\Windows\System32\slmgr.vbs /dlv"
```

`cscript //nologo` is used so `slmgr.vbs` writes to standard output instead of opening a dialog, which would not return through Run Command. `slmgr.vbs /ato` (from Learn's troubleshooting page) retries activation. These commands were not executed in this review. `[VERIFY BEFORE IMPLEMENTATION]`

**Evidence.** The port test fails and the licensing status shows the host is not activated, typically with error 0xC004F074.

**Root cause.** An egress rule change removed TCP 1688. Existing hosts stayed activated, so nothing broke immediately.

**Fix.** Restore outbound TCP 1688 to KMS. See the rule in [Lab 3](../labs/lab-03-vnet-subnets-nsg-dns.md).

**Validation.** Activation succeeds on a rebuilt host, and the licensing status is confirmed rather than assumed.

**Prevention.** Include activation in the post build validation for every session host, so a failure is caught at build rather than weeks later.

**Interview lesson.** Explaining why existing hosts can stay unaffected while new builds fail shows you reason about timelines, not just causes.

**Architect's lesson.** Delayed symptoms make correlation hard. Validate at build time, so the gap between a change and its effect stays small.

---

## 13. The Architect's Four Questions

**What do I check first?** Which OS edition the host pool is running, and whether that matches what the tooling and licensing assume.

**What can I safely change now?** Max session limit on a pool. Adding a host. Reading licensing status.

**What must not be changed blindly?** Session host OS, which means a new image, retesting and often a new host pool. Host pool type, which cannot be changed at all. Max session limit in production during working hours, because it affects where users land.

**When do I escalate to Microsoft?** For activation failures where outbound 1688 is proven open, or where a documented multi-session capability does not behave as documented. Collect the output of `slmgr.vbs /dlv`, the connectivity test, the image publisher, offer, SKU (stock keeping unit) and version, and the region.

---

## Architect's Reality Check

> Engineering judgement, not measured data or documented customer cases. Statements about what is common or likely are reasoning, not survey results.

**What engineers commonly get wrong.** They treat multi-session as a Windows 11 feature. It is a separate edition, and that is why policies, tools and some applications behave differently on it.

**What I would check first in production.** Which OS edition the host pool runs, and whether the management tooling assumes something else. A third of Intune policies reporting Not applicable is not a fault, it is an edition mismatch.

**What I would ask the customer.** Whether any application requires Windows Server. If yes, that is a licensing conversation on day one rather than two weeks before go live.

**What I would decide as the architect.** Windows 11 multi-session for shared desktops unless there is a stated requirement otherwise, and any Windows Server pool scoped as narrowly as possible with the CAL cost written into the business case.

**What I would say in an interview.** Refuse to quote a density number. Explain the method instead, and name the constraint order: memory usually binds before CPU, and disk binds during logon storms.

---

## How This Changes With Scale

**Around 100 users.** One image, one OS choice. Density hardly matters because you are running few hosts either way.

**Around 1,000 users.** Density is now money. A difference of two users per host changes host count by twenty percent, which is why the pilot measurement earns its time.

**Around 5,000 users and beyond.** Multiple images for multiple personas, each with its own lifecycle. Licensing exceptions need tracking rather than remembering, and an unnoticed Windows Server pool becomes a compliance finding rather than a cost surprise.

---

## Chapter Close

**What was completed**
You can choose a session host OS from workload requirements, explain the licensing consequence of that choice, describe why multi-session behaves as a separate edition, and answer a density question without guessing.

**What you should test**
No lab. Instead: take your current employer's user population, split it into personas, and assign an OS to each with a one-line justification. Then check whether any of them would need RDS CALs.

**What comes next**
Chapter 6 covers clients and the endpoint story - Windows App, the web client, the MSRDC retirement, and what actually differs between platforms. That closes Part I. **Lab 4 (identity integration) begins in Chapter 7 and is the first lab with running compute cost.**

**Interview preparation carried forward**
Q12 is the one to practise. Most candidates answer it with a number and lose the point. Practise the version that refuses the number and supplies the method instead.
