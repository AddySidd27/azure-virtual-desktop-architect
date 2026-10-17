# Reassessment of open technical issues, 17 October 2026

> **Technical baseline:** Microsoft Learn searches run on 17 October 2026. Single reviewer, no independent pass. Nothing here was executed in Azure. **No issue is closed by this page.** Test steps live in [TEST-PLANS](TEST-PLANS.md). Approval items live in [DECISIONS-REQUIRED](DECISIONS-REQUIRED.md).

Sources marked "Learn" were read through the Microsoft Learn search tool on the date above. Sources marked "HashiCorp" are from the AzureRM 5.0 announcement. The AzureRM 5.0 upgrade guide and the provider resource pages on registry.terraform.io could not be retrieved in this environment, so provider argument behaviour remains unverified wherever it is mentioned.

## Summary

| Issue | Documentation resolves it? | What is still needed | Status |
|---|---|---|---|
| U23 | Behaviour yes, Terraform argument no | Confirm the argument with `terraform providers schema -json`, approve the module change, run the test | OPEN |
| U24 | No (provider behaviour) | `terraform plan` after Lab 4, then your choice of fix | OPEN |
| U26 | Partly | Static analysis done below. Test on a clean subscription | OPEN |
| U27 | Partly | Run the DNS commands on the lab DC | OPEN |
| U28 | Roles and scope yes, Terraform no | Your decision on role assignments, then a test | OPEN |
| U35 | No, Learn contradicts itself | Test narrower scopes | OPEN |
| U36 | Options yes, behaviour no | Test Bastion Developer to the DC | OPEN |

## U23. Private endpoint network policies and the Lab 3 storage NSG

**Question.** Does `nsg-storage` filter traffic to the Lab 5 private endpoint?

**Learn** ([Manage network policies for private endpoints](https://learn.microsoft.com/azure/private-link/disable-private-endpoint-network-policy), [What is a private endpoint?](https://learn.microsoft.com/azure/private-link/private-endpoint-overview)):
- Network policies are disabled by default on a subnet. To use NSG and user-defined route support for private endpoints, enable them on the subnet. The setting applies to all private endpoints in the subnet.
- Enable for NSGs only, for routes only, or both. ARM values: `Disabled`, `NetworkSecurityGroupEnabled`, `RouteTableEnabled`, `Enabled`.
- Azure CLI: `--private-endpoint-network-policies` accepts the same four values. The older `--disable-private-endpoint-network-policies` is documented as being replaced.
- Another Learn page (configure an application security group with a private endpoint) states that network policies must be enabled for NSG rules to apply to the private endpoint.

**Resolved by documentation?** The behaviour, yes: with the default, the lab's NSG rule does not filter private endpoint traffic. The AzureRM 5.0 argument name and values for `azurerm_subnet` are not confirmed. Learn's provider history records `private_endpoint_network_policies` from 3.103.0. A HashiCorp forum thread shows the name as "not expected" on 3.94.0, which fits that history but is not authoritative.

**Needs.**
1. Run `terraform providers schema -json` after `init` and read the attribute and its allowed values (no Azure access).
2. Your approval to change `terraform/lab03-network` (D3).
3. The U23 test in TEST-PLANS in a disposable subscription.

**Acceptance criteria for closure.**
- The schema output shows the attribute name and values, and the module sets it. CI `validate` passes.
- With the policy enabled, a VM in a different subnet is blocked from the storage private endpoint by an NSG deny rule, and allowed again when the rule is removed. Output recorded.
- Lab 3 and Lab 5 text is updated to say what was observed, and the "documentation of intent" warning is removed only if the test passes.

## U24. Lab 3 re-apply after the Lab 4 DNS change

**Question.** Does `terraform apply` on Lab 3 reset VNet DNS servers that Lab 4 set with the CLI?

**Learn.** None. This is Terraform provider behaviour. Learn only documents that custom DNS is set on the virtual network (see [Change DNS servers](https://learn.microsoft.com/azure/virtual-network/manage-virtual-network#change-dns-servers)). A web search for provider documentation returned no usable source, so the behaviour is unverified.

**Resolved by documentation?** No.

**Needs.** After Lab 4 Step 5, run `terraform plan` in `terraform/lab03-network` (read-only). Then a decision between `lifecycle { ignore_changes = [dns_servers] }` and the separate DNS servers resource (D4).

**Acceptance criteria for closure.** The plan output is recorded. If it shows `dns_servers` changing, the chosen fix is applied, `plan` then shows no DNS change, and Lab 4 and the journey page state the result. If the plan shows no change, the warning is replaced with the observed result.

## U26. Resource providers for the labs

**Question.** Is the Lab 1 provider list correct and sufficient on a clean subscription with AzureRM 5.x?

**Learn** ([Azure resource providers and types](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types), [Resource providers for Azure services](https://learn.microsoft.com/azure/azure-resource-manager/management/azure-services-resource-providers)):
- Register a provider only when you are ready to use it. Some are registered by default; the examples list is on the second page.
- Registering needs the `/register/action` permission, included in Contributor and Owner.
- Deploying a template can auto-register the providers it defines. Supporting resources outside the template may need manual registration.

**HashiCorp** (AzureRM 5.0 announcement): no resource providers are registered by default in 5.0.

**Static analysis done on 17 October 2026** (author's mapping from `azurerm_*` resource types to namespaces; not confirmed against provider documentation):
- Numbered lab modules use eight namespaces: Network, Compute, Storage, DesktopVirtualization, OperationalInsights, Insights, Authorization, Resources.
- Lab 1 registers eleven. Authorization and Resources are not on its list and are assumed to be registered already. That assumption is unconfirmed.
- Key Vault, Consumption, Recovery Services and Management are used only by the capstone modules. PolicyInsights is not required by any resource type found.
- Lab 1 text corrected to say this.

**Resolved by documentation?** Partly. The mapping and the 5.0 default are sourced. Behaviour on a clean subscription is not.

**Needs.** A clean disposable subscription.

**Acceptance criteria for closure.**
- `az provider show` for each of the eight namespaces, recorded before any apply, including Authorization and Resources.
- `terraform apply` for Labs 2 to 5, 7, 8 and 10 succeeds with only the Lab 1 list registered, or each failure names the missing namespace and Lab 1 is updated.

## U27. DNS forwarders on the lab domain controller

**Question.** Do the Lab 4 Step 5b commands make `file.core.windows.net` resolve to the private endpoint from the DC and from joined hosts?

**Learn** ([Name resolution for VMs and role instances](https://learn.microsoft.com/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances), [Troubleshoot DNS resolution failures caused by conditional forwarder misconfiguration](https://learn.microsoft.com/troubleshoot/azure/dns/troubleshoot-azure-dns-resolution-fails-conditional-forwarder-misconfiguration), [Troubleshoot private endpoint DNS resolution failure](https://learn.microsoft.com/troubleshoot/azure/private-link/troubleshoot-private-endpoint-dns-resolution)):
- A forwarding timeout above four seconds when forwarding to Azure DNS (from the first page, read earlier).
- Custom DNS servers such as AD DS must forward private-zone queries to Azure DNS (168.63.129.16), and 168.63.129.16 is reachable only from inside the VNet.
- The troubleshooting pages show conditional forwarders for `privatelink.*` zone names, for example `privatelink.blob.core.windows.net`. The lab forwards `file.core.windows.net`. The pages disagree on the zone to forward, which the lab records as a judgement.

**Resolved by documentation?** Partly. The mechanism is documented. The exact zone choice and the timeout settings are not exercised.

**Needs.** The U27 test on the lab DC (TEST-PLANS), after U36 gives an interactive session.

**Acceptance criteria for closure.** From the DC and from a restarted joined VM, `Resolve-DnsName <account>.file.core.windows.net` returns an address in `10.10.4.0/24`; `Resolve-DnsName microsoft.com` returns public addresses; forwarder and timeout values are recorded; the same check with the alternative zone name is recorded so the Judgement can be replaced by an observation.

## U28. Start VM on Connect and autoscale role assignments

**Question.** Do the documented manual role assignments make Start VM on Connect and autoscale work, and should Terraform create them?

**Learn** ([Configure Start VM on Connect](https://learn.microsoft.com/azure/virtual-desktop/start-virtual-machine-connect), [Azure built-in roles](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles)):
- Start VM on Connect needs Desktop Virtualization Power On Contributor on a managed identity of the host pool or the AVD service principal, at a scope that contains the host pool and session host VMs. You can only configure it on an existing host pool. The configuring account needs Desktop Virtualization Host Pool Contributor.
- **New finding.** The page now says earlier guidance that a lower scope prevents Start VM on Connect from working was "technically incorrect". Subscription scope is recommended for simplicity. Lower scopes work if they contain the VMs. Chapter 10 already stated this.
- Role IDs: Power On Contributor `489581de-a3bd-480d-9518-53dea7416b33`, Power On Off Contributor `40c5ff49-9181-41f8-ae61-143b0e78555e`. Autoscale scope is under U35.

**Resolved by documentation?** The roles, scopes and prerequisites, yes. Whether the labs' configuration works, no.

**Needs.** Your decision D2 (Terraform or manual), then the U28 test.

**Acceptance criteria for closure.** After the role exists, a deallocated host starts when a user connects through Windows App, with the connection time and activity log recorded; without the role it does not. If Terraform creates the role, `plan` shows only the intended role assignment and `terraform destroy` removes it.

## U35. Autoscale role scope

**Question.** Does autoscale work with Power On Off Contributor assigned below subscription scope?

**Learn** (retrieved 17 October 2026): [Create and assign an autoscale scaling plan](https://learn.microsoft.com/azure/virtual-desktop/autoscale-create-assign-scaling-plan) says the role needs the subscription as assignable scope and that any lower level "prevents autoscale from working properly". The troubleshooting page allows host pool, resource group or subscription. The Start VM on Connect page was corrected for the same kind of statement (see U28), which suggests the autoscale wording may also be stale, but Learn does not say so. That is an inference, not evidence.

**Resolved by documentation?** No, Learn conflicts. The repository keeps subscription scope, which satisfies both pages.

**Needs.** The U35 test at three scopes.

**Acceptance criteria for closure.** For each scope (host pool, resource group, subscription) record whether the host changes power state across a ramp-down window and the activity log result. Then Chapter 10, Lab 10, Project 07 and the ADR state the observed scope rule and cite which Learn page was right.

## U36. Interactive session on the domain controller

**Question.** Which route gives an interactive domain-admin session on the lab DC, and does it work with the lab's NSG?

**Learn** (retrieved 17 October 2026, from earlier searches recorded in the journey page): Bastion Developer SKU is free, shared, same VNet, one VM at a time, East US 2 supported. Serial Console is unsuitable. Managed Run Command supports `--run-as-user`.

**Resolved by documentation?** The options, yes. Whether Bastion Developer reaches the DC through the lab's NSGs, and whether run-command accepts a domain account, no.

**Needs.** The U36 test (TEST-PLANS), after Lab 4 Step 4.

**Acceptance criteria for closure.** A Bastion Developer session signs in as the lab admin and `whoami` and `Get-ADDomain` succeed, or the failure and the NSG rule needed are recorded. The run-command domain-account test result is recorded either way. The labs are updated to state the route that worked.
