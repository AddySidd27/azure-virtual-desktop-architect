# Audit 11 - Phase 2: Citation Integrity Check and Labs 5-10

**Date:** August 2026
**Trigger:** Phase 2 of the publication remediation. Part A is the focused citation-integrity check requested before new content. Part B is the Labs 5-10 build, completing the lab sequence to a working, end-to-end AVD deployment.

---

## Part A - Citation integrity check

Full detail in [Audit 10](audit-10-citation-integrity-check.md). Summary:

- All 25 chapters confirmed to carry an Official References section (was already a chapter-contract requirement, verified rather than assumed).
- The six highest citation-density files read in full end to end.
- One genuine gap found: `appendices/intune-avd-support-matrix.md`, a ten-section reference table with 39 originally-cited claims backed by only 5 links positioned once at the bottom of a 167-line file. Fixed with nine section-level `*Source:*` lines, each naming the specific Microsoft Learn page for that section's claims, using only URLs already present in the file's own reference list.
- Zero claims required rewriting as original prose (none had drifted from correct attribution), and zero claims were found unverifiable.

---

## Part B - Labs 5-10

### What was built

| Lab | Markdown | Terraform module | New Azure resources |
|---|---|---|---|
| 5 - Profile Storage | [`labs/lab-05-storage.md`](../labs/lab-05-storage.md), 333 lines | `terraform/lab05-storage` | Premium `FileStorage` account (ZRS), file share, private endpoint, private DNS zone + link + A record, share-level RBAC |
| 6 - FSLogix | [`labs/lab-06-fslogix.md`](../labs/lab-06-fslogix.md), 216 lines | None (see reasoning below) | None. Configures host-side registry settings and validates share mechanics against Lab 5 |
| 7 - Core AVD Objects | [`labs/lab-07-avd-host-pool.md`](../labs/lab-07-avd-host-pool.md), 167 lines | `terraform/lab07-avd-core` | Host pool, workspace, desktop application group, association, role assignment, registration token |
| 8 - Session Hosts | [`labs/lab-08-session-hosts.md`](../labs/lab-08-session-hosts.md), 249 lines | `terraform/lab08-session-hosts` | Session host VM, NIC, domain-join extension, AVD agent DSC extension |
| 9 - Application Delivery | [`labs/lab-09-application-groups.md`](../labs/lab-09-application-groups.md), 168 lines | `terraform/lab09-app-delivery` | Second (RemoteApp-preferred) host pool, application group, association, role assignment, published application |
| 10 - Operations | [`labs/lab-10-operations.md`](../labs/lab-10-operations.md), 234 lines | `terraform/lab10-operations` | Log Analytics workspace, diagnostic settings on the Lab 7 host pool, a scaling plan |

**Total new content:** 6 lab files (1,367 lines), 5 new Terraform modules (Lab 6 deliberately has none), all committed with `README.md` and `terraform.tfvars.example` per module.

### Why Lab 6 has no Terraform module

FSLogix is host-side configuration — registry values and exclusions applied to a Windows machine — not an Azure resource. Session hosts do not exist until Lab 8. Rather than invent a Terraform resource with nothing to declare, Lab 6 produces the exact configuration script Lab 8 applies, and proves the underlying storage mechanics (VHDX create/mount/dismount) against the Lab 5 share using the Lab 4 domain controller as a stand-in Windows machine. This is stated as a deliberate sequencing decision in the lab itself, not left as an unexplained gap.

### Coherence with the existing environment

Every new module follows the conventions already established in Labs 2-4, verified before writing anything: the `<abbreviation>-<workload>-<environment>-<region>-<instance>` naming pattern, the same tag set (`environment`, `workload`, `owner`, `costCenter`, `deletionDate`, `managedBy`), the same `data` source pattern for cross-lab references (no `terraform_remote_state` is used anywhere in this repository, including the pre-existing modules — cross-lab resources are looked up by name via `data` blocks, and the new modules follow that exactly), and the same `.tfvars.example` / sensitive-output conventions.

**Cross-lab dependencies, made explicit rather than implicit:**

- Lab 5 depends on Lab 3 (VNet, storage subnet) and Lab 4 (DC for AD auth and DNS).
- Lab 6 depends on Lab 5 (the share) and produces the script Lab 8 consumes.
- Lab 7 depends only on Lab 2 (deliberately no network dependency — control-plane objects).
- Lab 8 depends on Labs 3, 4, 5, 6 and 7, and is where they all converge — this is stated explicitly in the lab's own dependency table.
- Lab 9 depends on Lab 7 (workspace, via `data` source) and repeats Lab 8's session-host pattern for a second pool, deliberately not abstracted away this early in the sequence.
- Lab 10 depends on the whole chain and validates it end to end.

**A design decision surfaced by this cross-lab consistency check, not hidden:** Lab 7's host pool was built with `preferred_app_group_type = "Desktop"` (matching Chapter 3's guidance on setting this correctly at creation). Lab 9 needs a RemoteApp-preferred pool. Rather than change a live setting Lab 7 explicitly warns against changing, Lab 9 creates a second host pool — which is also the more realistic production pattern demonstrated in Project 10. This is called out in both labs, not silently worked around.

### Terraform validation

```
### lab05-storage — HCL parse: PASS — 7 resources, 3 data sources, 13 variables, 4 outputs
### lab07-avd-core — HCL parse: PASS — 6 resources, 1 data source, 8 variables, 4 outputs
### lab08-session-hosts — HCL parse: PASS — 4 resources, 3 data sources, 17 variables, 3 outputs
### lab09-app-delivery — HCL parse: PASS — 5 resources, 3 data sources, 7 variables, 2 outputs
### lab10-operations — HCL parse: PASS — 3 resources, 3 data sources, 8 variables, 2 outputs
```

Run with `terraform-config-inspect`, the same real HashiCorp tool used in the Phase 1 report, for the same reason: the Terraform CLI remains unavailable in this environment, and `terraform-config-inspect` checks structure and syntax, not provider-schema correctness. **`terraform fmt`, `terraform init -backend=false`, and `terraform validate` were not run against these modules, and this report does not claim they were.** The `.github/workflows/terraform-check.yml` workflow added in Phase 1 will run the real commands against all eight modules (three existing plus five new) on the next push or pull request touching `terraform/`, using `hashicorp/setup-terraform` in GitHub's runner environment, which has registry access this sandbox does not.

**Secrets discipline maintained across all five new modules:** every sensitive input (`admin_password`, `registration_token`) is marked `sensitive = true` and sourced from `terraform.tfvars` (gitignored) or `-var`; every module ships `.tfvars.example` with placeholder values only; the `azurerm_virtual_desktop_host_pool_registration_info` resource's token output is explicitly marked sensitive with a comment warning against committing or pasting it; the domain-join extension keeps the admin password in `protected_settings`, not plaintext `settings`.

### Diagrams

Five small Mermaid diagrams added, one per lab (Labs 5, 7, 8, 9, 10), each showing only what that specific lab adds to the environment rather than re-drawing the whole thing every time — consistent with the "progressive disclosure" principle already established for this repository's diagram standard. No new solution-architecture SVG/drawio diagram was judged necessary for Labs 5-10: none of the six introduces network topology complex enough to justify it beyond what the existing Chapter 1 and Project diagrams already show: these labs assemble already-diagrammed components (session host, storage, host pool) rather than introducing new architectural relationships. Lab 10's diagram is the exception worth noting — it is the fullest of the five, showing the complete Labs 1-10 environment with every box captioned by the lab that built it, because that synthesis view earns its place as the closing lab's diagram.

### Validation run after the build

```bash
# 1. Local link check, whole repository
# result: 0 broken links

# 2. Citation artifact and drafting-instruction scan, new files
grep -rniE '<cite index=|\b(bring in|then explain|add what to do|TODO|TBD)\b' labs/lab-0[5-9]*.md labs/lab-10*.md
# result: 0 matches

# 3. Secret scan, new files
grep -rnoE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' labs/lab-0[5-9]*.md labs/lab-10*.md terraform/lab0[5-9]* terraform/lab10*
find terraform/lab0[5-9]* terraform/lab10* -name "*.tfvars" ! -name "*.example"
# result: 0 matches, no committed .tfvars

# 4. Full repository re-scan (not just new files)
# broken links: 0
# cite tags: 0
```

### Navigation updated

- README status table: Labs 1-4 → Labs 1-10, with the new per-lab cost tiers named explicitly (Labs 1-3 and 7 free, Lab 4 domain controller cost, Labs 8-9 session host cost).
- README Terraform section: module list extended from 3 to 8, validation commands extended to cover all 8.
- README roadmap: Labs 5-10 removed from "not yet built," replaced with Labs 11-20.
- SUMMARY.md: all six new lab files linked in place of their former `_(planned)_` markers; the Terraform index extended to 8 modules with the Lab 6 reasoning stated inline.
- **A lab-numbering conflict found and resolved.** The original book master plan allocated Lab 10 to "Workspace" and Lab 11 to "User Assignment," separate from Lab 14 ("Monitoring") and Lab 15 ("Scaling"). This Phase 2 build's explicit brief assigns Lab 7 to host pool *and* workspace, and Lab 10 to scaling *and* monitoring *and* operational validation — a genuine renumbering, not an oversight. SUMMARY.md now carries an explicit note explaining the change (workspace and user assignment folded into Labs 7 and 9; monitoring and scaling folded into Lab 10) rather than leaving two sets of lab numbers that silently disagree with each other. Lab numbers 10 and 11 in their original meaning are retired and not reused elsewhere in the plan.

---

## What Labs 1-10 now prove, end to end

Lab 10's own closing checklist is the honest test of this claim, not this report's assertion of it: every session host registers and shows `Available`; a real sign-in completes with a mounted FSLogix profile on both the Desktop and RemoteApp delivery paths; diagnostic data is confirmed flowing, not just configured; drain mode's reconnect exception is demonstrated, not just described; a scaling plan is applied and at least one power-state transition observed. That is what "Labs 1-10 form a technically coherent path to a working AVD user session" means operationally, and it is what a reader following the sequence in order should be able to check off for themselves.

---

## Remaining roadmap, updated

1. Labs 11-20 (DR testing, multi-region, security hardening, automation) — not started.
2. The 28 remaining solution-architecture diagrams (Chapters and Projects) — unchanged from Audit 08, not addressed in this pass.
3. Projects 03 and 11-15 — not started.
4. Curated interview index and standalone troubleshooting runbooks — not started; Labs 5-10 each added their own interview section but did not consolidate.
5. Live CI run of the Phase 1 workflows against a real pull request — not yet exercised.

---

## Known limitations of this pass

- `terraform validate` was not run against the five new modules, for the same environment reason as Phase 1; the structural check performed is named accurately and not conflated with it.
- External Microsoft Learn links referenced from the new lab files were not individually re-verified as currently reachable in this pass.
- The DSC artifact URL used in Lab 8's AVD agent extension (`wvdportalstorageblob.blob.core.windows.net/.../Configuration_1.0.02790.446.zip`) is flagged `[VERIFY BEFORE IMPLEMENTATION]` in both the Terraform comment and the lab text, because Microsoft has changed this specific URL before without a redirect; a reader applying this lab for real should confirm the current artifact reference against the Azure portal's own AVD deployment flow first.
- Marketplace image SKU strings (`win11-23h2-avd` in Lab 8) drift as new versions release; flagged the same way.

## Release-readiness verdict, restated

Labs 1-10 are now genuinely published and, per the Terraform structural validation and the internal consistency checks in this report, form a coherent chain rather than six isolated tutorials. Combined with Phase 1, the repository has moved further toward **Public MVP ready** against its own stated bar (Labs 1-10 ✅, 6+ projects ✅ at 9, curated 75-question interview index ❌, 5 standalone runbooks ❌, 8-10 hero diagrams ❌ at 4). **Still Private preview ready, not yet Public MVP ready** — the same verdict as Phase 1, for the reasons that remain open and are listed above, not repeated here as a new finding.
