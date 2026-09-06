# Terraform - Lab 10: Scaling, Monitoring and Operations

Log Analytics workspace, diagnostic settings on the Lab 7 host pool, and a scaling plan. Closes the lab sequence.

**Depends on:** Lab 2 (resource groups), Lab 7 (host pool, referenced by data source).

```bash
cd terraform/lab10-operations
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

Diagnostic data takes roughly 15 minutes to begin appearing in the workspace after this applies — do not assume a KQL query returning nothing after 2 minutes means something is broken.
