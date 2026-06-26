#!/usr/bin/env bash
set -euo pipefail

if git rev-parse HEAD^ >/dev/null 2>&1; then
  changed_files=$(git diff --name-only HEAD^ HEAD)
else
  changed_files=$(git ls-files)
fi

app_files=$(printf '%s\n' "$changed_files" | grep -vE '^$|^\.github/workflows/seguridad-vercel\.yml$|^\.github/devsecops/' || true)

if [ -n "$app_files" ]; then
  echo "changed=true" >> "$GITHUB_OUTPUT"
  echo "Archivos de aplicacion detectados:"
  printf '%s\n' "$app_files"
else
  echo "changed=false" >> "$GITHUB_OUTPUT"
  echo "Solo cambio el workflow corporativo; se omite despliegue."
fi
