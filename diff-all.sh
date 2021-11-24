#!/usr/bin/env bash

# Assume all manifests are .yml, .yaml for helm values files.
exec find . -type f -name '*.yml' -exec kubectl diff -f {} \; | less
