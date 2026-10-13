# Start in VS Code

This is the exact code folder for Blog Post 7. For this walkthrough, use this
folder rather than the earlier Lab 5 AD DS module.

## Open the code

Install VS Code, Git, Azure CLI and Terraform from their official sources.
Open a terminal and run:

```powershell
git clone https://github.com/AddySidd27/azure-virtual-desktop-architect.git
cd azure-virtual-desktop-architect
code .
```

In VS Code choose Terminal > New Terminal. From the repository root:

```powershell
cd terraform/blog-post07-profile-storage
Copy-Item terraform.tfvars.example terraform.tfvars
```

Open terraform.tfvars in the Explorer. Replace every placeholder and every
zero. Zero means not configured. Choose sizes for the validation environment;
do not use the fictional company's production totals just for screenshots.

## Find inputs

- Subscription ID: Azure portal > Subscriptions > your Enabled subscription.
- Resource group: the existing workload storage resource group.
- Region: the supported workload region agreed in the design.
- Subnet ID: existing VNet > Subnets > planned private endpoint subnet;
  obtain its full Resource ID from JSON View or Azure CLI.
- DNS zone ID: existing privatelink.file.core.windows.net > Overview > JSON View.
- Group object IDs: Microsoft Entra ID > Groups > chosen group > Overview.
- Capacity/IOPS/throughput: approved measured requirement and region limits.

## Authenticate and check

```powershell
az login
az account set --subscription '<enabled-subscription-id>'
terraform init
terraform fmt -check
terraform validate
terraform plan -out=storage.tfplan
```

Review the plan against the post's resource table. There must be no
unexplained deletion or replacement of existing profile data.

```powershell
terraform apply storage.tfplan
terraform output profile_paths
```

This configures infrastructure and share roles only. Follow the post's
separate Entra application/client and Windows ACL steps, then its two-user
access tests. Successful apply does not prove user-profile attachment.

## Evidence

Capture actual validation, reviewed plan, apply, outputs, portal properties,
private endpoint/DNS and two-user permission tests. Mask IDs and usernames.
Never publish account keys, tokens, terraform.tfvars, state or plan files.
