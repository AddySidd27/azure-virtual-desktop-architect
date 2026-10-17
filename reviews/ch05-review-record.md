# Chapter 5 review record

Chapter: `chapters/ch05-operating-systems-multisession-licensing.md`
Technical pass date: 2026-10-16. Process: single reviewer/process (Claude, in-session) performed both passes, so the passes are NOT independent. No runtime execution; no Azure access.

## Sources (retrieved 2026-10-16)

| ID | Page | Mode |
|---|---|---|
| S1 | Windows Enterprise multi-session FAQ (azure/virtual-desktop/windows-multisession-faq) | Full fetch |
| S2 | Licensing Azure Virtual Desktop (.../licensing) | Full fetch |
| S3 | Prerequisites (.../prerequisites) | Full fetch |
| S4 | Windows Enterprise multi-session remote desktops, Intune (mem/intune/fundamentals/azure-virtual-desktop-multi-session) | Full fetch |
| S5 | Understanding ESU for Windows 10 on AVD (.../understanding-extended-security-updates) | Full fetch |
| S6 | Apply Windows license to session host VMs (.../apply-windows-license) | Full fetch |
| S7 | Troubleshoot Azure Windows VM activation problems | Full fetch |
| S8 | Enable ESU for cloud and VMs (windows/whats-new/enable-extended-security-updates-virtual) | Search excerpt only |
| S9 | Azure verification for VMs (Azure Local) | Not fetched |

## Claim log

| # | Claim | Outcome | Evidence / action |
|---|---|---|---|
| 1 | Multi-session definition, per-user licensing instead of RDS CAL | Verified | S1 |
| 2 | "Separate OS edition" quote | Corrected attribution | Wording is from S4 (Intune), not the FAQ. S1 calls it a virtual edition and adds ProductType = 3. |
| 3 | Intune Not applicable; update rings not applied | Verified, extended | S4: only Settings catalog, certificate and device-tunnel VPN templates; update rings unsupported; Autopilot/ESP/some remote actions unsupported. |
| 4 | Production use only inside AVD | Verified, extended | S1: licence terms, no on-prem KMS activation, no upgrade to multi-session, no in-place upgrade in pooled pools. |
| 5 | Azure Local / Arc / hybrid multi-session boundaries | Unverified | Not covered by S1-S7; VERIFY marker narrowed. |
| 6 | Licensing table (Windows Server row) | Corrected (defect) | S2/S3: Server uses RDS CAL with SA or RDS User SL, not per-user M365/Windows licence; per-user access pricing unavailable for Server; table now lists eligible licences and Server versions 2016-2025. |
| 7 | Server needs RDS license server | Added, Verified | S6 |
| 8 | Unsupported session host configurations | Added, Conflict | S3 lists ephemeral OS disks as unsupported; conflicts with other Learn content (see Ch1 record). |
| 9 | Azure Local activation wording | Verified; partial | S3 verbatim in substance. Azure Edition scope beyond 2022 Unverified (S9). |
| 10 | KMS endpoint TCP 1688 | Verified, extended | S7: public azkms.core.windows.net, US Gov kms.core.usgovcloudapi.net; error 0xC004F074. |
| 11 | Windows_Client licence type | Added, Verified | S6 |
| 12 | Windows 10 EOS and ESU on AVD | Corrected | S5: free automatic ESU on AVD; marketplace image retirement 14 April 2026 for the M365 Apps image. CONFLICT: S5 says explicit policy enablement/manual install needed, S8 excerpt says none needed. Unresolved. |
| 13 | Entra-joined prerequisites sentence | Re-scoped | Not on S3; deferred to Chapters 7 and 8. Marked as forward reference. |
| 14 | Intune portal path | Corrected | S4 path: Devices > By platform > Windows > Manage devices > Configuration. |
| 15 | Scenario 3 `slmgr.vbs /dlv` via Run Command | Corrected | Changed to `cscript //nologo` so output is returned; not executed. |
| 16 | "Activation has a grace period" | Downgraded | Not stated in S7; wording now says timings not verified. |
| 17 | D8s 8-10 users start point | Judgement | Labelled as the author's assumption, not a Microsoft figure. |

Outcome: Verified with caveats (claims 5, 8, 9, 12, 13, 17). Also fixed heading numbering (duplicate 8/9) and removed duplicate lessons.

Follow-ups: Ch24/appendix Intune support matrix should cite S4 limits; Ch17 should own sizing numbers.

## Close-out pass, 2026-10-16

Issue dispositions affecting this chapter (details and Learn URLs in [UNRESOLVED-ISSUES.md](UNRESOLVED-ISSUES.md)): U4 open, U5 closed with caveat, U6 closed with caveat, U7 closed with caveat.

Changes: ESU flag rewritten (automatic entitlement, EnableESUSubscriptionCheck scope); Azure Local activation and OS support paragraph rewritten; ephemeral OS disk flag points to U4.

Checks rerun on the final local state are listed in [ASSET-VERIFICATION.md](ASSET-VERIFICATION.md). Source verification only; no Azure, Terraform, CLI, PowerShell or KQL execution.

## Second source pass, 17 October 2026

Session-host-only licence scope, Intune enrolment prerequisites (device credentials, agent 1.0.2944.1400 or later, pooled ARM-deployed host pool, no cloned enrolled images, FSLogix RoamIdentity disabled) and per-user pricing limits added. Azure verification page re-read at its azure-stack path and still supports the chapter's statements. Baseline line updated.

Single reviewer, no independent pass. Scope and pages: [CHAPTER-SOURCE-RECHECK](CHAPTER-SOURCE-RECHECK.md). Source verification only; no Azure, Terraform, CLI, PowerShell or KQL execution.
