# ADR-CAP-06: Finance FSLogix Profile Storage Isolation

**Status:** Partially accepted (RBAC), partially deferred (storage account)
**Date:** August 2026
**Applies to:** [Part F](../parts/part-f-avd-platform-architecture.md), section 9; `terraform/capstone-northwind/avd-platform/fslogix/`

---

## Requirement

Chapter 15 states, in the host pool design table: *"Isolation is a compliance requirement"* for the finance persona's host pool. Part F's audit found that this isolation was never extended to FSLogix profile storage - all five personas, including finance, share one storage account, one file share, and one combined RBAC group per region.

## Context

**What Chapter 15 actually says, and doesn't say.** The isolation requirement is stated at the host-pool level, in a one-line table cell, with no elaboration on what specifically it protects against or whether it extends to storage. It does not say "finance data must never coexist with other personas' data at rest."

**What SOX actually requires, per this book's own established scope.** [Part D, section 6](../parts/part-d-governance-security-foundation.md#6-sox-evidence-collection-in-scope-and-out-of-scope-made-concrete) already scoped this platform's SOX contribution precisely: access control evidence, segregation of duties, change management, and audit trail. SOX's IT General Controls are about who can access financial systems and whether that access is evidenced - not, unlike frameworks such as PCI-DSS, a mandate for physical or logical data segregation by business function.

**What actually isolates one user's profile from another's, regardless of storage layout.** Chapter 20's two-layer permission model - share-level RBAC plus per-user NTFS permissions on each FSLogix profile container - already means a task worker cannot open a finance user's profile VHDX, whether they share a storage account or not. The file-level isolation this model provides does not depend on account-level separation.

## Options considered

**Option A: Leave storage shared, but split the RBAC group.** Give finance its own share-level RBAC group, distinct from the combined group the other four personas currently use, while keeping one physical storage account and share. Cost: negligible - a second `azurerm_role_assignment`, no new resource. Operational complexity: negligible. Security benefit: real but narrow - it makes access review and audit-log filtering by persona genuinely easier ("show me every principal with SMB access to finance's share" becomes a direct query, not a shared-group audit), without changing the actual file-level protection, which was already adequate.

**Option B: A fully dedicated storage account, share, private endpoint, and RBAC group for finance.** Cost: one additional Premium/ZRS storage account per region (roughly proportional to finance's own 250-user share of capacity, not the full regional quota again) plus one additional private endpoint. Operational complexity: one more resource to patch, monitor, and back up per region - a real but modest addition, not a structural redesign, since it reuses the exact same module pattern already proven for the shared account. Security/audit benefit: adds blast-radius containment (a misconfiguration or compromise of the shared account can no longer expose finance's data as a side effect) and gives auditors a resource they can point to directly as "the finance boundary," which the shared design cannot offer as cleanly even with Option A's RBAC split.

**Option C: No change - accept the shared design as-is.** Rejected outright, not because the shared design is technically unsafe (it isn't - Option A's RBAC point about file-level isolation being independent of storage layout stands), but because it forgoes Option A's real, essentially-free audit-clarity improvement for no offsetting benefit.

## Security implications

File-level isolation is equivalent across all three options - this is the finding that keeps this decision honest rather than defaulting to "isolate everything, always." What differs is blast-radius scope (Option B only) and audit/access-review clarity (Options A and B both, B more completely than A).

## Operational implications

Option A: none beyond the RBAC split itself. Option B: a second storage account and private endpoint per region to patch, monitor, and include in backup scope - real but proportionate, using the existing module pattern rather than a new one.

## Cost implications

Option A: $0 incremental. Option B: a second Premium file share, sized to finance's own 250-user share of the total quota, not a full duplicate of the shared account's capacity - a modest, not a doubling, cost increase.

## Decision

**Option A is adopted now, unconditionally: finance gets its own share-level RBAC group, effective immediately in this pass.** This is the part of the question this book's own established SOX scope (Part D, section 6) can answer directly - access-control clarity is exactly what that section already commits to providing, and this is a free, unambiguous way to provide more of it.

**Option B (the dedicated storage account) is not adopted, and not rejected - it is preserved as an available, fully-built, opt-in path.** Whether Northwind's own compliance and audit function requires storage-account-level segregation, beyond what SOX's ITGC scope technically mandates, is a genuine business/compliance interpretation this engagement's source material does not settle - some organizations' internal policy goes beyond the letter of the regulation they're formally subject to, and only Northwind can confirm whether that's true here. **BUSINESS/COMPLIANCE DECISION REQUIRED.**

## Consequences

Finance's audit story is measurably better than before this ADR (a real, filterable RBAC boundary exists), without forcing a cost and complexity decision that this engagement isn't positioned to make unilaterally. If Northwind's compliance function later confirms Option B is required, the Terraform is already written and gated behind a single variable - not a redesign, a flag flip.

## Terraform changes required

`avd-platform/fslogix`: split the single `avd_users_group_object_id` variable into a finance-specific group and a combined group for the other four personas, with two `azurerm_role_assignment` resources instead of one. Add an `enable_finance_dedicated_storage` variable, default `false`, gating a second, finance-only storage account, share, and private endpoint - fully built, inactive until Northwind's compliance function answers the Option B question.
