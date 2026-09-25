# Interview Question Index

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation

193 study questions are indexed from the chapters, labs, and fictional architecture case studies: 74 from the 25 published chapters, 75 from all 15 published projects (5 each), and 44 from Labs 5-20 (13 from Labs 5-10, 31 from Labs 11-20). Each entry links to its source file, where the full answer appears. Search the source file for the question number, for example `Q59`.

This index reuses existing content. It does not generate new questions to inflate a count, and it does not duplicate full answers that already exist elsewhere in the book.

**How to use this for interview preparation.** Read a question here, try to answer it out loud from memory, then open the linked source and search for its number. The gap between your answer and the linked one is what to study.

---

## Chapter questions, by topic

### AVD Fundamentals

| # | Question | Source |
|---|---|---|
| Q1 | What is Azure Virtual Desktop? | [ch01-what-avd-actually-is.md](../chapters/ch01-what-avd-actually-is.md) |
| Q2 | When would you *not* recommend AVD? | [ch01-what-avd-actually-is.md](../chapters/ch01-what-avd-actually-is.md) |
| Q3 | Does AVD need extra licences if the customer already has Microsoft 365 E3? | [ch01-what-avd-actually-is.md](../chapters/ch01-what-avd-actually-is.md) |
| Q4 | Walk me through what Microsoft manages in AVD. | [ch02-control-plane-management-plane-data-plane.md](../chapters/ch02-control-plane-management-plane-data-plane.md) |
| Q5 | Users say AVD is down. How do you triage it? | [ch02-control-plane-management-plane-data-plane.md](../chapters/ch02-control-plane-management-plane-data-plane.md) |
| Q6 | Explain the relationship between host pools, application groups and workspaces. | [ch03-avd-object-model.md](../chapters/ch03-avd-object-model.md) |
| Q7 | A user subscribes to the workspace and sees nothing. Walk me through it. | [ch03-avd-object-model.md](../chapters/ch03-avd-object-model.md) |
| Q11 | What is Windows Enterprise multi-session and why does it matter? | [ch05-operating-systems-multisession-licensing.md](../chapters/ch05-operating-systems-multisession-licensing.md) |
| Q12 | How many users can you put on a session host? | [ch05-operating-systems-multisession-licensing.md](../chapters/ch05-operating-systems-multisession-licensing.md) |
| Q13 | A customer wants Windows Server session hosts. How do you respond? | [ch05-operating-systems-multisession-licensing.md](../chapters/ch05-operating-systems-multisession-licensing.md) |
| Q14 | What is the current AVD client situation? | [ch06-clients-and-the-endpoint-story.md](../chapters/ch06-clients-and-the-endpoint-story.md) |
| Q15 | Contractors on their own laptops need AVD access. What do you do? | [ch06-clients-and-the-endpoint-story.md](../chapters/ch06-clients-and-the-endpoint-story.md) |
| Q16 | Users say AVD stopped working after a client update. How do you handle it? | [ch06-clients-and-the-endpoint-story.md](../chapters/ch06-clients-and-the-endpoint-story.md) |

### Application Delivery

| # | Question | Source |
|---|---|---|
| Q72 | How do you decide how to deliver an application in AVD? | [ch25-application-delivery-remoteapp-design.md](../chapters/ch25-application-delivery-remoteapp-design.md) |
| Q73 | RemoteApp or full desktop? | [ch25-application-delivery-remoteapp-design.md](../chapters/ch25-application-delivery-remoteapp-design.md) |
| Q74 | What would you ask for before designing application delivery? | [ch25-application-delivery-remoteapp-design.md](../chapters/ch25-application-delivery-remoteapp-design.md) |

### Authentication and Conditional Access

| # | Question | Source |
|---|---|---|
| Q20 | Walk me through authentication in an AVD connection. | [ch08-authentication-flows-in-detail.md](../chapters/ch08-authentication-flows-in-detail.md) |
| Q21 | Users are getting an extra password prompt. How do you find out why? | [ch08-authentication-flows-in-detail.md](../chapters/ch08-authentication-flows-in-detail.md) |
| Q22 | How would you prevent this class of problem? | [ch08-authentication-flows-in-detail.md](../chapters/ch08-authentication-flows-in-detail.md) |
| Q23 | How do you enforce MFA for AVD? | [ch09-conditional-access-mfa-zero-trust.md](../chapters/ch09-conditional-access-mfa-zero-trust.md) |
| Q24 | Explain sign-in frequency for AVD. | [ch09-conditional-access-mfa-zero-trust.md](../chapters/ch09-conditional-access-mfa-zero-trust.md) |
| Q25 | How would you design Conditional Access for AVD in a regulated environment? | [ch09-conditional-access-mfa-zero-trust.md](../chapters/ch09-conditional-access-mfa-zero-trust.md) |

### Control Plane and Connection Flow

| # | Question | Source |
|---|---|---|
| Q8 | Walk me through what happens when a user connects to AVD. | [ch04-connection-flow-end-to-end.md](../chapters/ch04-connection-flow-end-to-end.md) |
| Q9 | Do you need to open any inbound ports for AVD? | [ch04-connection-flow-end-to-end.md](../chapters/ch04-connection-flow-end-to-end.md) |
| Q10 | Users say the session feels laggy but nothing is broken. Where do you look? | [ch04-connection-flow-end-to-end.md](../chapters/ch04-connection-flow-end-to-end.md) |

### FSLogix

| # | Question | Source |
|---|---|---|
| Q53 | Why does AVD need FSLogix? | [ch19-why-profiles-cause-avd-failure.md](../chapters/ch19-why-profiles-cause-avd-failure.md) |
| Q54 | Users report slow sign-in. Walk me through it. | [ch19-why-profiles-cause-avd-failure.md](../chapters/ch19-why-profiles-cause-avd-failure.md) |
| Q55 | What would you check first when a user has an empty desktop? | [ch19-why-profiles-cause-avd-failure.md](../chapters/ch19-why-profiles-cause-avd-failure.md) |
| Q60 | What are the FSLogix settings you would always configure? | [ch21-fslogix-production-implementation.md](../chapters/ch21-fslogix-production-implementation.md) |
| Q61 | Why do antivirus exclusions matter so much for FSLogix? | [ch21-fslogix-production-implementation.md](../chapters/ch21-fslogix-production-implementation.md) |
| Q62 | How would you stop profiles growing out of control? | [ch21-fslogix-production-implementation.md](../chapters/ch21-fslogix-production-implementation.md) |
| Q63 | What does Cloud Cache do, and when would you use it? | [ch22-profile-operations-failure-recovery.md](../chapters/ch22-profile-operations-failure-recovery.md) |
| Q64 | A container is corrupt. What are your options? | [ch22-profile-operations-failure-recovery.md](../chapters/ch22-profile-operations-failure-recovery.md) |
| Q65 | How do you keep profile storage from growing forever? | [ch22-profile-operations-failure-recovery.md](../chapters/ch22-profile-operations-failure-recovery.md) |

### Golden Images

| # | Question | Source |
|---|---|---|
| Q66 | How would you manage session host images? | [ch23-golden-image-engineering.md](../chapters/ch23-golden-image-engineering.md) |
| Q67 | What is the risk of a custom image? | [ch23-golden-image-engineering.md](../chapters/ch23-golden-image-engineering.md) |
| Q68 | Where do you draw the line between image and policy? | [ch23-golden-image-engineering.md](../chapters/ch23-golden-image-engineering.md) |

### Host Pools

| # | Question | Source |
|---|---|---|
| Q41 | Pooled or personal, and how do you decide? | [ch15-host-pool-design-decisions.md](../chapters/ch15-host-pool-design-decisions.md) |
| Q42 | Breadth-first or depth-first? | [ch15-host-pool-design-decisions.md](../chapters/ch15-host-pool-design-decisions.md) |
| Q43 | A pool is unevenly loaded. What do you check? | [ch15-host-pool-design-decisions.md](../chapters/ch15-host-pool-design-decisions.md) |
| Q44 | What is session host configuration and when would you use it? | [ch16-automated-host-pools-session-host-configuration.md](../chapters/ch16-automated-host-pools-session-host-configuration.md) |
| Q45 | How does a rolling update work, and what would you check before running one? | [ch16-automated-host-pools-session-host-configuration.md](../chapters/ch16-automated-host-pools-session-host-configuration.md) |
| Q46 | Your customer has a mature Terraform pipeline. Do you move them to session host configuration? | [ch16-automated-host-pools-session-host-configuration.md](../chapters/ch16-automated-host-pools-session-host-configuration.md) |

### Identity

| # | Question | Source |
|---|---|---|
| Q17 | What are the join options for AVD session hosts and how do you choose? | [ch07-identity-architecture-foundations.md](../chapters/ch07-identity-architecture-foundations.md) |
| Q18 | Explain Entra Kerberos and why it matters. | [ch07-identity-architecture-foundations.md](../chapters/ch07-identity-architecture-foundations.md) |
| Q19 | A customer wants to move from domain joined to Entra joined session hosts. How do you approach it? | [ch07-identity-architecture-foundations.md](../chapters/ch07-identity-architecture-foundations.md) |

### Intune

| # | Question | Source |
|---|---|---|
| Q69 | How do you manage AVD session hosts with Intune? | [ch24-intune-and-avd-endpoint-management.md](../chapters/ch24-intune-and-avd-endpoint-management.md) |
| Q70 | Why do some Intune policies show Not applicable on session hosts? | [ch24-intune-and-avd-endpoint-management.md](../chapters/ch24-intune-and-avd-endpoint-management.md) |
| Q71 | How do you split settings between Group Policy, Configuration Manager and Intune? | [ch24-intune-and-avd-endpoint-management.md](../chapters/ch24-intune-and-avd-endpoint-management.md) |

### Networking

| # | Question | Source |
|---|---|---|
| Q29 | What outbound access do AVD session hosts need? | [ch11-network-fundamentals-required-connectivity.md](../chapters/ch11-network-fundamentals-required-connectivity.md) |
| Q30 | Would you use Private Link for AVD? | [ch11-network-fundamentals-required-connectivity.md](../chapters/ch11-network-fundamentals-required-connectivity.md) |
| Q31 | A session host will not register. Walk me through it. | [ch11-network-fundamentals-required-connectivity.md](../chapters/ch11-network-fundamentals-required-connectivity.md) |
| Q32 | Hub and spoke or Virtual WAN for AVD? | [ch12-enterprise-topologies-ip-planning.md](../chapters/ch12-enterprise-topologies-ip-planning.md) |
| Q33 | How do you size a session host subnet? | [ch12-enterprise-topologies-ip-planning.md](../chapters/ch12-enterprise-topologies-ip-planning.md) |
| Q34 | Where does AVD sit in a landing zone? | [ch12-enterprise-topologies-ip-planning.md](../chapters/ch12-enterprise-topologies-ip-planning.md) |
| Q35 | How do you control outbound traffic for AVD? | [ch13-hybrid-connectivity-egress-control.md](../chapters/ch13-hybrid-connectivity-egress-control.md) |
| Q36 | Session hosts are unhealthy but the firewall shows no denies. What now? | [ch13-hybrid-connectivity-egress-control.md](../chapters/ch13-hybrid-connectivity-egress-control.md) |
| Q37 | ExpressRoute or VPN for an AVD deployment? | [ch13-hybrid-connectivity-egress-control.md](../chapters/ch13-hybrid-connectivity-egress-control.md) |
| Q38 | Users say AVD is slow. How do you approach it? | [ch14-protocol-optimisation-network-performance.md](../chapters/ch14-protocol-optimisation-network-performance.md) |
| Q39 | Explain Teams media optimisation and why it matters. | [ch14-protocol-optimisation-network-performance.md](../chapters/ch14-protocol-optimisation-network-performance.md) |
| Q40 | How much bandwidth does an AVD user need? | [ch14-protocol-optimisation-network-performance.md](../chapters/ch14-protocol-optimisation-network-performance.md) |

### RBAC and Assignment

| # | Question | Source |
|---|---|---|
| Q26 | What does Desktop Virtualization Contributor allow? | [ch10-rbac-delegation-administrative-model.md](../chapters/ch10-rbac-delegation-administrative-model.md) |
| Q27 | Design a delegation model for a 3,000 user AVD estate. | [ch10-rbac-delegation-administrative-model.md](../chapters/ch10-rbac-delegation-administrative-model.md) |
| Q28 | A user connects to an Entra joined host and is rejected at sign in. What is it? | [ch10-rbac-delegation-administrative-model.md](../chapters/ch10-rbac-delegation-administrative-model.md) |

### Session Hosts

| # | Question | Source |
|---|---|---|
| Q47 | How do you size session hosts? | [ch17-session-host-sizing-compute-selection.md](../chapters/ch17-session-host-sizing-compute-selection.md) |
| Q48 | Would you use ephemeral OS disks? | [ch17-session-host-sizing-compute-selection.md](../chapters/ch17-session-host-sizing-compute-selection.md) |
| Q49 | How do you make a host pool resilient inside a region? | [ch17-session-host-sizing-compute-selection.md](../chapters/ch17-session-host-sizing-compute-selection.md) |
| Q50 | A session host is not registering. Walk me through it. | [ch18-session-host-lifecycle-hybrid.md](../chapters/ch18-session-host-lifecycle-hybrid.md) |
| Q51 | How do you patch AVD session hosts? | [ch18-session-host-lifecycle-hybrid.md](../chapters/ch18-session-host-lifecycle-hybrid.md) |
| Q52 | When would you use Arc-enabled session hosts? | [ch18-session-host-lifecycle-hybrid.md](../chapters/ch18-session-host-lifecycle-hybrid.md) |

### Storage

| # | Question | Source |
|---|---|---|
| Q56 | Azure Files or Azure NetApp Files for FSLogix? | [ch20-profile-storage-architecture.md](../chapters/ch20-profile-storage-architecture.md) |
| Q57 | Explain the permission model for FSLogix on Azure Files. | [ch20-profile-storage-architecture.md](../chapters/ch20-profile-storage-architecture.md) |
| Q58 | What redundancy would you use for FSLogix profile storage? | [ch20-profile-storage-architecture.md](../chapters/ch20-profile-storage-architecture.md) |
| Q59 | Users say sign-in is slow only at shift start. What is happening? | [ch20-profile-storage-architecture.md](../chapters/ch20-profile-storage-architecture.md) |

---

## Architecture scenario questions, by project

Each of the 15 fictional architecture case studies ends with five questions about its requirements, decisions, trade-offs, and risks. Use these questions to practise senior architecture discussions.

**[Project 01 - Harbourview Legal: Cost-Sensitive SMB Deployment](../scenarios/project-01-smb-cost-sensitive.md)**

- Walk me through how you sized this environment.
- You had a hard budget ceiling. What did you sacrifice?
- Why AVD rather than Windows 365 at this size?
- How do you know the design met the requirement that data stays off endpoints?
- What would you do differently?

**[Project 02 - Calderbank Group: 850 User Enterprise, First Real Operating Model](../scenarios/project-02-enterprise-850-users.md)**

- You inherit an AVD platform with unhappy users and no monitoring. What do you do first?
- How would you know whether an AVD estate is healthy?
- Users complain about slow sign-in. Where do you start?
- How would you measure and explain a reduction in platform cost?
- How do you stop it degrading again?

**[Project 03 - Meridian Global Industries: 3,200-User Multi-Region Governance](../scenarios/project-03-global-enterprise-governance.md)**

- Why one subscription per business unit instead of one shared subscription with resource groups?
- Why keep standing access for Session Host Operator and Service Desk but require PIM for everything else?
- Four business units each want their own naming convention. How do you get agreement on one standard?
- How do you decide what stays centrally owned versus what stays with each business unit?
- The CFO wants a single cost number today. What do you actually tell them in week one, before any of this is built?

**[Project 04 - Halbrook Retail Group: Hybrid AD, 18 Years of Group Policy, and an AVD Estate in the Middle](../scenarios/project-04-hybrid-active-directory.md)**

- In a hybrid estate, which wins, Group Policy or Intune?
- Session hosts have inconsistent logon times with no pattern. Where do you look?
- How would you place domain controllers for an AVD estate?
- How do you migrate a setting from GPO to Intune safely?
- What would you do differently?

**[Project 05 - Auralis Media Group: Moving AVD to Entra-Only, and What It Actually Costs](../scenarios/project-05-entra-only-cloud-native.md)**

- What does it actually take to run AVD without Active Directory?
- An application works on hybrid joined hosts and fails on Entra joined hosts. What is happening?
- How does administrative access work without a domain?
- Is Entra-only cheaper?
- What would you do differently?

**[Project 06 - Trentham Group: BYOD, Contractors and a Remote Workforce](../scenarios/project-06-byod-remote-workforce.md)**

- How do you secure AVD for BYOD users?
- Explain how redirection controls interact.
- A security standard says maximum restriction everywhere. How do you respond?
- Four contractors ended up on the pool with drive redirection enabled. What went wrong?
- What would you do differently?

**[Project 07 - Brightwater Energy: Call Centre, 1,400 Agents, Three Shifts](../scenarios/project-07-call-centre-high-density.md)**

- Explain how AVD autoscale decides how many hosts to run.
- A customer says autoscale is not saving them money. How do you investigate?
- How do you decide the session limit for a call centre?
- How would you handle a workload with three shifts rather than office hours?
- What would you do differently?

**[Project 08 - Kestrel Systems: Developer Desktops, Local Admin and the Cost of Personal Pools](../scenarios/project-08-developer-engineering.md)**

- How do you design AVD for developers?
- Start VM on Connect is enabled and nothing happens. Why?
- How do you handle configuration drift on personal desktops?
- How did you cost this?
- What would you do differently?

**[Project 09 - Thornbury Rail Partners: CAD, GPU and the Cost of Getting Drivers Wrong](../scenarios/project-09-gpu-cad.md)**

- How do you design AVD for CAD?
- How do you handle a CAD vendor's certified driver list against a monthly image cycle?
- Where would you put session hosts for an offshore design team?
- Was it cheaper than workstations?
- What would you do differently?

**[Project 10 - Ardencote Claims Services: RemoteApp, Six Clients, One Platform](../scenarios/project-10-remoteapp-line-of-business.md)**

- When would you use App Attach rather than putting applications in the image?
- An App Attach application is missing for a user. How do you investigate?
- How do you size the App Attach share?
- Can App Attach satisfy a contractual segregation requirement?
- What would you do differently?

**[Project 11 - Ashford Regional Health Network: Highly Secure and Regulated AVD](../scenarios/project-11-highly-secure-regulated.md)**

- How do you decide which security controls to apply and which to skip, on a regulated platform?
- Walk me through how you'd rebuild a broken break-glass process.
- An audit finding says "no efficient access-evidence capability." How do you actually close that, not just document a plan to close it?
- A hardening baseline breaks a clinical application during testing. What do you do?
- How do you decide which redirection and screen controls are proportionate for a specific user population?

**[Project 12 - Falkirk Logistics Group: Citrix to AVD Migration](../scenarios/project-12-citrix-migration.md)**

- How do you handle an application that depends on a hardware fingerprint for licensing, when moving from a persistent Citrix model to AVD's disposable-host model?
- Your Citrix estate has six Delivery Groups. How many AVD host pools do you build, and why?
- Your discovery finds that Citrix Studio's published-application list doesn't match what's actually used. How does that change your migration plan?
- How do you sequence migration waves for an estate with three shifts and no acceptable downtime window?
- A vendor's application ties its licence to a hardware fingerprint that AVD's rebuild model breaks. How is this different from a technical bug to fix?

**[Project 13 - Solheim Trading: Multi-Region AVD Architecture](../scenarios/project-13-multi-region-architecture.md)**

- Why did you choose active/active with no cross-region failover, when active/passive sounds more resilient?
- Why did you choose separate hub-spoke networks per region instead of Azure Virtual WAN?
- How do you keep three regions' golden images provably identical without a manual process someone eventually forgets?
- Why does each region get its own FSLogix storage with no Cloud Cache spanning regions, when Cloud Cache exists specifically for resilience?
- How do you validate that three regions are actually independent, rather than just assuming the architecture makes them so?

**[Project 14 - Corrigan Insurance: Business Continuity and Disaster Recovery for AVD](../scenarios/project-14-disaster-recovery.md)**

- Your DR test missed its RTO target on the first attempt. How do you handle that?
- Why is "we use Terraform, so we can just redeploy" not a complete disaster recovery plan?
- How do you set an RTO when the business hasn't told you what "acceptable downtime" means?
- Your board won't fund a fully duplicate always-on second region. How do you still meet a defensible recovery target?
- Your DR runbook has a recovery process. Does it need a separate failback process, or can you just run recovery in reverse?

**[Project 15 - Northgate Retail: Simulated Production Incident](../scenarios/project-15-production-troubleshooting.md)**

- You arrive at a live incident where the customer's own team has already made several changes. How does that affect your approach?
- Walk me through why you use a fixed, ordered layer sequence instead of investigating whichever layer seems most likely first.
- How do you hold a structured diagnostic method when the customer is pressuring you to "just try something" faster?
- The customer's own team made changes before you arrived that didn't help. How do you handle that conversation without it feeling like blame?
- The root cause turned out to be an application memory leak the vendor had already patched. Was this really an AVD problem to solve?

---

## Hands-on lab questions

Each of Labs 5-20 ends with two to five questions tied directly to what that lab built, useful for demonstrating hands-on depth rather than only design knowledge.

**[Lab 5 - Profile Storage](../labs/lab-05-storage.md)**

- Why does Azure Files for FSLogix need two separate permission grants?
- Why did you choose FileStorage over StorageV2 for this account?
- What would you change about this lab's NTFS permissions for a production deployment?

**[Lab 6 - FSLogix Configuration](../labs/lab-06-fslogix.md)**

- What is the one FSLogix setting you would never deploy without, and why?
- A user's container will not mount. How do you tell whether it is a lock, a permission problem, or a storage problem?

**[Lab 7 - Core AVD Objects](../labs/lab-07-avd-host-pool.md)**

- Why can't you safely change preferred application group type after creating a host pool?
- Where does user assignment actually live in the AVD object model?

**[Lab 8 - Session Hosts](../labs/lab-08-session-hosts.md)**

- Walk me through what "registered" actually means for a session host, and how you would prove it rather than assume it.
- You just deployed a session host and it never appears in the host pool. What's your first check?

**[Lab 9 - Application Delivery](../labs/lab-09-application-groups.md)**

- A user is assigned to both a desktop and a RemoteApp application group on the same host pool. What do they see?
- Why did this lab build a second host pool instead of adding a RemoteApp group to the existing one?

**[Lab 10 - Scaling, Monitoring and Operational Validation](../labs/lab-10-operations.md)**

- You configure diagnostic settings and want to prove they are actually working. What do you check, and when?
- What does drain mode actually stop, and what does it not stop?

**[Lab 11 - Multi-Region Network Foundation](../labs/lab-11-multiregion-network-foundation.md)**

- Why build two separate VNets peered together, rather than one VNet spanning two regions?
- Why does `centralus`'s identity NSG need a rule for the entire `eastus2` address range, when the original design only allowed the local hosts subnet?
- This lab explicitly doesn't configure DNS. Why not just point both VNets at each other's future DNS servers now, to save a step later?

**[Lab 12 - Regional Identity](../labs/lab-12-regional-identity.md)**

- Why join the existing forest with a second domain controller, rather than create a separate domain in `centralus` and trust it?
- What actually breaks if you deploy a second domain controller in `centralus` but skip the AD Sites and Services configuration?
- Why change the VNet DNS server settings only after confirming replication, rather than as part of the same deployment?

**[Lab 13 - Regional Storage Foundation](../labs/lab-13-regional-storage-foundation.md)**

- Why build a second, completely independent storage account for `centralus`, rather than just letting `centralus` session hosts use the existing `eastus2` share over the peered network?
- Two private DNS zones in this build share the exact same name, `privatelink.file.core.windows.net`. Why doesn't that conflict?

**[Lab 14 - Active-Active Host Pools and Workspaces](../labs/lab-14-active-active-hostpools-workspaces.md)**

- Why does Microsoft's active-active design produce two visible desktop entries for a user assigned to both regions, and why is that treated as correct rather than a bug to fix?
- This lab explicitly avoids Session Host Configuration even though the Azure feature is GA. Walk me through how you'd evaluate whether a new AVD capability is actually ready to build a required deployment on.
- If Session Host Configuration's tooling reaches full stability next year, what would actually need to change in this lab's design to adopt it?

**[Lab 15 - Cloud Cache Replication](../labs/lab-15-cloud-cache-replication.md)**

- Why does `centralus`'s configuration list its own storage account first in `CCDLocations`, while `eastus2`'s configuration lists its own storage account first too, rather than both regions using an identical provider order?
- You reproduced `ERROR_LOCK_VIOLATION` deliberately in this lab. What does that error actually tell you, and what would a production incident involving it look like?
- Given that the lock-violation failure is expected and documented, why not just tell users "don't sign in from two regions at once" instead of building Lab 16's group-based prevention?

**[Lab 16 - User Region Assignment](../labs/lab-16-user-region-assignment.md)**

- Why build two separate groups per population instead of one group with conditional logic deciding which region a member reaches?
- This lab's Terraform creates the groups but not their membership. Why draw the boundary there instead of automating membership too?
- How would you extend this design if a user genuinely needs access to both regions, say a manager overseeing both desks?

**[Lab 17 - Regional Autoscaling](../labs/lab-17-regional-autoscaling.md)**

- Why do the two regions' scaling plans use genuinely different schedule values instead of the same conservative defaults everywhere?
- What would you actually check to confirm two scaling plans are truly independent, beyond reading their Terraform configuration?
- Dynamic Autoscaling can create and delete hosts, which sounds more efficient than Power Management Autoscale's start-and-stop model. Why isn't it this lab's required implementation, given the Azure feature is GA?

**[Lab 18 - Regional Security and Monitoring](../labs/lab-18-regional-security-monitoring.md)**

- Why build two separate Log Analytics workspaces instead of pointing both regions' diagnostics at one shared workspace, which would be simpler to query?
- How would you actually verify that two Log Analytics workspaces are genuinely independent, rather than just configured with different names?
- Azure Firewall is a common recommendation for egress control. Why does this lab default it to off, and when would you turn it on?

**[Lab 19 - Disaster Recovery Failover](../labs/lab-19-disaster-recovery-failover.md)**

- Walk me through why this lab's DR target had to move from `centralus` to a third region during the build.
- Why does this lab treat failback as a separate runbook rather than just running the failover script in reverse?
- You built both an active-active region pair and an active-passive DR pair in this book. How would you explain to a stakeholder which one their business actually needs?
- Your DR region's session hosts originally authenticated only against the protected region's domain controller. Why is that a real design flaw, and how did you fix it?
- You said an on-demand capacity reservation "guarantees capacity during failover" at "no extra cost beyond the reserved VM rate." Is that accurate?

**[Lab 20 - Validation, Cost and Teardown](../labs/lab-20-validation-cost-teardown.md)**

- Why isn't the teardown order for Labs 11-20 simply the reverse of the build order?
- What's the actual value of re-running Lab 19's failover exercise here, in Lab 20, rather than trusting the result from when Lab 19 was originally built?
- If you were presenting this environment's cost to a stakeholder who wasn't technical, how would you use the Labs 11-20 plan's cost table and this lab's Step 3 output together?

---

## Five mock senior-level interview scenarios

Each scenario is a full simulated interview: the customer or hiring situation, the interviewer's actual questions in sequence, what a strong candidate response covers, the follow-up pressure that actually comes next, a side-by-side of a strong versus a weak answer, the specific technical decision points being probed, and what evidence a good answer produces. Answer out loud, from memory, before reading the strong-answer column.

### Mock 1 - Design a new AVD environment

**Customer situation.** A 500-person professional services firm is moving off physical laptops onto AVD ahead of a lease renewal deadline. You are the candidate in a senior architect interview for the role that would own this design.

**Interviewer questions, in the order they'd actually come.**
1. "Walk me through how you'd design this. What do you need to know before you draw anything?"
2. "Say they tell you 500 named users, no concurrency data yet. What do you do with that?"
3. "Why identity first, not host pool sizing first?"
4. "The CFO asks why you can't just tell them the monthly cost today. How do you answer that in the room?"

**Strong candidate response.** Opens with the requirements gap, not a design: no concurrency figure means no defensible host pool size yet, and asking for it (or a way to estimate it: named users by role, typical role-based concurrency ratios) is the first real answer, not a stall. Walks the decision order deliberately: identity model ([Chapter 7](../chapters/ch07-identity-architecture-foundations.md)) before anything else, because it determines the Kerberos path for profile storage and the join model for every host; host pool type and count ([Chapter 15](../chapters/ch15-host-pool-design-decisions.md)) next; sizing from a measured or estimated concurrency figure, not a vendor rule of thumb ([Chapter 17](../chapters/ch17-session-host-sizing-compute-selection.md)); profile storage sized from the sign-in burst, not steady-state ([Chapter 20](../chapters/ch20-profile-storage-architecture.md)). Closes with a real cost figure and names the one trade-off made to hit it.

**Follow-up pressure.** "Give me a number right now, what's this going to cost per month?" A strong candidate gives a range with the stated assumption behind it ("with 500 named users and an estimated 75% concurrency for this kind of firm, in this range, assuming Dsv5 pooled hosts") rather than either refusing to answer or inventing false precision.

**Strong versus weak answer.**

| | Strong | Weak |
|---|---|---|
| Opens with | The missing concurrency figure and how to get one | A host pool size and SKU |
| Handles the CFO's cost question | A range, with the assumption stated | Either "I can't say yet" with nothing else, or a precise number with no stated basis |
| Identity ordering | Explains *why* it comes first (Kerberos path, join model) | States the order without the reasoning |

**Technical decision points being probed.** Whether the candidate designs from measurement or from memorised defaults. Whether they can give a useful, honestly-caveated answer under pressure for a number they don't fully have yet, instead of either stonewalling or fabricating false confidence.

**Evidence a good answer produces.** A named next step ("I'd want a week of sign-in telemetry, or if that doesn't exist, a role-based concurrency estimate") and a cost figure with its assumption stated in the same breath, not as a footnote.

**Reference material.** [Project 01](../scenarios/project-01-smb-cost-sensitive.md) is the fullest worked example of exactly this scenario at a similar size, including the cost model and what was deliberately left out.

### Mock 2 - Investigate slow logons

**Customer situation.** You are already hired, six weeks into an ops role. It's 9:04am and the helpdesk queue has eleven tickets in the last ten minutes, all "AVD is slow this morning."

**Interviewer questions, in the order they'd actually come.**
1. "Walk me through what you're doing right now, live, while I'm listening."
2. "You said you'd check logon phase timing, what query, exactly?"
3. "Say the storage phase is the slow one. What's your very next action?"
4. "It's 9:15 and the queue is still growing. Do you communicate anything before you've found the cause?"

**Strong candidate response.** Refuses to guess-and-change. States the decomposition-first principle immediately: logon time is several phases, not one number, and treating it as one number is how people fix the wrong thing. Names the actual KQL for phase-by-phase timing, not a vague "I'd check the logs." When the storage phase comes back slow, the next action is checking storage account latency and throttling metrics for the same time window. This connects a symptom to a specific, checkable layer, not jumping to a fix.

**Follow-up pressure.** "The queue is still growing and it's 9:15. Do you say anything to anyone before you've found the cause?" A strong candidate says yes: a short, honest status update ("we're aware, actively investigating, decomposing where in sign-in the delay is") goes out immediately, separate from and not blocking the actual diagnosis, silence during a visible incident erodes trust faster than an update with no fix yet in it.

**Strong versus weak answer.**

| | Strong | Weak |
|---|---|---|
| First action | Decompose logon phases with a named query | Restart something, or check "the logs" generally |
| Under growing-queue pressure | Sends a short status update in parallel with diagnosis | Either goes silent until the fix, or stops diagnosing to write a long update |
| When storage looks slow | Checks storage latency/throttling metrics specifically | Assumes storage is the cause and starts changing storage configuration |

**Technical decision points being probed.** Whether the candidate has a structured method or reacts symptom-first. Whether they can run an incident under visible pressure without abandoning the method or going silent.

**Evidence a good answer produces.** A specific KQL query named correctly, a specific next metric to check once a phase is implicated, and a description of a parallel communication action that doesn't block the diagnosis.

**Reference material.** [Runbook 04](../troubleshooting/runbook-04-slow-signin-logon-storm.md) is the full evidence-first version of this exact scenario. [Project 02](../scenarios/project-02-enterprise-850-users.md) shows it solved end to end with real numbers. [Project 15](../scenarios/project-15-production-troubleshooting.md) shows the same discipline held under three days of prior uncoordinated changes and real incident-command pressure.

### Mock 3 - Resolve FSLogix failures

**Customer situation.** A user calls the helpdesk, escalated to you: "My AVD desktop has none of my files. Everything is gone."

**Interviewer questions, in the order they'd actually come.**
1. "What's your very first response to that user, before you've looked at anything?"
2. "What do you check first, technically?"
3. "Say the FSLogix log shows the container is locked. What now?"
4. "The user's manager is now on the phone asking if the data is lost. What do you tell them?"

**Strong candidate response.** First response to the user is reassurance grounded in what's actually likely true, not empty comfort: explains that this almost always means the profile didn't attach, not that data was deleted, and that the underlying container is very likely intact. Technically, checks whether this is genuinely a new/temporary profile (folder creation timestamp) before assuming a full FSLogix investigation is even needed. Walks the evidence sequence in order: temporary profile confirmation, the FSLogix log itself, storage connectivity, permissions, then a lock check. Explicitly states they would not delete or recreate the container as a first move.

**Follow-up pressure.** "The user's manager is now on the phone asking if the data is lost. What do you tell them?" A strong candidate gives an honest, currently-accurate answer, "the profile container itself is very likely intact; we're resolving what's preventing it from attaching", rather than a premature guarantee ("nothing is lost, don't worry") before the lock/permissions check is actually complete.

**Strong versus weak answer.**

| | Strong | Weak |
|---|---|---|
| First technical action | Confirms whether it's actually a temporary profile | Jumps straight to FSLogix log review without confirming the symptom |
| On a locked container | Checks whether the lock is stale (session/host no longer exists) before closing it | Force-closes the handle immediately, risking a live session |
| To the manager | An honest, currently-true statement, not a premature guarantee | Either alarmist ("data may be lost") or a guarantee made before the investigation is complete |

**Technical decision points being probed.** Whether the candidate treats profile failure as a data-loss event by default (wrong, and needlessly alarming) or correctly frames it as most likely an access-path problem. Whether they communicate honestly under pressure without either overclaiming or underclaiming certainty.

**Evidence a good answer produces.** The specific evidence sequence named in order, and a stated refusal to delete or recreate the container as a first move.

**Reference material.** [Runbook 03](../troubleshooting/runbook-03-fslogix-profile-attach-failure.md) is this exact scenario in full. [Chapter 19](../chapters/ch19-why-profiles-cause-avd-failure.md) covers the reasoning behind why this fails the way it does.

### Mock 4 - Diagnose connection drops or latency

**Customer situation.** Several remote users report sessions "feel laggy" over the past two days. Nothing has actually disconnected or failed, this is a subjective quality complaint, which is harder to triage than an outright failure.

**Interviewer questions, in the order they'd actually come.**
1. "Where do you start, given nothing has technically failed?"
2. "What's the one thing you check before anything else, and why that one?"
3. "Say the client shows TCP, not UDP. What does that tell you, and what's next?"
4. "How do you tell the difference between a Shortpath problem and a genuine network problem?"

**Strong candidate response.** Starts by naming that "feels laggy" with no hard failure is exactly the kind of symptom that gets mis-triaged toward storage or profile issues by instinct, and states the actual first check: the transport type shown in the client connection info. Explains that this single check splits the investigation cleanly, TCP instead of the expected UDP means Shortpath fell back to reverse connect, which explains reduced quality with no error, because reverse connect still works, just with different characteristics. Next step: check outbound UDP 3478 reachability from the host, not assume the client's home network is at fault.

**Follow-up pressure.** "How do you tell the difference between a Shortpath problem and a genuine network problem?" A strong candidate separates it cleanly: if UDP is reachable from the host but the client still shows TCP, the block is likely client-side (their home router or ISP); if UDP is not reachable from the host at all, it's an Azure-side or recently-changed security-tooling problem, not the user's network.

**Strong versus weak answer.**

| | Strong | Weak |
|---|---|---|
| First check | Transport type in the client connection info | Ping tests, generic "check the network" |
| On seeing TCP instead of UDP | Explains what Shortpath fallback means and why it's silent | Treats TCP as itself the problem to fix, without explaining the fallback mechanism |
| Isolating client-side vs host-side | Tests UDP reachability from the host to separate the two | Assumes it's the user's home network without checking |

**Technical decision points being probed.** Whether the candidate understands Shortpath's silent fallback behaviour specifically, not just "check the network" generically. Whether they can localise a fault to client-side or host-side with one specific test rather than guessing.

**Evidence a good answer produces.** The specific transport-type check named first, and a clear method for separating client-side from host-side causes using one test.

**Reference material.** [Runbook 05](../troubleshooting/runbook-05-connection-quality-shortpath-teams.md) is the full version. [Chapter 4](../chapters/ch04-connection-flow-end-to-end.md) covers the underlying connection flow this diagnosis depends on.

### Mock 5 - Reduce cost without damaging user experience

**Customer situation.** Finance has mandated a 30% AVD cost reduction. You are presenting your plan to the CFO and the Head of Operations, who will push back on anything that risks user complaints.

**Interviewer questions, in the order they'd actually come.**
1. "What would you actually do to hit 30%, and what would you refuse to do?"
2. "Raising the session limit is free and immediate, why wouldn't you just do that first?"
3. "Give me the levers in order, cheapest-to-user-experience first."
4. "What number do you need from me to actually commit to a plan, not just a list of options?"

**Strong candidate response.** Separates levers that cost nothing in user experience (autoscaling tuned to actual demand, right-sizing from measurement rather than a legacy over-provisioned SKU, image-based patching instead of manual host maintenance windows) from levers that trade experience for savings, naming raising session limits specifically as the second category. States plainly they would refuse to raise session limits without first quantifying the agent-time cost of doing so, citing that Project 07 measured this as a real, non-trivial cost that can exceed the compute saving it was meant to produce.

**Follow-up pressure.** "Raising the session limit is free and immediate. Why wouldn't you just do that first?" A strong candidate holds the line: "free and immediate" is exactly why it's tempting and exactly why it needs a number before being agreed to, not despite that. The cost shows up in reduced productivity per agent, which is real money, just not on the Azure bill, and Finance's mandate was to reduce cost, not just reduce the Azure invoice.

**Strong versus weak answer.**

| | Strong | Weak |
|---|---|---|
| To "just raise the limit, it's free" | Refuses without a quantified productivity cost first, cites specific prior evidence | Agrees, because the requester is the CFO and the saving is real and immediate |
| Lever ordering | Zero-user-experience-cost levers first, explicitly | No clear ordering, or leads with the highest-saving lever regardless of cost |
| What they ask for to commit | A specific number (agent time cost, or acceptable session-density ceiling) | Commits to a plan with no further information needed |

**Technical decision points being probed.** Whether the candidate treats "the person asking is senior" as a reason to agree to a technically unsound request. Whether they can separate genuinely free savings from savings that are free only on the metric being measured.

**Evidence a good answer produces.** A named number or a named next step to get one, and a refusal stated with its specific reasoning, not just a refusal.

**Reference material.** [Project 07](../scenarios/project-07-call-centre-high-density.md) is where this exact trade-off was quantified with real agent-time and compute-cost figures. [Project 03](../scenarios/project-03-global-enterprise-governance.md) shows the same "defend a trade-off to a senior stakeholder" pattern applied to a governance decision (subscription design) rather than a cost lever.

---

## Navigation

Back to [the main book](../README.md) | [Full index](../SUMMARY.md) | [Interview material status](../interviews/README.md)
