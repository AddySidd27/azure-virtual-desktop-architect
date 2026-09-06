# Security Policy

This repository is a book and a set of lab instructions, not a running service. There is no application attack surface to report against. This policy covers two things: accidental secret exposure in this repository, and how Terraform/Azure guidance in this repository should be treated from a security standpoint.

## Reporting an accidentally committed secret

If you find what looks like a real subscription ID, tenant ID, password, API key, registration token, certificate, or private key committed anywhere in this repository:

**Do not open a public GitHub issue.** Instead, open a private security advisory on this repository (GitHub: Security tab > Report a vulnerability), or contact the maintainer directly through the profile linked on the repository's GitHub page.

Include the file path and line, and nothing else sensitive in the report itself.

A repository-wide scan for this class of issue was run as part of the August 2026 remediation pass; the result is documented in [appendices/audit-09-remediation-report.md](appendices/audit-09-remediation-report.md). The scan is not a guarantee against future accidental commits, which is why this policy exists.

## Using the Terraform and lab guidance safely

- Never commit a real `.tfvars` file. Every module ships a `.tfvars.example`; copy it locally and keep your copy out of version control (`.gitignore` already excludes `*.tfvars` except `*.tfvars.example`).
- Registration tokens, connection strings, and any credential a lab asks you to generate are yours, scoped to your own subscription, and should never be pasted into an issue, pull request, or commit.
- Treat every cost figure in this repository as an estimate requiring verification against the [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) for your region, not as a quote.
- Labs that create real Azure resources say so and include a cleanup step. Running a lab and then abandoning the resources is a cost risk, not a security one, but it is worth stating here too: clean up what you do not intend to keep running.

## Scope

This policy does not cover vulnerabilities in Azure, Windows, AVD, or any Microsoft product itself. Report those directly to the [Microsoft Security Response Center](https://www.microsoft.com/msrc).
