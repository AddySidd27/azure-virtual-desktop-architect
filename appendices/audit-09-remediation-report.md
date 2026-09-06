# Audit 09 - August 2026 Publication Remediation

**Date:** August 2026
**Trigger:** A full professional remediation pass ahead of public GitHub publication, MVP evidence, and MVP-track review. This is the report of what was actually done, with the commands used, not a claim of completion where none exists.

---

## 1. Executive summary

The repository was audited and remediated across citation artifacts, drafting-instruction leakage, broken links, README/SUMMARY accuracy, Chapter 24's Intune guidance, Terraform structural validation, security and privacy, and GitHub publication hygiene.

**What is genuinely fixed, with evidence:** all 348 unresolved citation artifacts removed; all 24 instances of reader-facing drafting-instruction leakage rewritten into natural prose; all 62 broken local links repaired or converted to honest plain-text `*(planned)*` markers; the duplicate Project 09 entry in SUMMARY.md removed; README and SUMMARY rewritten to match the repository's actual state; Chapter 24's Intune guidance corrected with newly verified Microsoft documentation on user-scope configuration; a repository-wide security scan run and found clean; three GitHub Actions workflows and LICENSE/CONTRIBUTING/SECURITY added; audit history moved out of primary reader navigation.

**What is not done, stated plainly:** Labs 5-10 do not exist. A consolidated 75-question interview index does not exist. Five standalone troubleshooting runbook files do not exist as separate files (the underlying incident content exists, embedded in chapters and projects). 28 of 32 solution-architecture diagrams remain Mermaid rather than rebuilt against official Azure icons. `terraform validate` was not run against live provider schemas because the Terraform CLI is unavailable in this environment; a real HCL structural check was run instead and is reported as such, not conflated with `terraform validate`.

**Verdict: Private preview ready.** Not yet Public MVP ready by the repository's own stated MVP criteria (Labs 1-10, 6+ projects, 75+ interview questions, 5+ runbooks, 8-10 hero diagrams). It is publication-safe in the sense that matters most: no exposed secrets, no broken navigation, no unresolved internal artifacts, and no claim in the README that overstates what exists.

---

## 2. Files changed

**Repository-wide (cite tag strip):** 33 files - see section 3 for the full list, all under `chapters/`, `scenarios/`, and `appendices/intune-avd-support-matrix.md`.

**Drafting-instruction rewrites:** 20 chapter files, plus `scenarios/project-05-entra-only-cloud-native.md` and `chapters/ch11-network-fundamentals-required-connectivity.md`.

**Chapter 24** (`chapters/ch24-intune-and-avd-endpoint-management.md`): Q68 simple answer corrected, Q69 fully rewritten, and a new subsection "Device scope is not the only scope" added with verified Microsoft guidance on user-scope Settings Catalog policies, user certificates, user-context scripts, the Entra Domain Services enrolment boundary, and the RemoteApp/App Attach Intune management gap.

**Broken links:** every `.md` file in the repository that contained a local link was scanned; fixes applied in-place across ~30 files (filename corrections plus planned-content conversions — see section 5).

**README.md:** fully rewritten.
**SUMMARY.md:** duplicate removed, header restructured, audit history moved to a new bottom section.
**appendices/book-master-plan.md:** status note added at the top.

## 3. Files added

- `LICENSE`, `CONTRIBUTING.md`, `SECURITY.md`
- `.github/workflows/link-check.yml`, `.github/workflows/terraform-check.yml`, `.github/workflows/mlc-config.json`
- `interviews/README.md`, `troubleshooting/README.md`, `capstone/README.md`, `bicep/README.md`, `assets/README.md` (all rewritten from one-line placeholders to honest status/purpose/roadmap pages)
- This file, `appendices/audit-09-remediation-report.md`

---

## 4. Citation cleanup result

**Before:** 348 `<cite index=` artifacts (each wrapping a claim in a `</cite>` closing tag) across 33 files (confirmed by scan, matching the reported estimate of ~309/32 closely enough that the discrepancy is normal drift as the repository grew after the estimate was made).

**Method:** the wrapper tags were stripped programmatically, leaving the enclosed prose intact. The enclosed text was already written as paraphrase or short quotation under the repository's own citation rules (quotes under 15 words, one quote per source), so no rewriting of the underlying claims was needed — the artifact was the HTML tag, not the content.

**Citation policy going forward**, documented in the README: rather than a footnote per sentence, each chapter carries a numbered **Official References** section listing the Microsoft Learn pages its claims are drawn from. This was already the existing pattern in every chapter; the change is that it is now the *only* citation mechanism, with the inline artifact removed.

**Verification:**

```bash
grep -rc -- '<cite ' --include="*.md" . | grep 'index='
# result: no output — zero matches repository-wide
```

**Confirmed: zero unresolved citation-wrapper tags remain.**

---

## 5. Broken-link report

**Before:** 62 broken local links (matching the reported estimate of ~63).

**Fixed by filename correction** (target existed under a different name), 6 links across 4 files:
- `appendices/intune-integration-note.md` → `appendices/structure-change-01-intune.md`
- `ch13-hybrid-connectivity-and-egress-control.md` → `ch13-hybrid-connectivity-egress-control.md`
- `ch17-session-host-sizing-and-compute-selection.md` → `ch17-session-host-sizing-compute-selection.md`

**Converted to plain text with a `*(planned)*` marker**, 56 links, all pointing at Labs 5-17 or Chapters 28/30-35/38/43/47, none of which exist yet. Example: a Markdown link reading "Lab 8" that pointed at the not-yet-written Lab 8 file became the plain text `Lab 8 *(planned)*`, with the link syntax removed entirely rather than left dangling.

**Verification:**

```bash
python3 - << 'EOF'
import re, pathlib
md_files = list(pathlib.Path(".").rglob("*.md"))
link_re = re.compile(r'\[([^\]]+)\]\(((?!https?://|mailto:)[^)#]+)(#[^)]*)?\)')
broken = []
for f in md_files:
    text = f.read_text(errors="ignore")
    for m in link_re.finditer(text):
        target = m.group(2)
        if not target or target.startswith("#"): continue
        resolved = (f.parent / target).resolve()
        try: rel = resolved.relative_to(pathlib.Path(".").resolve())
        except ValueError: continue
        if not (pathlib.Path(".") / rel).exists():
            broken.append((str(f), target))
print("remaining broken:", len(broken))
EOF
# result: remaining broken: 0
```

**Confirmed: zero accidental broken local links remain.** The `.github/workflows/link-check.yml` workflow added in this pass runs this same check on every pull request touching a Markdown file, so this does not regress silently.

**External links** were not exhaustively checked in this pass (no live network validation of every `https://learn.microsoft.com/...` reference was run). The added workflow includes a best-effort external link checker (`gaurav-nelson/github-action-markdown-link-check`) configured with retries and a permissive status-code allowlist, running with `continue-on-error: true` so a transient Microsoft Learn outage does not block merges.

---

## 6. Chapter 24 Intune correction

**What was wrong.** The Q68 simple answer said "scope everything to device groups," which overstates the actual Microsoft support boundary and was flagged as an interview answer a candidate could be corrected on.

**What was verified and added**, against current Microsoft Learn guidance (`learn.microsoft.com/en-us/intune/intune-service/fundamentals/azure-virtual-desktop-multi-session` and the multi-session solutions guide): user-scope Settings Catalog policies, user certificate profiles (Trusted, SCEP, PKCS), and user-context PowerShell scripts are all supported on Windows Enterprise multi-session and assign to user groups, not device groups — device-scope and user-scope are two separate, non-overriding paths, and mismatching them produces Error or Not applicable, the same signature as every other scope mistake in the chapter. Microsoft Entra Domain Services joined session hosts fall outside the supported enrolment paths (Intune enrolment for multi-session requires Entra join or Entra hybrid join; Domain Services join is neither), flagged with a `[VERIFY BEFORE IMPLEMENTATION]` marker since this is inferred from the documented enrolment requirement rather than a single explicit Microsoft statement. RemoteApp and MSIX App Attach are not currently managed through Intune, which is now stated explicitly with a pointer to where they are actually managed.

**Q69 rewrite.** The unfinished answer containing literal drafting instructions ("Add what to do about it," "Then the process point," "Bring in the reporting consequence") was rewritten into two complete, natural spoken answers.

---

## 7. Drafting-instruction cleanup

24 instances of instructional meta-text ("Bring in X," "Then explain Y") were found bleeding into published interview answers across 20 chapter files, plus 2 further instances of related patterns ("Say this," "The lesson for the reader") in 2 additional files. All 26 were rewritten into natural prose or, in the "lesson for the reader" case, renamed to match the repository's established `**Architect lesson.**` label convention used everywhere else.

**Verification:**

```bash
grep -rniE '\b(bring in|then explain|add what to do|say this|the lesson for the reader)\b' --include="*.md" chapters/ scenarios/
# result: no output — zero matches
```

Legitimate uses of similar phrasing remain only inside the authoring standards themselves (`CHAPTER-CONTRACT.md`, `PROJECT-STANDARD.md`, etc.), which are contributor-facing process documents, not reader-facing chapters, and were correctly left untouched.

---

## 8. README and SUMMARY status correction

- README rewritten with an accurate status table, a project-by-project table (9 published, 1 planned, 5 not started), honest cost language, and a roadmap section that names what is not yet built rather than implying it exists.
- The overstated opening claim in SUMMARY.md ("165 interview questions, 20 mock interviews, 14 decision frameworks") was replaced with a pointer to the README status table as the authoritative source.
- The duplicate `Project 09 - GPU and CAD` line in SUMMARY.md was removed.
- Audit history (9 audit files, 3 structure-change records) was moved out of the top of SUMMARY.md into a new "Contributor and project-management history" section at the bottom, explicitly labelled as not being part of reader navigation.
- `appendices/book-master-plan.md` received a status note at the top pointing to the README as authoritative, since the master plan describes the target scope rather than current state and was being read as a status document.

---

## 9. Terraform validation report

| Module | HCL parse (`terraform-config-inspect`) | `terraform fmt` | `terraform validate` |
|---|---|---|---|
| `terraform/lab02-foundation` | **Pass** — 6 resources, 5 variables, 2 outputs, providers `azuread`/`azurerm` | Not run | Not run |
| `terraform/lab03-network` | **Pass** — 22 resources, 9 variables, 4 outputs, providers `azuread`/`azurerm` | Not run | Not run |
| `terraform/lab04-identity` | **Pass** — 2 resources, 13 variables, 3 outputs, providers `azuread`/`azurerm` | Not run | Not run |

**Why `fmt` and `validate` were not run:** the Terraform CLI is not installed in the environment this remediation ran in, and the network allowlist available to that environment does not include `releases.hashicorp.com`. Rather than skip validation silently or falsely claim it passed, a real structural check was substituted: `terraform-config-inspect`, a genuine HashiCorp tool, was installed via `apt-get` and run against all three modules, confirming each parses as valid HCL with no syntax errors, and reporting the actual resource/variable/output counts above. This is evidence of structural correctness, not of provider-schema correctness — `terraform validate` additionally checks that every resource argument is valid for the pinned provider version, which requires the full CLI and registry access.

**The `.github/workflows/terraform-check.yml` workflow added in this pass runs the real `terraform fmt -check -recursive` and `terraform init -backend=false && terraform validate` per module on every push and pull request touching `terraform/`, using `hashicorp/setup-terraform`, which has registry access in GitHub's runner environment. That workflow, not this local pass, is where full validation will actually execute; this report does not claim it has run successfully yet, only that it is now in place to run automatically going forward.**

**Secret scan on Terraform specifically:** no `.tfvars` files other than `.tfvars.example` templates, no `.tfstate`/`.tfplan` files, no hardcoded subscription or tenant IDs, and no password/secret/token literal assignments were found in any `.tf` file. See section 12.

---

## 10. Diagram inventory and validation

Unchanged from [Audit 08](audit-08-repository-diagram-coverage.md), which remains the authoritative diagram tracking document: 48 diagrams total, 16 correctly kept as Mermaid (decision trees, sequences, object relationships), 32 requiring solution-architecture treatment, of which 4 are complete (Chapters 1 and the 3 Project 09 diagrams) using official Azure icons via the draw.io MCP connector against the locked [Diagram Style Guide](../DIAGRAM-STYLE-GUIDE.md), and 28 remain scheduled. No diagram work was performed in this remediation pass; it was explicitly out of scope for this pass, which focused on citations, links, README accuracy, Chapter 24, GitHub hygiene, Terraform, and security. See Audit 08 for the full coverage table and priority order.

---

## 11. Labs completed and tested

Labs 1-4 were not modified in this pass; they were already published and are unaffected by the citation strip (none contained cite tags) beyond the broken-link corrections described in section 5 (`lab-04-identity-integration.md` had two broken forward-references, now converted to plain text). Labs 5-20 remain unwritten. No lab was "tested" against live Azure in this pass; that was out of scope and would require an Azure subscription, which this environment does not have configured.

---

## 12. Security and privacy scan result

**Scope:** subscription IDs, tenant IDs, real email addresses, passwords, secrets, tokens, registration tokens, `.tfvars` files other than examples, committed Terraform state or plan files, and certificate/key files, across every Markdown and Terraform file in the repository.

**Commands used:**

```bash
grep -rnoE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' --include="*.md" --include="*.tf" --include="*.example" .
grep -rnoE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' --include="*.md" --include="*.tf" .
grep -rnoiE '(password|secret|api[_-]?key|client[_-]?secret)\s*=\s*"[^"]{6,}"' --include="*.tf" --include="*.md" .
find . -name "*.tfvars" ! -name "*.example"
find . -name "*.tfstate*" -o -name "*.tfplan" -o -name "tfplan"
find . -name "*.pem" -o -name "*.key" -o -name "*.pfx"
```

**Result: clean.** The only GUID-format strings found are Microsoft's own public, documented first-party application IDs (Azure Virtual Desktop `9cdead84-...`, Windows Cloud Login `270efc09-...`, Microsoft Remote Desktop `a4a365df-...`), which appear throughout Microsoft's own Conditional Access documentation and are meant to be public — not a leak, and left as-is with that context stated here for anyone re-running the scan and wondering why they were not flagged. Email addresses found were placeholder templates (`your.name@domain.com`). No password/secret/token literals, no non-example `.tfvars`, no state or plan files, and no certificate or key files were found anywhere in the repository.

`.gitignore` was reviewed and already correctly excludes `.terraform/`, `*.tfstate*`, `*.tfplan`/`tfplan`, `*.tfvars` (with `*.tfvars.example` explicitly un-ignored), `crash*.log`, `.terraformrc`/`terraform.rc`, `.terraform.lock.hcl`, `*.pem`, `*.key`, `.env`, and `secrets/`. No changes to `.gitignore` were needed.

---

## 13. Remaining roadmap items

In priority order, matching the README roadmap:

1. Labs 5-10 (profile storage through scaling/monitoring), taking the environment to a working, validated AVD deployment.
2. The remaining 28 diagrams, rebuilt to the locked Diagram Style Guide (tracked in Audit 08).
3. Projects 03 and 11-15.
4. A consolidated, curated interview index (75+ questions, cross-referenced by topic).
5. Five standalone troubleshooting runbook files, extracted from existing project incident content.
6. Live validation of the new GitHub Actions workflows against a real pull request (they are written and committed but have not yet run in CI as of this report).
7. Chapters 26-54 / their project-led equivalents.

---

## 14. Known limitations of this remediation pass

- `terraform validate` and `terraform fmt` were not executed locally; a real but different tool (`terraform-config-inspect`) was substituted and the distinction is stated explicitly rather than blurred. The new CI workflow will run the real commands going forward.
- External links (Microsoft Learn URLs cited throughout the book) were not individually re-verified as reachable in this pass; the new link-check workflow includes a best-effort external checker but it has not yet run.
- This pass did not re-verify every technical claim in Chapters 1-25 against current Microsoft documentation line by line; it verified and corrected the specific claim flagged (Chapter 24's Intune scoping guidance) and relied on the currency flags already present elsewhere in the book from earlier writing passes. A full line-by-line re-verification of 25 chapters was out of scope for this pass.
- Diagram rebuilding, new labs, the interview index, and standalone runbooks are explicitly not done, per sections 10, 11, and 13.

---

## 15. Release-readiness verdict

**Private preview ready.**

Reasoning: the repository is now safe to share privately (with a hiring manager, an MVP reviewer, a mentor) without the artifacts that would undermine credibility on first read — no citation debris, no broken links, no drafting instructions leaking into interview answers, and a README that tells the truth about what exists. It is not yet **Public MVP ready** by the repository's own stated MVP bar, which requires Labs 1-10, a 75-question interview index, 5 standalone runbooks, and 8-10 hero diagrams, none of which existed before this pass and only the diagram work has any progress (4 of the required 8-10). Declaring Public MVP ready today would repeat the exact problem this remediation pass was commissioned to fix: a status claim ahead of the evidence.
