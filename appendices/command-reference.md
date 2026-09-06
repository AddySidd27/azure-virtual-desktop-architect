# PowerShell and Azure CLI Command Reference

Replace example names and run commands only in an authorized environment. Commands that change state are labelled.

## Context and inventory

```powershell
Connect-AzAccount
Get-AzContext
Set-AzContext -SubscriptionId <subscription-id>
Get-AzWvdHostPool -ResourceGroupName <resource-group>
Get-AzWvdSessionHost -ResourceGroupName <resource-group> -HostPoolName <host-pool>
```

```bash
az login
az account show
az account set --subscription <subscription-id>
az desktopvirtualization hostpool list -g <resource-group> -o table
az desktopvirtualization hostpool show -g <resource-group> -n <host-pool>
```

## Host maintenance

The following command changes state by preventing new sessions on one host:

```powershell
Update-AzWvdSessionHost `
  -ResourceGroupName <resource-group> `
  -HostPoolName <host-pool> `
  -Name <session-host-name> `
  -AllowNewSession:$false
```

Restore new-session placement after validation:

```powershell
Update-AzWvdSessionHost `
  -ResourceGroupName <resource-group> `
  -HostPoolName <host-pool> `
  -Name <session-host-name> `
  -AllowNewSession:$true
```

## Assignment and active sessions

```powershell
Get-AzWvdApplicationGroup -ResourceGroupName <resource-group>
Get-AzRoleAssignment -Scope <application-group-resource-id>
Get-AzWvdUserSession -ResourceGroupName <resource-group> -HostPoolName <host-pool>
```

## VM and network checks

```bash
az vm list -g <resource-group> -d -o table
az vm get-instance-view -g <resource-group> -n <vm-name> -o json
az network nic show -g <resource-group> -n <nic-name>
az network vnet peering list -g <resource-group> --vnet-name <vnet-name> -o table
```

```powershell
Resolve-DnsName <storage-account>.file.core.windows.net
Test-NetConnection <storage-account>.file.core.windows.net -Port 445
Test-NetConnection <required-avd-fqdn> -Port 443
Get-Service RDAgentBootLoader, RDAgent, frxsvc
```

`Test-NetConnection -Port` tests TCP. Do not use it as proof that UDP 3478 or an RDP Shortpath UDP path works.

## FSLogix checks

```powershell
Get-ItemProperty 'HKLM:\SOFTWARE\FSLogix\Profiles'
Test-Path '\\<storage-account>.file.core.windows.net\<share>'
Get-Acl '\\<storage-account>.file.core.windows.net\<share>'
Get-SmbOpenFile | Where-Object Path -like '*<user>*'
```

## Terraform

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
terraform plan -out=tfplan
terraform show tfplan
```

Do not commit `tfplan`, state, `.tfvars`, credentials, or registration tokens.

## References

- [Azure Virtual Desktop PowerShell overview](https://learn.microsoft.com/en-us/powershell/module/az.desktopvirtualization/)
- [Azure Virtual Desktop Azure CLI commands](https://learn.microsoft.com/en-us/cli/azure/desktopvirtualization)
- [Terraform on Azure](https://learn.microsoft.com/en-us/azure/developer/terraform/)
