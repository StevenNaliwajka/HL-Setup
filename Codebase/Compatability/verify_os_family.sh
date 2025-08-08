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

version_ge() {
  [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

detect_platform() {
  case "$(uname -s)" in
    Linux)   echo "linux" ;;
    Darwin)  echo "darwin" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *)       echo "unknown" ;;
  esac
}

detect_linux_family_and_version() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    local id="${ID:-unknown}"
    local ver="${VERSION_ID:-0}"

    case "$id" in
      debian) echo "debian $ver" ;;
      ubuntu) echo "debian $ver" ;; # Ubuntu → Debian
      rhel|redhatenterpriseserver) echo "rhel $ver" ;;
      rocky|almalinux|centos|centosstream) echo "rhel $ver" ;;
      alpine)
        if [ -f /etc/alpine-release ]; then
          echo "alpine $(cat /etc/alpine-release)"
        else
          echo "alpine $ver"
        fi
        ;;
      *) echo "unknown 0" ;;
    esac
  else
    echo "unknown 0"
  fi
}

detect_darwin_version() {
  sw_vers -productVersion 2>/dev/null || echo "0"
}

detect_windows_version() {
  if command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -Command "[System.Environment]::OSVersion.Version.ToString()" | tr -d '\r'
  else
    echo "0"
  fi
}

main() {
  platform="$(detect_platform)"

  case "$platform" in
    linux)
      read -r family ver <<<"$(detect_linux_family_and_version)"
      min="$(jq -r --arg fam "$family" '.compatibility.os_family[$fam].min // empty' "$CONFIG_FILE")"

      if [[ -z "$min" ]]; then
        echo "[FAIL] Linux family '$family' not supported in config."
        exit 1
      fi
      if version_ge "$ver" "$min"; then
        echo "[OK] $family $ver >= $min"
        exit 0
      else
        echo "[FAIL] $family $ver < $min"
        exit 1
      fi
      ;;
    darwin)
      ver="$(detect_darwin_version)"
      min="$(jq -r '.compatibility.os_family.darwin.min' "$CONFIG_FILE")"
      if version_ge "$ver" "$min"; then
        echo "[OK] macOS $ver >= $min"
        exit 0
      else
        echo "[FAIL] macOS $ver < $min"
        exit 1
      fi
      ;;
    windows)
      ver="$(detect_windows_version)"
      min="$(jq -r '.compatibility.os_family.windows.min' "$CONFIG_FILE")"
      major="${ver%%.*}"
      if [[ "$major" =~ ^[0-9]+$ ]] && [ "$major" -ge "$min" ]; then
        echo "[OK] Windows $ver >= $min"
        exit 0
      else
        echo "[FAIL] Windows $ver < $min"
        exit 1
      fi
      ;;
    *)
      echo "[FAIL] Unknown platform."
      exit 1
      ;;
  esac
}

main "$@"
