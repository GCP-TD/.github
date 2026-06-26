#!/usr/bin/env bash
set -euo pipefail

mapfile -d '' package_files < <(find . -name "package.json" -not -path "*/node_modules/*" -print0)

if [ ${#package_files[@]} -eq 0 ]; then
  echo "::notice::No existe package.json; se omite depcheck."
  exit 0
fi

for pkg in "${package_files[@]}"; do
  dir=$(dirname "$pkg")
  echo "::group::Revisando dependencias huerfanas en: $dir"
  pushd "$dir" > /dev/null

  # Vite/Astro and build tools are usually referenced from package scripts or config files.
  depcheck_ignores="vite,@vitejs/*,astro,typescript,eslint,prettier,tailwindcss,postcss,autoprefixer"
  npx --yes depcheck --json --ignores="$depcheck_ignores" > depcheck-results.json || true

  node <<'NODE'
const fs = require('fs');
let report;
try {
  report = JSON.parse(fs.readFileSync('depcheck-results.json', 'utf8'));
} catch (e) {
  console.error('No se pudo procesar depcheck-results.json.');
  process.exit(0);
}

const unused = [
  ...(report.dependencies || []),
  ...(report.devDependencies || []),
];

if (unused.length > 0) {
  console.error('Se detectaron dependencias no utilizadas en esta ruta:');
  for (const dependency of unused) {
    console.error(`- ${dependency}`);
  }
  process.exit(1);
}
console.log('Todas las dependencias estan en uso correcto.');
NODE

  popd > /dev/null
  echo "::endgroup::"
done
