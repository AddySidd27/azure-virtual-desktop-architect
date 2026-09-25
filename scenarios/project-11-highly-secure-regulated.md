# Project 11 - Ashford Regional Health Network: Highly Secure and Regulated AVD

> **Fictional architecture case study:** Ashford Regional Health Network is not a customer delivery record. Requirements, measurements, costs, tests, and outcomes are worked examples or validation targets unless separate lab evidence is linked.

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Part XI:** Architecture Case Studies
> **Standard:** [PROJECT-STANDARD.md](../PROJECT-STANDARD.md)
> **Technical baseline:** August 2026
> **Concepts introduced here:** Zero Trust reference architecture, data and administrative security, Microsoft Sentinel integration, audit evidence collection

---

## Engagement brief

**What this represents.** A regional healthcare provider whose clinicians need access to patient records from AVD, whose compliance team answers to a healthcare regulator with specific technical control requirements, and whose previous AVD deployment passed its last audit only after two remediation cycles and a great deal of manual evidence-gathering. This engagement rebuilds the security posture so the next audit is a formality, not a fire drill.

**The business problem.** The regulator's most recent audit found three gaps: no consistent session-host hardening baseline, no working break-glass process (the documented one referenced an account that had been deleted), and no way to produce evidence of who accessed which patient record from which session without a multi-day manual log correlation exercise. A repeat finding in the next audit cycle carries a formal enforcement risk, not just a report.

**Constraints that cannot be designed away.** Patient record access cannot be interrupted during the security uplift, clinicians work in real time with live patients. The regulator's technical control framework is prescriptive on some points (MFA is mandatory, specific session timeout limits apply) and silent on others, where Ashford's own risk assessment has to fill the gap. Budget exists for this uplift because it is compliance-driven, but it is not unlimited, and user-experience complaints from clinicians carry real political weight, a control that makes charting slower has a downstream patient-safety argument against it, not just an inconvenience argument.

**Previously learned concepts applied.** Conditional Access and identity ([Chapters 7-9](../chapters/ch07-identity-architecture-foundations.md)), RBAC ([Chapter 10](../chapters/ch10-rbac-delegation-administrative-model.md)), network egress control ([Chapter 13](../chapters/ch13-hybrid-connectivity-egress-control.md)), redirection controls introduced in [Project 06](project-06-byod-remote-workforce.md), monitoring architecture from [Project 02](project-02-enterprise-850-users.md).

**New concepts introduced here.** A Zero Trust reference architecture applied specifically to AVD rather than as a generic framework, break-glass access done correctly, session-host hardening against a named baseline, Microsoft Defender for session hosts, Key Vault and encryption specifics, and (the part that actually closes the audit finding) how to produce access evidence on demand instead of reconstructing it under deadline pressure.

**Architectural decisions to make.** Whether Conditional Access alone is sufficient or whether a dedicated Privileged Access Workstation model is needed for the small number of administrators who can reach patient data infrastructure directly. How session recording and evidence collection are designed so they answer an auditor's question without becoming a surveillance program that damages clinician trust. Where watermarking and screen-capture protection are proportionate and where they are theatre.

**What could realistically go wrong.** A hardening baseline applied without testing breaks a clinical application that depends on a setting the baseline disables. Break-glass access, built correctly, is never tested until the day it is needed and fails silently. MFA fatigue leads clinicians to approve push notifications without reading them, which is a real attack path the compliance team has not considered. The audit evidence system itself becomes a data-protection liability if it is not scoped correctly.

**Validation and handover.** A working break-glass process, tested under simulated conditions, not just documented. A hardening baseline applied and validated against the actual clinical application set, not a generic checklist. An evidence report that answers "who accessed patient record X, from where, when" inside minutes, not days, demonstrated live to the compliance team before handover.

---

## 1. The situation as found

**Ashford Regional Health Network.** 2,100 clinical and administrative staff across six sites, using AVD to access an electronic health record system and several smaller clinical applications that cannot run natively on staff devices for licensing and data-locality reasons. AVD was deployed 20 months ago to a functional but security-shallow standard: it worked, users could sign in and chart, but almost nothing beyond MFA had been deliberately hardened.

**What the audit found, verbatim from the finding summary.**

| Finding | Severity | Detail |
|---|---|---|
| No documented session-host hardening baseline | High | Session hosts built from a default Windows 11 multi-session image with no CIS or Microsoft Security Baseline applied |
| Break-glass process non-functional | Critical | Documented emergency-access account had been deleted 8 months prior during an unrelated cleanup; no one had tested the process since |
| No efficient access-evidence capability | High | Producing "who accessed this record" required manual correlation across three separate log sources, taking 2-4 days per request |

**What already works and is preserved.** MFA is enforced tenant-wide and clinicians are used to it, this engagement does not touch MFA enrolment, only where and how Conditional Access applies it. The existing FSLogix and storage design (built correctly, following Chapter 20's guidance) is preserved unchanged.

---

## 2. Business and technical requirements

**Regulatory requirements, from the control framework.** MFA on every access to systems handling patient records, already met. Session timeout no longer than 15 minutes of inactivity for sessions with access to patient data, not currently met (existing timeout is 60 minutes). Audit trail of record access, retrievable on request within a defined SLA, not currently met at all.

**Business requirements.** No interruption to clinical access. No control introduced without a documented, risk-assessed reason, the compliance team wants defensible decisions, not maximum restriction for its own sake. A break-glass process that a non-technical on-call administrator can execute correctly from written instructions at 3 a.m.

**Explicit non-goal.** This engagement does not claim to make Ashford's AVD deployment compliant with the regulator's framework by itself. AVD is one control surface among several, network segmentation of the EHR backend, physical site security, staff training, and data classification elsewhere in the estate all contribute to the overall compliance posture. This project closes the three specific findings that relate to the AVD platform. It is not, and does not claim to be, a complete compliance solution on its own.

---

## 3. Zero Trust reference architecture, applied to AVD specifically

Zero Trust as a general framework is well documented and not repeated here. What matters for this engagement is what it means concretely for an AVD session accessing patient data, at each stage of the connection.

| Zero Trust principle | Generic meaning | What it means for this AVD session |
|---|---|---|
| Verify explicitly | Authenticate and authorise every access | Conditional Access evaluated at feed authorisation and again at session sign-in ([Chapter 9](../chapters/ch09-conditional-access-mfa-zero-trust.md)), not once at the start of the day |
| Least privilege access | Grant only what's needed | Clinical application access scoped per role via application groups, not one desktop with everything installed |
| Assume breach | Design for compromise, not just prevention | Session isolation, no lateral path from a compromised session host to the EHR backend without its own authentication, and evidence collection sufficient to reconstruct what a compromised session actually touched |

**The specific Conditional Access policy built for this engagement.** Compliant device required, MFA required, session control set to sign-in frequency of 15 minutes for the application group carrying patient-data access, directly implementing the regulatory 15-minute session timeout requirement at the identity layer rather than only at the RDP idle-timeout layer, because the identity-layer control cannot be bypassed by a session that stays technically connected but idle.

**Why device compliance matters here specifically.** A clinician signing in from a personally owned, unmanaged device onto a session that reaches patient data is a materially different risk than the same clinician on a hospital-managed workstation, even though the AVD session itself looks identical from inside. Device compliance is the control that distinguishes them, and it is why Project 06's device-trust-tier pattern (different pools, different policy, for different device trust levels) is directly reused here rather than reinvented.

---

## 4. Session-host hardening baseline

**The baseline chosen.** The Microsoft Security Baseline for Windows 11, applied via Intune security baselines, with documented deviations for the two settings that broke a clinical application during testing.

**The two deviations, documented rather than silently skipped.** The baseline's default PowerShell script execution restriction blocked a legitimate clinical application's install-time PowerShell hook; this was scoped down to allow signed scripts only, rather than disabled outright, preserving the security intent while unblocking the application. The baseline's default SMB signing requirement conflicted with a third-party imaging device driver that predates SMB signing support; this was flagged as a compensating-control risk (the device sits on an isolated VLAN with no direct session-host reachability) rather than silently exempted, and is scheduled for the vendor's next driver release.

**Why documenting deviations matters more than achieving zero deviations.** An auditor reviewing "100% baseline compliance" with no documented exceptions is, in practice, reviewing a baseline that was either never actually tested against real applications or was tested and had its failures quietly suppressed. Two documented, risk-assessed deviations with compensating controls is a stronger audit position than an implausible perfect score.

**Microsoft Defender for session hosts.** Microsoft Defender for Endpoint deployed to every session host via the same Intune policy pipeline used for the hardening baseline, with the AVD-specific exclusions Microsoft documents for FSLogix VHDX paths and the AVD agent process, applied from the start rather than discovered through a profile-attach failure investigation, avoiding the exact class of problem the antivirus-exclusion guidance in [Chapter 21](../chapters/ch21-fslogix-production-implementation.md) exists to prevent.

---

## 5. Redirection, watermarking, and screen-capture controls, applied proportionately

**Building on Project 06's pattern, not repeating it.** Project 06 established the redirection-control mechanics: RDP properties, Intune policy layering, the secure-defaults posture. This engagement applies the same mechanics to a different risk profile and makes different proportionality calls, which is the actual point worth recording.

| Control | Project 06's BYOD decision | This engagement's decision | Why different |
|---|---|---|---|
| Clipboard redirection | Blocked entirely for unmanaged devices | Enabled, one-way (host to client blocked, client to host allowed) for clinical roles | Clinicians need to paste from local reference material into charting; the risk of patient data leaving is what matters, not data entering |
| Drive redirection | Blocked, no exception | Blocked, no exception | Same reasoning as Project 06: no business case for writing patient material to an unmanaged device |
| Screen-capture protection | Not evaluated | Evaluated and rejected for general use | Breaks legitimate clinical workflows that rely on screenshotting a scan result into a referral note; a control that blocks a genuine clinical need creates workaround pressure worse than the risk it prevents |
| Watermarking | Not evaluated | Applied only to the small subset of desktops used by external auditors and vendors reviewing records under a data-sharing agreement | Proportionate to a specific, named higher-risk population rather than applied universally where it would add friction with no corresponding risk difference for regular clinical staff |

**The principle this table demonstrates.** The same control catalogue produces different decisions for different populations and different risk profiles. A security control applied because it exists, rather than because a specific risk assessment justified it here, is exactly the kind of finding an auditor is trained to probe, "why is this control here" needs a better answer than "it was available."

---

## 6. Break-glass access, built and actually tested

**What was found.** A documented process referencing an emergency-access account (`svc-breakglass-admin`) that had been deleted eight months earlier during an unrelated service-account cleanup, because nobody flagged it as exempt from that cleanup. The process had never been tested since the account was originally created, so its failure was discovered only during this engagement's audit, not during an actual emergency, which is the best-case way to discover a broken break-glass process, and still not good.

**The rebuilt process.**

1. Two break-glass accounts, not one, a single account is a single point of failure in exactly the scenario break-glass exists for.
2. Both accounts are excluded from Conditional Access policies that could themselves be the reason normal access is unavailable (this is the entire point of break-glass: it must work when the normal path does not), but retain a strong, unique, physically-secured (safe, dual-custody) password and are monitored with a high-priority alert on any sign-in attempt.
3. Both accounts are explicitly flagged `DoNotDelete` in a tag and documented in the service-account inventory that governs future cleanup exercises, so the exact failure mode that broke the previous process cannot recur silently.
4. The process is tested quarterly, on a schedule, by actually signing in with the break-glass account against a non-production validation path, not just reviewing the documentation.

**The first quarterly test, run before handover.** Found a second problem: the break-glass account could authenticate but had no assigned role on the AVD host pool resource group, because RBAC assignment had been treated as a separate, forgotten step from account creation. Fixed and re-tested successfully. This is presented as the outcome of the process working as designed, finding the gap in a scheduled test rather than during a real incident is exactly why the quarterly test exists.

---

## 7. Key Vault, encryption, and network segmentation

**Encryption at rest.** Azure Files (FSLogix profiles) and session host OS disks use platform-managed keys as the default, upgraded to customer-managed keys stored in Azure Key Vault specifically for the resource groups holding patient-data-adjacent storage, per the regulator's preference for demonstrable key control, Key Vault access is itself RBAC-scoped to the Platform Engineer role and logged.

**Network segmentation.** The AVD session host subnet reaches the EHR backend only through a specific, documented firewall rule set, not general connectivity to the clinical network. This follows the same pattern established in [Chapter 13](../chapters/ch13-hybrid-connectivity-egress-control.md) and the hero hub-spoke diagram, applied here with the EHR backend treated as its own protected zone rather than flat "on-premises" connectivity.

**Private endpoints and DNS.** Azure Files, Key Vault, and the Log Analytics workspace all sit behind private endpoints with no public network access. This was verified, not assumed, by attempting (and confirming failure of) a public internet connection attempt to each resource's endpoint as part of validation.

---

## 8. Monitoring, Microsoft Sentinel, and audit evidence, the finding that actually mattered most

**Why this section is the centre of the engagement.** The hardening baseline and break-glass process address real findings, but the evidence-collection gap is the one with a hard SLA implication and the one that consumed 2-4 days of staff time per request under the old process. Solving it well is the difference between this engagement succeeding and merely looking thorough.

**What was built.** Every AVD session sign-in, application launch, and file share access relevant to patient data flows into the existing Log Analytics workspace (already collecting AVD diagnostics per the Project 02 monitoring pattern), joined with Microsoft Sentinel for correlation and retention. A saved KQL query, not a general-purpose search, answers the specific question the auditor actually asks:

```kql
// "Who accessed record system X, from where, when" - the exact audit request pattern
WVDConnections
| where TimeGenerated between (StartTime .. EndTime)
| where SessionHostName in (PatientDataHostPool)
| join kind=inner (
    SigninLogs
    | where AppDisplayName == "EHR Application"
) on $left.UserName == $right.UserPrincipalName
| project TimeGenerated, UserName, SessionHostName, ClientIPAddress, DeviceDetail
| order by TimeGenerated desc
```

**Retention set to the regulator's minimum requirement plus a documented margin, not indefinitely.** Log Analytics retention for this workspace is set to match the regulatory minimum retention period exactly, plus 90 days as a working margin for investigations that span a retention boundary, not set to maximum retention by default. Retaining more data than required is itself a data-protection consideration the compliance team weighed deliberately: more retained access logs is more data that itself could be breached, and "we kept it because storage is cheap" is not a defensible answer to a data-protection question.

**The evidence report, demonstrated live before handover.** A request matching the exact pattern the previous audit took 2-4 days to answer manually was run against the new Sentinel-backed query during the handover meeting and returned a complete, exportable result in under three minutes: concrete, demonstrated proof that this finding is closed, not a claim that it is.

---

## 9. Validation

- Break-glass process tested quarterly, first test already run and its finding (missing RBAC assignment) fixed and re-verified.
- Hardening baseline applied to 100% of session hosts, two documented deviations with compensating controls, zero undocumented deviations.
- Access-evidence query demonstrated live, answering the exact audit-request pattern in minutes rather than days.
- Conditional Access session control confirmed enforcing 15-minute re-authentication on the patient-data application group, tested by an idle session and observing the forced re-authentication.
- Private endpoint public-access denial confirmed by attempted external connection, not assumed from configuration alone.

## 10. Rollback

The Conditional Access session-control policy was piloted against a 50-user subset for one week before full rollout, with a documented rollback (revert to the prior 60-minute setting) available if clinical workflow complaints exceeded a defined threshold, they did not, and full rollout proceeded on schedule. The hardening baseline's two deviations mean rollback of the baseline itself was never required; had a third application failure been found, the baseline rollout would have paused for that application's exception review rather than proceeding uniformly.

## 11. Risks accepted

The SMB-signing deviation for the legacy imaging device remains an accepted risk with a compensating control (VLAN isolation) until the vendor ships signing support, tracked with an owner and a review date, not left open-ended. Sentinel query performance on very large date-range evidence requests (a multi-year audit lookback) has not been tested and is flagged as a known gap for the next engagement cycle, since the current audit's evidence requests have all been within the retention window's normal operating range.

---

## 12. Interview questions from this engagement

### Q1. How do you decide which security controls to apply and which to skip, on a regulated platform?

**30-second answer.** Every control needs a specific risk it addresses, documented, not applied because it's available. Controls that block a genuine clinical workflow create workaround pressure worse than the risk they prevent, so proportionality has to be assessed per population, not applied uniformly.

**Two-minute senior answer.** The instinct on a regulated platform is to apply every available control, because more control feels safer and defensible. It's often the wrong call. Screen-capture protection sounds like an obvious win for a healthcare platform, and it was rejected here because it breaks a real clinical workflow, capturing a scan result into a referral note, and a blocked legitimate workflow creates pressure for staff to find a workaround, which is a worse security position than the risk the control was meant to prevent. The proportionality table in this engagement shows the same control catalogue producing different decisions for clinical staff versus external auditors, because the risk profile genuinely differs. An auditor asking "why is this control here" needs an answer better than "it's best practice", the answer has to be the specific risk it addresses for this specific population.

**Deep-dive points.** The one-way clipboard decision and the reasoning that separated "data leaving" risk from "data entering" risk. How the watermarking decision was scoped to a named higher-risk population rather than applied universally.

**Expected follow-up.** "What would make you add screen-capture protection back?", a documented incident or specific new regulatory requirement naming it, not a general security review recommending it.

**Common weak answer.** Listing every available AVD security control as something that should be enabled on a healthcare platform, without differentiating by actual risk or workflow impact.

**What the interviewer is testing.** Whether the candidate can reason about proportionate risk rather than defaulting to maximum restriction.

### Q2. Walk me through how you'd rebuild a broken break-glass process.

**30-second answer.** Two accounts, not one. Excluded from the Conditional Access policies that might themselves be the outage. Tagged to prevent accidental deletion. Tested on a schedule, not just documented.

**Two-minute senior answer.** The failure mode here is instructive: the process was documented, looked complete on paper, and had silently failed eight months before anyone found out, because nobody tested it and the account got swept up in an unrelated cleanup that had no way of knowing it was exempt. Fixing this needed more than recreating the account. It needed the account tagged so future cleanups can't repeat the mistake, and, the part that actually matters, a recurring test on a calendar, because the first test after rebuilding it found a second problem: the account could sign in but had no RBAC role assigned. Break-glass access is exactly the kind of control that looks fine until the one moment it's actually needed, and a test schedule is the only way to find that out before that moment instead of during it.

**Deep-dive points.** Why two accounts, not one. The specific tag and inventory process preventing recurrence. The dual-custody password-storage approach.

**Expected follow-up.** "How often should it be tested, and why that interval?", quarterly here, balanced against the operational cost of testing more often versus the staleness risk of testing less often; a genuinely higher-risk environment might justify monthly.

**Common weak answer.** Describing break-glass account creation without describing the ongoing test process, which is where this specific failure actually occurred.

**What the interviewer is testing.** Whether the candidate understands that access controls degrade silently over time and require active verification, not just correct initial configuration.

### Q3. An audit finding says "no efficient access-evidence capability." How do you actually close that, not just document a plan to close it?

**30-second answer.** Build the exact query that answers the exact question an auditor asks, then demonstrate it live against a real request, not a hypothetical one. A plan to build evidence capability is not evidence capability; a working query with a measured response time is.

**Two-minute senior answer.** The gap between "we have a monitoring solution" and "we can answer an auditor's specific question in minutes" is where most audit remediation quietly fails, because a general-purpose Sentinel deployment technically satisfies "we have logging" while still leaving someone doing a multi-day manual correlation when an actual request comes in. Closing this finding meant identifying the exact question that gets asked, "who accessed record system X, from where, when," and building a saved, tested query that answers precisely that, joined across the two log sources that actually matter for this question. The proof that mattered wasn't the query existing. It was running it live, during the handover meeting, against a request shaped exactly like the one that took 2-4 days manually before, and it returning a complete answer in under three minutes. That's the difference between a capability and a claim.

**Deep-dive points.** Why retention was set to the regulatory minimum plus a working margin, not indefinitely, as its own deliberate data-protection decision. The specific two log sources joined and why a single source wasn't sufficient.

**Expected follow-up.** "What if the auditor asks a differently shaped question than the one you built the query for?" the query pattern generalises (it's a join on user, host, and time window), but a genuinely novel question would need a new saved query, built and tested before being relied on, not assumed to work from the existing one.

**Common weak answer.** Pointing to a Sentinel deployment or a monitoring dashboard as evidence the finding is closed, without demonstrating the specific, timed answer to the specific audit question.

**What the interviewer is testing.** Whether the candidate distinguishes having the raw data from having the capability to answer a real question quickly, and treats a live demonstration as the actual bar for "closed," not a completed configuration checklist.

### Q4. A hardening baseline breaks a clinical application during testing. What do you do?

**30-second answer.** Scope the specific setting down to preserve the security intent without the breakage, document it as a deviation with its reasoning and a compensating control, and move on. Don't disable the whole control, and don't quietly exempt the application either.

**Two-minute senior answer.** Two settings in the Microsoft Security Baseline broke real clinical workflows during testing here, and the wrong response to either would have been the two extremes: disabling the control entirely because one application didn't like it, or quietly carving out an undocumented exception that an auditor would later find and rightly question. The PowerShell restriction, for instance, wasn't disabled, it was narrowed to allow signed scripts only, which kept almost all of the original protection while unblocking the specific legitimate install-time hook the application needed. The SMB signing conflict couldn't be narrowed the same way, because the device's driver genuinely predates signing support, so that one became a documented, risk-assessed deviation with a compensating control, an isolated VLAN, and a tracked date for when the vendor's fix should land. Two documented deviations with real reasoning is a stronger audit position than a suspiciously perfect compliance score, because a perfect score on a baseline this comprehensive usually means it was never actually tested against real applications.

**Deep-dive points.** Why 100% baseline compliance with zero documented exceptions would itself be a yellow flag to a competent auditor. The specific compensating control (VLAN isolation) chosen for the SMB signing deviation and why it was judged sufficient.

**Expected follow-up.** "What if a third application had also failed, and there was no good compensating control available?" the baseline rollout pauses for that specific host pool while the trade-off gets escalated to a risk owner, rather than proceeding uniformly and hoping nobody notices.

**Common weak answer.** Either disabling the control tenant-wide to avoid the conflict, or silently exempting the affected host without documenting why.

**What the interviewer is testing.** Whether the candidate treats a real-world conflict between security and functionality as something to reason through and document, rather than as a binary "security wins" or "functionality wins" decision.

### Q5. How do you decide which redirection and screen controls are proportionate for a specific user population?

**30-second answer.** By the actual risk that population presents and the actual workflow it would break, not by what the control catalogue offers. The same set of available controls produces different decisions for clinicians than for external auditors, because the risk profiles genuinely differ.

**Two-minute senior answer.** It's tempting, especially on a healthcare platform with a recent audit finding, to apply every available protective control by default, because it looks maximally cautious. It's usually the wrong instinct, and screen-capture protection is the clearest example from this engagement: it looked like an obvious win and was rejected after clinical pushback, because it breaks a real workflow, capturing a scan result into a referral note, and a blocked legitimate workflow creates pressure for staff to find a workaround, which is a worse security position than the risk the control was meant to prevent. Watermarking went the other way: not applied broadly, but applied specifically to the small population of external auditors and vendors reviewing records under a data-sharing agreement, because that population's risk profile is genuinely different and the control doesn't interfere with any workflow they need. The proportionality test is the same every time: what specific risk does this control address for this specific population, and does applying it break something they actually need to do.

**Deep-dive points.** The one-way clipboard decision (host-to-client blocked, client-to-host allowed) and the specific reasoning that separated inbound risk from outbound risk.

**Expected follow-up.** "How would you know if you'd got this wrong, in either direction?" a documented incident or a specific new regulatory requirement for the too-permissive direction; a spike in workaround behaviour or shadow IT for the too-restrictive direction.

**Common weak answer.** Applying the full available control set uniformly because it's available and sounds maximally secure, without checking it against actual workflow impact per population.

**What the interviewer is testing.** Whether the candidate can reason about proportionate risk per population rather than defaulting to either maximum restriction or a one-size-fits-all policy.

---

## 13. Official Microsoft references

- [Zero Trust guidance for Azure Virtual Desktop](https://learn.microsoft.com/en-us/azure/virtual-desktop/security-guide)
- [Microsoft Security Baselines](https://learn.microsoft.com/en-us/windows/security/threat-protection/windows-security-configuration-framework/windows-security-baselines)
- [Manage emergency access accounts in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)
- [Microsoft Sentinel documentation](https://learn.microsoft.com/en-us/azure/sentinel/overview)
- [Conditional Access session controls](https://learn.microsoft.com/en-us/entra/identity/conditional-access/concept-session-lifetime)
