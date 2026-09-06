# Terraform Reference Implementation

This folder contains Terraform for the learning labs and the fictional Northwind enterprise case study.

## Lab modules

The `lab*` directories support [Labs 1-20](../labs/README.md). Some labs do not need their own Terraform module:

- Lab 1 checks prerequisites.
- Lab 6 configures FSLogix against resources created by other modules.
- Lab 15 uses the regional storage and host-pool resources.
- Lab 20 validates and removes the environment.

## Northwind modules

The [Northwind Terraform index](capstone-northwind/README.md) explains the three implementation layers and their state dependencies.

## Required checks

Run these checks in every module before planning an Azure deployment:

```bash
terraform fmt -check
terraform init -backend=false
terraform validate
```

Then configure the approved backend and values for the target environment before running `terraform plan`.

The GitHub workflow discovers every directory that contains `versions.tf`, including nested Northwind modules. Format and provider validation do not prove that an Azure deployment will succeed.

Never commit `.tfvars`, state, plan, credentials, tokens, keys, or certificates. See [Validation Status](../VALIDATION-STATUS.md).
