# Asset verification matrix, Chapters 1 to 12

Created 2026-10-16 for the end-to-end validation of Chapters 1 to 12. One row per chapter. Each column is recorded separately and uses these values: **Verified**, **Verified with caveats**, **Unverified**, **Not tested**, **Not applicable**.

Process note: one reviewer/process (Claude, in-session) performed every pass, so no pass is independent. Nothing here is a deployment claim. No Azure access was used.

## Tests actually executed

| Test | Scope | Result |
|---|---|---|
| `python3 tools/validate_repository.py` | whole repo | 0 FAIL after each batch |
| Internal link and anchor check (script) | all `*.md` | 0 broken |
| Mermaid render with `mmdc` (Chromium) | every in-chapter and standalone `diagrams/*.mermaid` used by Ch3 to Ch12 | all rendered without error |
| SVG render in headless Chromium, then visual inspection | diagrams listed per chapter below | rendered; defects fixed where listed |
| XML well-formedness of edited `.svg` and `.drawio` | edited diagrams | OK |
| HCL syntax parse (python-hcl2) | every `.tf` file under `terraform/` | 0 parse failures |
| `terraform fmt`, `init`, `validate`, `plan`, `apply` | any module | **Not run.** Terraform and OpenTofu are not installable here (U25) |
| Azure CLI, PowerShell and KQL commands in chapters and labs | all | **Not run.** Marked untested |

## Matrix

| Chapter | Content review | Diagrams | Labs and scenarios | Terraform/config | Execution tests | Cross-document | Caveats |
|---|---|---|---|---|---|---|---|
| Ch1 | Verified with caveats ([record](ch01-review-record.md)) | `ch01-shared-responsibility` redrawn (client to gateway arrow, outbound reverse connect from host, orchestration label, ownership box renamed); SVG and drawio rebuilt in step; rendered. Verified with caveats (own drawing, no Learn diagram) | Lab 1: provider list extended for AzureRM 5.0, `ARM_SUBSCRIPTION_ID`, stale 5.0.1 claim replaced. Verified with caveats | Version pin and lock files read; locks pin azurerm 5.10.0 | Rendered diagram only | Caption claiming official Azure icons corrected | U26 |
| Ch2 | Verified with caveats ([record](ch02-review-record.md)) | `ch02-avd-control-plane` flows 2 to 4 reordered to the Ch4 sequence (client to gateway, broker to host, host outbound to gateway); prose no longer cites arrows that are not drawn; rendered | Lab 1 (shared with Ch1) | Not applicable | Rendered | Ch2 prose and diagram agree | Diagram still has no drawn arrows (design choice) |
| Ch3 | Verified with caveats ([record](ch03-review-record.md)) | Object-model mermaid renders; standalone copy identical to chapter | Lab 2: "enforced tagging" corrected to applied tagging; baseline updated; module excerpts match repo. Verified with caveats | `terraform/lab02-foundation`: static read, six resource groups and seven tags match doc; HCL parses | Not run (U25) | Lab 2 outputs and names match Ch10 examples | U1, U2, U25 |
| Ch4 | Verified with caveats ([record](ch04-review-record.md)) | Connection-flow mermaid renders; stale standalone copy re-synced to chapter | Lab 3: UDP row, TCP 80 row, snippet resource references and for_each note corrected, DNS forwarding step added. Verified with caveats | `terraform/lab03-network`: static read; rules match doc; comment on TCP 80 corrected; no functional change | Not run (U25) | Lab 3 diagram `lab03-network-topology` rewritten to match the module (five 443 rules, UDP 3478, KMS, HTTP, other NSGs); drawio source was stale and is now in sync | U23, U24, U10, U11 |
