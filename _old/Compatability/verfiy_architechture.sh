#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"
CONFIG_FILE="$ROOT_DIR/Config/compatabillity.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[FAIL] Config file not found: $CONFIG_FILE"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[FAIL] 'jq' is required but not installed."
  exit 1
fi

# Get allowed architectures from JSON
ALLOWED_ARCHS=$(jq -r '.compatibility.architectures[]' "$CONFIG_FILE")

normalize_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo "x86_64" ;;
    arm64|aarch64) echo "arm64" ;;
    *) echo "unknown" ;;
  esac
}

main() {
  arch="$(normalize_arch)"

  if echo "$ALLOWED_ARCHS" | grep -qx "$arch"; then
    echo "[OK] Architecture '$arch' is supported."
    exit 0
  else
    echo "[FAIL] Architecture '$arch' is NOT supported. Allowed: $ALLOWED_ARCHS"
    exit 1
  fi
}

main "$@"
