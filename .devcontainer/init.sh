#!/bin/bash

owner=$(stat -c '%U' "$HOME/.pre-commit")

if [[ "$owner" == "root" ]]
then
  sudo chown vscode:vscode "$HOME/.pre-commit"
  pre-commit install
  pre-commit install-hooks
fi

# command -v tflint > /dev/null && [[ -f .tflint.hcl ]] && tflint --init
