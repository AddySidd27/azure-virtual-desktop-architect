# Lab 2 - Terraform Foundation

Terraform configuration for [Lab 2](../../labs/lab-02-terraform-foundation-and-governance.md).

Creates the six lab resource groups with the book's standard tag set.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # then edit owner
# edit backend.tf with your bootstrapped storage account name
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Cost

Resource groups are free. The only cost is the state storage account created in Lab 2 Step 1 - under $1.00/month.
