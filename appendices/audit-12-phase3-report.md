# Audit 12 - Phase 3 Report: Diagrams, Readability, Runbooks, Interview Index

> **Internal development record.** Not required reading. See [Development history](development-history.md) for a summary.

**Date:** August 2026
**Scope:** Draw.io hero diagrams, readability review, Labs 5-10 detailed review, five troubleshooting runbooks, professional interview index, Terraform/diagram consistency, final validation.
**Builds on:** [Audit 09](audit-09-remediation-report.md) (Phase 1), [Audit 10](audit-10-citation-integrity-check.md) and [Audit 11](audit-11-phase2-labs-5-10.md) (Phase 2). Nothing from those passes is repeated or undone here.

---

## 1. Executive summary

This pass delivered five complete, evidence-first troubleshooting runbooks; a 132-question interview index organised by topic, replacing 74 previously scattered chapter questions, 45 project questions, and 13 lab questions with one navigable structure; two new professional hero diagrams built with the draw.io MCP connector against official Azure icons; a Terraform/lab consistency check that found and fixed one real cross-shell scripting bug and one real naming inconsistency; a readability scan against the specific banned-word list, with every match manually verified in context rather than blindly stripped; and a full final validation pass.

**It did not deliver** all ten required hero diagrams (2 of 10 built to the new standard, 3 carried over from the prior pass, 5 still Mermaid pending upgrade), a line-by-line readability rewrite of all 25 chapters and 10 labs (a targeted scan was run instead, and is reported as such), or true visual rendering of the SVGs (this environment cannot render SVG as an image for inspection — a structural bounds check was substituted and is disclosed as different from visual QA).

**Verdict: Private preview ready.** Not yet Public MVP candidate, for reasons detailed in section 20.

---

## 2. Files created

**Troubleshooting (`troubleshooting/`):** `runbook-01-session-host-registration-failure.md`, `runbook-02-desktop-remoteapp-not-visible.md`, `runbook-03-fslogix-profile-attach-failure.md`, `runbook-04-slow-signin-logon-storm.md`, `runbook-05-connection-quality-shortpath-teams.md`. `troubleshooting/README.md` rewritten from a placeholder.

**Interview index (`interviews/`):** `interview-index.md` (132 questions, five mock scenarios). `interviews/README.md` rewritten.

**Diagrams (`diagrams/architecture/`):** `hero-05-fslogix-permission-flow.svg` + `.drawio`, `hero-10-final-mvp-lab-architecture.svg` + `.drawio`. `diagrams/architecture/README.md` rewritten with an honest visual-QA disclosure.

**This report:** `appendices/audit-12-phase3-report.md`.

## 3. Files modified

- `chapters/ch21-fslogix-production-implementation.md` through `ch25-application-delivery-remoteapp-design.md`: five interview questions renumbered (Q59-Q73 shifted to Q60-Q74) to resolve a genuine duplicate-Q59 collision found during the interview index build.
- `labs/lab-08-session-hosts.md`: Step 4's FSLogix configuration command rewritten. It mixed PowerShell here-string syntax (`@'...'@`) inside a bash double-quoted string in a way bash would not interpret as intended — a real bug matching exactly the class of error the Phase 3 brief asked to check for. Rewritten to match the working pattern already used correctly in Labs 4, 5 and 6 (bash double-quoting with `\$` escapes).
- `terraform/lab09-app-delivery/variables.tf`, `locals.tf` and `terraform/lab10-operations/variables.tf`, `locals.tf`: both modules hardcoded the literal string `"eus2"` in their `local.suffix` instead of referencing `var.location_short` as every other module does. Fixed to use the variable, matching the established convention. Both modules re-verified with `terraform-config-inspect` after the change; both still parse cleanly.
- `chapters/ch01-what-avd-actually-is.md` diagram (`ch01-shared-responsibility.svg`): fixed a footer positioned outside the canvas bounds (clipped/invisible text) and removed a leftover zero-size element with an orphaned, disconnected icon glyph and empty label.
- `README.md`: added an "Architecture at a glance" section with four diagram previews.
- `SUMMARY.md`, `diagrams/architecture/README.md`: index entries added for the two new hero diagrams; one broken link (referencing this report before it existed) found and fixed.

---

## 4. Simple-English review result

The brief's specific banned-word list was scanned across README, all 25 chapters, all 10 labs, and all 9 published projects:

| Pattern | Occurrences found | Action |
|---|---|---|
| obviously | 2 | Both read in context: "does not obviously correlate" and "do not obviously show" — correct grammatical use meaning "in an obvious way," not the filler pattern ("obviously, this means..."). No change. |
| clearly, (as a sentence-opener) | 0 | — |
| simply, (dismissive) | 0 | — |
| genuinely | 61 | Sampled for clustering. Highest single-file count is 5 (Chapter 1, several thousand words). No file showed the word used as a verbal tic; each instance checked functions as an honest qualifier ("a genuinely working environment," "genuinely need"), consistent with the book's stated voice of avoiding overclaiming. No change made on the basis of a keyword match alone. |
| crucial | 0 | — |
| robust | 0 | — |
| seamless | 1 | Appears inside a paraphrase of Microsoft's own Well-Architected Framework wording for AVD network requirements, not original prose. Left as an accurate reflection of Microsoft's documented language. |
| comprehensive | 0 | — |
| leverage | 1 | Used correctly as a noun ("commercial leverage"), not the verb-as-jargon pattern ("leverage this to achieve that"). No change. |
| TODO / TBD / placeholder | 1 | The word "placeholder" used correctly in a sentence contrasting real work against a placeholder, not a leftover marker. No change. |

**What this review did not do:** a full line-by-line rewrite of 25 chapters, 10 labs, and 9 projects for tone, sentence length, and repetition. That is a substantially larger task than a keyword scan, and doing it honestly would require reading roughly 250,000 words in full. This pass ran the specific scan the brief listed and manually verified every match; it did not attempt the broader subjective readability edit implied elsewhere in the brief. That gap is listed in section 17.

---

## 5. Diagram inventory

| # | Status | File | Standard met |
|---|---|---|---|
| 1. Complete enterprise reference architecture | Partial | `ch01-shared-responsibility.svg`/`.drawio` | Covers Microsoft-managed vs customer boundaries, session hosts, storage, identity, monitoring. Does not yet show hub-spoke networking, application delivery, or reverse connect labelling to the full 10-diagram spec |
| 2. End-to-end connection and authentication flow | Not built to hero standard | Mermaid sequence exists (`ch04-connection-flow.mermaid`), correct tool for an ordered sequence, but not the numbered-steps Draw.io version the brief specifies | Backlog |
| 3. Hybrid join vs Entra join comparison | Not built | Mermaid decision tree exists for join model choice; a side-by-side Draw.io comparison does not | Backlog |
| 4. Hub-spoke AVD network architecture | Not built | `ch13-avd-egress-architecture` SVG exists from the earlier diagram-tier pass and covers egress specifically; a full hub-spoke hero diagram does not exist | Backlog |
| 5. FSLogix and Azure Files permission flow | **Built this pass** | `hero-05-fslogix-permission-flow.svg`/`.drawio` | All four layers, private endpoint/DNS path, four failure points, Terraform-matched naming |
| 6. Golden image lifecycle | Not built | `ch23-image-build-pipeline` SVG exists from the earlier pass, covers the build/publish chain; the full lifecycle including pilot/rollback framing from the brief is not yet in Draw.io form | Backlog |
| 7. Monitoring and troubleshooting architecture | Not built | Backlog |
| 8. Multi-region HA/DR architecture | Not built | No multi-region project is published yet (Project 13 is planned); this diagram is more honestly built alongside that project | Backlog |
| 9. Terraform deployment and dependency architecture | Not built | The dependency chain is documented in prose (README Terraform section, each lab's README) but not diagrammed | Backlog |
| 10. Final MVP lab architecture | **Built this pass** | `hero-10-final-mvp-lab-architecture.svg`/`.drawio` | Every resource group, resource name, and service matches the actual Terraform across all 8 modules |

**Honest total: 2 of 10 required hero diagrams built to the new standard this pass. 3 more (Project 09's diagrams) already met an equivalent standard from the prior pass. 5 remain backlog.** Claiming 10 complete would not be true.

---

## 6. Draw.io source inventory

Five `.drawio` sources now exist, all built and rendered live through the `Draw.io:create_diagram` MCP tool against the official `mxgraph.azure.*` shape library and `icons.diagrams.net`/`app.diagrams.net` icon URLs: `ch01-shared-responsibility.drawio`, `hero-05-fslogix-permission-flow.drawio`, `hero-10-final-mvp-lab-architecture.drawio`, `project09-02-gpu-rendering-path.drawio`, `project09-03-production-architecture.drawio`. All five parse as valid XML (`xml.etree.ElementTree`, zero errors). `project09-01-current-state` has an SVG only, from before the `.drawio` pattern was established; noted as a gap rather than silently left inconsistent.

---

## 7. SVG rendering and visual QA result

**Disclosed limitation, stated plainly rather than glossed over:** this environment's image viewer does not support SVG as a renderable image format (only JPG, PNG, GIF, WEBP), so a true visual rendering and inspection, as the brief requires, was not possible here. Treating an SVG that merely parses as "visually validated" would misrepresent the check performed, so a different, real check was substituted and is reported as such rather than conflated with visual QA.

**What was actually done:** a structural bounds check across every committed SVG, confirming every element's coordinates fall inside the declared canvas `width`/`height`, plus a scan for zero-size or empty-label leftover elements. This caught two real, concrete bugs:

1. **`ch01-shared-responsibility.svg`:** the footer attribution text was positioned at `y=798` on a canvas declared `height=460` (later `760`) — entirely outside the visible area, meaning the "not a Microsoft diagram" attribution notice would not have rendered. Fixed by extending the canvas and repositioning the footer inside it.
2. **The same file:** a leftover zero-size (`width="0" height="0"`) element with an empty text label and a disconnected, orphaned icon path floating at an unrelated position — a stray artifact from an earlier edit. Removed entirely.

All five committed SVGs were re-checked after fixes and now pass the bounds and leftover-element checks. **This is not a substitute for opening each file in a browser and looking at it, which is recommended before treating any of these as final,** and that recommendation is stated in `diagrams/architecture/README.md` for anyone using this repository.

---

## 8. Diagram-to-Terraform consistency result

| Terraform resource | Lab | Diagram | Validation method | Cleanup dependency | Manual step |
|---|---|---|---|---|---|
| `azurerm_storage_account.fslogix` | 5 | hero-05, hero-10 | `terraform-config-inspect` (structural), name cross-checked against both diagrams | None until Lab 8/9 hosts are deployed | `Join-AzStorageAccountForAuth` (Lab 5 Step 4) |
| `azurerm_virtual_desktop_host_pool.lab` | 7 | hero-10 | Structural; name `hp-avd-lab-eus2-01` matches diagram exactly | Consumed by Labs 8, 9, 10 | None |
| `azurerm_windows_virtual_machine.host` | 8 | hero-10 | Structural; name `vm-avdlab-h1` matches | Depends on Labs 3, 4, 5, 7 | FSLogix registry config (Lab 6 output, applied via `az vm run-command`) |
| `azurerm_virtual_desktop_host_pool.remoteapp` | 9 | hero-10 (shown amber, as an exception) | Structural; name `hp-avd-remoteapp-lab-eus2-01` matches | Independent of Lab 7's pool by design | None |
| `azurerm_log_analytics_workspace.avd` | 10 | hero-10 | Structural; name `log-avd-lab-eus2-01` matches | None | None |
| `azurerm_virtual_desktop_scaling_plan.lab` | 10 | hero-10 | Structural; name `sp-avd-lab-eus2-01` matches | Attached to Lab 7's pool | None |

**Corrections made during this cross-check:** the two hardcoded-suffix bugs in Labs 9 and 10 (section 3) were found specifically by comparing the diagram's naming convention note against the actual `locals.tf` files and noticing the pattern did not match Labs 5, 7 and 8. No diagram was altered to make the code look better; the code was corrected because it was the one that was wrong, per the brief's explicit instruction.

**Not cross-checked in this pass:** the six chapter-level diagrams referencing FSLogix, host pool, and image concepts conceptually (not tied to specific Terraform) were not re-verified against Terraform, because they document the general architecture pattern rather than this specific lab deployment.

---

## 9. Runbook inventory

Five, all new this pass, all following the evidence-first structure (symptom, business impact, scope and recent-change questions, evidence collected before remediation, ranked hypotheses, fast triage tree, root-cause indicators, remediation, validation, rollback, prevention, escalation criteria, evidence for a Microsoft support case, official references): session host registration failure, desktop/RemoteApp not visible, FSLogix profile attach failure, slow sign-in/logon storm, connection quality/Shortpath/Teams. None opens with restart, reinstall, resize, or delete as a first step. Full detail in `troubleshooting/README.md`.

---

## 10. Interview-question count

**132 total**, indexed not duplicated: 74 from the 25 published chapters (renumbered Q1-Q74 after resolving the Q59 collision), 45 from the 9 published projects (5 each), 13 from Labs 5-10. Organised into 13 chapter-level topic groups plus per-project and per-lab sections. Exceeds the 75-question MVP target without inventing new questions.

## 11. Mock-interview inventory

Five, as specified: design a new AVD environment, investigate slow logons, resolve FSLogix failures, diagnose connection drops or latency, reduce cost without damaging user experience. Each links to the runbook, chapter, and project that provides the full supporting material rather than repeating it.

---

## 12. Link-check result

```
broken local links, whole repository: 0
```

Re-run after every change in this pass, not only at the end. Two broken links were found and fixed during the pass itself (both in newly-created files: the interview index's relative paths, and the architecture README's forward-reference to this report before it existed).

## 13. Citation scan

```
grep -rc -- '<cite index=' --include="*.md" .
```

Three matches, all confirmed by direct inspection to be legitimate self-references: this report's own description of the Phase 1 fix, the Phase 2 report's documentation of the exact grep command used to check for the pattern, and the GitHub Actions workflow's own prohibited-string check definition. Zero actual unresolved citation artifacts.

## 14. Drafting-instruction scan

```
grep -rniE '\b(bring in|then explain|add what to do|say this early|the lesson for the reader)\b' chapters/ scenarios/ labs/ troubleshooting/ interviews/
```

Zero matches.

## 15. Security scan

Repeated in full against the expanded repository (now including `troubleshooting/`, `interviews/`, and the new diagram sources): zero real subscription IDs, tenant IDs, passwords, secrets, or tokens. Zero non-example `.tfvars` files. The GUID pattern check still only matches Microsoft's own public first-party application IDs, correctly not flagged as a leak.

## 16. Terraform validation status

No change from Phase 2's position, restated because the brief asks for it explicitly in every report: **`terraform fmt`, `terraform init -backend=false`, and `terraform validate` were not run**, because the Terraform CLI remains unavailable in this environment and the network allowlist does not include `releases.hashicorp.com`. `terraform-config-inspect` (a genuine but different HashiCorp tool, checking HCL syntax and structure, not provider-schema correctness) was re-run against the two modules modified in this pass (`lab09-app-delivery`, `lab10-operations`) after the suffix fix, and both still parse cleanly. This is not claimed as equivalent to `terraform validate`. The `.github/workflows/terraform-check.yml` workflow added in Phase 1 will run the real commands on the next push or pull request touching `terraform/`.

---

## 17. Known limitations

- SVG visual rendering was not possible in this environment; a structural check was substituted and disclosed as such, not conflated with true visual QA.
- 8 of 10 required hero diagrams remain unbuilt to the new standard.
- The readability review was a targeted keyword scan against the brief's specific banned-word list, not a full line-by-line rewrite of all published prose.
- `terraform validate` still has not been run against real provider schemas.
- No live Azure subscription has been used to deploy and test Labs 5-10 end to end; all validation is structural (HCL parsing) and internal consistency (naming cross-checks), not a real deployment.
- External Microsoft Learn links referenced throughout the runbooks and interview index were not individually re-verified as currently reachable in this pass.

## 18. Manual Azure validation still required

Before this repository's labs can be called tested rather than reviewed: run all 8 Terraform modules against a real subscription in order (Lab 2 through Lab 10), confirm each `terraform apply` succeeds, walk every lab's manual steps (domain join verification, `Join-AzStorageAccountForAuth`, FSLogix registry application, session host registration, scaling plan behaviour) against real Azure resources, and time the true end-to-end path from Lab 1 to a working, monitored, scaled AVD sign-in.

## 19. Remaining work

In priority order: the 8 outstanding hero diagrams; a full manual Azure run-through of Labs 1-10; `terraform validate` in CI (already scheduled to run automatically); a full readability pass beyond the targeted keyword scan; Projects 03 and 11-15; Labs 11-20; live exercise of all three GitHub Actions workflows against a real pull request.

## 20. Honest readiness verdict

**Private preview ready.**

Reasoning: this pass added real, checkable value — five complete runbooks, a genuinely useful 132-question interview index, two new hero diagrams with real Azure iconography, and it found and fixed four concrete bugs (a broken bash/PowerShell script in Lab 8, a naming inconsistency across two Terraform modules, a duplicate question number across two chapters, and two SVG rendering defects) that a less thorough pass would have shipped. None of that adds up to **Public MVP candidate**, which by the repository's own stated bar requires all ten hero diagrams and a live Azure validation pass, neither of which happened here. Calling it a Public MVP candidate today would repeat the exact pattern these three phases have been correcting: a status claim ahead of the evidence.
