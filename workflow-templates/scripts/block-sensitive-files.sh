#!/usr/bin/env bash
set -euo pipefail

blocked_files=$(git ls-files | grep -E '(^|/)\.env($|\.|/)|(^|/).*\.(pem|p12|pfx|key)$|(^|/)id_rsa$|(^|/)id_ed25519$|(^|/)credentials\.json$|(^|/)service-account.*\.json$' | grep -vE '(^|/)\.env\.example$' || true)

if [ -n "$blocked_files" ]; then
  echo "::error::Archivos sensibles versionados detectados. No se permite publicar .env, llaves privadas, certificados ni credenciales."
  printf '%s\n' "$blocked_files"
  exit 1
fi
