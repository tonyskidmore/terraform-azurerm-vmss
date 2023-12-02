# Development

The code

## pre-commit

Dev Containers: Re

## GitHub Super-Linter

Download the super-linter container image: `docker pull ghcr.io/super-linter/super-linter:latest`.

> Note uses `.github/super-linter.env` for shared local/GitHub Actions scanning configuration.

````bash

docker run \
  -e ACTIONS_RUNNER_DEBUG=true \
  -e RUN_LOCAL=true \
  -v "$HOME/github/terraform-azurerm-vmss":/tmp/lint \
  ghcr.io/super-linter/super-linter:latest

````

[gha-super-linter-local]: https://github.com/super-linter/super-linter/blob/main/docs/run-linter-locally.md
