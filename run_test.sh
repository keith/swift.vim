#!/bin/bash

set -euo pipefail

tempdir=$(mktemp -d)
trap cleanup EXIT

cleanup() {
  rm -r "$tempdir"
}

for example_file in example/*.swift; do
  autoindented_file="$tempdir/${example_file##*/}"
  OUTPUT_FILE="$autoindented_file" vim -u autoindent.vim "$example_file"
  diff -u --color=auto "$example_file" "$autoindented_file"
done

echo "test passed!"
