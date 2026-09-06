# Lab 19 Correction Report

**Date:** August 2026
**Scope:** Two technical corrections to Lab 19 (Disaster Recovery and Failover), applied after the lab was provisionally accepted and before Labs 11-20 closed.
**Status:** Both corrections complete and validated. Labs 11-20 close with this report.

---

## 1. Identity dependency on the failed region, removed

### The finding

Lab 19's original design peered `westus2` (the DR region) to `eastus2` (the protected region) only, and set DR session hosts' DNS servers to `eastus2`'s domain controller alone. During an actual `eastus2` regional outage, the only scenario in which this lab's failover runbook would ever genuinely be needed, DR session hosts created during failover would have no reachable domain controller to authenticate against. The design depended exclusively on the region it existed to protect against.

### The fix

`westus2` now peers to **both** `eastus2` and `centralus`. DR session hosts' DNS server order lists `centralus`'s domain controller (Lab 12) first, `eastus2`'s second - never depended on alone. `westus2`'s subnet is mapped to the existing `centralus-Site` in AD Sites and Services, so DR session hosts are site-aware toward the identity plane that actually survives an `eastus2` failure. Full reasoning, including why `centralus` was chosen over a dedicated third domain controller or a hub/transit redesign, is documented in the lab markdown's "Identity and networking during an eastus2 outage" section.

### What this design claims, and does not claim

`westus2` is independently recoverable with respect to identity: it does not require `eastus2` to be reachable in order to authenticate DR session hosts. It is not independent of Microsoft Entra ID as a global service, and it is not independent of `centralus` remaining healthy - a simultaneous failure of both `eastus2` and `centralus` has no further fallback in this design. This is stated explicitly in the lab, not implied away.

---

## 2. Capacity Reservation cost, corrected and made opt-in

### The finding

Azure on-demand Capacity Reservations bill at the full rate of the reserved VM size continuously from the moment the reservation is created, whether or not a matching VM is ever deployed against it. This was verified directly against Microsoft's own documentation during this correction pass: *"Capacity reservations are priced at the same rate as the underlying VM size... you start getting billed... even if the reservation isn't being used"* (`learn.microsoft.com/azure/virtual-machines/capacity-reservation-overview`). A companion Microsoft troubleshooting article and a Microsoft Community Hub technical post independently corroborate the same behaviour: billing starts immediately once the reservation exists, and stopping or never deploying the associated VM does not reduce it.

The lab's original cost table did not clearly distinguish this from session-host compute cost, and the variable controlling it (`reserve_capacity`) defaulted to `true`, meaning the lab's "default" configuration silently carried an ongoing cost that a reader following the defaults would not necessarily expect.

### The fix

The variable is renamed `enable_capacity_reservation` and now defaults to `false`, matching this lab set's general cost-conscious posture. The cost table in both the lab markdown and the Terraform README now shows four distinct billing states, not two, since `deploy_active` (session hosts) and `enable_capacity_reservation` (the reservation) are independent variables:

| State | Session hosts | Capacity reservation | Cost |
|---|---|---|---|
| Default (both `false`) | 0 deployed | Not created | $0 |
| `deploy_active = true`, reservation off | 1+ running | Not created | Full VM rate, per running host |
| `deploy_active = false`, reservation on | 0 deployed | Billing continuously | Full VM rate per reserved slot, despite nothing running |
| `deploy_active = true`, reservation on | 1+ running | Billing continuously | Charged once per matched VM, not twice |

Validation Step 2 was extended to include a specific, positive check that no capacity reservation exists with the default configuration (`az capacity-reservation-group show` returning `ResourceNotFound`), rather than only checking session-host VM count. The cleanup section now calls out re-disabling the reservation after any exercise as its own explicit step, since it is the cost item most likely to be left on by accident precisely because it produces no visible symptom.

---

## 3. Files changed

**Terraform, `terraform/lab19-dr-failover/`:**
- `network.tf` - corrected header comment describing the peering design
- `remote-state.tf` - added `lab11_network` and `lab12_identity` remote state data sources
- `peering-centralus.tf` - new file, `westus2`-`centralus` bidirectional peering
- `session-hosts.tf` - DNS server order corrected (`centralus` DC primary, `eastus2` DC secondary); capacity reservation block comment rewritten with the four-state billing explanation
- `variables.tf` - `reserve_capacity` renamed to `enable_capacity_reservation`, default changed `true` to `false`
- `outputs.tf` - `capacity_reservation_group_id` output description corrected; new `billing_state_summary` output added
- `terraform.tfvars.example` - variable renamed, default corrected
- `README.md` - cost table rebuilt as four states; correction summary added; dependency list extended to Labs 11 and 12

**Terraform, `terraform/lab11-multiregion-network/`:**
- `nsg-identity-storage.tf` - new inbound rule `Allow-Auth-From-Westus2-DR`, permitting DR session host authentication traffic from `westus2` (`10.30.0.0/16`) to `centralus`'s domain controller
- `README.md` - note added for readers who applied this lab before the correction

**Diagrams, `diagrams/architecture/`:**
- `lab19-active-passive-dr.svg` / `.drawio` - rebuilt to show both peering links and the corrected DNS/identity design
- `lab20-full-environment-topology.svg` / `.drawio` - rebuilt to remove the stale "peers to eastus2 only" claim and show the corrected identity backstop role `centralus` now plays for DR

**Lab markdown, `labs/lab-19-disaster-recovery-failover.md`:**
- Correction summary added near the top
- Cost summary rebuilt as the four-state table
- Prerequisites extended to require Labs 11 and 12
- New "Identity and networking during an eastus2 outage" section: normal operation, what the original design got wrong, the corrected design, why `centralus` over a dedicated DC or hub/transit redesign, AD Sites and Services, authentication dependencies, failback, and an explicit statement of what the design does and does not claim
- Step 1 and Step 2 updated to reflect two peering links and the capacity-reservation-absence check
- Validation checklist extended: peering state for both links, AD site mapping, DNS order, a simulated-outage authentication test
- Troubleshooting table extended with failure modes specific to the corrected design
- Cleanup section extended with an explicit capacity-reservation-off confirmation step
- Two new interview questions added (identity dependency correction, capacity reservation cost precision), three original interview questions retained unchanged

**New file:** this report (`appendices/lab-19-correction-report.md`).

---

## 4. Final identity, networking, and capacity strategy for Lab 19

**Identity.** `westus2` has no domain controller of its own. DR session hosts authenticate against `centralus`'s domain controller (Lab 12) as the primary path, with `eastus2`'s domain controller (Lab 4) as a secondary that is never relied upon alone. `westus2`'s subnet is mapped to `centralus-Site` for site-aware authentication. This removes the single point of failure the original design had, at no meaningful additional standing cost.

**Networking.** `westus2` peers bidirectionally to both `eastus2` and `centralus`. No peering exists between `westus2` and any resource that would make it dependent on `eastus2`'s specific health to reach `centralus`, or vice versa - each peering link is independent. `centralus`'s identity subnet NSG permits inbound authentication traffic from `westus2` specifically, distinct from the pre-existing DC-to-DC replication rule for `eastus2`.

**Capacity.** Session host deployment (`deploy_active`) and capacity assurance (`enable_capacity_reservation`) are independent, both default `false`, and both must be deliberately enabled - there is no default configuration in which this lab bills for compute without an explicit choice to do so. Enabling the capacity reservation is a genuine trade-off between capacity assurance and ongoing cost, not a free improvement, and the lab states this plainly rather than defaulting to paying for it.

---

## 5. Validation performed this pass

- Terraform structural checks: brace balance confirmed across every modified file in `lab19-dr-failover` and `lab11-multiregion-network`
- Diagram render, inspect, and fix: both corrected diagrams rendered to PNG, inspected, one real defect found and fixed (footer text overflow on Lab 20's diagram from the longer corrected caption), re-rendered clean
- Repository-wide link check: 0 broken links after this report was added (2 forward-references to this report resolved by its creation)
- Em-dash check: 0 across every file touched this pass
- Failover/failback runbook variable consistency confirmed: `$avdUsersGroupObjectId`, `$eastus2ApplicationGroupId`, and `$drApplicationGroupId` used consistently and correctly across both scripts
- Confirmed no new or existing claim that this Terraform has been run against a live Azure subscription, or that `terraform validate`/`plan`/`apply` has actually been executed - the original honest disclaimer remains unchanged and accurate

---

## 6. What this correction pass does not change

The active-active architecture in Labs 11-18 is untouched. Lab 19's overall pattern - warm standby, shared workspace, no duplicate feed, admin-triggered failover, `westus2` as a genuine third region rather than reusing `centralus` - is unchanged; only the identity path and the capacity reservation default were corrected. No live Azure validation has been performed as part of this correction; every claim above is a structural, documentation, and internal-consistency check, consistent with every prior audit in this repository's history.
