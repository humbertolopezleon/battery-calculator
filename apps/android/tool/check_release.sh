#!/usr/bin/env bash
# Compila el release y comprueba los criterios de PROMPT §4:
# sin permiso INTERNET en el manifiesto del APK y APK arm64-v8a ≤ 10 MB.
# Uso (desde apps/android): tool/check_release.sh
set -euo pipefail
cd "$(dirname "$0")/.."

flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/symbols

APK=build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
SIZE=$(stat -c %s "$APK")
LIMIT=$((10 * 1000 * 1000))
echo "APK arm64-v8a: $SIZE bytes"
if [ "$SIZE" -gt "$LIMIT" ]; then
  echo "ERROR: pasa de 10 MB" >&2
  exit 1
fi

AAPT=$(ls -d "${ANDROID_HOME:-$HOME/Android/Sdk}"/build-tools/*/ | sort -V | tail -1)aapt2
if "$AAPT" dump permissions "$APK" | grep -q 'android.permission.INTERNET'; then
  echo "ERROR: el APK pide INTERNET" >&2
  exit 1
fi
echo "Sin permiso INTERNET. Permisos:"
"$AAPT" dump permissions "$APK"
