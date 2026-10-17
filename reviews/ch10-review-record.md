# Chapter 10 review record

Chapter: `chapters/ch10-rbac-delegation-administrative-model.md`
Technical pass date: 2026-10-16. Process: single reviewer/process (Claude, in-session) performed both passes, so the passes are NOT independent. No Azure access; no role assignment or command was executed.

## Sources (retrieved 2026-10-16)

| ID | Page | Mode |
|---|---|---|
| S1 | Built-in Azure RBAC roles for AVD (virtual-desktop/rbac) | Full fetch |
| S2 | Delegated access in AVD (virtual-desktop/delegated-access-virtual-desktop) | Search excerpt only |
| S3 | Deploy AVD, assign users to an application group | Search excerpt only |
| S4 | Ch7 review (VM User Login with session host configuration) | Prior review |

## Claim log

| # | Claim | Outcome | Evidence / action |
|---|---|---|---|
| 1 | Contributor excludes user/group assignment; needs User Access Administrator; no compute access | Verified | S1 |
| 2 | Role descriptions for Reader, User, App Group, Workspace, Host Pool roles | Verified, Host Pool Contributor extended | S1: needs VM Contributor to create VMs, plus App Group and Workspace Contributor for portal deploy |
| 3 | User Session Operator: message, disconnect, sign out | Verified, extended | S1: scope recommendation and RG-scope read caveat added |
| 4 | Session Host Operator "without adding new hosts" | Corrected | S1: cannot add in portal; can add outside portal with valid token plus VM Contributor |
| 5 | Table complete | Corrected | Power On, Power On Off and Desktop Virtualization VM Contributor service roles added (S1) |
| 6 | Desktop Virtualization User "assigned automatically" | Reworded | S2/S3 show the role is assigned at app group scope when publishing; "automatically" softened |
| 7 | Entra join exception (VM User Login) | Caveated | Per S4 not required with a session host configuration. Currency flag added; U15 |
| 8 | Tier 2 needs VM Contributor | Caveated | Only needed for adding/managing VMs |
| 9 | Delegation tiers, PIM, resource locks, naming | Judgement | Design advice, not Learn claims |
| 10 | Scenarios, 80 users, 12 staff, 3,000 user model | Illustrative | Not real incidents; commands not executed |
| 11 | Terraform role assignment blocks | Unverified | Not run (no Terraform locally); comment added |

Outcome: Verified with caveats (claims 6, 7, 9, 10, 11; S2/S3 excerpt-only).

## Close-out pass, 2026-10-16

Issue dispositions affecting this chapter (details and Learn URLs in [UNRESOLVED-ISSUES.md](UNRESOLVED-ISSUES.md)): U15 open, U21 closed with caveat.

Changes: Service-role scope table added (autoscale subscription scope, Start VM on Connect any containing scope).

Checks rerun on the final local state are listed in [ASSET-VERIFICATION.md](ASSET-VERIFICATION.md). Source verification only; no Azure, Terraform, CLI, PowerShell or KQL execution.

## Third documentation pass, 17 October 2026

All role descriptions re-read against the RBAC page and match. The session host configuration role scope is sourced: the host pool managed identity needs Desktop Virtualization Virtual Machine Contributor on the resource group or subscription. Lab 10 read in full: destroy loop changed from auto-approve to a reviewed plan. Lab 8 cost wording corrected. U35 stays open. Evidence level: official-source verified for the claims named, static check only for labs. Not independently reviewed. Not executed in Azure.
