#!/usr/bin/env bash

cd "${0%/*}/../"

npx prettier --prose-wrap=always --print-width=80 --write '**/*.md'
npx prettier --print-width=100 --write '**/*.yaml'
terraform fmt -recursive