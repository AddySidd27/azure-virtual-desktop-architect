#!/usr/bin/env bash
# Reproduce the repository CI Terraform steps locally, without touching the repository.
#
# CI reference: .github/workflows/terraform-check.yml
#   1. terraform fmt -check -recursive -diff terraform/
#   2. for every directory containing versions.tf:
#        terraform init -backend=false -input=false
#        terraform validate
#
# This script runs the same steps against a COPY of each module, so the tracked
# .terraform.lock.hcl files and the working tree are never modified. The copied
# lock files make provider selection identical to the repository.
#
# It does NOT run terraform plan or apply, does not read tfvars, does not need Azure
# credentials, and creates no Azure resources.
#
# Usage:  tools/terraform-validate-all.sh [output-directory]
# Exit:   0 all passed, 1 at least one step failed, 2 terraform not found.
#
# Status (17 October 2026): written and syntax-checked with `bash -n` only. NOT RUN
# by the author, because Terraform could not be installed in the authoring
# environment. Run it where the Terraform registry and releases are reachable.
# Optional: export TF_PLUGIN_CACHE_DIR=<dir> to avoid downloading the provider once
# per module.

set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$(mktemp -d)}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$OUT"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform not found on PATH" >&2
  exit 2
fi

terraform version | tee "$OUT/terraform-version.txt"

failures=0
summary="$OUT/summary.tsv"
: > "$summary"

echo "== fmt (whole tree) =="
if (cd "$REPO_ROOT" && terraform fmt -check -recursive -diff -no-color terraform/) > "$OUT/fmt.log" 2>&1; then
  printf 'fmt\tPASS\n' >> "$summary"
else
  printf 'fmt\tFAIL\n' >> "$summary"
  failures=$((failures + 1))
  echo "fmt failed, see $OUT/fmt.log" >&2
fi

echo "== init -backend=false and validate (per module copy) =="
while IFS= read -r versions_file; do
  src="$(dirname "$versions_file")"
  rel="${src#"$REPO_ROOT"/}"
  slug="$(printf '%s' "$rel" | tr '/' '_')"
  copy="$WORK/$slug"
  cp -a "$src" "$copy"
  rm -rf "$copy/.terraform"

  if terraform -chdir="$copy" init -backend=false -input=false -no-color > "$OUT/$slug.init.log" 2>&1; then
    if terraform -chdir="$copy" validate -no-color > "$OUT/$slug.validate.log" 2>&1; then
      printf '%s\tPASS\n' "$rel" >> "$summary"
    else
      printf '%s\tFAIL validate\n' "$rel" >> "$summary"
      failures=$((failures + 1))
    fi
  else
    printf '%s\tFAIL init\n' "$rel" >> "$summary"
    failures=$((failures + 1))
  fi
done < <(find "$REPO_ROOT/terraform" -name versions.tf | sort)

echo
cat "$summary"
echo
echo "Logs: $OUT"
echo "Failures: $failures"

[ "$failures" -eq 0 ]
