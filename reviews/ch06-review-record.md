# Chapter 6 review record

Chapter: `chapters/ch06-clients-and-the-endpoint-story.md`
Technical pass date: 2026-10-16. Process: single reviewer/process (Claude, in-session) performed both passes, so the passes are NOT independent. No runtime execution; no Azure access.

## Sources (retrieved 2026-10-16)

| ID | Page | Mode |
|---|---|---|
| S1 | Remote Desktop client overview (previous-versions/remote-desktop-client/overview) | Full fetch |
| S2 | What is Windows App? (windows-app/overview) | Full fetch |
| S3 | Compare Windows App features across platforms (windows-app/compare-platforms-features) | Full fetch |
| S4 | Get started with Windows App (windows-app/get-started-connect-devices-desktops-apps) | Full fetch saved to file; AVD Windows and web prerequisites sections read, other pivots not read |
| S5 | Prerequisites for AVD (unsupported RADC/MSTSC) | Full fetch (Ch5 review) |

## Claim log

| # | Claim | Outcome | Evidence / action |
|---|---|---|---|
| 1 | MSI and web client unsupported for public cloud from 27 Mar 2026 | Verified | S1 |
| 2 | MSI extended to 28 Sep 2026 for Gov, 21Vianet, AVD Classic | Verified, flagged stale | S1. Date had passed on review date; page unchanged. Current status UNVERIFIED. Chapter text that treated it as planning room corrected. |
| 3 | Store app end of support Sept 2025 | Verified | S1 |
| 4 | Web client Gov/21Vianet no date announced | Verified | S1 |
| 5 | Windows App covers AVD, W365, Dev Box, RDS, remote PC | Corrected | S2/S4: Windows App on Windows does not do RDS; browser does not do RDS or remote PC. |
| 6 | "Microsoft has said it is working to reach feature parity" | Removed, Unverified | Not found in S1-S4. |
| 7 | mstsc.exe is not the AVD client | Verified | S5: RADC and MSTSC not supported. |
| 8 | Browser requirements (12 months, AVC, WebGL) | Corrected attribution, Verified | S4 (Windows App web), not "older web client". Added minimum versions and 15 June 2025 date. |
| 9 | Platform differences (Shortpath, USB, monitors, screen capture protection, watermarking, Teams) | Added, Verified | S3 |
| 10 | Multipath client versions | Added, Verified | S3: 2.0.559.0 (UDP), 2.0.1069.0 (UDP+TCP). Behaviour itself to be reviewed in Ch14. |
| 11 | Redirections disabled by default; MAM not a substitute | Added, Verified | S3 |
| 12 | Store vs MSI update control for Windows App | Downgraded | Not verified; VERIFY marker. |
| 13 | Intune portal path in Scenario 1 | Unverified | Marked as typical layout, not checked against Learn. |
| 14 | "3,000 people... happened to a lot of organisations" | Removed | No source. |
| 15 | Lab 4 cost "$30 to $70 per month" | Removed from chapter | Lab 4 states ~$30/month for B2s; chapter now points to the lab. |
| 16 | Meta Quest support | Conflict | S2 lists it as a platform; S4 labels it preview. Left as unconfirmed. |

Outcome: Verified with caveats (claims 2, 12, 13, 16).

## Close-out pass, 2026-10-16

Issue dispositions affecting this chapter (details and Learn URLs in [UNRESOLVED-ISSUES.md](UNRESOLVED-ISSUES.md)): U8 open, U9 open, U12 open.

Changes: Re-checked 2026-10-16: Learn unchanged for U8 and U9, no pinning guidance found for U12; chapter text states each.

Checks rerun on the final local state are listed in [ASSET-VERIFICATION.md](ASSET-VERIFICATION.md). Source verification only; no Azure, Terraform, CLI, PowerShell or KQL execution.

## Second source pass, 17 October 2026

All Windows App platform, redirection, Shortpath, Multipath and browser statements match the full comparison and get-started pages. Store app wording and the stale status header corrected. U8, U9 and U12 unchanged.

Single reviewer, no independent pass. Scope and pages: [CHAPTER-SOURCE-RECHECK](CHAPTER-SOURCE-RECHECK.md). Source verification only; no Azure, Terraform, CLI, PowerShell or KQL execution.

## Third documentation pass, 17 October 2026

Windows App platform, redirection and Shortpath claims re-read. No new edit. U9 (Quest label) stays open. Evidence level: official-source verified for the claims named, static check only for labs. Not independently reviewed. Not executed in Azure.
