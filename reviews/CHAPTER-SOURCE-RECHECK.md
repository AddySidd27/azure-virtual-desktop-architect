# Chapter source recheck, 17 October 2026

> Single reviewer, no independent pass. Microsoft Learn read through the Learn fetch and search tools on 17 October 2026. Nothing was executed in Azure. This page records **what was and was not re-read**. A chapter that is not listed under "Re-read" has **not** been freshly verified in this pass and still rests on the 16 October 2026 review in its own review record.

## Re-read on 17 October 2026

| Chapter | Learn page | Scope of the check | Result |
|---|---|---|---|
| 4 | [RDP Shortpath](https://learn.microsoft.com/en-us/azure/virtual-desktop/rdp-shortpath) (full page) | Managed and public network modes, ports, ranges, TURN range, first-found rule, security statement, symmetric NAT | Four wording corrections, symmetric NAT added. See the [Ch4 record](ch04-review-record.md) |
| 8 | [Configure single sign-on](https://learn.microsoft.com/en-us/azure/virtual-desktop/configure-single-sign-on) (full page) | Five tasks, app ID, roles, KB minimums, consent prompt limits, Kerberos server object, host pool property, client list | Client list and external identity requirement added. See the [Ch8 record](ch08-review-record.md) |
| 9 | [Enforce MFA with Conditional Access](https://learn.microsoft.com/en-us/azure/virtual-desktop/set-up-mfa) (full page) | App IDs (`9cdead84-...`, `270efc09-...`, `50e95039-...`, `0af06dc6-...`), two-policy structure, sign-in frequency table, Every time rule, per-user MFA, Security Defaults, authentication flow | Matches, except the sign-in frequency table in the chapter still named the Microsoft Remote Desktop app beside Windows Cloud Login. Learn's table lists only Windows Cloud Login. Corrected |
| 11 | [Required FQDNs and endpoints](https://learn.microsoft.com/en-us/azure/virtual-desktop/required-fqdn-endpoint) (full page) | Required and optional endpoint tables, service tags, platform addresses and ports, US Government differences | Ports and platform addresses match. **Error found and fixed:** the chapter and Lab 3 named `oneocsp.microsoft.com` and `catalogartifact.azureedge.net` as endpoints without a service tag. Learn lists service tags for both (`AzureFrontDoor.FirstParty`, `AzureFrontDoor.Frontend`), and lists `azkms.core.windows.net` only with the generic `Internet` tag. The Chapter 4 table was already correct |
| 10 | [Configure Start VM on Connect](https://learn.microsoft.com/azure/virtual-desktop/start-virtual-machine-connect), [Create and assign a scaling plan](https://learn.microsoft.com/azure/virtual-desktop/autoscale-create-assign-scaling-plan), [Azure built-in roles](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles) (search excerpts, not full pages) | Power On and Power On Off role purposes, Start VM on Connect scope and prerequisites, autoscale scope sentence | Matches. Learn now calls the older "lower scope breaks Start VM on Connect" guidance incorrect, which the chapter already reflects. The autoscale scope conflict (U35) is unchanged |
| 7 | [Introduction to Microsoft Entra Kerberos](https://learn.microsoft.com/entra/identity/authentication/kerberos), Azure Files Entra Kerberos and the two FSLogix Entra pages (search excerpts, not full pages) | Cloud-only identity support wording, Settings catalog note for multi-session, `LoadCredKeyFromProfile`, no line-of-sight requirement, RC4 to AES-SHA1 notice, six-month service principal password note | Consistent with the chapter. Learn's Entra Kerberos introduction still labels the cloud-only scenario "(Preview)", which the chapter's existing currency flag covers (U13) |

## Not re-read in this pass

Chapters 1 (beyond the retirement paragraph link), 2, 3, 5, 6 and 12, and the parts of Chapters 7, 10 and 11 not listed above (for example the Private Link section of Chapter 11, session host configuration roles in Chapter 10, and the join model material in Chapter 7). They keep their 16 October 2026 status and caveats from [REVIEW-REGISTER](../REVIEW-REGISTER.md).

## Follow-up outside Chapters 1 to 12

Chapter 13 is on hold and was not changed. It states that several required endpoints have no service tag. That is true for the entries Learn marks N/A, but it should be re-read against the table when Chapter 13 is reviewed.
