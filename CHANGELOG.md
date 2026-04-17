# CHANGELOG

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2026-04-17

Major release bringing the module up to 2026 standards. This release contains
breaking changes — see the "Migrating from 0.4.x" section of the README.

### Breaking

* **AzureRM provider** constraint moved from `>=3.1.0, <4.0.0` to `~> 4.0`.
  Consumers must be on AzureRM v4.x; v3.x is no longer supported.
* **Terraform core** minimum bumped from `>= 1.0.0` to `>= 1.10.0`.
* **Identity inputs** `vmss_identity_type` and `vmss_identity_ids` replaced by
  a single object input `vmss_identity = { type, identity_ids }`.
* **`vmss_auto_upgrade_minor_version`** is now `bool` instead of `string`.
* **`vmss_enable_automatic_updates`** is now `bool` instead of `string`.
* **`vmss_data_disks[].disk_size_gb`** is now `number` instead of `string`.
* **`vmss_ssh_public_key`** now defaults to `null` (was `""`).
* **Outputs:** the full `vmss` object output has been removed. Targeted
  outputs (`vmss_id`, `vmss_name`, `vmss_unique_id`, `vmss_identity`) cover
  common needs without leaking every resource attribute.

### Added

* New `vmss_identity` object input with `optional()` attributes and
  cross-field validation.
* New outputs: `vmss_name`, `vmss_unique_id`, flat `vmss_identity`
  (principal_id, tenant_id, user_assigned_identity_ids).
* New example `examples/identity_user_assigned/` demonstrating the new
  `vmss_identity` input with a user-assigned managed identity.
* Native `terraform test` suite under `tests/` with plan-only unit tests
  using `mock_provider "azurerm"` — no Azure credentials required.
* `scripts/test-examples.sh` runs init + validate (optionally plan) across
  every example.
* `scripts/test.sh` top-level local test runner.
* Variable validation for `vmss_instances`, `vmss_disk_size_gb`, `vmss_sku`.

### Changed

* Every example now uses `source = "../.."` so in-tree changes are exercised
  end-to-end during testing.
* Examples split `versions.tf` (required providers) from `providers.tf`
  (provider config) for clarity.
* `examples/custom_source_image` parameterizes the Shared Image Gallery name,
  resource group, image definition, and image version (previously hardcoded).
* Pre-commit, TFLint, Checkov, terraform-docs, and GitHub Actions versions
  bumped to current. `terrascan` (archived) removed; Trivy added.
* CI workflow prepared to run `terraform test` (native framework).
* Comment URLs updated from `docs.microsoft.com` to `learn.microsoft.com`.

### Fixed

* Type mismatch on `vmss_auto_upgrade_minor_version` (declared `string`,
  defaulted to `true`).
* Type mismatch on `vmss_enable_automatic_updates` (declared `string`,
  semantically `bool`).
* `vmss_ssh_public_key` empty-string sentinel replaced with `null` for
  consistency with other optional inputs.

## [0.4.0]

* Added initial Windows support
* Added `windows` and `linux-and-windows` examples

## [0.3.2]

* Added `user_data` argument

## [0.3.1]

* Minor documentation updates

## [0.3.0]

* Added data disk support

## [0.2.2]

* Checkov updates

## [0.2.1]

* Fixing terrascan CI failures

## [0.2.0]

* Added support for Linux custom script extension
* Moved provider block
* Updated examples

## [0.1.0]

Initial version
