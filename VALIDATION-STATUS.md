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
| Chapters 1-25 | Documented; core service, identity, network, management, profile, Intune, image, and application topics checked against the sources in `SOURCE-VERIFICATION.md` |
| Labs 1-20 | Documented; live validation must be confirmed per lab |
| Lab Terraform | Implemented; Terraform 1.13.3 format and parse checks pass; provider validation must complete in GitHub Actions or an unrestricted workstation |
| Northwind Parts A-H | Architecture documents complete as a fictional reference case study |
| Northwind Terraform | Reference implementation present; not applied as one complete environment |
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

- [ ] Complete the Microsoft source review.
- [ ] Validate every Terraform module, including nested capstone modules.
- [ ] Resolve code-level `VERIFY BEFORE IMPLEMENTATION` items that block validation.
- [ ] Add evidence only for procedures that were actually tested.
- [ ] Keep design-only material clearly labelled.
- [ ] Confirm all local links and draw.io/SVG pairs.
- [ ] Run a secrets scan.
