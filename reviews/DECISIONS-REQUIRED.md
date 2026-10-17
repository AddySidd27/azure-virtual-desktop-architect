# Decisions that need explicit approval

Prepared 17 October 2026. **Nothing on this page has been applied.** Each item is a change the audit declined to make without approval, because it touches role assignments, a provider baseline, a lock file, a Terraform module, or the remote repository. Every snippet is a proposal that has not been through `terraform validate`.

| # | Decision | Why it needs approval | Current state in the repo |
|---|---|---|---|
| D1 | Push the branch so CI validates its Terraform edits | Pushes are not allowed without approval | 16 local commits ahead of `main`. Twelve Terraform files differ from `main` and have not been through CI (U25) |
| D2 | Create the U28 role assignments in Terraform | New role assignments change authorization | Documented as manual steps in Lab 7 Step 2b and Lab 10 Step 0 |
| D3 | Enable private endpoint network policies on the storage subnet (U23) | Changes a Terraform module and a network control | `nsg-storage` is documented as not enforced |
| D4 | Protect the Lab 4 VNet DNS setting from a Lab 3 re-apply (U24) | Changes a Terraform module | Documented warning and a `terraform plan` rule |
| D5 | Approve the `random` provider baseline and its lock file for `capstone-northwind/platform/security` | Provider baseline and lock file changes | The module has no lock file. Not changed |
| D6 | Autoscale role scope (U35): keep subscription scope | None needed unless you want a narrower scope | Subscription scope everywhere, with the Learn conflict stated |

## D1. Push for CI

CI (`.github/workflows/terraform-check.yml`) runs `terraform fmt -check`, `terraform init -backend=false` and `terraform validate` on every module and has passed on `main` at `86e083d`. It cannot see this branch until it is pushed. The alternative that needs no push is to run `tools/terraform-validate-all.sh` on a machine that has Terraform. Pushing a branch does not merge or deploy anything, but it still needs your approval.

## D2. U28 role assignments

Learn (retrieved 16 and 17 October 2026): Start VM on Connect needs Desktop Virtualization Power On Contributor for the Azure Virtual Desktop service principal (application ID `9cdead84-a844-4324-93f2-b2e6bb768d07`) or the host pool's managed identity, at a scope that contains the host pool and the VMs. Power management autoscale needs Desktop Virtualization Power On Off Contributor at subscription scope. Making the assignment needs `Microsoft.Authorization/roleAssignments/write`.

| Option | What it needs | Trade-offs |
|---|---|---|
| A. Variable-based assignment in Terraform | A new input `avd_service_principal_object_id` (the object ID of the service principal in your tenant, for example from `az ad sp show --id 9cdead84-a844-4324-93f2-b2e6bb768d07 --query id -o tsv`). No new provider. No lock file change | Gives the AVD service its Learn-documented rights over every VM in the subscription from a lab module. A reader must look up the ID. `terraform destroy` removes the assignment, which is good for cleanup |
| B. `azuread_service_principal` data source | Adds the `azuread` provider to the Lab 7 and Lab 10 modules | Provider baseline and lock file change, so it needs its own approval |
| C. Keep manual (current) | Nothing | Readers can skip the step and see no VM start or no autoscale. The assignment survives `terraform destroy` unless the reader removes it |

Proposal for option A, **not applied and not validated**:

```hcl
variable "avd_service_principal_object_id" {
  description = "Object ID of the Azure Virtual Desktop service principal (application ID 9cdead84-a844-4324-93f2-b2e6bb768d07) in this tenant."
  type        = string
}

resource "azurerm_role_assignment" "avd_power_on" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Desktop Virtualization Power On Contributor"
  principal_id         = var.avd_service_principal_object_id
}
```

Judgement: C until the labs have been run once, then A with a clear destroy warning. This is an engineering recommendation, not a Learn statement.

## D3. Private endpoint network policies (U23)

Learn: policies are disabled by default and NSG rules are bypassed for private endpoint traffic until enabled. Learn's Terraform provider history records the property as `private_endpoint_network_policies` from AzureRM 3.103.0. The values and the name in 5.x are unverified. CI would catch a wrong argument name, because `terraform validate` checks the provider schema, but not the behaviour.

| Option | Notes |
|---|---|
| 1. Set `private_endpoint_network_policies` on `azurerm_subnet.storage` | Needs D1 or a local Terraform run to confirm the name. Behaviour needs the U23 test. Enabling policies also makes UDR and NSG rules apply to private endpoint traffic, which can break access if a rule is wrong |
| 2. Keep the NSG, document that it is intent only (current) | No risk, no enforcement |
| 3. Remove the misleading allow rule | Simplest, but loses the teaching value of the example |

## D4. Lab 3 re-apply and Lab 4 DNS (U24)

Run `terraform plan` in `terraform/lab03-network` after Lab 4 Step 5 first. If it shows a `dns_servers` change, the options are `lifecycle { ignore_changes = [dns_servers] }` on `azurerm_virtual_network.avd`, or the separate `azurerm_virtual_network_dns_servers` resource (it exists in the provider; Learn's provider history records it from 2.69.0). Do not use both ways of setting DNS on one VNet without testing. Neither option has been validated.

## D5. `random` provider baseline

The `capstone-northwind/platform/security` module is the only root module without a committed lock file (33 of 34 have one). It needs a decision on the `random` provider baseline. Not changed.

## D6. Autoscale role scope (U35)

The two Learn pages disagree (see U35). Subscription scope satisfies both and is what every document in this repository uses. Change it only if you want to test narrower scopes (TEST-PLANS U35).
