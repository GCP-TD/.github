#!/usr/bin/env bash
set -euo pipefail

mapfile -d '' files < <(find . \
  -type f \( -name '*.js' -o -name '*.mjs' -o -name '*.cjs' \) \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -print0)

if [ "${#files[@]}" -eq 0 ]; then
  echo "No se encontraron archivos JavaScript para validar."
  exit 0
fi

for file in "${files[@]}"; do
  node --check "$file"
done
