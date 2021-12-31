#!/usr/bin/env bash

# Assume all manifests are .yaml for helm values files.
exec find . -type f -name '*.yaml' -exec kubectl diff -f {} \; | less
