# Chapter 1 review record

This is the evidence record for Chapter 1 in the [Review register](../REVIEW-REGISTER.md).

| Item | Value |
|---|---|
| Chapter file | `chapters/ch01-what-avd-actually-is.md` |
| Text reviewed | `main` at `86e083d8c6974eea4ffd2cc344feec1e5695cbf1` (unchanged since the initial commit of 2026-09-06 apart from section renumbering in `fc4fd0e`) |
| Review date | 2026-10-16 |
| Reviewer or process | One AI assistant (Claude) working under the repository owner's direction. No second human or second process reviewed this chapter. |
| Independence | Pass 1 and Pass 2 were done by the same process, one after the other. They are separate passes, not independent reviews. See the limitation at the end. |

## Pass 1: technical verification

### Sources

All pages were retrieved on 2026-10-16. "Full page" means the whole page was fetched through the Microsoft Learn documentation tool. The pricing page is on azure.microsoft.com, not Learn.

| # | Page title | URL | Read |
|---|---|---|---|
| S1 | What is Azure Virtual Desktop? | https://learn.microsoft.com/en-us/azure/virtual-desktop/overview | Full page |
| S2 | Licensing Azure Virtual Desktop | https://learn.microsoft.com/en-us/azure/virtual-desktop/licensing | Full page |
| S3 | Enroll in per-user access pricing | https://learn.microsoft.com/en-us/azure/virtual-desktop/enroll-per-user-access-pricing | Full page |
| S4 | Azure Virtual Desktop service architecture and resilience | https://learn.microsoft.com/en-us/azure/virtual-desktop/service-architecture-resilience | Full page |
| S5 | What's new in Azure Virtual Desktop? | https://learn.microsoft.com/en-us/azure/virtual-desktop/whats-new | Full page retrieved; entries were located by searching the retrieved text |
| S6 | Azure Virtual Desktop pricing | https://azure.microsoft.com/en-us/pricing/details/virtual-desktop/ | Full page |
| S7 | Host pool management approaches for Azure Virtual Desktop | https://learn.microsoft.com/en-us/azure/virtual-desktop/host-pool-management-approaches | Full page |
| S8 | Regional Host Pools | https://learn.microsoft.com/en-us/azure/virtual-desktop/regional-host-pools | Full page |
| S9 | Azure Virtual Desktop Hybrid Overview | https://learn.microsoft.com/en-us/azure/virtual-desktop/hybrid-overview | Full page |
| S10 | Azure Virtual Desktop on Azure Local | https://learn.microsoft.com/en-us/azure/virtual-desktop/azure-local-overview | Full page |
| S11 | Configure managed identity in Azure Virtual Desktop | https://learn.microsoft.com/en-us/azure/virtual-desktop/configure-managed-identity | Full page |
| S12 | What is Windows 365? | https://learn.microsoft.com/en-us/windows-365/overview | Full page |
| S13 | What is Windows 365 Flex? | https://learn.microsoft.com/en-us/windows-365/enterprise/introduction-windows-365-flex | Full page |
| S14 | Azure Virtual Desktop FAQ | https://learn.microsoft.com/en-us/azure/virtual-desktop/faq | Full page |
| S15 | Ephemeral OS disks on Azure Virtual Desktop | https://learn.microsoft.com/en-us/azure/virtual-desktop/deploy/session-hosts/ephemeral-os-disks | Full page |
| S16 | App Attach in Azure Virtual Desktop | https://learn.microsoft.com/en-us/azure/virtual-desktop/app-attach-overview | Full page |
| S17 | Access a Cloud PC | https://learn.microsoft.com/en-us/windows-365/end-user-access-cloud-pc | Full page |
| S18 | Migrate automatically from Azure Virtual Desktop (classic) | https://learn.microsoft.com/en-us/azure/virtual-desktop/automatic-migration | Full page |
| S19 | Migrate manually from Azure Virtual Desktop (classic) | https://learn.microsoft.com/en-us/azure/virtual-desktop/manual-migration | Full page |

### Claim log

Outcome values: Verified, Corrected, Conflict (Learn disagrees with itself), Unverified, Judgement (author opinion, not checkable against Learn).

| ID | Claim in Chapter 1 | Evidence | Outcome |
|---|---|---|---|
| C1 | AVD classic is closed to new tenants | S5, September 2023 entry: classic "now blocks users from creating new tenants" | Verified. Wording now says "since September 2023". |
| C2 | Classic support ends in September 2026 | S1, S5, S18, S19 banner: classic retires September 30, 2026; connections to classic resources will be blocked after retirement | Corrected to the exact date and past tense |
| C3 | Classic has actually been retired and blocked | The same banner was still in its pre-retirement form on 2026-10-16. No Learn page confirms that retirement took effect. | Unverified. The chapter tells the reader to confirm the real state of any classic environment. |
| C4 | Migration paths exist | S18 (automatic migration module) and S19 (manual migration) | Verified |
| C5 | Multi-session is "available only in Azure" | S1: multi-session is "exclusive to Azure Virtual Desktop". S10: Windows 10 and 11 Enterprise multi-session is supported on Azure Local. S9: multi-session is not supported on AVD Hybrid. | Corrected |
| C6 | Eligible licence list | S2 and S6 list Microsoft 365 E3, E5, A3, A5, F3, Business Premium, Student Use Benefit; Windows Enterprise E3, E5; Windows Education A3, A5; Windows VDA per user | Corrected (list completed) |
| C7 | Windows Server session hosts need an RDS CAL | S2, S6, S9: an RDS CAL with active Software Assurance (per-user or per-device), or an RDS User Subscription License | Corrected |
| C8 | Per-user access pricing is for external commercial use only, bills only users who connect, has no Office, Defender XDR or Universal Print | S2, S3 | Verified, no change |
| C9 | Windows 365 gives "one VM per user" | S12: Enterprise, Business and Government are 1:1 per user. S13: Flex lets several users share a Cloud PC, one concurrent session per licence. | Corrected to "one concurrent session per Cloud PC" |
| C10 | A Windows 365 Cloud PC is always allocated and does not scale down | S12: fixed per-user monthly cost for human-use Cloud PCs. S13: Flex in Dedicated mode powers off after sign-off. | Corrected: true for Enterprise, not for Flex |
| C11 | Windows 365 uses "fixed SKUs" | Not established by S12, S13 or S17. Cloud PC sizes exist but resize rules were not read. | Unverified. Marked `[VERIFY BEFORE IMPLEMENTATION]`. |
| C12 | Host pool type cannot be changed after creation | S14: "Once you create a host pool, you can't change its type." S7: the management approach cannot be changed later and a session host configuration cannot be added afterwards. S4, S8 and S15: deployment scope cannot be changed after creation. | Verified. Chapter now also names management approach and deployment scope. |
| C13 | MSIX App Attach retired 1 June 2025 | S5, March 2025 entry: MSIX App Attach "will be deprecated on June 1, 2025". The word "retired" is not on that page. | Corrected to "deprecated" |
| C14 | App Attach supports MSIX, Appx and App-V | S16 | Verified |
| C15 | Session host configuration is for pooled host pools | S7: "pooled host pools only". S9: not supported on AVD Hybrid. | Verified, detail added |
| C16 | Dynamic autoscaling is available for pooled pools with session host configuration | S5, June 2026 entry. The entry gives no GA or preview label. | Verified as "listed as available". No GA claim made. |
| C17 | Ephemeral OS disks are available for pooled pools with session host configuration | S5, June 2026 entry says available. S15 still describes preview limits and pooled-with-session-host-configuration only. S14 says they are not supported. | Conflict. Chapter says so. |
| C18 | RDP Multipath (redundant TCP) GA July 2026 | S5, July 2026 entry: "now generally available". May 2026 entry: GA rollout began. | Verified |
| C19 | Azure Arc session hosts announced May 2026 | S5, May 2026: public preview. S5, September 2026: "Azure Virtual Desktop Hybrid (Generally Available)", no day given. S9: supported operating systems and unsupported features. | Corrected. No GA day is stated. |
| C20 | (New row) Managed identity | S5, September 2026: generally available. S11: host pools with a session host configuration will require a managed identity in a future service update. No date is given. | Added with no date |
| C21 | (New row) Regional host pools | S5, September 2026: generally available. S8 still describes preview behaviour and two regions. S4 describes deployment scope as a current option. | Conflict. Chapter says so. |
| C22 | MSRDC retired March 2026 | S17: support for the Remote Desktop client for Windows (MSI) ends March 27, 2026; users should move to Windows App | Corrected to Learn's wording |
| C23 | Control plane versus customer split, reverse connect, no inbound ports | S1, S4 | Verified, no change |
| C24 | Citrix DaaS and on-premises comparison columns, operational skill and best-fit rows | No Learn page covers these. S3 notes per-user access pricing does not currently support Citrix DaaS and Omnissa Horizon Cloud, which the chapter does not claim. | Judgement. Labelled in the chapter. |
| C25 | Cost comparisons, thresholds such as 50 or 100 users, engineering-time remarks | No Learn page | Judgement. Labelled in the chapter. |
| C26 | Northwind figures and the three production scenarios | Fictional case study | Environment-specific, not checked against Learn |

### Reference fix

The chapter cited `app-attach-setup`, while `SOURCE-VERIFICATION.md` lists `app-attach-overview`. The chapter now cites `app-attach-overview` (S16, read in full). The `app-attach-setup` page was not read.

### Pass 1 outcome

Verified with caveats. The caveats are C3, C11, C17, C21 (Learn disagrees with itself or gives no confirmation) and C24, C25 (judgement, not Microsoft guidance).

### Post-change re-read

After the edits, each changed passage in the chapter was read again against the sources and claim log above. One overstatement was found and fixed: the classic paragraph said connections "are blocked", but Learn says they "will be blocked after retirement" (C2, C3). No other differences were found. This re-read was done by the same process that made the edits.

## Pass 2: readability and architecture quality

Date 2026-10-16. Same reviewer and process as Pass 1 (see the limitation below).

| Check | Finding |
|---|---|
| Contract structure (five questions, scenarios, Reality Check, scale, decision structure) | Present. Not re-reviewed in depth here. |
| Duplicate diagram callout | Two callouts stood before one diagram. The first was removed and the one with the editable-source link was kept. |
| Statement of what is Microsoft guidance versus author judgement | Added a source note under the comparison table and a note at the start of the scale section |
| Release-status table | Columns now say where the status comes from. Conflicts are shown rather than hidden. |
| Long dash characters | None added |
| Voice and structure | Existing voice, scenarios and section order kept. No rewrites. |
| Not done | A reader test with a person who did not write or edit the text. Interview answers were not read aloud. |

### Pass 2 outcome

Reviewed with caveats. The checks above passed, but the reader test and the read-aloud check were not done.

## Limitation

No independent reviewer was available. One process did both passes. Neither pass should be described as an independent review. To close this, someone other than the author of the corrections should read the changed sections and the claim log.

## Follow-up items (not changed in this review)

| Item | Existing evidence |
|---|---|
| `chapters/ch03-avd-object-model.md` and `chapters/ch15-host-pool-design-decisions.md` | Both repeat the host pool type claim. Chapter 15 (lines 398 and 411) states it. S14 supports it. Neither chapter has been reviewed. |
| `appendices/adr-shc-vs-standard-host-pools.md` and Labs 11 to 20 | They describe Regional Host Pools and session host configuration as Preview or unavailable as of 6 September 2026. S5 now lists regional host pools and several session host configuration features as generally available or available. Terraform and API status was not checked here. |
| `SOURCE-VERIFICATION.md` | Has no rows for Windows 365, AVD Hybrid, AVD on Azure Local, managed identity, regional host pools or the FAQ. Add them when the register is next updated. |
| Other 24 chapters | Not reviewed. |

## Close-out pass, 2026-10-16

Issue dispositions affecting this chapter (details and Learn URLs in [UNRESOLVED-ISSUES.md](UNRESOLVED-ISSUES.md)): U1 closed with caveat, U2 closed with caveat, U3 open (Learn conflict), U4 open (Learn conflict).

Changes: Ch1 status table rows for Session host configuration, Dynamic autoscaling, Ephemeral OS disks and Regional host pools rewritten with the Learn evidence.

Checks rerun on the final local state are listed in [ASSET-VERIFICATION.md](ASSET-VERIFICATION.md). Source verification only; no Azure, Terraform, CLI, PowerShell or KQL execution.

## Editorial pass, 17 October 2026

Inline source links added under the "How AVD got here" table and the classic retirement paragraph (What's new, host pool management approaches, App Attach, Regional host pools, AVD Hybrid, managed identity). The table contents were not re-verified on 17 October; they carry the 16 October retrieval date. The "three real decisions" scenarios are now labelled as illustrative composites. U3 and U4 are unchanged.

## Second source pass, 17 October 2026

Control plane list, outage behaviour, licensing limits (per-user pricing not for Windows Server, not supported for Citrix or Omnissa), contractor licence note, Hybrid row, Windows 365 Flex wording, Store app dates and Q1 answers corrected against full Learn pages. Baseline line updated.

Single reviewer, no independent pass. Scope and pages: [CHAPTER-SOURCE-RECHECK](CHAPTER-SOURCE-RECHECK.md). Source verification only; no Azure, Terraform, CLI, PowerShell or KQL execution.

## Third documentation pass, 17 October 2026

Every row of the history table re-checked against What's new. ARM integration is now dated June 2020 announce and July 2020 GA (the earlier text tied it to 2021). The 2019 WVD year is stated as resting on Learn's 'Fall 2019 release' wording. Single reviewer. No Azure execution. Evidence level: official-source verified for the claims named, static check only for labs. Not independently reviewed. Not executed in Azure.
