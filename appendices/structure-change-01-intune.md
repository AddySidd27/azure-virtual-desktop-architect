# Structure Change 01 - Intune as a First-Class Topic

**Date:** August 2026
**Status:** Applied
**Chapter count impact:** none - remains 54
**Lab count impact:** none - remains 20

---

## Why this change

Intune is not an application-delivery detail. On a modern AVD design it is the answer to several separate architecture questions: how session hosts are configured, how they are hardened, how compliance is proved to Conditional Access, how applications land in the system context, and how updates are handled between image releases. In an Entra-joined AVD environment there is often no Group Policy at all, which makes Intune the *only* configuration mechanism.

Treating it as a paragraph inside the application chapter would have left a real gap - and it is a gap interviewers probe, because it separates people who have built Entra-joined AVD from people who have only built domain-joined AVD.

---

## What changed

### 1. Part VI renamed and rebalanced

**Before:** Part VI - Images and Application Delivery (Ch 23-26)

| Ch | Old title |
|---|---|
| 23 | Golden Image Engineering |
| 24 | Application Delivery Strategy |
| 25 | App Attach in Practice |
| 26 | RemoteApp Design and Line-of-Business Applications |

**After:** Part VI - Images, Endpoint Management and Application Delivery (Ch 23-26)

| Ch | New title | Change |
|---|---|---|
| 23 | Golden Image Engineering | Unchanged |
| **24** | **Intune and AVD - Endpoint Management Architecture** | **New dedicated chapter** |
| 25 | Application Delivery Strategy and RemoteApp Design | Old Ch 24 and Ch 26 merged |
| 26 | App Attach in Practice | Was Ch 25 |

**Justification for the merge.** RemoteApp is a delivery strategy, not a separate technology stack. The old Chapter 24 already had to introduce RemoteApp to explain the four delivery routes, and the old Chapter 26 repeated that framing. Merging removes duplication and keeps the chapter count at 54. This is the only content merge in the change.

### 2. Chapter 24 scope

- AVD + Intune reference architecture and where Intune sits relative to the AVD control plane
- Entra join, Entra hybrid join and what each means for enrolment
- Enrolment mechanics: device credentials, GPO-based auto-enrolment for hybrid, why enrolment must not be baked into an image
- Configuration profiles and the Settings catalog, device scope versus user scope
- Application deployment in system context, and why user context is an exception on multi-session
- Windows Update management, and why update rings do not apply to multi-session
- Compliance policies and their role in Conditional Access
- Security baselines and Endpoint Security policy
- Defender for Endpoint onboarding for session hosts
- Multi-session as a distinct OS edition, and the "Not applicable" problem
- The persistent-device assumption versus disposable session hosts - the central architectural tension
- Enterprise use cases and implementation sequence

### 3. Intune threaded through existing chapters

Intune material is placed where it belongs rather than duplicated. Each of these gets a scoped section, not a repeat of Chapter 24.

| Chapter | Intune content added |
|---|---|
| 7 - Identity Architecture Foundations | Entra join versus hybrid join, and what each enables for MDM enrolment |
| 9 - Conditional Access, MFA and Zero Trust | Device compliance as a Conditional Access signal for session hosts |
| 18 - Session Host Lifecycle | Enrolment at deployment, orphaned device records, device cleanup rules, drain-remove-rebuild instead of wipe |
| 23 - Golden Image Engineering | Why an enrolled machine must never be captured as an image |
| 25 - Application Delivery Strategy | Intune as one of four delivery routes, with the selection framework |
| 28 - Session Host Hardening | Security baselines, Endpoint Security policies, Defender for Endpoint onboarding |
| 32 - Day-2 Operations | Update strategy between image releases, policy change control, reporting |
| 45-47 - Troubleshooting | Enrolment failures, "Not applicable" policies, cloned-image errors, app context failures |
| 52 - Decision Frameworks | Two new matrices (see below) |

### 4. Lab roadmap

Lab numbering and count are unchanged. Intune content is added to existing labs.

| Lab | Change |
|---|---|
| Lab 8 - Session Hosts | Adds enrolment verification: confirm device appears in Intune, confirm device-credential enrolment, confirm no cloned-image error |
| **Lab 16 - renamed: Intune Management, Security Baselines and Hardening** | Was "Security". Now covers enrolment configuration, a device-scope configuration profile, a user-scope profile, a system-context app deployment, a compliance policy targeted at the multi-session device group, a security baseline, and Defender onboarding |
| Lab 14 - Monitoring | Adds Intune reporting and policy assignment status alongside AVD Insights |
| Lab 17 - Troubleshooting | Adds three Intune break/fix scenarios: user-credential enrolment failure, policy reporting Not applicable, app deployed in the wrong context |

### 5. Scenarios

| Scenario | Intune treatment |
|---|---|
| 5 - Hybrid Active Directory enterprise | GPO and Intune coexistence, and how to divide setting ownership |
| 6 - Entra ID-only environment | Intune as the sole configuration mechanism; the reference design for cloud-native AVD |
| 7 - Remote workers / BYOD | Compliance-driven Conditional Access |
| 13 - Highly secure enterprise | Security baselines, Endpoint Security, Defender, compliance evidence for audit |

### 6. Decision frameworks

Chapter 52 goes from 14 matrices to **16**:

15. **Group Policy versus Intune for AVD session hosts**
16. **Configuration Manager versus Intune versus co-management**

### 7. Interview roadmap

The total stays at **165 questions**. An **Endpoint Management** domain band is added inside Chapter 49, taking 12 questions redistributed from the over-weighted Intermediate and Senior Engineer bands. Sample coverage:

- When is Intune the only configuration option, and why?
- Why does a policy that works on laptops report Not applicable on a session host?
- How do you patch a pooled host pool, and why aren't update rings the answer?
- How does device compliance work for a machine that gets deleted every night?
- GPO or Intune for a hybrid-joined estate - how do you decide, and how do you prevent conflicts?

### 8. Diagrams

Four new diagrams, all original, each with the relevant Microsoft Learn reference alongside:

| Diagram | Chapter |
|---|---|
| AVD + Intune management architecture (control plane, MDM channel, session hosts) | 24 |
| Enrolment flow for Entra joined versus Entra hybrid joined session hosts | 24 |
| Policy application path: device scope versus user scope on multi-session | 24 |
| Configuration ownership boundary: image versus GPO versus Intune | 52 |

### 9. New appendix

**[Intune and AVD Support Matrix](../appendices/intune-avd-support-matrix.md)** - supported, unsupported and scenario-dependent capabilities, verified against Microsoft Learn and referenced from every chapter that touches Intune. This is the single lookup table that prevents the most common design errors.

---

## What did not change

- 54 chapters
- 20 labs, same numbering, same dependency chain
- 15 scenarios
- 193 interview questions in the final repository
- 20 mock interviews
- Northwind Global capstone
- Terraform-first IaC, Bicep for comparison
- The wave-based completion order
