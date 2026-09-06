# ADR-CAP-01: Microsoft Entra Connect Sync, Not Cloud Sync

**Status:** Accepted
**Date:** August 2026
**Applies to:** [Capstone Part C](../parts/part-c-identity-connectivity-foundation.md), section 3

---

## Context

Microsoft is running a strategic transition from Microsoft Entra Connect Sync (formerly Azure AD Connect) to Microsoft Entra Cloud Sync, with tenant migration notifications beginning July 2026 and Microsoft explicitly recommending Cloud Sync as the direction for most organizations. Northwind's AVD platform requires Hybrid Microsoft Entra Join for its session hosts - an existing, unchanged decision from [Chapter 7](../../chapters/ch07-identity-architecture-foundations.md) - which depends on whichever sync tool is chosen actually supporting hybrid join in production.

## What was verified, directly, before this decision

Cloud Sync's support for Hybrid Microsoft Entra Join is delivered via an AD-to-Entra device synchronization job, which reached public preview in July 2026. Independent sources describing hands-on use of this feature confirm it operates under supplemental preview terms: no SLA, no support commitment. A second, separate mechanism - client-initiated hybrid join via Microsoft Entra Kerberos, requiring no device object sync at all - reached preview in February 2026, and is specifically called out in Microsoft's own community guidance as suited to non-persistent VDI scenarios, which is directly relevant to AVD but is, itself, also still preview.

Microsoft Entra Connect Sync, by contrast, supports hybrid join today under full production support terms, with no preview caveat.

## Decision

Northwind's hybrid identity synchronization uses Microsoft Entra Connect Sync, installed on a dedicated, domain-joined server in `sub-northwind-identity`, in both regions' identity infrastructure.

## Reasoning

**Provider/tooling support.** The same standard this book already applied in [the Session Host Configuration ADR](../../appendices/adr-shc-vs-standard-host-pools.md): a required, production dependency should not sit on a capability carrying no SLA and no support commitment, regardless of how strategically Microsoft is positioning it as the future direction.

**Production supportability.** Northwind's AVD platform is a production replacement for an existing platform serving 3,200 users - not a pilot where a preview feature's rough edges are an acceptable cost of learning early.

**Portability and migration path.** Connect Sync and Cloud Sync are not designed to manage the same objects simultaneously - a future migration is a deliberate, scoped project, not an incidental side effect of this decision. Choosing Connect Sync now does not lock Northwind out of Cloud Sync later; it defers that migration to the point the specific capability this design depends on (hybrid join) is actually production-ready.

**Future migration path, named explicitly.** This decision is revisited when either the Cloud Sync device-sync hybrid-join path or the Entra Kerberos hybrid-join path reaches general availability with a full Microsoft support commitment. Given Microsoft's stated direction, this is treated as a "when," not an "if" - a planned future migration, not a permanent architectural position.

## Consequences

Northwind runs a tool Microsoft is actively moving customers away from, for the specific, stated reason that its replacement's relevant capability isn't production-ready yet. This is accepted as the correct trade-off today, with the review trigger stated above so the decision doesn't quietly become stale once that capability matures. Revisit this ADR at that point rather than assuming it remains correct indefinitely.
