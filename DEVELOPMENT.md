# Development

The GitHub Actions workflow does some basic linting as defined in: `.github/workflows/ci.yml`.

The workflow actions can be replicated locally during development as per the sections below.

## pre-commit

When [Developing inside a Container](https://code.visualstudio.com/docs/devcontainers/containers) has been enabled, in VSCode open  `Dev Containers: Reopen in Container`.

Pre-commit hooks should be installed automatically but if not run:

````bash

pre-commit install

pre-commit install-hooks

````

Pre-commit hooks should now kick in when making local commit.

## GitHub Super-Linter

Download the super-linter container image: `docker pull ghcr.io/super-linter/super-linter:latest`.

> Note uses `.github/super-linter.env` for shared local/GitHub Actions scanning configuration.

Perform the scanning [locally][gha-super-linter-local], for example:

````bash

docker run \
  -e ACTIONS_RUNNER_DEBUG=true \
  -e RUN_LOCAL=true \
  -v "$HOME/github/terraform-azurerm-vmss":/tmp/lint \
  ghcr.io/super-linter/super-linter:latest

````

[gha-super-linter-local]: https://github.com/super-linter/super-linter/blob/main/docs/run-linter-locally.md
