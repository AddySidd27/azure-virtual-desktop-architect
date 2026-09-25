# Project 03 - Meridian Global Industries: 3,200-User Multi-Region Governance

> **Fictional architecture case study:** Meridian Global Industries is not a customer delivery record. Requirements, measurements, costs, tests, and outcomes are worked examples or validation targets unless separate lab evidence is linked.

> **Book:** Azure Virtual Desktop - Architect to Hands-on Implementation
> **Part XI:** Architecture Case Studies
> **Standard:** [PROJECT-STANDARD.md](../PROJECT-STANDARD.md)
> **Technical baseline:** August 2026
> **Concepts introduced here:** Infrastructure as code at scale, cost governance, operational automation, landing zone placement, delegated administration, ADR discipline

---

## Engagement brief

**What this represents.** A global manufacturer with four regional business units, each of which has already built its own AVD environment independently, using a different naming convention, a different Terraform layout (or none), and a different idea of who owns what. The board has approved a single global platform. This is not a greenfield build. It is a governance and consolidation engagement layered on top of infrastructure that already runs production workloads.

**The business problem.** Four business units, four AVD estates, four sets of naming, four sets of RBAC, four cost centres billed inconsistently, and no central visibility. The CFO cannot get a single number for what AVD costs the company. The CISO cannot confirm who has standing access to production. A recent audit finding requires privileged access to be time-bound within six months.

**Constraints that cannot be designed away.** The four business units keep their own budgets and will not accept a single shared subscription. Two of the four regions have data residency requirements that forbid session data leaving the region. The consolidation must not cause a single day of downtime for any of the 3,200 existing users. Central IT has a team of six to operate a platform this size, not sixty.

**Previously learned concepts applied.** Everything from Chapters 1-25 and every prior project. This engagement is explicitly a synthesis, not an introduction to new AVD mechanics: the identity models, host pool patterns, FSLogix design, and monitoring approach are all decisions already made correctly in at least one of the four existing estates. The problem is that they were made four different ways.

**New concepts introduced here.** Landing zone placement for AVD, subscription and resource group design at scale, delegated administration and Privileged Identity Management, naming and tagging as a governed standard rather than a convention, Azure Policy as enforcement, Terraform module design for multi-business-unit reuse, and the operating model, RACI, change management, cost allocation, and incident escalation, that makes six people able to run 3,200 users' worth of platform.

**Architectural decisions to make.** One subscription per business unit or one shared subscription with resource group separation. A single central Terraform module set or four independent ones. Central operations for the shared platform layer, regional operations for business-unit-specific applications, or one team for everything. How cost is measured and charged back when the business units share nothing but the platform.

**What could realistically go wrong.** Migrating naming and tagging on live production resources breaks a monitoring alert rule or an automation script nobody remembers exists. A shared Terraform module changes behaviour for a business unit that did not ask for the change. PIM activation friction gets bypassed within a month because nobody explained why it exists. The consolidation stalls because one business unit's political ownership of "their" environment is stronger than the governance mandate.

**Validation and handover.** Every business unit's environment provably converted to the standard without a change in the user experience their staff already have. A single Azure Policy compliance dashboard the CFO and CISO can both read. An operations team of six who can each explain, without notes, who owns what when something breaks at 2 a.m. in a region they don't work in.

---

## 1. The situation as found

**Meridian Global Industries.** A manufacturing group with roughly 3,200 AVD users across four business units: Meridian Automotive (UK, 1,100 users), Meridian Electronics (Germany, 900 users), Meridian Materials (US, 850 users), and Meridian APAC (Singapore, 350 users). Each business unit deployed AVD independently between 18 and 30 months ago, using whichever partner or internal team was available at the time.

| Business unit | Region | Users | Identity model | IaC | Naming |
|---|---|---|---|---|---|
| Automotive | UK South | 1,100 | Hybrid AD | Terraform, undocumented | `avd-uk-*` |
| Electronics | Germany West Central | 900 | Hybrid AD | ARM templates | `meridian-de-avd-*` |
| Materials | East US 2 | 850 | Entra-only | Manual portal builds | Inconsistent, several conventions |
| APAC | Southeast Asia | 350 | Hybrid AD | Terraform, different module style than UK | `sg-avd-*` |

**What the assessment found in week one.** Four separate Azure AD tenant configurations for role assignment, none of them using PIM. Eleven people across the four business units hold `Owner` at subscription scope, most inherited from the original build and never reviewed. No consistent tag exists for cost centre, environment, or business unit across any of the four estates, which means the CFO's finance team currently produces the AVD cost report by hand, monthly, by cross-referencing VM names against a spreadsheet.

**What is genuinely working and must not be broken.** All four business units' end-user experience is acceptable, this is a governance and consolidation engagement, not a rescue. Materials' Entra-only model (built by a team that had read Project 05) is the cleanest of the four and becomes the template for identity going forward, everywhere data residency allows it.

---

## 2. Business and technical requirements

**Business requirements.**

- A single, board-reportable AVD cost figure, broken down by business unit, within one quarter.
- Privileged access to production time-bound within six months (the audit deadline).
- No business unit loses its existing budget autonomy or its ability to approve its own application changes.
- Zero unplanned downtime during consolidation.

**Technical requirements.**

- One naming and tagging standard, applied to all new resources immediately and back-filled onto existing resources without recreating them.
- One Terraform module set, versioned, that all four business units consume, with room for business-unit-specific variables, not business-unit-specific forks.
- Azure Policy enforcing the naming and tagging standard going forward, so drift cannot silently return.
- PIM-based just-in-time access replacing standing `Owner` assignments.
- A RACI that names, by role not by individual, who is accountable for each layer: platform, identity, network, image, application, and end-user support.

**Data residency requirement, stated plainly.** Electronics (Germany) and APAC (Singapore) must keep session and profile data within their region. This is not a preference, it rules out a single shared storage account or a single shared host pool spanning regions for those two business units, regardless of what would otherwise be operationally simpler.

---

## 3. Landing zone placement and subscription design

**The decision.** One subscription per business unit, inside a shared management group hierarchy, not one shared subscription with resource-group-level separation.

**Why, against the simpler-sounding alternative.** A single shared subscription is easier to build and easier to report on directly from Cost Management. It was the first option proposed internally, and it was rejected. Azure subscriptions are still the hard boundary for budgets, for many Azure Policy scopes, and for blast radius, a runaway automation script or a misconfigured Azure Policy assignment in a shared subscription can affect every business unit at once. Four business units that already resist losing budget autonomy will resist a shared subscription even harder once they understand a policy mistake in someone else's resource group could affect their environment. The subscription boundary is the boundary that actually protects both budget separation and blast radius, and it is the boundary Azure's own governance tooling (Management Groups, Policy, Cost Management scopes) is built around.

**Landing zone structure.**

```text
Tenant root management group
  Meridian Platform (management group)
    mg-meridian-platform-shared      <- shared services: identity, network hub, central monitoring
  Meridian Business Units (management group)
    mg-meridian-automotive
      sub-meridian-automotive-avd
    mg-meridian-electronics
      sub-meridian-electronics-avd
    mg-meridian-materials
      sub-meridian-materials-avd
    mg-meridian-apac
      sub-meridian-apac-avd
```

Azure Policy is assigned at the `Meridian Business Units` management group level for anything that must be universal (naming, tagging, allowed regions, mandatory diagnostic settings) and at the individual business-unit management group only for exceptions specific to that unit (for example, APAC's additional data-residency-tagging policy).

**Hub-spoke, not one flat network.** A shared hub subscription (`mg-meridian-platform-shared`) holds the ExpressRoute or VPN connectivity, the central Azure Firewall, and DNS resolution shared services. Each business unit's subscription contains its own spoke VNet, peered to the hub. This keeps identity and network shared where sharing genuinely reduces cost and operational overhead, while keeping compute, storage, and budget separated where separation is the actual requirement.

---

## 4. Naming, tagging, and Azure Policy as enforcement

**The naming standard, applied going forward.**

```text
<resource-type>-<workload>-<business-unit>-<region-short>-<instance>
```

Examples: `vnet-avd-automotive-uks-01`, `hp-avd-electronics-dew-01`, `st-avd-materials-eus2-01`.

**The tagging standard, mandatory on every resource.**

| Tag | Purpose | Example |
|---|---|---|
| `BusinessUnit` | Cost allocation, RBAC scoping | `Automotive` |
| `CostCentre` | Finance chargeback code | `CC-4471` |
| `Environment` | Production vs non-production | `Production` |
| `DataResidency` | Compliance flag | `EU-only` |
| `Owner` | Named accountable role, not a person | `platform-team-de` |

**Enforcing it, not just documenting it.** An Azure Policy initiative, assigned at the `Meridian Business Units` management group, denies the creation of any resource missing the `BusinessUnit`, `CostCentre`, or `Environment` tag, and denies any resource name that does not match the naming pattern via a `deny` effect using a regex-based policy definition. This is the difference between a naming convention (a document nobody reads after week one) and a naming standard (a document Azure itself enforces).

**Back-filling existing resources.** Existing resources cannot be renamed without recreating them, which the zero-downtime requirement rules out for anything in active use. The back-fill applies tags only, via a scripted pass using `az resource tag`, run business unit by business unit during a low-traffic window, validated against the Cost Management API before and after to confirm every resource is now attributable. Renaming happens only opportunistically, as resources are replaced through their normal lifecycle (an old session host image refresh, a storage account migration already planned for another reason), never as a standalone renaming exercise, which is disruption for no functional gain.

---

## 5. RBAC, delegated administration, and Privileged Identity Management

**The role model.** Five roles, defined once, assigned consistently across all four business-unit subscriptions:

| Role | Scope | Standing or PIM-eligible |
|---|---|---|
| Platform Engineer | Shared platform subscription | PIM-eligible, `Contributor` |
| Business Unit AVD Admin | That business unit's subscription | PIM-eligible, `Desktop Virtualization Contributor` |
| Session Host Operator | That business unit's host pool resource group | Standing, scoped `Virtual Machine Contributor` |
| Service Desk | That business unit's application groups | Standing, `Desktop Virtualization User Session Operator` |
| End User | Assigned application groups only | Standing, `Virtual Machine User Login` |

**Why standing access remains for two of the five roles.** Session Host Operator and Service Desk are high-frequency, low-blast-radius roles, a service desk agent logging off a stuck session multiple times a day cannot reasonably PIM-activate for every occurrence, and the role's scope (session operations only, not the ability to delete or reconfigure infrastructure) limits what standing access to that role can actually damage. Platform Engineer and Business Unit AVD Admin carry infrastructure-changing permissions and go through PIM without exception, this is where the audit finding's six-month deadline is actually met.

**PIM configuration.** Maximum activation duration 8 hours. Approval required for Platform Engineer (approved by a second platform engineer, not self-approved). Justification required and logged for every activation. Access reviews run quarterly, owned by the business unit's named accountable role, not by central IT, central IT cannot know whether a Materials engineer still needs access; Materials' own management can.

**The eleven standing `Owner` assignments found in the assessment.** Removed over a phased two-month window, not deleted overnight. Each was individually reviewed: three were genuinely still-needed platform engineers, migrated to PIM-eligible Platform Engineer. Five belonged to people who had left the AVD project entirely and were removed outright. Three could not be attributed to a still-active person or a documented reason and were removed with a 30-day notice period in case something broke, nothing did, which is itself evidence they should never have existed.

---

## 6. Terraform and CI/CD governance

**One module set, business-unit variables, not business-unit forks.** The central platform team owns a versioned Terraform module repository. Each business unit's environment is a thin root module that calls the shared modules with its own variable values (region, business unit tag, data residency flag, host pool sizing) rather than each business unit maintaining its own copy of the module logic.

```hcl
module "avd_host_pool" {
  source  = "git::https://dev.azure.com/meridian/platform-terraform//modules/avd-host-pool?ref=v2.3.0"

  business_unit    = "electronics"
  region           = "germanywestcentral"
  data_residency   = "EU-only"
  host_pool_type   = "Pooled"
  session_host_sku = "Standard_D4s_v5"
  session_host_count = 45
}
```

**Why a pinned module version (`ref=v2.3.0`), not `ref=main`.** Four business units consuming a shared module from a moving branch means a module change made for Automotive's requirements can silently apply to Electronics on its next `terraform plan`, without Electronics ever approving that change. Pinning to a released version means every business unit chooses when to adopt a module update, and the platform team can make breaking changes in a new major version without breaking anyone who has not opted in yet.

**CI/CD pipeline, one pattern, four instances.** Each business unit subscription has its own pipeline (Azure DevOps or GitHub Actions, matching what Meridian's existing engineering teams already use) running `terraform fmt -check`, `terraform validate`, and `terraform plan` on every pull request, with `terraform apply` gated behind a required approval from that business unit's named AVD Admin. The pipeline definition itself is templated centrally so all four behave identically; only the target subscription, service principal, and variable file differ.

**Governance the pipeline enforces that a person reviewing by eye would miss.** A `tfsec` or `checkov` scan step blocking any plan that would create a resource without the mandatory tags, catching a policy violation before Azure Policy would have denied it at apply time, cheaper to fail in CI than to fail in production and have to explain why the pipeline reported success.

---

## 7. Architecture decision records

Two ADRs from this engagement, in the format used throughout this book.

**ADR: One subscription per business unit versus one shared subscription.**
Decision: one subscription per business unit. Status: accepted. Context: four business units want budget autonomy and reject shared blast radius. Consequences: more subscriptions to govern centrally, but Azure Policy and Management Groups make this practical at four subscriptions; would not scale cleanly to forty without a landing zone automation tool, which is out of scope at this size.

**ADR: Standing access for Session Host Operator and Service Desk roles.**
Decision: standing access retained for these two roles only. Status: accepted. Context: PIM activation friction for high-frequency, low-blast-radius operational tasks creates workaround pressure that undermines PIM adoption everywhere else. Consequences: these two roles remain a residual standing-access surface, mitigated by tightly scoped permissions and quarterly access review; revisit if audit guidance changes.

---

## 8. Operating model: RACI, ownership, and escalation

| Layer | Accountable | Responsible | Consulted | Informed |
|---|---|---|---|---|
| Shared platform (network, identity, hub) | Platform Lead | Platform Engineers | CISO | All BU AVD Admins |
| Business-unit AVD infrastructure | BU AVD Admin | BU AVD Admin, Platform Engineers (Terraform) | Platform Lead | BU IT Director |
| Golden image | Platform Lead | Image Engineer (central) | BU AVD Admins | Service Desk |
| Applications | BU AVD Admin | BU application owners | Service Desk | End users |
| End-user support | BU IT Director | Service Desk | BU AVD Admin |, |

**Why the golden image is centrally owned and applications are not.** The image, OS, agents, FSLogix, baseline security tooling, is the one layer where divergence between business units creates the most operational cost for the least business value: four different patch cadences and four different baseline configurations multiply support burden without multiplying business benefit. Applications are exactly the opposite: an Automotive-specific CAD tool has no reason to be centrally governed, and forcing that would recreate the "central IT doesn't understand our business" resentment that caused the four business units to build independently in the first place. The RACI reflects this deliberately, not by default.

**Incident escalation, by scope.** A single session host failure is Business Unit AVD Admin territory, resolved locally. A shared platform issue (the hub firewall, the central identity dependency, the shared Terraform module) escalates to the Platform Lead regardless of which business unit noticed it first, because a shared-layer problem is very likely affecting more than one business unit even if only one has reported it yet. The on-call rotation covers the shared platform layer only; business-unit layers are covered by that business unit's own on-call, sized to that business unit's own risk tolerance.

**Change management.** Business-unit-scoped changes (a host pool resize, an application group change) follow that business unit's own change process, Meridian does not impose a single global change board on decisions that only affect one business unit's users. Shared-platform changes (a hub firewall rule, a shared Terraform module release) go through a lightweight central change board with one representative from each business unit, meeting weekly, because a shared-layer change by definition affects everyone and every business unit gets a voice before it ships.

---

## 9. Cost allocation and capacity planning

**The chargeback model.** Compute and storage costs are directly attributable per business unit through the subscription boundary and enforced tagging, this was the actual point of the subscription-per-business-unit decision, and it pays off here. Shared platform costs (the hub network, central identity infrastructure, central monitoring) are apportioned across the four business units by a simple, published formula: 60% split by active user count, 40% split evenly, reviewed annually. The even-split component exists because some shared costs (identity infrastructure, the central Log Analytics workspace baseline) do not scale linearly with user count, and a pure per-user split would unfairly load APAC's 350 users with a share of fixed costs disproportionate to what driving them lower would actually save.

**Capacity planning, done per business unit, informed centrally.** Each business unit forecasts its own headcount growth and seasonal patterns, Materials has a known Q4 demand spike tied to their fiscal year close that the other three do not share. The platform team aggregates these forecasts to plan shared-layer capacity (ExpressRoute bandwidth, central firewall throughput) but does not attempt to plan business-unit compute capacity on their behalf; that authority and that budget accountability stay with the business unit.

---

## 10. Governance exceptions

**APAC's exception.** APAC's 350 users are the smallest business unit and cannot economically justify a dedicated Platform Engineer. APAC's Business Unit AVD Admin role is filled by a Platform Engineer from the central team, wearing that hat part-time, an explicitly documented exception to the "each business unit owns its own AVD Admin" pattern, reviewed annually as APAC's headcount grows.

**Materials' interim standing-access exception.** During the two-month PIM migration window, Materials retained two standing `Contributor` assignments beyond the phase-out date agreed for the other business units, because a critical application migration already in flight could not tolerate the activation-approval latency mid-cutover. This was time-boxed to 45 days, documented, and closed on schedule, an exception is not a precedent unless it is left open past its stated end date, and this one was not.

**The principle governing exceptions generally.** Every exception in this engagement is written down, has a named accountable owner, and has either an end date or an annual review date. An exception with neither is not a decision, it is drift that has not been caught yet.

---

## 11. Terraform strategy in practice

The four business units' Terraform state is kept in four separate remote state backends (one per subscription), never one shared state file, a shared state file would mean a Terraform error while planning Electronics' changes could lock or corrupt state affecting Automotive, exactly the blast-radius risk the subscription boundary was chosen to prevent, undone at the tooling layer if state were shared. Each backend uses Azure Storage with soft delete and versioning enabled, and state file access is itself an RBAC-controlled, tagged, monitored resource. State is infrastructure and is governed like infrastructure, not treated as a build artefact nobody watches.

**Migrating existing hand-built and ARM-based environments into this Terraform model** happened via `terraform import`, one resource type at a time, starting with the lowest-risk resources (resource groups, tags) and ending with the highest-risk (the session host VMs themselves), each import validated with `terraform plan` showing zero unexpected changes before moving to the next resource type. Electronics' ARM-template-based environment took the longest of the four, because ARM's implicit dependency resolution does not map cleanly onto Terraform's explicit dependency graph, and several resources needed to be manually reconciled rather than mechanically imported.

---

## 12. Validation

- Azure Policy compliance dashboard shows 100% tag and naming compliance across all four subscriptions, verified monthly, not just at go-live.
- A single Cost Management report, filterable by `BusinessUnit` tag, reproduces the same total the CFO's team previously took a week to assemble by hand, validated by running both methods in parallel for one month and confirming the numbers match within rounding.
- PIM activation logs show zero standing `Owner` assignments remaining at the six-month audit checkpoint, and every Platform Engineer and Business Unit AVD Admin activation carries a logged justification.
- Each business unit's end users report no change in their day-to-day AVD experience, measured by comparing helpdesk ticket volume for the four weeks before and after consolidation, not by assumption.

## 13. Rollback

Because this is a governance overlay on live infrastructure rather than a rebuild, rollback is scoped per change, not global. Tag back-fill is reversible by re-running the script against a saved pre-change export. Azure Policy assignments can be set to `Audit` mode instead of `Deny` within minutes if a policy is found to be blocking a legitimate operation, without removing the policy. This was used once, in week three, when the naming-pattern regex incorrectly rejected a legacy resource type still in use by Automotive, and was corrected and reset to `Deny` within a day. RBAC and PIM changes are rolled back by re-assigning the previous role; because the eleven standing `Owner` removals were phased with a notice period, no rollback was needed for any of them.

## 14. Risks accepted, not eliminated

APAC's part-time Platform Engineer arrangement is a single point of knowledge risk smaller than the other three business units carry, accepted, with an annual review trigger tied to APAC's headcount. The pinned Terraform module version means a critical security fix to a shared module does not reach a business unit until that business unit chooses to bump its `ref`, mitigated by a monthly module-currency report showing which business units are behind, but not eliminated, because forcing immediate adoption would reintroduce the uncontrolled blast radius the pinning was designed to prevent.

---

## 15. Interview questions from this engagement

### Q1. Why one subscription per business unit instead of one shared subscription with resource groups?

**30-second answer.** Subscriptions are the real boundary for budget, blast radius, and many Azure Policy scopes. Four business units that want budget autonomy will resist sharing a subscription once they understand a mistake in someone else's resource group can still affect their environment through shared policy or shared quota.

**Two-minute senior answer.** Resource groups don't isolate blast radius the way subscriptions do, a runaway script with subscription-scoped credentials, or a misapplied policy at the wrong scope, can reach across resource groups inside one subscription. Four business units already distrustful of central control after building independently for two years will not accept that risk to save the platform team some management group complexity. Azure's own governance tooling, Management Groups, Policy assignment scopes, Cost Management, is built to make several subscriptions under one management group hierarchy entirely practical at this scale. It would not scale as cleanly to forty business units without landing zone automation, but at four, subscription-per-business-unit is the right-sized answer, not the maximally scalable one.

**Deep-dive points.** Cost Management API attribution accuracy per subscription versus per resource-group-and-tag. Azure Policy `Deny` effect evaluation scope. The specific blast-radius scenario walked through with the CISO before this was approved.

**Expected follow-up.** "What would change your mind?", a much larger number of business units, where four separate subscriptions per unit becomes unmanageable and a landing zone accelerator with automated subscription vending becomes worth the investment.

**Common weak answer.** "Subscriptions are best practice" without explaining what specific risk the practice mitigates here.

**What the interviewer is testing.** Whether the candidate can justify a governance decision from the actual risk it addresses, not from a memorised pattern.

### Q2. Why keep standing access for Session Host Operator and Service Desk but require PIM for everything else?

**30-second answer.** PIM friction on high-frequency, low-blast-radius tasks creates workaround pressure that undermines PIM everywhere. Those two roles can't meaningfully damage infrastructure even with standing access, so the friction isn't buying real risk reduction.

**Two-minute senior answer.** Blanket PIM policies sound more secure but often reduce actual security, because people find ways around friction that blocks their normal work, shared credentials, sticky notes, permanent elevated groups nobody remembers to remove. Session Host Operator can log a user off or restart a host; it cannot delete infrastructure or change configuration. Applying PIM there buys almost no risk reduction for real productivity cost, and the friction erodes goodwill toward PIM for the roles where it actually matters, Platform Engineer and Business Unit AVD Admin, which can change infrastructure and where the audit finding is specifically about that risk. Being selective about where friction is justified is what makes the friction that remains actually get followed.

**Deep-dive points.** The specific scoped permission set for Session Host Operator that limits its blast radius by design, not just by policy. Quarterly access review as the compensating control for the roles that remain standing.

**Expected follow-up.** "How do you know Session Host Operator can't be escalated to do more damage?", walk through the exact role definition and confirm no `Microsoft.Compute/virtualMachines/delete` or similar destructive actions are included.

**Common weak answer.** Applying PIM uniformly to every role because it sounds more rigorous, without assessing actual blast radius per role.

**What the interviewer is testing.** Judgement about proportionate control, not maximum control.

### Q3. Four business units each want their own naming convention. How do you get agreement on one standard?

**30-second answer.** Make Azure Policy enforce it, not a document. A naming standard nobody has to remember to follow survives; a naming convention that relies on discipline drifts within a quarter, which is exactly what happened here before this engagement.

**Two-minute senior answer.** Getting four business units to agree on paper is the easy part; getting them to actually follow it six months later is where naming conventions usually fail, and this estate's assessment found four different conventions precisely because the original standard, if one ever existed, was never enforced. The fix here wasn't better documentation. It was an Azure Policy initiative with a `Deny` effect, assigned at the management group level, so a resource that doesn't match the pattern simply cannot be created, not "shouldn't be created." That converts a discipline problem into a technical constraint. The one thing this required getting right was testing the policy in `Audit` mode first against real, varied resource types before switching to `Deny`, because a naming-pattern regex that's slightly too strict blocks legitimate work and burns the goodwill needed to keep the policy in place.

**Deep-dive points.** The specific `Audit`-to-`Deny` rollout sequence and the one incident where the regex needed correcting. Why back-filling tags on existing resources used a script rather than a rename, given the zero-downtime constraint.

**Expected follow-up.** "What happens when a business unit has a genuine, defensible reason to deviate?" a documented, owned, reviewed exception, exactly like APAC's part-time AVD Admin arrangement, not a silent carve-out in the policy itself.

**Common weak answer.** Relying on a written standard and a rollout email, with no technical enforcement mechanism behind it.

**What the interviewer is testing.** Whether the candidate distinguishes a documented convention from an enforced standard, and knows which one actually survives contact with four independent teams.

### Q4. How do you decide what stays centrally owned versus what stays with each business unit?

**30-second answer.** By what creates the most operational cost through divergence versus what creates the most resentment through central control. The golden image is centrally owned because four different patch baselines cost more than they're worth; applications stay local because a central team dictating a business unit's line-of-business software recreates exactly the distrust that caused the fragmentation in the first place.

**Two-minute senior answer.** This isn't a technical question so much as an organisational-design one wearing a technical costume, and getting it wrong in either direction breaks the engagement. Centralise too much and business units disengage or route around the platform team the way they did before this engagement existed. Centralise too little and you're back to four different security baselines and no board-reportable cost figure, which is the exact problem this project was hired to fix. The test applied here was consistent: does divergence at this layer create real operational cost with no offsetting business benefit? Golden images, naming, and PIM policy all failed that test in the direction of "centralise." Applications and business-unit-specific Terraform variables failed it in the direction of "leave local." The RACI in section 8 is the direct output of applying that test layer by layer, not a generic template.

**Deep-dive points.** Why monitoring workspaces are split by concern (shared platform layer centrally owned, business-unit-specific dashboards locally owned) rather than being a single centralise-or-not decision.

**Expected follow-up.** "What would you do if a business unit disagreed with where you drew that line?" treat it as a data point to re-examine the specific line, not a governance violation to override, since the whole premise of the split is that business units understand their own context better than the central team does.

**Common weak answer.** A blanket rule ("infrastructure is central, applications are local") applied without the underlying reasoning, which breaks down at the first genuine edge case.

**What the interviewer is testing.** Whether the candidate has a transferable principle for the centralise/delegate decision, not just a memorised answer for this specific engagement.

### Q5. The CFO wants a single cost number today. What do you actually tell them in week one, before any of this is built?

**30-second answer.** The honest current state: the number they have was built by hand, monthly, from a spreadsheet, and cannot be trusted or reproduced quickly. Promise a validated, automated figure by a specific date, and show the interim manual number with its known limitations rather than pretending precision that doesn't exist yet.

**Two-minute senior answer.** The instinct under executive pressure is to produce a number immediately, because "I don't have a reliable number yet" feels like a weak answer to give a CFO. It's actually the strong answer, provided it comes with a plan and a date. Giving a false-precision number in week one to avoid an uncomfortable conversation is how architects lose credibility three months later when the real, tag-enforced figure turns out to be meaningfully different from what was promised. The better move here was validating the existing manual process against the new automated one for a full month in parallel, specifically so the CFO's team could see the numbers converge and trust the switch, rather than being asked to simply believe a new dashboard.

**Deep-dive points.** The specific one-month parallel-validation window and why a shorter window wouldn't have been convincing.

**Expected follow-up.** "What if the CFO needs a number for a board meeting next week, before any of this is ready?" provide the best available manual estimate, explicitly labelled as an estimate with its margin of error, rather than silence or false precision.

**Common weak answer.** Producing a confident-sounding number in week one to satisfy the immediate pressure, without flagging that it comes from an unreliable, manual process.

**What the interviewer is testing.** Professional honesty under executive pressure, and whether the candidate can manage expectations without either stonewalling or overpromising.

---

## 16. Official Microsoft references

- [Azure landing zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Policy overview](https://learn.microsoft.com/en-us/azure/governance/policy/overview)
- [Microsoft Entra Privileged Identity Management](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)
- [Manage Azure Virtual Desktop environments using Azure Resource Manager templates and Terraform](https://learn.microsoft.com/en-us/azure/virtual-desktop/automation-github)
- [Organize your resources with management groups](https://learn.microsoft.com/en-us/azure/governance/management-groups/overview)
