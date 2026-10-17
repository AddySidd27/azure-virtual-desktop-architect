# Chapter 9 review record

Chapter: `chapters/ch09-conditional-access-mfa-zero-trust.md`
Technical pass date: 2026-10-16. Process: single reviewer/process (Claude, in-session) performed both passes, so the passes are NOT independent. No Entra tenant access; no policy was created or tested.

## Sources (retrieved 2026-10-16)

| ID | Page | Mode |
|---|---|---|
| S1 | Enforce Entra MFA for AVD using Conditional Access (virtual-desktop/set-up-mfa) | Full fetch |
| S2 | Configure single sign-on (Ch8 review) | Full fetch |
| S3 | Troubleshoot connections to Entra joined VMs (Ch8 review) | Full fetch |
| S4 | Troubleshoot SSO and Conditional Access for AVD (troubleshoot/azure/virtual-desktop/troubleshoot-sso-conditional-access) | Not fetched |
| S5 | Sign in to Windows VM with Entra (entra/identity/devices/howto-vm-sign-in-azure-ad-windows) | Not fetched |
Local diagram `ch09-conditional-access-app-targeting.svg` text inspected: two apps, two policies, order consistent with S1's flow.

## Claim log

| # | Claim | Outcome | Evidence / action |
|---|---|---|---|
| 1 | AVD app ID 9cdead84..., Windows Cloud Login 270efc09... | Verified | S1 |
| 2 | Microsoft Remote Desktop app (a4a365df...) as a session host CA target | Removed, Unverified | Not on S1 for AVD (ARM). Row removed. Still cited in `appendices/audit-01-chapter-contract.md`; see U19. |
| 3 | Naming trap (Windows Virtual Desktop) | Verified | S1 |
| 4 | Match policies except sign-in frequency; Policy 2 match or exceed | Verified, extended | S1 |
| 5 | Every time only on Windows Cloud Login; AVD app causes constant prompts | Verified | S1 (also 5 to 10 minute behaviour) |
| 6 | Background feed refresh and diagnostics upload silently fail | Verified | S1 |
| 7 | Frequency applies only when a new token is needed; reconnect after disruption re-prompts | Added, Verified | S1 |
| 8 | Per-user MFA error text and portal path | Verified | S1, S3 |
| 9 | Do not target AVD ARM Provider app; do not block Windows 365 app | Added, Verified | S1 |
| 10 | Security Defaults conflict; P1/P2 licence | Added, Verified | S1 |
| 11 | Policy 3 device compliance on both apps | Corrected | S1 warns compliance and location conditions can break SSO on session hosts. Re-scoped to AVD app first with test guidance. |
| 12 | Azure Windows VM Sign-In exclusion | Added, Verified | S1/S3; app ID from S3's KQL. |
| 13 | Break glass accounts and report-only mode | Marked general practice | Not on S1. |
| 14 | Scenario 3: missing WVDConnections rows from silent diagnostics failure | Inference flagged | S1 says upload fails silently; link to table rows is the chapter's inference. Query not executed. |
| 15 | Stale "Microsoft consolidating onto Windows Cloud Login" currency note | Rewritten | Dated flag. |
| 16 | Sign-in log and CA tab portal paths | Verified | S1 |
| 17 | SSO troubleshooting page | Unverified | S4 not fetched. |

Outcome: Verified with caveats (claims 2, 13, 14, 17).
