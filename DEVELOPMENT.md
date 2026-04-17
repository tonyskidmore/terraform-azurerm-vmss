# Development

## Required tooling

| Tool      | Minimum version | Notes                                                                 |
|-----------|-----------------|-----------------------------------------------------------------------|
| Terraform | 1.10            | Needed for `terraform test` with `mock_provider` and ephemeral values |
| Python    | 3.12            | For the pre-commit toolchain                                          |
| pre-commit| 4.5             | Pinned in `requirements.txt`                                          |
| tflint    | latest          | The `azurerm` ruleset is pinned in `.tflint.hcl`                       |
| Trivy     | latest          | Replaces the deprecated tfsec and the archived terrascan              |

Provider versions are pinned at the module root in `versions.tf`
(`azurerm ~> 4.0`). Each example ships its own `versions.tf` and `providers.tf`.

## Local testing (no Azure credentials required)

The repo supports three layers of tests, all runnable locally with no Azure
subscription:

```bash
# 1. Pre-commit: fmt, validate, tflint, trivy, terraform-docs
pre-commit run --all-files

# 2. Native Terraform unit tests (mock_provider, plan-only)
terraform test

# 3. Example validation: init + validate every example
scripts/test-examples.sh
```

Or run all three via the top-level wrapper:

```bash
scripts/test.sh

# Pass `--with-plan` to also run `terraform plan` against each example.
# This requires ARM_SUBSCRIPTION_ID or `az login` context for examples that
# use data sources (e.g. custom_source_image).
scripts/test.sh --with-plan
```

## Integration tests (real apply/destroy)

Under `tests/integration/` there are opt-in `terraform test` files that use
`command = apply` to deploy each example against a real Azure subscription,
assert on the outputs, then let Terraform destroy everything on teardown.
They are not part of `scripts/test.sh` because they incur cost and take
several minutes per test.

```bash
# All integration tests (prompts once for confirmation)
scripts/test-integration.sh

# Just one example
scripts/test-integration.sh admin_password

# Skip the confirmation prompt (e.g. for CI)
scripts/test-integration.sh --yes
```

Requires Azure credentials (`az login` or `ARM_SUBSCRIPTION_ID` plus the
usual AzureRM env vars). See `tests/integration/README.md` for the list of
tests and how to clean up resources after a failed run.

## GitHub Actions

`.github/workflows/ci.yml` runs the same checks as `scripts/test.sh` on push
and pull request, plus GitHub super-linter. When GitHub Actions minutes are
constrained, rely on local `scripts/test.sh` runs — it exercises the same
paths offline.

## Migrating code that uses this module

If you are updating from `tonyskidmore/vmss/azurerm` 0.4.x to 1.0.0, these are
the caller-facing changes you need to make:

```hcl
# Before (0.4.x)
module "vmss" {
  source  = "tonyskidmore/vmss/azurerm"
  version = "0.4.0"

  vmss_identity_type = "UserAssigned"
  vmss_identity_ids  = [azurerm_user_assigned_identity.example.id]

  vmss_data_disks = [
    { caching = "None", create_option = "Empty", disk_size_gb = "10", lun = 0, storage_account_type = "Standard_LRS" }
  ]
}

# After (1.0.0)
module "vmss" {
  source  = "tonyskidmore/vmss/azurerm"
  version = "~> 1.0"

  vmss_identity = {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.example.id]
  }

  vmss_data_disks = [
    { caching = "None", create_option = "Empty", disk_size_gb = 10, lun = 0, storage_account_type = "Standard_LRS" }
  ]
}
```

## Devcontainer

When [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers) has been enabled, in VS Code open `Dev Containers: Reopen in Container`.

Pre-commit hooks should be installed automatically, but if not run:

```bash
pre-commit install
pre-commit install-hooks
```

## Super-Linter (local)

Download the super-linter container image:

```bash
docker pull ghcr.io/super-linter/super-linter:latest
```

> Note: `.github/super-linter.env` is shared between local and GitHub Actions scans.

Run locally:

```bash
docker run \
  -e ACTIONS_RUNNER_DEBUG=true \
  -e RUN_LOCAL=true \
  --env-file ".github/super-linter.env" \
  -v "$PWD":/tmp/lint \
  ghcr.io/super-linter/super-linter:latest
```

[gha-super-linter-local]: https://github.com/super-linter/super-linter/blob/main/docs/run-linter-locally.md
