# Consolidated unresolved issues

Maintained during the 2026-10-16 chapter review. Each item lists what is in conflict or unverified so it is not re-investigated without new evidence. Process note: all reviews so far were single-process, not independent.

| ID | Topic | Detail | Affected | Status |
|---|---|---|---|---|
| U1 | Regional host pools | What's new says GA; data-locations page lists Regional scope only in Central US and East US 2; an article still says preview | Ch2, Ch3, ADRs | Conflict recorded |
| U2 | Session host configuration / SHC GA status | SHC is pooled only and not for Azure Local; GA unlabelled; some deploy-article variants say preview | Ch3, ADR | Unverified |
| U3 | Dynamic autoscaling | Autoscale scenarios page says preview; What's new says available | Ch15 | Conflict recorded |
| U4 | Ephemeral OS disks | Prerequisites lists as unsupported; other Learn pages describe use | Ch1, Ch5 | Conflict recorded |
| U5 | Windows 10 ESU on AVD | AVD ESU page says explicit policy enablement/manual install; cloud-VM ESU excerpt says none needed (excerpt only) | Ch5 | Conflict, unresolved |
| U6 | Azure verification for VMs, newer Azure Edition | Page not fetched | Ch5 | Unverified |
| U7 | Multi-session on Azure Local/Arc/hybrid | Not covered by pages reviewed | Ch5 | Unverified |
| U8 | Legacy client end dates after 28 Sep 2026 (Gov, 21Vianet, Classic) | Learn page unchanged after date passed | Ch6 | Unverified |
| U9 | Meta Quest preview vs listed platform | Overview vs get-started pages differ | Ch6 | Conflict |
| U10 | WVDConnections State values | Not enumerated on table reference | Ch4 | Unverified |
| U11 | Event 3701 / URL checker tool page | Page not fetched | Ch4 | Unverified |
| U12 | Intune version pinning for Windows App | Not verified | Ch6 | Unverified |
| U13 | Cloud-only identities with Azure Files/FSLogix: status | Entra joined page says fully supported; same page's profile section says hybrid; Entra Kerberos intro says Preview; Azure Files/FSLogix pages say public cloud only | Ch7, Ch20, Ch21 | Conflict |
| U14 | Cloud-only profile permissions | Entra Kerberos intro says Azure RBAC with no NTFS ACLs; FSLogix page configures permissions via Manage access tab | Ch7, Ch20 | Unresolved |
| U15 | VM User Login role with session host configuration | Learn says not required for SHC pools; reason not stated | Ch5, Ch7, Ch8 | Unverified mechanism |
| U16 | Entra Domain Services limits (Domain Admin, schema) | Not checked | Ch7 | Unverified |
| U17 | Ch8 identity architecture SVG/drawio | Draws Conditional Access at first sign-in only; with SSO, Windows Cloud Login is also a CA target. Caption note added, diagram not redrawn | Ch8, Ch9 | Open (diagram work, Phase 5) |
| U18 | KDC proxy with Windows App | Learn's KDC proxy page names the Windows Desktop client only | Ch8 | Unverified |
| U19 | Microsoft Remote Desktop app (a4a365df) as CA target | Removed from Ch9 because current Learn set-up-mfa page lists only AVD and Windows Cloud Login; `appendices/audit-01-chapter-contract.md` still lists it | Ch9, appendices | Unverified, cross-doc follow-up |
| U20 | Who requests the session host SSO token | Learn set-up-mfa says the gateway initiates SSO via Windows Cloud Login; Ch8 mermaid shows client requesting RDP token | Ch8 | Unverified, diagram wording |
| U21 | Per-feature scope guidance for AVD service roles (Power On, Power On Off, DV VM Contributor) not independently fetched | Role definitions verified on rbac page only | Ch10 | Unverified |
| U22 | Private Link setup page, private endpoint DNS and Entra join private-connectivity statements not fetched in Ch11 review | Overview page verified only | Ch11 | Unverified |
