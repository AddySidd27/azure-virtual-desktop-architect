# Lab 18 - Regional Security and Monitoring

Terraform for [Lab 18](../../labs/lab-18-regional-security-monitoring.md).

Deploys a `centralus` Log Analytics workspace, diagnostic settings for the
`centralus` host pool, and an optional (off by default) Azure Firewall.

## Cost

| Resource | Monthly cost |
|---|---|
| Log Analytics workspace | ~$5-15/month at lab scale, ingestion-based |
| Diagnostic settings | $0.00 - no direct charge, cost is in ingestion above |
| Azure Firewall (`deploy_firewall = true`) | **~$900/month running, regardless of traffic** |

**`deploy_firewall` defaults to `false`.** Lab 11's NSGs already provide the
outbound-only egress control this lab environment needs. Only set it `true` if
you specifically want to exercise the Firewall pattern and understand the cost -
this is stated plainly in the variable description and in the lab markdown, not
buried in a comment nobody reads.

## Dependency on Labs 11 and 14

Reads Lab 11's state for the `centralus` monitoring and network resource groups,
and Lab 14's state for the `centralus` host pool ID.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars   # edit owner, primary_state_storage_account
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```
