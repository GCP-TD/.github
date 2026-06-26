#!/usr/bin/env bash
set -euo pipefail

if [ -z "${VERCEL_TOKEN:-}" ]; then
  echo "::error::Falta configurar VERCEL_TOKEN o VERCEL_TOKEN_SECRET."
  exit 1
fi

if [ -z "${RESOLVED_PROJECT_ID:-}" ] || [ -z "${VERCEL_TEAM_ID:-}" ]; then
  echo "::error::No se recibio project_id/team_id desde el auto-aprovisionamiento de Vercel."
  exit 1
fi

mkdir -p .vercel
jq -n \
  --arg orgId "$VERCEL_TEAM_ID" \
  --arg projectId "$RESOLVED_PROJECT_ID" \
  '{orgId: $orgId, projectId: $projectId}' > .vercel/project.json

npx --yes vercel@latest deploy --prod --yes --token "$VERCEL_TOKEN"
