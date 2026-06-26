#!/usr/bin/env bash
set -euo pipefail

echo "::warning::Vulnerabilidad detectada. Iniciando rollback automatico..."
git config --global user.name "DevSecOps Gate"
git config --global user.email "ciberseguridad@casapellas.com"

if git show -s --format=%P "$SHA_TO_REVERT" | grep -q ' '; then
  git revert --no-edit -m 1 "$SHA_TO_REVERT"
else
  git revert --no-edit "$SHA_TO_REVERT"
fi

git push origin "$REF_NAME"
echo "::notice::El codigo vulnerable ha sido revertido exitosamente."
