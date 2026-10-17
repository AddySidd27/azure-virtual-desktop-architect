# Chapter 7 review record

Chapter: `chapters/ch07-identity-architecture-foundations.md`
Technical pass date: 2026-10-16. Process: single reviewer/process (Claude, in-session) performed both passes, so the passes are NOT independent. No runtime execution; no Azure access.

## Sources (retrieved 2026-10-16, full fetch)

| ID | Page |
|---|---|
| S1 | Supported identities and authentication methods (azure/virtual-desktop/authentication) |
| S2 | Microsoft Entra joined session hosts (azure/virtual-desktop/azure-ad-joined-session-hosts) |
| S3 | Enable Entra Kerberos for hybrid and cloud-only identities on Azure Files (azure/storage/files/storage-files-identity-auth-hybrid-identities-enable) |
| S4 | Introduction to Microsoft Entra Kerberos (entra/identity/authentication/kerberos) |
| S5 | Store FSLogix profile containers on Azure Files using Entra ID (fslogix/how-to-configure-profile-container-entra-id-hybrid) |
| S6 | Prerequisites for AVD (Ch5 review) |
Not fetched: Entra Domain Services docs, CAF identity recommendations, Lab 4.

## Claim log

| # | Claim | Outcome | Evidence / action |
|---|---|---|---|
| 1 | Users must exist in Entra ID; AD-only unsupported | Verified, extended | S1 (also AD FS standalone; UPN or SID match) |
| 2 | Same identity for service and host; CA bypass | Verified | S1 |
| 3 | Entra join benefits quote | Verified | S2 |
| 4 | Entra join does not support external identities (B2B) | Corrected (stale) | S1/S2: supported with OS/KB, SSO, client requirements and limits. |
| 5 | "Store app does not support Entra joined VMs" | Removed | Store app is end of support (Ch6); not in S2. |
| 6 | Azure Files hybrid-only vs broader | CONFLICT recorded | S2 intro says hybrid, cloud-only and external fully supported; S2 User profiles section says hybrid accounts; S4 labels cloud-only Preview; S3/S5 say cloud-only public cloud only. Unresolved (U13). |
| 7 | Entra Kerberos description | Verified | S4, S5 |
| 8 | Session hosts need no DC line of sight; DC needed to configure permissions | Corrected scope | S5/S3: applies to hybrid identities; cloud-only differs (File Explorer not supported; Manage access tab). |
| 9 | One identity source per storage account | Verified | S3, S4 |
| 10 | No partial TGTs to unsynced identities | Verified, clarified | S4 security considerations; cloud-only get Cloud TGT. |
| 11 | No cross-tenant; government external users unsupported; external limited to FSLogix on AVD | Verified | S3 |
| 12 | CloudKerberosTicketRetrievalEnabled via Settings catalog not OMA-URI | Verified | S3; S5 confirms multi-session supported via Settings catalog. |
| 13 | DCs close to AVD recommendation | Verified | S4 |
| 14 | Entra Kerberos setup traps (MFA exclusion, admin consent, 1,010 SID limit and manifest tag, LoadCredKeyFromProfile, SPN expiry, client prerequisites, RC4 to AES change) | Added, Verified | S3, S4, S5 |
| 15 | VM User Login role always required for Entra join | Corrected | S2: not required for pools using a session host configuration. Reason not stated. Role can be on VM, RG or subscription. |
| 16 | Host pool join type must be uniform; OS requirements; targetisaadjoined | Added, Verified | S2 |
| 17 | Entra DS "no Domain Admin, no schema extensions" | Unverified | Not in fetched pages; flagged. Intune unsupported with Entra DS joined hosts is Verified (S6). |
| 18 | Azure Local: only AD DS join | Added, Verified | S6 |
| 19 | Scenario 2 PowerShell | Adjusted | Filters role names, adds Scope; not executed. |
| 20 | Scenario 3 FSLogix Event Viewer path | Unverified | Path removed from claim; deferred to Ch21. |
| 21 | Lab 4 cost | Removed from chapter | Points to Lab 4. |

Outcome: Verified with caveats (claims 6, 8, 17, 20). Chapter 5 forward reference updated.

## Close-out pass, 2026-10-16

Issue dispositions affecting this chapter (details and Learn URLs in [UNRESOLVED-ISSUES.md](UNRESOLVED-ISSUES.md)): U13 closed with caveat, U14 closed, U15 open, U16 closed.

Changes: Lab 4 Step 7 now documents the selected identity-sync design (U30, U32); Lab 4 objective corrected to AD DS join.

Checks rerun on the final local state are listed in [ASSET-VERIFICATION.md](ASSET-VERIFICATION.md). Source verification only; no Azure, Terraform, CLI, PowerShell or KQL execution.

## Third documentation pass, 17 October 2026

Prerequisites and Entra joined session hosts pages read in full. The one-identity rule, three join models, UPN or SID rule, Entra Domain Services hosts not manageable with Intune, Server not enrollable in Intune and the Virtual Machine User Login requirement (not needed with a session host configuration) all match. The cloud-only Azure Files conflict flag remains. Lab 4 read in full: Bastion cost wording and the U24 note corrected, U24 stays open. Evidence level: official-source verified for the claims named, static check only for labs. Not independently reviewed. Not executed in Azure.
