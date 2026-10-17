# Test plans for untested behaviour (U23 to U28, plus the Lab 4 to 8 chain)

Prepared 17 October 2026. **None of these tests has been executed.** No Azure subscription, Terraform or OpenTofu was available, and no billable operation was run. Each plan lists what is verified from Microsoft Learn, what is the standard behaviour of a tool but not from Learn, and what is simply unknown. Expected results are descriptions drawn from documentation, not observed output.

Common environment for every plan: an Azure subscription you own for lab use, the Lab 1 tool set, and Terraform 1.9.0 or later with `azurerm ~> 5.0` (from `terraform/*/versions.tf`). Estimated cost is only given where the lab itself already states one.

---

## U23. Private endpoint and NSG behaviour

| Item | Detail |
|---|---|
| Objective | Find out whether `nsg-storage` filters traffic to the Lab 5 private endpoint with the Lab 3 subnet defaults, and whether enabling private endpoint network policies changes that |
| Learn says (retrieved 17 October 2026) | Network policies are disabled by default on a subnet and NSG rules are bypassed for private endpoint traffic until they are enabled ([Manage network policies for private endpoints](https://learn.microsoft.com/azure/private-link/disable-private-endpoint-network-policy)). The Azure CLI accepts only `true` or `false` for `--disable-private-endpoint-network-policies` and cannot enable NSG or route table support selectively. ARM values are `Disabled`, `NetworkSecurityGroupEnabled`, `RouteTableEnabled`, `Enabled` |
| Prerequisites | Labs 3 to 5 applied. DC and one Windows VM in the VNet. Lab 5 private endpoint resolving to its private IP |
| Permissions | Network Contributor on the network resource group |
| Tools | Azure CLI. `Test-NetConnection` on a Windows VM (standard Windows cmdlet, not sourced from Learn) |
| Steps | 1. Record the private endpoint IP (`private_endpoint_ip` output from Lab 5). 2. From a VM in the hosts subnet run `Test-NetConnection <ip> -Port 445`. Record the result. 3. Add a temporary inbound Deny rule for TCP 445 on `nsg-storage` with a lower priority number than `Allow-SMB-From-Session-Hosts`. 4. Repeat the test. 5. Enable the policy: `az network vnet subnet update --disable-private-endpoint-network-policies false --name snet-storage-lab-eus2-01 --resource-group rg-avd-network-lab-eus2-01 --vnet-name vnet-avd-lab-eus2-01`. 6. Repeat the test. 7. Run `az network vnet subnet show` and record the policy value |
| Expected, from Learn | Step 4: connection still succeeds, because the NSG is bypassed. Step 6: the Deny rule is applied and the connection fails |
| Failure indicators | Step 4 fails (the default is not what Learn describes). Step 6 still succeeds (policy not applied, or rule priority wrong) |
| Cleanup | Delete the temporary Deny rule. Decide whether to keep the policy enabled. If kept, record the AzureRM argument that produced it, then remove drift from Lab 3 Terraform with approval |
| Azure resources, billable | Uses existing Lab 3 to 5 resources. Private endpoint charges already apply |
| Executed | **No** |

## U24. Lab 3 re-apply after the Lab 4 DNS change

| Item | Detail |
|---|---|
| Objective | Find out whether `terraform plan` or `apply` on Lab 3 reverts the VNet DNS servers set by Lab 4 Step 5 |
| Known | The Lab 3 module has no `dns_servers` argument (`grep` over `terraform/lab03-network`). Lab 4 sets DNS with `az network vnet update --dns-servers 10.10.1.4` |
| Unknown | Whether the AzureRM provider treats an unset `dns_servers` as "leave alone" or "reset to empty". Not verified against the provider documentation in this review |
| Prerequisites | Terraform installed with registry access. Lab 3 applied, Lab 4 Step 5 done |
| Permissions | Reader on the network resource group is enough for `plan`. Contributor for `apply` |
| Steps | 1. `az network vnet show -g rg-avd-network-lab-eus2-01 -n vnet-avd-lab-eus2-01 --query dhcpOptions.dnsServers`. 2. In `terraform/lab03-network` run `terraform plan`. 3. Read the plan for a change on `azurerm_virtual_network.avd` touching `dns_servers`. 4. Do not apply if the plan shows a reset |
| Expected | Unknown. Both outcomes are possible. Record the plan text |
| Failure indicator | Plan shows `dns_servers` going to empty. Applying it would break name resolution for every VM, including domain join in Lab 8 |
| Cleanup | None for `plan` |
| Azure resources, billable | No new resources |
| Executed | **No**. Needs Terraform with registry access (U25) |

## U25. Terraform execution

| Item | Detail |
|---|---|
| Objective | (1) Confirm `fmt`, `init -backend=false` and `validate` pass for every module **at this branch's commit**, which includes Terraform edits that CI has not seen. (2) Later, run `plan` per layer |
| Already recorded | GitHub CI passed these three steps in all 34 modules on `main` at `86e083d` (run 38991596213, Terraform 1.16.6). See [TERRAFORM-VALIDATION](../TERRAFORM-VALIDATION.md). Not a plan, apply or deployment |
| Not yet checked | The twelve Terraform files that differ between `main` and this branch (list in UNRESOLVED-ISSUES U25) |
| Prerequisites | Terraform 1.9.0 or later (CI uses 1.16.6) or OpenTofu, and access to the Terraform registry and release hosts. No Azure credentials are needed for part 1 |
| Permissions | None for part 1. Reader or Contributor on a lab subscription for `plan`, depending on the data sources a module reads |
| Exact commands, part 1 | From the repository root: `tools/terraform-validate-all.sh`. It runs `terraform fmt -check -recursive -diff terraform/`, then for each of the 34 directories containing `versions.tf` it copies the module to a temporary directory and runs `terraform init -backend=false -input=false` and `terraform validate`. Tracked lock files and the working tree are not modified. Add `TF_PLUGIN_CACHE_DIR=<dir>` to download the provider once. Equivalent by hand for one module: `cd terraform/lab05-storage && terraform init -backend=false -input=false && terraform validate` (this updates that module's lock file only if the lock does not match the constraints) |
| Exact commands, part 2 (plan) | Per module in lab order: copy `terraform.tfvars.example` to `terraform.tfvars`, replace every example value, configure a remote state backend (see Lab 2), `terraform init`, `terraform plan -out=tfplan`. Read the plan. Do not apply without an authorised subscription |
| Expected | Part 1: `Failures: 0` and 34 PASS lines plus a `fmt` PASS line in `summary.tsv`. If a file fails, the log names the argument |
| Failure indicators | `Unsupported argument`, `Missing required argument`, deprecated attribute errors, `fmt` diff output, provider version conflicts |
| Cleanup | None. The script removes its temporary copies. `rm -rf` the output directory if kept |
| Azure resources, billable | None for part 1. Part 2 reads Azure only through data sources and creates nothing until `apply` |
| Executed | **No.** The author's environment cannot install Terraform or OpenTofu and the restriction was not bypassed. The script was checked with `bash -n` and `shellcheck`, run once without Terraform (it exited 2 as designed), and its control flow was exercised once with a stub program that is not Terraform (34 modules enumerated, working tree and lock files unchanged). That proves the script logic only |

## U26. Required resource providers

| Item | Detail |
|---|---|
| Objective | Determine the minimum resource provider set for Labs 1 to 20 on a clean subscription |
| Learn says | `Microsoft.DesktopVirtualization` must be registered before deploying AVD, and registering requires the `*/register/action` permission (Contributor or Owner). Registration commands are `az provider register --namespace Microsoft.DesktopVirtualization` and `az provider show --namespace Microsoft.DesktopVirtualization --query {RegistrationState:registrationState}` ([Prerequisites for Azure Virtual Desktop](https://learn.microsoft.com/azure/virtual-desktop/prerequisites)). Custom image templates list further providers: `Microsoft.VirtualMachineImages`, `Microsoft.Storage`, `Microsoft.Compute`, `Microsoft.Network`, `Microsoft.KeyVault`, `Microsoft.ContainerInstance` |
| Unknown | Whether the AzureRM provider registers providers automatically in your configuration, and which of the Lab 1 list (`Consumption`, `RecoveryServices`, `Management`, `PolicyInsights`) are actually needed |
| Prerequisites | A clean subscription with no providers registered beyond defaults |
| Permissions | Contributor or Owner on the subscription |
| Steps | 1. `az provider list --query "[?registrationState=='Registered'].namespace" -o tsv` and save it. 2. Apply Labs 2 to 10 in order without registering anything extra. 3. Record each failure that names a provider. 4. After the labs, list registered providers again and diff against step 1 |
| Expected | Failures only where a provider is required and not auto-registered. The diff is the real minimum set |
| Failure indicators | `MissingSubscriptionRegistration` errors |
| Cleanup | Resource providers can stay registered. Destroy the lab resources |
| Azure resources, billable | Yes, the full lab chain |
| Executed | **No** |

## U27. DNS forwarders

| Item | Detail |
|---|---|
| Objective | Prove the DC forwards Azure names correctly and that the storage FQDN resolves to the private endpoint |
| Learn says (retrieved 17 October 2026, [Configure DNS name resolution for Azure virtual networks](https://learn.microsoft.com/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances)) | A DC in Azure can forward other queries to Azure DNS at `168.63.129.16`. When Windows DNS forwards to Azure DNS, set the forwarding timeout above four seconds, or private zone names can resolve to public IPs. Once custom DNS is set, port 53 traffic bypasses the subnet and NIC NSGs |
| Prerequisites | Lab 4 Steps 1 to 5b done. Lab 5 Step 1 applied for the storage check |
| Permissions | Local administrator on the DC (via `az vm run-command` as in the labs) |
| Steps | 0. Lab 4 Step 5b now sets `-ForwarderTimeout 5` on the zone forwarder and `Set-DnsServerForwarder -Timeout 5`; confirm both. 1. `Get-DnsServerForwarder` and `Get-DnsServerZone -Name file.core.windows.net` on the DC. 2. Check the forwarder timeout. 3. From the DC and from a restarted VM in the VNet run `Resolve-DnsName <storage_account>.file.core.windows.net` and `Resolve-DnsName microsoft.com` |
| Expected | The storage name returns the private endpoint IP in `10.10.4.0/24`. The public name returns public addresses. The timeout is above four seconds |
| Failure indicators | Storage name returns a public IP. Lookups time out |
| Cleanup | None. Deallocate the DC to stop compute cost |
| Azure resources, billable | DC VM compute while running |
| Executed | **No** |

## U28. Start VM on Connect and autoscale role assignments

| Item | Detail |
|---|---|
| Objective | Prove Start VM on Connect and autoscale work with the role assignments the labs document, and find out whether `start_vm_on_connect = true` is accepted at host pool creation |
| Learn says (retrieved 16 and 17 October 2026) | Start VM on Connect: Desktop Virtualization Power On Contributor on the AVD service principal (`9cdead84-a844-4324-93f2-b2e6bb768d07`) or the host pool managed identity, at a scope containing the host pool and VMs (subscription recommended). It is configured on an existing host pool, and the configuring account needs Desktop Virtualization Host Pool Contributor. A pooled pool starts at most one VM per five minutes. Autoscale: Power On Off Contributor at subscription scope, and a lower scope prevents autoscale from working properly. Making the assignment needs `Microsoft.Authorization/roleAssignments/write` |
| Approval required | **Adding these role assignments to Terraform needs explicit approval and has not been done.** This test uses manual assignments |
| Prerequisites | Labs 3 to 8 working, one host registered. Lab 10 applied for the autoscale part |
| Permissions | Owner or User Access Administrator, plus Contributor |
| Steps, Start VM on Connect | 1. `terraform apply` Lab 7 and record whether `start_vm_on_connect = true` is accepted at create. 2. Assign the role with `az role assignment create --assignee 9cdead84-a844-4324-93f2-b2e6bb768d07 --role "Desktop Virtualization Power On Contributor" --scope /subscriptions/<sub-id>`. 3. Enable the setting with `az desktopvirtualization hostpool update --start-vm-on-connect true` (Learn command). 4. `az vm deallocate` the host. 5. Connect with Windows App. 6. Record whether the VM starts and how long the connection takes |
| Steps, autoscale | 1. Apply Lab 10. 2. Run once with no role assignment and record the outcome. 3. Assign Power On Off Contributor at subscription scope. 4. After the ramp-down window, record a power-state change. 5. Optional negative test: scope the role to the resource group only and record the result |
| Expected | VM starts on connect once the role exists. Autoscale changes power state only with the subscription-scope role |
| Failure indicators | Connection fails with no VM start. Scaling plan enabled with no power change. Activity log shows an authorization failure for the service principal |
| Cleanup | Remove both role assignments. Deallocate or destroy hosts |
| Azure resources, billable | Yes, VM compute and storage while the host runs |
| Executed | **No** |

## U35. Autoscale role scope

| Item | Detail |
|---|---|
| Objective | Find out whether autoscale works with the role below subscription scope, since two Learn pages disagree |
| Learn says (retrieved 17 October 2026) | Create and assign a scaling plan: the role needs the subscription as assignable scope, and a lower scope "prevents autoscale from working properly". Troubleshoot autoscale: the role is assigned at host pool, resource group or subscription scope |
| Prerequisites | Lab 10 applied, one registered host, Owner or User Access Administrator |
| Steps | 1. Assign Power On Off Contributor to the AVD service principal at host pool scope only. 2. Wait through a ramp-down window and record whether the host changes power state. 3. Repeat at resource group scope, then subscription scope. 4. Record the activity log result for each |
| Expected | Unknown. Subscription scope is the baseline the repository uses |
| Failure indicators | Scaling plan enabled, no power change, authorization failure for the service principal in the activity log |
| Cleanup | Remove all three role assignments. Deallocate or destroy hosts |
| Azure resources, billable | Yes, host compute while running |
| Executed | **No** |

## U36 (U-ACCESS). Interactive session on the domain controller

| Item | Detail |
|---|---|
| Objective | Prove a documented route gives an interactive domain-admin session on the DC for Lab 5 Steps 4 to 6 and Lab 6 |
| Learn says (retrieved 17 October 2026) | Bastion Developer SKU: free, shared, one VM at a time in the same virtual network, no AzureBastionSubnet or public IP, East US 2 supported. Managed Run Command has `--run-as-user`; the user must exist on the VM and Secondary Logon must run |
| Prerequisites | Lab 4 Step 4 done (DC promoted), a domain admin account (for example `labadmin`, created over run-command) |
| Steps | 1. Create a Bastion Developer connection to the DC in the portal and sign in as `AVDLAB\labadmin`. Record whether the connection times out. If it does, read the DC NIC effective security rules. 2. In that session run `whoami` and `Get-ADDomain`. 3. Separately test `az vm run-command create --run-as-user AVDLAB\labadmin` with `whoami` and record whether a domain account works |
| Expected | Step 1 gives an interactive session as the domain admin. Step 3 is unknown |
| Failure indicators | Connection timeout, credential rejection, `whoami` returns SYSTEM |
| Cleanup | Delete the Bastion resource and the `labadmin` account |
| Azure resources, billable | DC compute while running. Bastion Developer is $0 |
| Executed | **No** |

## E2E-1. Lab 4 to 8 chain: sign in and mount a profile

| Item | Detail |
|---|---|
| Objective | Walk the whole documented chain once and record where it breaks |
| Prerequisites | A test Entra tenant with a verified custom domain, a subscription, Hybrid Identity Administrator in the tenant, Domain Admin in `avdlab.local` (see [Lab 4 Step 7](../labs/lab-04-identity-integration.md) and the [dependency matrix](../labs/LAB-DEPENDENCY-MATRIX.md)) |
| Steps | Follow Labs 1 to 8 in order, completing Lab 4 Step 7. At each matrix row, run the validation in its column and record the output |
| Expected | Matrix rows 1 to 22 validate in order. Row 22 shows a profile container (VHDX) for the signed-in user |
| Failure indicators | Any row's failure signal in the matrix |
| Cleanup | Lab 20 teardown. Remove the Entra Cloud Sync configuration and the synced test objects |
| Azure resources, billable | Yes. Lab 4 and Lab 8 state their own costs |
| Executed | **No** |

## Not testable from documentation alone

U8 (legacy client end dates after 28 September 2026), U9 (Meta Quest label), U12 (Windows App version pinning), U15 (VM User Login role mechanism) and U18 (KDC proxy with Windows App) cannot be settled by an Azure test the author can run. U8, U9 and U12 depend on Microsoft documentation changing or on a vendor statement. U15 and U18 need a support case or a client test with a smart card and KDC proxy.
