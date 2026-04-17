# Examples

Each example uses a local module source (`source = "../.."`) so changes to the
module are exercised end-to-end during testing. For registry consumers, the
equivalent source is `tonyskidmore/vmss/azurerm`.

| Name                  | Description                                                                 |
|-----------------------|-----------------------------------------------------------------------------|
| admin_password        | Minimal example: a Linux VMSS authenticated with an admin password.         |
| custom_source_image   | Builds instances from a Shared Image Gallery image (gallery is external).   |
| data_disk             | Linux VMSS with one or more data disks attached.                            |
| identity_user_assigned| Attaches a User Assigned Managed Identity via the new `vmss_identity` input.|
| linux-and-windows     | Deploys both a Linux and a Windows VMSS via `for_each`.                     |
| windows               | Windows VMSS with a custom script extension.                                |

## Running an example

```bash
cd examples/admin_password
terraform init
terraform plan   # requires ARM_SUBSCRIPTION_ID or `az login` context
terraform apply
terraform destroy
```

To validate every example locally without touching Azure:

```bash
./scripts/test-examples.sh
```
