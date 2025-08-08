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

# Get allowed platforms from JSON
ALLOWED_PLATFORMS=$(jq -r '.compatibility.platforms[]' "$CONFIG_FILE")

normalize_platform() {
  case "$(uname -s)" in
    Linux)   echo "linux" ;;
    Darwin)  echo "darwin" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *)       echo "unknown" ;;
  esac
}

main() {
  platform="$(normalize_platform)"

  if echo "$ALLOWED_PLATFORMS" | grep -qx "$platform"; then
    echo "[OK] Platform '$platform' is supported."
    exit 0
  else
    echo "[FAIL] Platform '$platform' is NOT supported. Allowed: $ALLOWED_PLATFORMS"
    exit 1
  fi
}

main "$@"
