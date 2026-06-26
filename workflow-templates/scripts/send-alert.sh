#!/usr/bin/env bash
set -euo pipefail

if [ -z "${SECURITY_ALERT_WEBHOOK_URL:-}" ]; then
  echo "::warning::SECURITY_ALERT_WEBHOOK_URL no configurado; no se pudo enviar alerta externa."
  exit 0
fi

repo_name="${ALERT_REPOSITORY#*/}"
owner_user=""
owner_email=""

if [ -f ".github/devsecops-owner.json" ]; then
  owner_user=$(jq -r '.user // empty' .github/devsecops-owner.json)
  owner_email=$(jq -r '.email // empty' .github/devsecops-owner.json)
fi

if [ -z "$owner_user" ]; then
  owner_user="${repo_name%%_*}"
  if [ -z "$owner_user" ] || [ "$owner_user" = "$repo_name" ]; then
    owner_user="$ALERT_ACTOR"
  fi
fi

if [ -z "$owner_email" ]; then
  owner_email="${owner_user}@casapellas.com"
fi

security_alert_to="ciberseguridad@casapellas.com"
alert_recipients="${security_alert_to};${owner_email}"

payload=$(jq -n \
  --arg repository "$ALERT_REPOSITORY" \
  --arg actor "$ALERT_ACTOR" \
  --arg workflow "$ALERT_WORKFLOW" \
  --arg run_url "$ALERT_RUN_URL" \
  --arg ref "$ALERT_REF" \
  --arg alert_to "$security_alert_to" \
  --arg owner_email "$owner_email" \
  --arg email "$alert_recipients" \
  --arg to "$alert_recipients" \
  '{repository: $repository, actor: $actor, email: $email, workflow: $workflow, ref: $ref, run_url: $run_url, status: "Fallido", alert_to: $alert_to, owner_email: $owner_email, to: $to, emailMessage: {To: $email, Subject: ("Alerta DevSecOps: fallo en " + $repository), Body: ("El workflow DevSecOps fallo en " + $repository + ". Run: " + $run_url)}}')

response_file=$(mktemp)
http_code=$(curl -sS -o "$response_file" -w "%{http_code}" \
  -H "Content-Type: application/json" \
  -d "$payload" \
  "$SECURITY_ALERT_WEBHOOK_URL")

if [ "$http_code" -lt 200 ] || [ "$http_code" -ge 300 ]; then
  echo "::error::El webhook SECURITY_ALERT_WEBHOOK_URL respondio HTTP $http_code."
  cat "$response_file"
  exit 1
fi

echo "::notice::Alerta enviada correctamente a Power Automate."
