# Lab 19 - Disaster Recovery and Failover (Active-Passive)

Terraform for [Lab 19](../../labs/lab-19-disaster-recovery-failover.md).

Builds a warm-standby DR region in `westus2`, protecting `eastus2` specifically
(not `centralus` - see below). Genuinely separate from Lab 14's active-active
pools: own Terraform directory, own region, own workspace strategy (shares
`eastus2`'s workspace rather than creating a new one).

## Correction pass: identity dependency and capacity reservation cost

Two corrections were made to this module after initial review, both documented in
full in the [Lab 19 correction report](../../appendices/lab-19-correction-report.md):

1. **westus2 now peers to both eastus2 and centralus, not eastus2 alone.** The
   original design gave DR session hosts a DNS/authentication path only to
   eastus2's domain controller - meaning during an actual eastus2 outage, the
   exact scenario this lab exists to survive, DR session hosts had no working
   identity path at all. `westus2` now also peers to `centralus`, and DR session
   hosts list `centralus`'s domain controller (Lab 12, independently healthy
   during an eastus2 failure) first in DNS server order, with eastus2's domain
   controller second, never depended on alone. See `peering-centralus.tf` and
   `session-hosts.tf`.
2. **`enable_capacity_reservation` now defaults to `false`, renamed from
   `reserve_capacity`.** Confirmed against Microsoft's own documentation
   (`learn.microsoft.com/azure/virtual-machines/capacity-reservation-overview`):
   an on-demand capacity reservation bills at the full VM rate continuously from
   the moment it's created, regardless of `deploy_active` and regardless of
   whether any VM is ever deployed against it. This is a real, ongoing,
   *additional* cost, not a contingent one, and is off by default to match this
   lab set's general cost-conscious posture.

## Plan correction: `westus2`, not `centralus`

The original Labs 11-20 plan described this lab's DR target as living "in
centralus." Building it revealed why that doesn't hold up: `centralus` already
hosts Lab 14's active production host pool. A DR target for `eastus2` needs to
sit in a region that does not share `eastus2`'s or `centralus`'s own failure
domain, so this lab uses a third region, `westus2`, instead. This is a
plan-accuracy correction made during the build, not a change to the approved
active-active architecture in Labs 11-18, which is untouched.

## Cost

Four distinct billing states, not two - `deploy_active` and
`enable_capacity_reservation` are independent variables, and conflating them
understates cost in some combinations:

| State | Session hosts | Capacity reservation | Cost |
|---|---|---|---|
| Default (both `false`) | 0 deployed | Not created | **$0/month** compute |
| `deploy_active = true`, reservation off | 1+ running | Not created | ~$70/month per host |
| `deploy_active = false`, reservation on | 0 deployed | Billing continuously | ~$70/month per reserved host slot, **even though nothing is running** |
| `deploy_active = true`, reservation on | 1+ running | Billing continuously | You are charged once, not twice, for the matched quantity - see the lab markdown's capacity reservation section for the exact mechanism |

Network (VNet, subnet, NSG, both peering links): ~$1/month regardless of the
above, peering data transfer only.

**`enable_capacity_reservation` defaults to `false`.** Enabling it improves
capacity assurance (confidence the DR VM SKU will actually be available during a
real, regionally-constrained failover) at the cost of paying for that assurance
continuously, not just during an actual incident. This is a genuine trade-off,
not a free improvement, and this lab does not default to paying it silently.

## Dependency on Labs 3, 7, 11 and 12

Reads Lab 3's state for the `eastus2` VNet (for peering) and Lab 7's state for the
`eastus2` host pool and workspace (the failover target). **Added in this
correction pass:** also reads Lab 11's state (for the `centralus` VNet, to peer
against) and Lab 12's state (for `centralus`'s domain controller IP, the new
primary DNS server for DR session hosts).

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit owner, admin_password, avd_users_group_object_id, primary_state_storage_account
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

With the default `deploy_active = false` and `enable_capacity_reservation =
false`, this creates the network (including both peering links), host pool, and
application group, but zero session hosts and no capacity reservation - the
true, fully cost-conscious warm-standby state.
