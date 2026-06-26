#!/usr/bin/env bash
set -euo pipefail

cat > .gitleaks-ci.toml <<'EOF'
title = "Corporate DevSecOps Gitleaks Config - Strict"

[extend]
useDefault = true

[[rules]]
id = "corporate-strict-hardcoded-secret"
description = "Detects generic hardcoded credentials in English and Spanish, including short or weak values."
regex = '''(?i)(?:secret|token|api[_-]?key|access[_-]?key|client[_-]?secret|private[_-]?key|password|passwd|pwd|llave|clave|contrasena|secreto)[A-Za-z0-9_-]*\s*[:=]\s*['"`]([A-Za-z0-9_./+=:@-]{4,})['"`]'''
secretGroup = 1
keywords = [
  "secret",
  "token",
  "api_key",
  "apikey",
  "access_key",
  "client_secret",
  "private_key",
  "password",
  "passwd",
  "pwd",
  "llave",
  "clave",
  "contrasena",
  "secreto"
]
EOF
