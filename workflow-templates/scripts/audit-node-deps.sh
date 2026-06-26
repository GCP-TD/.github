#!/usr/bin/env bash
set -euo pipefail

mapfile -d '' package_files < <(find . -name "package.json" -not -path "*/node_modules/*" -print0)

if [ ${#package_files[@]} -eq 0 ]; then
  echo "::notice::No existe package.json en ningun directorio; se omite auditoria Node.js."
  exit 0
fi

corepack enable || true

for pkg in "${package_files[@]}"; do
  dir=$(dirname "$pkg")
  echo "::group::Auditando directorio: $dir"
  pushd "$dir" > /dev/null

  if [ -f pnpm-lock.yaml ]; then
    echo "Proyecto pnpm detectado. Instalando y auditando con pnpm."
    corepack prepare pnpm@10 --activate
    pnpm install --frozen-lockfile --ignore-scripts
    pnpm audit --audit-level high
  elif [ -f package-lock.json ] || [ -f npm-shrinkwrap.json ]; then
    echo "Proyecto npm con lockfile detectado. Instalando y auditando con npm."
    npm ci --ignore-scripts
    npm audit --audit-level=high
  else
    echo "Proyecto npm sin lockfile detectado. Generando package-lock temporal para auditoria."
    npm install --package-lock-only --ignore-scripts
    npm audit --audit-level=high
  fi

  popd > /dev/null
  echo "::endgroup::"
done
