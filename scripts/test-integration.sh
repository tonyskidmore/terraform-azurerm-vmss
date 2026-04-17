#!/usr/bin/env bash
# Runs integration tests that apply real Azure resources and destroy them.
#
# Each test under tests/integration/ provisions a VMSS (plus supporting
# network) in your currently logged-in Azure subscription, asserts on outputs,
# then `terraform test` destroys the resources on teardown.
#
# Requires:
#   - Terraform >= 1.10
#   - Azure credentials via `az login` OR ARM_SUBSCRIPTION_ID plus the usual
#     AzureRM provider env vars.
#
# Usage:
#   scripts/test-integration.sh                # run every integration test (prompts)
#   scripts/test-integration.sh admin_password # run one test
#   scripts/test-integration.sh --yes          # skip the confirmation prompt
#
# See tests/integration/README.md for what's covered and how to clean up a
# failed run.

set -euo pipefail

REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$REPO_ROOT"

YES=0
FILTER=""
for arg in "$@"; do
  case "$arg" in
    --yes|-y) YES=1 ;;
    -h|--help)
      sed -n '2,19p' "$0"
      exit 0
      ;;
    -*)
      echo "Unknown flag: $arg" >&2
      exit 2
      ;;
    *)
      if [[ -n "$FILTER" ]]; then
        echo "Multiple filter arguments not supported." >&2
        exit 2
      fi
      FILTER="$arg"
      ;;
  esac
done

TEST_DIR="tests/integration"

if [[ ! -d "$TEST_DIR" ]]; then
  echo "$TEST_DIR not found — nothing to run." >&2
  exit 0
fi

# Confirm Azure credentials are available.
if [[ -z "${ARM_SUBSCRIPTION_ID:-}" ]]; then
  if ! command -v az >/dev/null 2>&1 || ! az account show >/dev/null 2>&1; then
    echo "No Azure credentials detected: set ARM_SUBSCRIPTION_ID or run 'az login'." >&2
    exit 2
  fi
  ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
  export ARM_SUBSCRIPTION_ID
fi

SUB_NAME=""
if command -v az >/dev/null 2>&1; then
  SUB_NAME="$(az account show --query name -o tsv 2>/dev/null || true)"
fi

cat >&2 <<EOF

============================================================================
WARNING: Integration tests CREATE and DESTROY real Azure resources.

  Subscription: ${ARM_SUBSCRIPTION_ID}${SUB_NAME:+  (${SUB_NAME})}

Each test provisions a VMSS and dependent networking, asserts on outputs,
then destroys everything. Expect a few minutes per test.

If a test is interrupted mid-apply, clean up manually with:
  az group delete --name rg-vmss-tftest-<suffix>-01 --yes --no-wait

See tests/integration/README.md for the list of tests and resource naming.
============================================================================

EOF

if [[ "$YES" -ne 1 ]]; then
  read -r -p "Proceed? [y/N] " response
  case "$response" in
    y|Y|yes|YES) ;;
    *) echo "Aborted."; exit 0 ;;
  esac
fi

# Build filter args.
filter_args=()
if [[ -n "$FILTER" ]]; then
  file="$TEST_DIR/${FILTER}.tftest.hcl"
  if [[ ! -f "$file" ]]; then
    echo "No integration test found matching '$FILTER' (looked for $file)." >&2
    echo "Available tests:" >&2
    for f in "$TEST_DIR"/*.tftest.hcl; do
      [[ -e "$f" ]] || continue
      echo "  $(basename "$f" .tftest.hcl)" >&2
    done
    exit 2
  fi
  filter_args+=("-filter=$file")
fi

# Fresh init at module root (required for `terraform test` to resolve providers
# when it swaps in module { source = "./examples/..." } during a run).
rm -rf .terraform .terraform.lock.hcl
terraform init -upgrade -input=false

echo
echo "==> terraform test -test-directory=$TEST_DIR ${filter_args[*]}"
terraform test -test-directory="$TEST_DIR" "${filter_args[@]}"
