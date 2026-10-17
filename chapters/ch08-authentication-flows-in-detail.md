# Chapter 8 - Authentication Flows in Detail

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Part II:** Identity and Authentication
> **Technical baseline:** Microsoft Learn as retrieved 16 October 2026 (see [Review register](../REVIEW-REGISTER.md))

---

## Chapter Information

| Item | Detail |
|---|---|
| **Chapter number** | 8 |
| **Objective** | Separate the three authentications in an AVD connection, configure single sign-on correctly, and troubleshoot authentication failures with evidence rather than guesswork |
| **Prerequisites** | Chapters 1 to 7. Lab 4 complete |
| **Dependencies** | Builds on the connection flow in [Chapter 4](ch04-connection-flow-end-to-end.md) and the join models in [Chapter 7](ch07-identity-architecture-foundations.md) |
| **Estimated lab time** | No dedicated configuration lab; the read-only checks can be run in any lab environment with an AVD host pool |
| **Azure resources required** | None for the chapter |
| **Cost** | $0.00 |

---

## What You Will Learn

- The three separate authentications in one AVD connection, and why mixing them up causes most MFA (multifactor authentication) problems
- How to enable single sign-on with Entra authentication, step by step
- When you need a Kerberos server object and what happens if you skip it
- When you need a KDC proxy
- Three full production troubleshooting scenarios, with the exact commands and queries

---

## Why This Matters

A user connects to AVD. They get an MFA prompt. Then they get a Windows password prompt. Then an application inside the session asks for credentials again.

That is three authentications, not one bad experience. Engineers who treat it as one thing spend days changing Conditional Access policies that were never involved.

Getting this right is also what makes single sign-on work, and single sign-on is usually the difference between users who like AVD and users who complain about it.

---

## 1. Three Authentications, Not One

Microsoft's own documentation splits the problem the same way. Learn's authentication page names three phases: cloud service authentication (subscribing to resources and authenticating to the gateway, with Microsoft Entra ID), remote session authentication (to the remote VM, with single sign-on recommended), and in-session authentication (to applications and sites inside the session). The KDC proxy page describes the first two as the two components of the service that need to be authenticated: the feed, authenticated in Entra ID, and the RDP (Remote Desktop Protocol) session, which uses Kerberos and needs a KDC proxy for remote smart card users.

> **OUR ORIGINAL ARCHITECTURE DIAGRAM.** Created for this book. Not a Microsoft diagram.
> Editable source: [`ch08-identity-architecture.drawio`](../diagrams/architecture/ch08-identity-architecture.drawio)

![AVD identity architecture showing two sign-ins: feed authorization and session authorization use different Entra app registrations](../diagrams/architecture/ch08-identity-architecture.svg)

*Reading note from the 16 October 2026 review: this diagram draws Conditional Access at the first sign-in only. Learn says that with single sign-on enabled, the Windows Cloud Login app is introduced into the sign-in path and Conditional Access policies, including MFA and sign-in frequency, are re-evaluated when the user reconnects, so the second sign-in can also be a Conditional Access target. The diagram has not been redrawn; this is recorded as a follow-up.*

The same three authentications, as a sequence, because the order is what people get wrong.

```mermaid
---
title: AVD authentication sequence
---
sequenceDiagram
    autonumber
    participant U as Windows App
    participant E as Entra ID
    participant S as AVD service
    participant G as AVD gateway
    participant H as Session host
    participant K as Domain controller

    Note over U,E: Stage 1 · service authentication
    U->>E: Sign in
    E->>E: Conditional Access, MFA (AVD app)
    E-->>U: Token

    Note over U,S: Authorization
    U->>S: Request feed
    S-->>U: Assigned desktops and apps

    Note over U,H: Stage 2 · session host authentication
    U->>G: Connect, presenting the service token
    G->>E: Start session host SSO (Windows Cloud Login)
    E->>E: Conditional Access re-evaluated when targeted
    E-->>G: Token for the session host
    G->>H: Pass token, host accepts it
    H->>K: Kerberos ticket (hybrid, or Kerberos server object)

    Note over H,K: Stage 3 · in-session authentication
    H->>K: Integrated auth to shares and apps
```

### What this diagram shows

Three authentications, drawn as three distinct paths, with the identity layer separated from the service and the session host. The important thing to read is which layer each control acts on.

Authentication and authorization are separated deliberately. Stage 1 proves who the user is. The step into the feed is authorization, deciding which application groups that identity is assigned to. Conflating the two is why people troubleshoot Conditional Access when the real problem is an assignment.

### Step by step flow

1. **Stage 1, service authentication.** The user signs in to Microsoft Entra ID. Conditional Access is evaluated here, including MFA, device state and location. The token is issued against the Azure Virtual Desktop application.
2. **Authorization.** The service checks which application groups the identity is assigned to and returns the feed. See [Chapter 3](ch03-avd-object-model.md).
3. **Stage 2, session host authentication.** The user signs in to Windows on the session host. With single sign-on enabled, the gateway starts SSO through the Windows Cloud Login application, which issues the token for the session host, and no second prompt appears. Without it, the user is prompted again.
4. **Kerberos.** Windows sign in uses Kerberos or NTLM. Kerberos needs a ticket from a domain controller over TCP (Transmission Control Protocol) 88, which requires line of sight or a KDC proxy.
5. **Stage 3, in-session authentication.** Applications and SMB shares inside the session authenticate separately, typically with integrated Windows authentication.

### Architect's interpretation

Where Conditional Access applies is the point most people get wrong. An earlier version of this chapter said Conditional Access is evaluated only at stage 1. That is not accurate once single sign-on is on: the Windows Cloud Login app becomes a Conditional Access target at the session host sign-in, and for Entra joined hosts the Azure Windows VM Sign-In app is involved as well (see Chapter 9). Conditional Access does not apply to stage 3, where applications use their own authentication. When somebody says MFA is not being enforced on the session host, check which Entra apps your policies target before deciding the model is broken.

The Kerberos path is the other design driver. It decides whether smart card users can work remotely, which is a network and infrastructure question rather than an identity one.

### Important design decisions

- **Single sign-on or not.** Enabling it removes the stage 2 prompt and, per Learn, involves five tasks, covered in section 2. With SSO, a locked session disconnects by default so Conditional Access is re-evaluated at reconnect.
- **Kerberos reachability.** Line of sight, VPN (virtual private network), or a KDC proxy. Each has an infrastructure cost. See section 3.
- **Same identity throughout.** Using different identities for the service and the session host can bypass Conditional Access enforcement.
- **Which Entra app the policy targets.** See [Chapter 9](ch09-conditional-access-mfa-zero-trust.md), where the two applications behave differently.

### Failure points

| Stage | Symptom | First check |
|---|---|---|
| 1, service authentication | Cannot sign in, or empty feed | Entra sign-in logs, licence, Conditional Access |
| Authorization | Feed loads but no icons | Application group assignment |
| 2, session host authentication | Connects, then prompts for a password | SSO configuration and the host pool RDP property, then Conditional Access on Windows Cloud Login |
| 2, Entra joined host | "Your account is configured to prevent you from using this device" | Virtual Machine User Login role (Learn's troubleshooting page) |
| 2, Entra joined host | "The user name or password is incorrect" with correct credentials | Role assignment, MFA exclusion for the Azure Windows VM Sign-In app, per-user MFA (not supported for VM sign-in) |
| 2, Kerberos path | Smart card users fail off network | Line of sight to a KDC, or a KDC proxy |
| 3, in-session | Session works, shares ask for credentials | Kerberos server object on Entra joined hosts |

**Official Microsoft reference:** https://learn.microsoft.com/en-us/azure/virtual-desktop/authentication

---

## 2. Single Sign-On With Entra Authentication

This is the configuration that removes the second prompt. It is also the one people half-configure and then spend a week debugging.

`CURRENCY FLAG - re-checked on 16 October 2026 against Learn's configure-single-sign-on page. Check the Microsoft page before configuring a production tenant. [VERIFY BEFORE IMPLEMENTATION]`

### What you are actually enabling

Source for this section: [Configure single sign-on for Azure Virtual Desktop using Microsoft Entra ID](https://learn.microsoft.com/en-us/azure/virtual-desktop/configure-single-sign-on), retrieved 17 October 2026.

Microsoft's guidance describes the first step: you must first allow Microsoft Entra authentication for Windows in your Microsoft Entra tenant, which enables issuing RDP access tokens allowing users to sign in to your Azure Virtual Desktop session hosts. You set the isRemoteDesktopProtocolEnabled property to true on the service principal's remoteDesktopSecurityConfiguration object for the Windows Cloud Login application, app ID 270efc09-cd0d-444b-a71f-39af4910ec45.

In plain terms. You are telling Entra ID that it is allowed to issue tokens that Windows will accept as a sign-in on a session host.

**Prerequisites from Learn.** You need the Application Administrator or Cloud Application Administrator role; session hosts on Windows 11 (KB5018418 or later), Windows 10 (KB5018410 or later) or Windows Server 2022 (KB5018421 or later); Entra joined or Entra hybrid joined hosts (hosts joined to Entra Domain Services or to AD only are not supported); a two-way trust if hybrid hosts are in a different AD domain than the users, otherwise connections fall back to older protocols; Microsoft Graph PowerShell SDK 2.9.0 or later; and a supported client (all Windows App versions on Windows, macOS 10.9.10+, iOS/iPadOS 10.5.2+, web browser; the page also lists versions of the Remote Desktop clients, which [Chapter 6](ch06-clients-and-the-endpoint-story.md) covers, including the end of support for the Windows MSI client). Learn also says that if you provide resources to external identities, SSO must be enabled for the host pool.

**Session lock.** With SSO on, a locked session disconnects by default (configurable to show the remote lock screen). Learn gives this as a security feature: Conditional Access, MFA and sign-in frequency are re-evaluated at reconnect.

**Domain administrators.** Learn warns that the default Password Replication Policy on RODCs denies replication for Domain Admins and Administrators, which can keep prompting such accounts on hybrid joined hosts, and recommends not connecting as a domain admin.

### The full checklist

Learn's task list has five tasks: enable Microsoft Entra authentication for RDP, hide the consent prompt dialog, create a Kerberos server object if Active Directory Domain Services is part of your environment, review your Conditional Access policies, and configure your host pool to enable single sign-on. This chapter's earlier four-step version left out the consent prompt; it is added below as Step 1b.

### Step 1, enable Entra authentication for RDP

Portal path: *Azure portal > Microsoft Entra ID > Devices > Remote connection configuration > Windows Cloud Login*.

Or with the Microsoft Graph PowerShell SDK:

```powershell
# Requires the Microsoft.Graph PowerShell SDK 2.9.0 or later
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Applications
Connect-MgGraph -Scopes "Application.Read.All","Application-RemoteDesktopConfig.ReadWrite.All"

# Windows Cloud Login application
$appId = "270efc09-cd0d-444b-a71f-39af4910ec45"
$sp = Get-MgServicePrincipal -Filter "AppId eq '$appId'"

# Check current state before changing anything
Get-MgServicePrincipalRemoteDesktopSecurityConfiguration -ServicePrincipalId $sp.Id

# Enable RDP access token issuing
Update-MgServicePrincipalRemoteDesktopSecurityConfiguration `
  -ServicePrincipalId $sp.Id `
  -IsRemoteDesktopProtocolEnabled
```

**What this does:** allows Entra ID to issue RDP access tokens for session host sign-in.
**Expected result:** per Learn, the update command produces no output, and `Get-MgServicePrincipalRemoteDesktopSecurityConfiguration` then returns `IsRemoteDesktopProtocolEnabled` as `True`.
**Common errors:** insufficient Graph permissions, or an older Graph module without the remote desktop configuration cmdlets. Update the module before assuming the tenant is the problem.

The cmdlet names and the two scopes above match Learn's page as retrieved 16 October 2026; the commands themselves were not executed here. `[VERIFY BEFORE IMPLEMENTATION]` Graph SDK cmdlets change between module versions, so confirm against the current page before running this in a production tenant.

### Step 1b, hide the consent prompt

By default, with SSO enabled users see a dialog to allow the Remote Desktop connection when connecting to a new session host; Entra remembers up to 15 hosts for 30 days. To hide it, add up to 10 Entra device groups (Learn recommends dynamic groups containing the session hosts, which need Entra ID P1 or Intune for Education licences) to the *Target device groups to enable SSO* property of the Windows Cloud Login service principal. In the portal this is under Entra ID > Devices > Remote connection configuration > Windows Cloud Login. Large tenants can take up to 24 hours for dynamic group membership.

### Step 2, create a Kerberos server object if you have AD DS

This is the step people skip, and the symptoms are misleading.

Learn's two conditions are: the host is Entra hybrid joined (needed to complete authentication to a DC), or the host is Entra joined and the environment has AD domain controllers (needed for on-premises resources).

**If you skip it on hybrid joined hosts,** Learn says you can get an error saying the specific session does not exist, or single sign-on is skipped and the user gets a standard authentication dialog. Learn also requires it for Entra joined hosts when the environment contains AD domain controllers and users need on-premises resources such as SMB shares or Windows-integrated websites. The connection appears to work. The user just gets prompted, and nobody can explain why.

### Step 3, enable SSO on the host pool

Portal path: *Azure portal > Azure Virtual Desktop > Host pools > `hp-avd-lab-eus2-01` > RDP Properties*, setting **Microsoft Entra single sign-on** to *Connections will use Microsoft Entra authentication to provide single sign-on* (the exact tab was not stated on Learn's page).

Or set the custom RDP property directly:

```powershell
Update-AzWvdHostPool `
  -ResourceGroupName rg-avd-service-lab-eus2-01 `
  -Name hp-avd-lab-eus2-01 `
  -CustomRdpProperty "enablerdsaadauth:i:1"
```

**Warning.** `CustomRdpProperty` replaces the whole string. Read the current value first and append to it, or you will silently remove other RDP settings such as multi monitor or drive redirection.

```powershell
# Always read before you write
(Get-AzWvdHostPool -ResourceGroupName rg-avd-service-lab-eus2-01 -Name hp-avd-lab-eus2-01).CustomRdpProperty
```

This is a good example of something in the "do not change blindly" category from the [operations standard](../OPERATIONS-AND-TROUBLESHOOTING-STANDARD.md). Overwriting RDP properties on a production host pool affects every user at their next connection.

### Step 4, review Conditional Access

Enabling SSO introduces a new Entra application (Windows Cloud Login) into the sign-in path. Existing policies scoped to AVD may now behave differently. Review before you enable, not after users start calling. Learn's SSO page points to a two-policy structure in the MFA article and to a separate troubleshooting page for repeated prompts. [Chapter 9](ch09-conditional-access-mfa-zero-trust.md) covers this properly.

---

## 3. KDC Proxy, and When You Need It

Smart card users working remotely are the classic case. Microsoft explains the problem directly: for the RDP portion of an AVD session, smart cards require a direct connection, or line of sight, with an Active Directory domain controller for Kerberos authentication. Without this direct connection, users can't automatically sign in to the organization's network from remote connections. Users can use the KDC proxy service to proxy this authentication traffic and sign in remotely.

You configure it on the host pool.

Portal path: *Azure portal > Azure Virtual Desktop > Host pools > your host pool > RDP Properties > Advanced*, then enter `kdcproxyname:s:<fqdn>` with no spaces.

Learn's prerequisites: remote client machines running at least Windows 10 with the Windows Desktop client; **the web client is not supported**; the KDC proxy must already be installed (RD Gateway role) on Windows Server 2016 or later. `[VERIFY BEFORE IMPLEMENTATION]` Learn's page names the Windows Desktop client, not Windows App. Because the Remote Desktop MSI client is out of support for public cloud (Chapter 6), confirm that Windows App honours `kdcproxyname` before designing around a KDC proxy.

**Architect's note.** The KDC proxy role typically runs on a Windows Server Gateway role server. That is another component to build, patch and make highly available. Before committing to it, ask whether Windows Hello for Business or FIDO keys would meet the same security requirement without the extra infrastructure. Microsoft supports in-session passwordless authentication with Windows Hello for Business or security devices such as FIDO keys when using Windows App.

---

## 4. Production Troubleshooting

> The scenarios below are illustrative composites written for this knowledgebase, not documented customer engagements. User counts, costs and timings are assumptions chosen to make the reasoning concrete.

Three scenarios, in the standard format. Each one is real, in the sense that these are the shapes these failures actually take.

---

### Scenario 1: Users get prompted for a password after SSO was enabled

**Problem.** Single sign-on was enabled last week. Around a third of users still get a Windows password prompt after connecting.

**Symptoms.**
- Users connect successfully, then see a credential dialog.
- Some users never see it. The difference does not obviously correlate with department or location.
- Helpdesk has been resetting passwords, which has not helped.
- Someone has already suggested it is a Conditional Access problem. It is not.

**Business impact.** A third of users prompted for credentials at every sign in, and a service desk resetting passwords that were never wrong.

**Initial hypothesis.** SSO configuration is incomplete rather than absent, because it works for some users. Candidates, all from Learn: a host pool where the RDP property was not applied; a missing Kerberos server object on hybrid joined hosts; hybrid hosts in a different AD domain from the users without a two-way trust (connections fall back to older protocols); administrator accounts blocked by the RODC (read-only domain controller) Password Replication Policy; and Conditional Access on Windows Cloud Login.

**Investigation.**

Start with the fastest check that splits the population. Is it host pool specific?

```powershell
# Compare RDP properties across host pools
Get-AzWvdHostPool -ResourceGroupName rg-avd-service-lab-eus2-01 |
  Select-Object Name, CustomRdpProperty
```

Then check whether the tenant level setting is actually on:

```powershell
Connect-MgGraph -Scopes "Application.Read.All"
$sp = Get-MgServicePrincipal -Filter "AppId eq '270efc09-cd0d-444b-a71f-39af4910ec45'"
Get-MgServicePrincipalRemoteDesktopSecurityConfiguration -ServicePrincipalId $sp.Id
```

Then look at the session host side. On an affected host:

*Event Viewer > Applications and Services Logs > Microsoft > Windows > RemoteDesktopServices-RdpCoreCDV > Operational*, and *Event Viewer > Windows Logs > Security* filtered for event ID 4624 to see the authentication package used. These log locations are standard Windows diagnostics and were not verified against Learn in this review.

Then check the connection data:

```kusto
WVDConnections
| where TimeGenerated > ago(24h)
| summarize Connections = dcount(CorrelationId) by UserName, SessionHostName
| order by Connections desc
```

The earlier `State == "Connected"` filter was removed because Learn's table reference does not enumerate State values. Learn's [Use Log Analytics for the diagnostics feature](https://learn.microsoft.com/azure/virtual-desktop/diagnostics-log-analytics) shows the connection states Started, Connected and Completed in its own queries (checked 16 October 2026, U10), so a `State` filter is documented there, but the table reference itself still does not list the values. The query was not executed. `[VERIFY BEFORE IMPLEMENTATION]` Confirm the `WVDConnections` table exists in your workspace (diagnostic settings must be enabled).

**Evidence.**
- If `CustomRdpProperty` on the affected host pool does not contain `enablerdsaadauth:i:1`, that is the answer. The tenant setting is fine, the host pool was missed.
- If the property is present on all pools and the tenant setting is enabled, and the affected users are all on hybrid joined hosts, the Kerberos server object is the likely cause.
- If Security event 4624 shows NTLM where you expected Kerberos, that supports the same conclusion.

**Root cause.** In this case, two host pools were configured and a third was created later by a different engineer from a template that predated the SSO work. Users were split across all three by persona, which is why the failure looked random.

**Fix.**

```powershell
# Read the current value first. This property overwrites, it does not merge.
$hp = Get-AzWvdHostPool -ResourceGroupName rg-avd-service-lab-eus2-01 -Name hp-know-prd-eus2-01
$existing = $hp.CustomRdpProperty
if ($existing -and -not $existing.EndsWith(";")) { $existing += ";" }
$new = $existing + "enablerdsaadauth:i:1;"

Update-AzWvdHostPool `
  -ResourceGroupName rg-avd-service-lab-eus2-01 `
  -Name hp-know-prd-eus2-01 `
  -CustomRdpProperty $new
```

Users pick this up at their next connection. Existing sessions are unaffected. The commands were not executed here.

**Validation.** A test user in the affected group disconnects fully, reconnects, and reaches the desktop with no credential prompt. Then confirm on a second user in the same host pool, on a different client platform. One successful test proves very little.

**Prevention.** Put the RDP property in Terraform so a host pool cannot be created without it. Add a scheduled check that compares `CustomRdpProperty` across all host pools and alerts on drift. This is exactly the class of problem infrastructure as code exists to prevent, and it is covered in [Project 03](../scenarios/project-03-global-enterprise-governance.md), where Terraform and CI/CD governance at scale is worked through in full.

**Interview lesson.** Explaining that the RDP property overwrites rather than merges shows you have made, or narrowly avoided, that mistake.

---

### Scenario 2: Remote smart card users cannot sign in, office users are fine

**Problem.** A regulated financial services team uses smart cards. In the office everything works. Working from home, users connect and then fail at Windows sign-in.

**Symptoms.**
- Failure only occurs off the corporate network.
- The AVD feed loads normally, so service authentication is fine.
- The failure is at stage 2, session host authentication.
- VPN users are unaffected.

**Business impact.** A regulated team unable to work remotely at all, which is a business continuity issue rather than an inconvenience.

**Initial hypothesis.** Stage 2 needs Kerberos, Kerberos needs line of sight to a KDC, and remote users do not have it. This matches Microsoft's documented behaviour exactly, so it is the first thing to test rather than the last.

**Investigation.**

Confirm the stage. If the feed loads and resources are listed, stage 1 passed. Check Entra sign-in logs to be certain:

*Azure portal > Microsoft Entra ID > Monitoring > Sign-in logs*, filter by user, and confirm a successful interactive sign-in to the AVD application.

Then confirm the authentication method in use. Smart card and Windows Hello for Business can only use Kerberos.

Then test connectivity from a client on the affected network to the domain controller. From an affected user's machine:

```powershell
Test-NetConnection -ComputerName avdlab-dc01.avdlab.local -Port 88
nltest /dsgetdc:avdlab.local
```

**Evidence.** From the office or over VPN, port 88 is reachable and `nltest` returns a domain controller. From a home network, both fail. That is a complete match for the hypothesis.

**Root cause.** Remote clients have no line of sight to a domain controller, so no Kerberos ticket can be obtained for the session host sign-in. Password based users are unaffected because NTLM is available to them. Smart card users have no fallback.

**Fix.** Two supported options.

1. Deploy a KDC proxy (RD Gateway role, Windows Server 2016 or later) and set `kdcproxyname:s:<fqdn>` on the host pool: *RDP Properties > Advanced*. The web client is not supported.
2. Require VPN for this user group, which gives line of sight.

Which one you choose is an architecture decision, not a support decision. The KDC proxy is another server to build, patch and make highly available. VPN may already exist. Present both with the cost and the operational load attached.

**Validation.** An affected user, on a home network, with no VPN, signs in with their smart card and reaches the desktop. Test with two users on different ISPs. Then confirm the office and VPN paths still work, because you have changed a shared host pool setting.

**Prevention.** Add smart card and remote access to the design assumptions register, and confirm the client (Windows App versus the retired MSI client) supports the KDC proxy property. This failure is entirely predictable from the documentation, which means it should have been caught at design time. Record it as a design assumption to be validated during pilot, and include an off network test in every future pilot plan.

**Interview lesson.** Presenting a KDC proxy and a VPN as an architecture choice with cost attached, rather than a fix, is the senior framing.

---

### Scenario 3: Session starts, then an on-premises file share asks for credentials

**Problem.** On a new Entra joined host pool, users reach the desktop but get a credential prompt when an application tries to reach an on-premises file share. FSLogix profiles are mounting correctly.

**Symptoms.**
- Stage 1 and stage 2 both succeed. This is stage 3.
- FSLogix works, which confuses people into thinking storage authentication is fine everywhere.
- Only on-premises resources are affected. Azure Files is fine.
- It started when the new Entra joined pool went live. The old hybrid joined pool is unaffected.

**Business impact.** Users can reach the desktop but not the applications that hold the data they need, which is worse than a clean failure because it looks like a permissions problem.

**Initial hypothesis.** Entra joined session hosts with no Kerberos server object cannot get tickets for on-premises Kerberos resources. FSLogix on Azure Files works because that path uses Entra Kerberos, which is a different mechanism. See [Chapter 7 section 3](ch07-identity-architecture-foundations.md#3-entra-kerberos-changed-the-design).

**Investigation.**

Confirm what the session actually has. On an affected session host, in the user's session:

```powershell
# What Kerberos tickets does the session hold?
klist
klist cloud_debug
dsregcmd /status

# Can the session reach a domain controller at all?
nltest /dsgetdc:avdlab.local
Test-NetConnection -ComputerName avdlab-dc01.avdlab.local -Port 88
```

`klist cloud_debug` and the `dsregcmd /status` SSO state (OnPremTgt and CloudTgt) are the checks Learn's Entra Kerberos page describes for the cloud and on-premises tickets. Then confirm the profile path is working through a different mechanism: the FSLogix logs under `C:\ProgramData\FSLogix\Logs` (Chapter 21 verifies FSLogix log locations). Then check whether the Kerberos server object exists in the AD environment.

**Evidence.** Expected, not captured from a live system: `dsregcmd /status` shows CloudTgt as YES and OnPremTgt as NO, and `klist` shows no ticket for the on-premises realm. `Test-NetConnection` to port 88 may succeed if there is a network path, which rules out a pure networking fault and points at the ticket issuance path instead.

**Root cause.** No Kerberos server object, so the Entra joined hosts cannot obtain tickets for on-premises Kerberos resources. FSLogix on Azure Files was unaffected because Entra Kerberos handles that path independently.

**Fix.** Create the Kerberos server object, then have users disconnect fully and reconnect. A reconnect to an existing session will not pick up new ticket behaviour.

**Validation.** In a new session, `klist` shows a ticket for the on-premises realm, and the file share opens without a prompt. Confirm with a second user, and confirm the hybrid joined pool is still unaffected.

**Prevention.** Add the Kerberos server object to the Entra join build standard, so it is a prerequisite rather than a discovery. Add an in-session test of an on-premises resource to the pilot checklist for every new host pool. Most importantly, correct the assumption that caused it: FSLogix working does not prove Kerberos works.

**Interview lesson.** Correcting that assumption unprompted demonstrates that you understand the identity paths rather than the symptoms.

---

## 5. The Architect's Four Questions

**What do I check first?** Which of the three stages failed. Feed loads or not, connects or not, prompted inside the session or not. That one question eliminates most causes in under a minute.

**What can I safely change now?** Adding a Kerberos server object. Testing with a single user. Reading configuration with `Get-` commands. Restarting a single session host that is already in drain mode.

**What must not be changed blindly?**
- `CustomRdpProperty` on a production host pool. It overwrites rather than merges, and it affects every user at their next connection.
- Conditional Access policies. Change one at a time, in report only mode first, with a break glass account excluded.
- VNet DNS (Domain Name System). See [Lab 4 Step 5](../labs/lab-04-identity-integration.md).
- Disabling SSO to "test something". Every user is affected immediately.
- Excluding the wrong app from MFA. Chapter 9 covers which app to exclude for Entra joined hosts.

**When do I escalate to Microsoft?** When you have evidence the failure sits inside a Microsoft managed component, or behaviour contradicts the documentation. Before opening the case, collect: the correlation ID from the client error, the Entra sign-in log entry, the relevant `WVDConnections` and `WVDErrors` rows with timestamps in UTC, the session host name and agent version, and the exact configuration state of the host pool and tenant setting. Support will ask for all of it, and some of it ages out.

---

## 6. Common Mistakes

- Treating three authentications as one and rewriting Conditional Access to fix a stage 2 problem.
- Overwriting `CustomRdpProperty` instead of appending to it.
- Enabling SSO without creating the Kerberos server object in an AD DS environment.
- Assuming FSLogix working means Kerberos works. Entra Kerberos for Azure Files is a separate path.
- Testing SSO with one user on one client and calling it done.
- Choosing a KDC proxy without asking whether passwordless would meet the same requirement with less infrastructure.
- Reconnecting to an existing session and concluding a fix did not work. Disconnect fully first.

---

## 7. Interview Preparation

### Q20. Walk me through authentication in an AVD connection.

**Simple answer**
Three separate authentications. To the service in Entra ID for the feed, to Windows on the session host, and then anything inside the session. Conditional Access and MFA are evaluated at the first, and with single sign-on also at the second through the Windows Cloud Login app.

**Strong senior architect answer**
"Three stages, and keeping them separate is what makes troubleshooting fast. Stage one is Entra ID for the feed, and that is where Conditional Access and MFA are first evaluated. Stage two is the sign-in to Windows on the session host, which uses Kerberos or NTLM, and that is where single sign-on removes the second prompt; with SSO, Windows Cloud Login is a Conditional Access target too. Stage three is anything inside the session, file shares and applications using integrated authentication. Each one fails differently. Empty feed is stage one. Connects then prompts is stage two. Session works but a share asks for credentials is stage three. The practical point is that Kerberos needs line of sight to a KDC, so smart card users working remotely need either a KDC proxy or a VPN, and that is a design decision to make up front rather than discover in pilot."

**Follow-up you should expect**
"How do you enable single sign-on?" Enable Entra authentication for RDP on the Windows Cloud Login service principal, optionally hide the consent prompt with target device groups, create a Kerberos server object if AD DS is in the environment, review Conditional Access because SSO puts a new application in the sign-in path, and set `enablerdsaadauth:i:1` on the host pool.

### Q21. Users are getting an extra password prompt. How do you find out why?

**30 second answer**
"First I would establish which stage is failing, because a prompt after connecting is stage two, which is usually the SSO configuration but can also be Conditional Access on the Windows Cloud Login app. Then I would compare host pools, because a likely cause is one pool missing the SSO RDP property. Then I would check whether the Kerberos server object exists if the estate is hybrid joined."

**2 minute answer**
Add the method. Check whether it affects everyone or a subset, and whether the subset maps to a host pool. Read `CustomRdpProperty` across all host pools with a single command. Check the tenant setting on the Windows Cloud Login service principal. Then look at Security event 4624 on an affected host to see which authentication package was used. Finish with the fix warning: the RDP property overwrites, so read it before you write it, or you will remove other settings and cause a second incident while fixing the first.

### Q22. How would you prevent this class of problem?

**Strong answer**
"Configuration drift between host pools is the root of most of it, so I would define host pools in Terraform with the RDP properties as code, and add a drift check that compares them and alerts. Then I would make the Kerberos server object part of the build standard for Entra join rather than a step someone remembers. And I would change the pilot checklist so it tests all three stages, including an on premises resource from inside the session and a connection from off the corporate network. Most of these failures are predictable from the documentation, which means they are design and process problems rather than technical ones."

---

## 8. Key Takeaways

- Three authentications: service, session host, in-session. Each fails with a different signature.
- Conditional Access and MFA are evaluated at the service stage and, with single sign-on, also for the Windows Cloud Login sign-in.
- Single sign-on, per Learn, has five tasks: enable Entra authentication for RDP on Windows Cloud Login, optionally hide the consent prompt, create a Kerberos server object where AD DS exists, review Conditional Access, and set `enablerdsaadauth:i:1` on the host pool.
- `CustomRdpProperty` overwrites. Always read before you write.
- Smart card and Windows Hello for Business require Kerberos, which requires line of sight to a KDC or a KDC proxy (not supported on the web client).
- FSLogix working on Azure Files does not prove Kerberos works for on-premises resources.

---

## 9. Official References

- Azure Virtual Desktop identities and authentication - https://learn.microsoft.com/en-us/azure/virtual-desktop/authentication
- Configure single sign-on using Microsoft Entra ID - https://learn.microsoft.com/en-us/azure/virtual-desktop/configure-single-sign-on
- Set up Kerberos Key Distribution Center proxy - https://learn.microsoft.com/en-us/azure/virtual-desktop/key-distribution-center-proxy
- Troubleshoot connections to Microsoft Entra joined VMs - https://learn.microsoft.com/en-us/azure/virtual-desktop/troubleshoot-azure-ad-connections
- Introduction to Microsoft Entra Kerberos - https://learn.microsoft.com/en-us/entra/identity/authentication/kerberos

---

## Architect's Reality Check

> Engineering judgement, not measured data or documented customer cases. Statements about what is common or likely are reasoning, not survey results.

**What engineers commonly get wrong.** They treat three authentications as one. A prompt after connecting is stage two. It is usually an SSO configuration gap, but Conditional Access on Windows Cloud Login can cause it, so check both before spending a day on either.

**What I would check first in production.** Which stage failed. Empty feed, prompted after connecting, or prompted inside the session. Each has a different cause and a different fix.

**What I would ask the customer.** Whether smart cards or Windows Hello for Business are in use, and whether anyone works off the corporate network. That combination decides whether you need a KDC proxy, and it is much cheaper to know at design time.

**What I would decide as the architect.** Single sign on enabled properly, all five tasks, with the Kerberos server object treated as a build standard rather than a task someone remembers. And RDP properties in code, because that setting overwrites rather than merges.

**What I would say in an interview.** The three stage model, then the failure signature of each. That framing is what makes the rest of the answer sound like experience.

---

## How This Changes With Scale

**Around 100 users.** Single sign on is a nice improvement. Without it people are mildly annoyed.

**Around 1,000 users.** An extra prompt per sign in is measurable lost time and a steady stream of tickets. Configuration drift between host pools starts producing failures that look random because they follow pool membership rather than user or location.

**Around 5,000 users and beyond.** Authentication configuration has to be enforced in code, because manual consistency across many host pools is not achievable. A KDC proxy becomes a service with its own availability requirement rather than a server someone built.

---

## Chapter Close

**What was completed**
You can separate the three authentications, configure single sign-on correctly, and work three real authentication failures end to end with commands and evidence.

**What you should test**
No new lab resources are created. Run the read-only commands from section 4 in any lab environment that has an AVD host pool so the authentication flow and checks are familiar.

**What comes next**
Chapter 9 covers Conditional Access and MFA for AVD, including the sign-in frequency behaviour that produces the "it prompts me every hour" complaint.

**Interview preparation carried forward**
Q20 is asked constantly. The three stage framing is what makes the answer sound like experience rather than reading.
