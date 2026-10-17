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
| Ch5 | Verified with caveats ([record](ch05-review-record.md)) | `ch05-session-host-os-decision` mermaid renders; standalone copy re-synced to chapter | Lab 8: FSLogix "not preinstalled" claim corrected to Learn (preinstalled, verify version); image and licence note added. Intune support matrix compared with the full Learn page: RemoteApp/MSIX app attach, Available intent, templates limited to Settings catalog/certificates/VPN Device Tunnel, FSLogix token roaming, host outside host pool added; an unsourced TPM remark marked `[UNVERIFIED]` | `lab08-session-hosts/session-hosts.tf`: image SKU 23H2 to `win11-25h2-avd` (23H2 Enterprise multi-session ends 2026-11-10), `license_type = "Windows_Client"` added, OUPath and DNS comments corrected | HCL parse only | Intune matrix now consistent with Ch5 limits; Labs 14, 19 and capstone still use the 23H2 SKU (U31) | SKU string and Windows_Client behaviour not deployed (U25); Ch5 Learn facts verified |
| Ch6 | Verified with caveats ([record](ch06-review-record.md)) | No dedicated diagram; client matrix referenced from Ch5/Ch8 diagrams | Lab 6: Hyper-V module, SYSTEM identity and SMB-path caveats added; Lab 8 Windows App sign-in step gated by the sync prerequisite | None specific | None | Lab 6 steps 2 and 4 depend on Lab 5 ACLs | Lab 6 commands untested |
| Ch7 | Verified with caveats ([record](ch07-review-record.md)) | Identity mermaid renders (via Ch8 asset) | Lab 5 Step 3 (share RBAC needs Entra-synced identities; default share-level permission documented), Step 4 (AzFilesHybrid `Join-AzStorageAccount`, replacing `Join-AzStorageAccountForAuth`), Step 6 (Learn-recommended ACLs via key-mounted `net use` and `icacls`) rewritten; Lab 8 prerequisite gap added (AD-only users cannot sign in via AVD) | `lab05-storage/storage.tf`: `azure_files_authentication` removed and ignored, avoids `AD` without `active_directory` block; `rbac.tf` note | HCL parse only | Contradiction between Ch7 sync rule and Labs 4 to 8 now recorded (U30, U32) | All Lab 5 steps untested; provider behaviour not run (U29) |
| Ch8 | Verified with caveats ([record](ch08-review-record.md)) | `ch08-identity-architecture` and `lab04-identity-topology` corrected earlier; `ch08-authentication-sequence` mermaid re-synced; `lab08-session-host-join` footer corrected (it claimed an exact match and an August verification) and re-rendered | Lab 7 gained Step 2b (Start VM on Connect role not created by the module); Lab 8 start-before-sign-in note; Project 04 and 05 read for Ch7/8 claims, no change needed beyond U20 | `lab07-avd-core/host-pool.tf`: `validate_environment` comment corrected, Start VM on Connect role gap documented in code | HCL parse only | Lab 7 registration key 24h 24h is within the limit stated on Learn's agent troubleshooting page (1 hour to 27 days); the maximum on the add-session-hosts page was not checked | U20, U28 |
| Ch9 | Verified with caveats ([record](ch09-review-record.md)) | Conditional Access content has no dedicated diagram; Ch8 sequence carries the CA touchpoints | Project 01 CA table read (matches Ch9); Project 11 corrected: CA sign-in frequency of 15 minutes was presented as the 15-minute idle timeout, replaced with session-layer limits and marked untested (U34) | Not applicable (no Terraform for CA in Ch1-12) | Not tested | Ch8 and Ch9 agree on SSO and Every time behaviour | U19, U34 |
| Ch10 | Verified with caveats ([record](ch10-review-record.md)) | No dedicated diagram | Lab 2 role references (Storage Blob Data Contributor) are data-plane and correct for the lab | `lab07-avd-core/rbac.tf` assigns Desktop Virtualization User at application group scope, consistent with Ch10; `lab10-operations/scaling-plan.tf` lacks the autoscale Power On Off Contributor assignment (Ch15 scope, recorded in U28) | HCL parse only | Ch3, Ch10 and Lab 7 agree on assignment scope | U28 |
| Ch11 | Verified with caveats ([record](ch11-review-record.md)) | `ch11-egress-enforcement-points` mermaid rendered with mmdc, no change needed | Lab 3 NSG rules identical to the Lab 11 hosts NSG apart from comments | `terraform/lab11-multiregion-network` read, consistent with Lab 3 | HCL parse only | CAF AVD topology reference marked deprecated (U33) | U33 |
| Ch12 | Verified with caveats ([record](ch12-review-record.md)) | `ch12-topology-decision` mermaid and the chapter's inline copy updated to the Learn triggers and rendered with mmdc | Lab 3 and Lab 11 compared; Ch12 section 5 now states Lab 11 is hub-less global peering and bypasses any hub inspection | `lab11-multiregion-network` address plan checked against the Ch12 sizing rules | HCL parse only | Scenario 2 arithmetic corrected; GatewaySubnet minimum corrected | U33 |

## Close-out pass, 2026-10-16 (final local state)

| Check | Type | Result |
|---|---|---|
| `python3 tools/validate_repository.py` | Static | 0 FAIL |
| Internal link and anchor check | Static | 0 broken |
| HCL parse (python-hcl2), `terraform/**/*.tf` | Syntax parse only, not Terraform validation | 232 files, 0 failures |
| XML well-formedness of every `diagrams/**/*.svg` and `.drawio` | Static | 0 failures |
| `mmdc` render of all 18 `diagrams/*.mermaid` and the Ch8 inline block | Render | 0 failures; Ch8 inline block identical to the standalone source |
| Ch8 SVG visual inspection after edit | Visual | Rendered in headless Chromium and viewed; flows 6 and 7 read correctly, no overflow |
| Repo grep, `win11-23h2-avd` in `.tf` | Static | 1 hit, a comment in Lab 8 listing the SKUs Learn offers; no resource uses it |
| Repo grep, `Join-AzStorageAccountForAuth` | Static | Only in places that cite it as obsolete or as a corrected record |
| Repo grep, autoscale role scope | Static | Project 07 corrected to subscription scope; Project 08 corrected to a scope containing the VMs |
| `terraform fmt`, `init`, `validate`, `plan` | **NOT RUN** | Terraform and OpenTofu cannot be installed here (U25) |
| Azure CLI, PowerShell, KQL, Cloud Sync, lab execution | **NOT RUN** | No Azure access; all such commands are marked `[UNTESTED]` |

Terraform files changed in this pass: `session-hosts.tf` in `lab14-active-active-hostpools`, `lab19-dr-failover` and `capstone-northwind/avd-platform/host-pools` (SKU `win11-25h2-avd`, `license_type = "Windows_Client"`). No provider, lock file or role assignment was changed.

Chapter rows above remain as written; the close-out dispositions per chapter are in each `reviews/chNN-review-record.md`.

