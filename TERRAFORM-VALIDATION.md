# Terraform Validation Record

## Current status (updated 16 October 2026)

**Source:** `main` at commit `2a7b03b3b9976b79c5b2f70bb296f6c703c37a76`.
**Scope:** 34 directories containing a `versions.tf` file and 232 `.tf` files. Every module declares `azurerm` `~> 5.0` and Terraform `>= 1.9.0`.

### Repository CI

The [Terraform structural check](.github/workflows/terraform-check.yml) runs `terraform fmt -check -recursive`, then `terraform init -backend=false` and `terraform validate` in every directory that contains a `versions.tf`. It passed on:

| Run | Event | Commit | Result |
|---|---|---|---|
| 38854619765 | pull request | `6fffd7b` | success |
| 38855731652 | pull request | `c4d3b62` | success |
| 38856054927 | push to `main` | `2a7b03b` | success |

The `terraform fmt -check -recursive` step and the `terraform init and validate every module` step both completed successfully in each run. On the earlier `main` commit `2d97b45` the same check failed in the `terraform init and validate every module` step (run 38354030287).

### Update, 17 October 2026 (read-only check of GitHub run metadata)

After the table above, the workflow was changed to pin Terraform 1.16.6 and the provider lock files were committed (pull requests #7 to #9). `gh run list` and `gh run view` were used read-only on 17 October 2026 to read run conclusions; logs were not downloaded.

| Run | Event | Commit | Result |
|---|---|---|---|
| 38991596213 | push to `main` | `86e083d` | success (both jobs: format and per-module validate; secret scan) |
| 38994438927 | manual dispatch on the remote branch `docs/review-register-ch01-remediation` | `a0ed80a` | success |

Terraform version at `86e083d`: pinned to 1.16.6 by the workflow file. AzureRM version: the committed lock files select 5.10.0 (5.9.0 in `blog-post07-profile-storage`).

**Superseded 17 October 2026.** The 12 Terraform files that differed from `main` were checked by CI on this branch at `6a11662` (see the section at the end of this page). `plan` and `apply` and local execution remain not done.

### Read-only diagnostic workflow

A separate read-only diagnostic workflow (branch `diag/tf-module-validation`, not part of `main`) validates each module in its own job without stopping at the first failure.

| Run | Source commit | Outcome, from the workflow's annotations |
|---|---|---|
| 38843347683 | `7bf6e93` | 10 of 34 modules failed `validate`: lab05, lab09, lab10, lab11, lab13, lab17, lab19, and the capstone `autoscaling`, `backup` and `security` modules |
| 38854096486 | `6fffd7b` | No failing phase (format, init, validate) reported for any of the 34 modules |

That workflow resolved Terraform 1.16.6 in every module job, AzureRM 5.10.0 in 33 modules and AzureRM 5.9.0 in `blog-post07-profile-storage`. The per-module result files were not downloaded or independently reviewed for this record; the outcomes above come from the workflow's annotations.

### Evidence limits

- *(Superseded for runs from `86e083d` on, see the 17 October 2026 update: Terraform is pinned to 1.16.6 and the provider is locked. It still applies to the three runs in the first table.)* The Terraform and provider versions used by the repository CI runs are **not recorded** here. The CI workflow does not pin a Terraform version, so the diagnostic workflow's versions are not assumed to match.
- This is a schema, formatting and initialization check. It is **not** a Terraform plan, an apply, a deployment, or runtime testing. The status in [VALIDATION-STATUS.md](VALIDATION-STATUS.md) therefore stays at *provider validated* for the Terraform; no lab is marked lab validated by this record.

### Checks still required before deployment

1. Configure approved remote-state backends and environment-specific values.
2. Run and review a Terraform plan for each layer in dependency order.
3. Deploy only in an authorized Azure subscription.
4. Retain sanitized evidence before marking a lab or implementation validated.

---

## Earlier record: 6 September 2026

This section is kept as written at the time. Its counts, versions and conclusions describe that review only and are superseded by the current status above.

**Checked:** 6 September 2026  
**Terraform CLI:** 1.13.3  
**Scope:** 230 Terraform files across 33 modules

## Completed checks

| Check | Result |
|---|---|
| `terraform fmt -recursive terraform/` | Passed after formatting 46 files |
| `terraform fmt -check -recursive terraform/` | Passed |
| HCL parsing during format | Passed for all Terraform files |
| Undeclared `var.*` reference scan | Passed |
| Sensitive file scan | Passed; no committed `.tfvars`, state, private key, or certificate files |
| Module discovery | Passed; 33 directories containing `versions.tf` |

The first format pass found invalid one-line nested provider blocks in Lab 9 and Lab 10. Both blocks were corrected and the full format check was run again successfully.

## Provider validation boundary

Earlier review passes could not install the Terraform CLI at all in their environment, because `releases.hashicorp.com` was unreachable, and used `terraform-config-inspect` as a substitute for structural checks instead. This review ran with Terraform CLI 1.13.3 already present, so that earlier limitation did not apply here: `terraform init -backend=false` successfully downloaded AzureRM 5.4.0 and created the provider installation for the first module. `terraform validate` could not complete in this review environment because the AzureRM provider process was not permitted to open its local Unix communication socket:

```text
plugin init error: listen unix /tmp/plugin...: socket: operation not permitted
```

This is a runtime restriction in the review environment, not a passing provider-validation result. The repository therefore does not label the 33 modules **provider validated**.

The workflow in [`.github/workflows/terraform-check.yml`](.github/workflows/terraform-check.yml) runs `terraform init -backend=false` and `terraform validate` separately in every module on GitHub. A successful workflow run is required before changing the status to provider validated.

## Checks still required before deployment (as of 6 September 2026)

1. Push the repository and confirm the Terraform GitHub Actions workflow passes all 33 modules. *(Done: see the current status above.)*
2. Configure approved remote-state backends and environment-specific values.
3. Run and review a Terraform plan for each layer in dependency order.
4. Deploy only in an authorized Azure subscription.
5. Retain sanitized evidence before marking a lab or implementation validated.

## CI result for this branch, 17 October 2026

Pushed `6a11662` to `origin/docs/review-register-ch01-remediation`. A push to a non-`main` branch does not trigger the workflows (they run on `pull_request`, `push` to `main` and `workflow_dispatch`), so the three were dispatched manually on the branch. All three passed on `6a11662`:

| Workflow | Run | Result |
|---|---|---|
| Terraform structural check (`fmt -check -recursive`, `init -backend=false` and `validate` per module, Gitleaks) | 39007047474 | success |
| Repository check | 39007048778 | success |
| Markdown link check | 39007050303 | success |

This is schema-level validation only. It does not cover `plan`, `apply`, Azure behaviour or lab execution (U25 stays open for those).

### Re-run on `b95af3f`, 17 October 2026

Commit `b95af3f8e83f42747dd7a380687bb91bb3859134` (Chapters 1 to 12 editorial pass; documentation only, no Terraform change since `6a11662`). The same three workflows were dispatched manually on the branch and all passed:

| Workflow | Run | Result |
|---|---|---|
| Terraform structural check | 39007931570 | success |
| Repository check | 39007932741 | success |
| Markdown link check | 39007933846 | success |

Scope is unchanged: formatting, provider schema validation, repository structure, links and a secret scan. Commits made after `b95af3f` (including the one that records this table) have not had a CI run.
