#!/usr/bin/env bash
# Genera ios/Flutter/Secrets.xcconfig a partir de .env (Android lee .env directo desde Gradle).
set -euo pipefail
cd "$(dirname "$0")/.."
[ -f .env ] || { echo "Falta .env: copia .env.example a .env y completa la key." >&2; exit 1; }
key=$(grep -E '^GOOGLE_MAPS_API_KEY=' .env | head -1 | cut -d= -f2- | tr -d '"'"'"' \r')
printf 'GOOGLE_MAPS_API_KEY=%s\n' "$key" > ios/Flutter/Secrets.xcconfig
echo "ios/Flutter/Secrets.xcconfig actualizado."
