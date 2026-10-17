# Validation Status

This page keeps architecture work, Terraform checks, and live Azure testing separate.

## Status definitions

| Status | Meaning |
|---|---|
| Documented | The topic or procedure is written and linked to its sources. |
| Architecturally reviewed | Requirements, dependencies, risks, and design decisions have been reviewed. |
| Terraform implemented | Terraform configuration exists for the documented design. |
| Format checked | Terraform formatting has been checked. |
| Provider validated | `terraform init` and `terraform validate` complete against the selected provider versions. |
| Plan reviewed | A Terraform plan has been generated and reviewed for a specific Azure environment. |
| Lab validated | The procedure has been run in an authorized Azure lab and evidence has been retained. |
| Production validated | The implementation has passed the organization's production approval and operational validation process. |

One status does not imply the next status. Valid Terraform can still fail because of permissions, quota, region availability, policy, DNS, identity, or an unsupported design choice.

## Current position

| Content | Current position |
|---|---|
| Chapters 1-25 | Documented. Topic-level sources are listed in `SOURCE-VERIFICATION.md`. Claim-level review status is recorded per chapter in [REVIEW-REGISTER.md](REVIEW-REGISTER.md): Chapter 1 has a recorded technical pass (verified with caveats) and a recorded readability pass (with caveats); Chapters 2 to 25 are Not Reviewed |
| Labs 1-20 | Documented; live validation must be confirmed per lab |
| Lab Terraform | Implemented; format checked and provider validated: repository CI (`terraform fmt -check`, `terraform init -backend=false`, `terraform validate`) passed for all 34 modules at commit `2a7b03b` (16 October 2026); see `TERRAFORM-VALIDATION.md`; the Terraform and provider versions used by that CI are not recorded; not plan reviewed and not applied |
| Northwind Parts A-H | Architecture documents complete as a fictional reference case study |
| Northwind Terraform | Reference implementation present; provider validated with the other modules (same CI evidence); not plan reviewed; not applied as one complete environment |
| Architecture case studies | Fictional design exercises; not customer delivery records |
| Troubleshooting runbooks | Documented procedures; AVD connectivity guidance checked; run commands in an authorized lab before calling them validated |
| Interview material | Study content derived from chapters, labs, and case studies |

## Mixed-validation rule

- Mark a component **lab validated** only when the exact procedure was run and evidence is available.
- A design-only case study cannot claim measured savings, completed migrations, tested failovers, production incidents, or customer outcomes.
- Label example requirements and calculations as assumptions or worked examples.
- Link Microsoft product support statements to current Microsoft Learn or Azure Architecture Center guidance.
- Check Terraform-specific behavior against official provider documentation.

## Evidence required for a lab-validated claim

Evidence can include:

- Sanitized Terraform plan or apply summary
- Azure resource inventory
- AVD host pool and session-host health output
- Successful user assignment and workspace feed check
- FSLogix profile-container creation and event-log check
- Scaling-plan assignment and observed scaling result
- Monitoring query result
- Cleanup or Terraform destroy result

Hide subscription IDs, tenant IDs, usernames, public IP addresses, passwords, tokens, and other sensitive information.

## Before publication

- [ ] Complete the Microsoft source review. Progress is tracked per chapter in [REVIEW-REGISTER.md](REVIEW-REGISTER.md).
- [x] Validate every Terraform module, including nested capstone modules (`terraform init -backend=false` and `terraform validate`; repository CI at commit `2a7b03b`).
- [ ] Resolve code-level `VERIFY BEFORE IMPLEMENTATION` items that block validation.
- [ ] Add evidence only for procedures that were actually tested.
- [ ] Keep design-only material clearly labelled.
- [ ] Confirm all local links and draw.io/SVG pairs.
- [ ] Run a secrets scan.
