# Integration tests

These tests use the native `terraform test` framework with `command = apply`
to deploy each example against a real Azure subscription, assert on outputs,
then let Terraform automatically destroy the resources on teardown.

Unlike the unit tests in `tests/*.tftest.hcl` (which use `mock_provider
"azurerm"` and run offline), integration tests:

* Require Azure credentials (`az login` or `ARM_SUBSCRIPTION_ID`+friends).
* Incur a small Azure cost per run (a few minutes of a non-running VMSS).
* Take several minutes each (provider download + create + destroy).

## Running

Use the wrapper, which validates credentials and prompts before applying:

```bash
# All integration tests (prompts once for confirmation)
scripts/test-integration.sh

# Just one example
scripts/test-integration.sh admin_password

# Skip the confirmation prompt (for CI)
scripts/test-integration.sh --yes
```

## What's covered

| Test file                                 | Exercises                                                   |
|-------------------------------------------|-------------------------------------------------------------|
| admin_password.tftest.hcl                 | Baseline Linux VMSS creation via the admin_password example |
| data_disk.tftest.hcl                      | Data disk propagation (number type after the 1.0.0 fix)     |
| identity_user_assigned.tftest.hcl         | The new `vmss_identity` object with a user-assigned MI      |

The `custom_source_image`, `linux-and-windows`, and `windows` examples are not
yet integration-tested — custom_source_image needs a pre-existing Shared Image
Gallery, linux-and-windows takes the longest due to multi-deployment
`for_each`, and windows images pull slow.

## If a test fails mid-apply

`terraform test` attempts to destroy on failure. If destroy also fails (Azure
throttling, etc.), delete the test resource group manually:

```bash
az group delete --name rg-vmss-tftest-adminpw-01 --yes --no-wait
```

Resource group names follow `rg-vmss-tftest-<suffix>-01` for easy cleanup.
