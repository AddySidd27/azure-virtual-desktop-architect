# Chapter 8 review record

Chapter: `chapters/ch08-authentication-flows-in-detail.md`
Technical pass date: 2026-10-16. Process: single reviewer/process (Claude, in-session) performed both passes, so the passes are NOT independent. No runtime execution; no Azure or Entra access.

## Sources (retrieved 2026-10-16, full fetch)

| ID | Page |
|---|---|
| S1 | Supported identities and authentication methods (virtual-desktop/authentication) |
| S2 | Configure single sign-on using Microsoft Entra ID (virtual-desktop/configure-single-sign-on) |
| S3 | Configure a Kerberos KDC proxy (virtual-desktop/key-distribution-center-proxy) |
| S4 | Troubleshoot connections to Microsoft Entra joined VMs (virtual-desktop/troubleshoot-azure-ad-connections) |
| S5 | Introduction to Microsoft Entra Kerberos (Ch7 review) |
Not fetched: set-up-mfa (Chapter 9), troubleshoot-sso-conditional-access, Entra Kerberos server object article. Local diagram files `diagrams/architecture/ch08-identity-architecture.svg/.drawio` text inspected.

## Claim log

| # | Claim | Outcome | Evidence / action |
|---|---|---|---|
| 1 | Three authentication phases | Verified | S1 names cloud service, remote session, in-session. |
| 2 | "Conditional Access is evaluated at stage 1 only; does nothing at stage 2 or 3" | Corrected (defect) | S2: Windows Cloud Login becomes a CA target with SSO; CA incl. MFA and sign-in frequency re-evaluated on reconnect; S4 references Azure Windows VM Sign-In app. Fixed in interpretation, Q20, takeaways, reality check, sequence diagram. |
| 3 | SSO needs four steps | Corrected | S2 lists five tasks including hiding the consent prompt. Step 1b added. |
| 4 | Windows Cloud Login app ID, portal path, cmdlets, scopes, property | Verified | S2 |
| 5 | Expected result text | Corrected | S2 shows no output from update; Get returns True. |
| 6 | Consent prompt: 15 hosts, 30 days, up to 10 target device groups, dynamic groups need P1 | Added, Verified | S2 |
| 7 | SSO prerequisites (roles, KBs, Graph 2.9.0, joined types, two-way trust, clients) | Added, Verified | S2 |
| 8 | Session lock default disconnect | Added, Verified | S2 |
| 9 | Domain admin accounts and RODC PRP | Added, Verified | S2 |
| 10 | Kerberos server object conditions and symptoms | Verified, extended | S2 |
| 11 | enablerdsaadauth=1 | Verified | S2 |
| 12 | RDP properties tab path | Unverified | S2 does not name the tab. Wording softened. |
| 13 | KDC proxy: property format, prerequisites, web client unsupported | Added, Verified | S3 |
| 14 | KDC proxy works with Windows App | Unverified | S3 names the Windows Desktop client only. VERIFY marker added. |
| 15 | Smart card and WHfB Kerberos-only; NTLM for passwords | Verified | S1 |
| 16 | Entra joined error messages and fixes | Added, Verified | S4 |
| 17 | TCP 88 for Kerberos | Not in fetched pages | General protocol knowledge; left as is. |
| 18 | Scenario 1 WVDConnections `State == "Connected"` | Corrected | State values Unverified (U10); filter removed; query not executed. |
| 19 | Scenario 1 fix script concatenation | Hardened | Adds missing semicolon; not executed. |
| 20 | Event Viewer paths (RdpCoreCDV, 4624) | Unverified | Standard Windows diagnostics, not on Learn pages fetched. |
| 21 | Scenario 3 klist and dsregcmd checks | Added | S5 describes `klist cloud_debug` and dsregcmd OnPremTgt/CloudTgt. Evidence text marked expected. |
| 22 | Scenario 3 title said "profile share" | Corrected | Body concerns an on-premises file share. |
| 23 | Diagram `ch08-identity-architecture` | Gap recorded | Draws CA at first sign-in only. Caption note added; SVG/drawio not redrawn (U17). Mermaid sequence updated. |

Outcome: Verified with caveats (claims 12, 14, 17, 20, 23).
