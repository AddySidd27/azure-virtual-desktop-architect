# Terraform - Lab 9: Application Delivery

Adds a second, RemoteApp-preferred host pool and publishes one application (Notepad, chosen because it requires no additional installation on any Windows image), demonstrating the RemoteApp path alongside the Desktop path from Lab 7.

**Depends on:** Lab 7 (workspace, referenced by data source). **Note:** the RemoteApp application group needs its own session hosts to actually serve a session — this module creates the host pool and application group; deploying a session host into it follows the same pattern as Lab 8, pointed at `hp-avd-remoteapp-lab-eus2-01` instead. The lab markdown covers this explicitly rather than silently assuming it.

```bash
cd terraform/lab09-app-delivery
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```
