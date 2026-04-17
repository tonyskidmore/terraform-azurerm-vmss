# Development

## Required tooling

| Tool       | Minimum version | Notes                                                                 |
|------------|-----------------|-----------------------------------------------------------------------|
| Terraform  | 1.10            | Needed for `terraform test` with `mock_provider` and ephemeral values |
| Python     | 3.12            | For the pre-commit toolchain                                          |
| pre-commit | 4.5             | Pinned in `requirements.txt`                                          |
| tflint     | latest          | The `azurerm` ruleset is pinned in `.tflint.hcl`                      |
| Trivy      | latest          | Replaces the deprecated tfsec and the archived terrascan              |

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
# This requires ARM_SUBSCRIPTION_ID or `az login` context. Examples that
# depend on caller-provisioned resources (e.g. custom_source_image, which
# reads from a Shared Image Gallery you must create first) are skipped
# via a `.skip-plan` marker file in the example directory.
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

# Show the full plan + state per run (what Azure actually created)
scripts/test-integration.sh --verbose
```

Requires Azure credentials (`az login` or `ARM_SUBSCRIPTION_ID` plus the
usual AzureRM env vars). See `tests/integration/README.md` for the list of
tests and how to clean up resources after a failed run.

What each integration test currently asserts:

| Test                     | Assertions beyond apply/destroy succeeding                                                      |
|--------------------------|-------------------------------------------------------------------------------------------------|
| admin_password           | `vmss_id` ends with the expected name; `vmss_name`, `vmss_location`, `vmss_sku` match inputs    |
| data_disk                | Exactly one data disk on the VMSS and its `disk_size_gb` equals the input                       |
| identity_user_assigned   | One UAI attached; no SystemAssigned principal; the identity's `client_id` is exposed            |

With `vmss_instances = 0` (the module default) no actual VM instances run,
so the Azure portal's "Disks" view for a data disk test will be empty while
the test is applying — the `data_disk` block lives on the VMSS template and
only materialises when instances scale up. Bump `vmss_instances` locally if
you want visual confirmation in the portal.

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

A few output shape changes worth noting:

* `output "vmss"` (the whole resource) has been removed. Use the narrower
  `vmss_id`, `vmss_name`, `vmss_unique_id`, `vmss_location`, `vmss_sku`,
  `vmss_instances`, `vmss_data_disks`, and `vmss_identity` outputs.
* `vmss_identity.principal_id` and `vmss_identity.tenant_id` are now `null`
  when unset (AzureRM returns `""`; the module normalizes this). So checks
  like `output.vmss_identity.principal_id != null` work as a predicate for
  "SystemAssigned is enabled".

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

Run locally (see the [super-linter run-locally docs](https://github.com/super-linter/super-linter/blob/main/docs/run-linter-locally.md)):

```bash
docker run \
  -e ACTIONS_RUNNER_DEBUG=true \
  -e RUN_LOCAL=true \
  --env-file ".github/super-linter.env" \
  -v "$PWD":/tmp/lint \
  ghcr.io/super-linter/super-linter:latest
```
