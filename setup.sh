#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/Codebase/Scripts"

SETUP_SH="$SCRIPTS_DIR/setup.sh"
UPDATE_SH="$SCRIPTS_DIR/update.sh"
UNINSTALL_SH="$SCRIPTS_DIR/uninstall.sh"
DEFAULT_DEPS_DIR="$PROJECT_ROOT/Codebase/Dependencies"

## Standard Setup indicates first time setup, defines where dependencies should be stored.
## calls projectroot/Codebase/Scripts/setup.sh
##  When calling setup afterwards, passes --path recursively.
##
## --abspath is setup being run by a parent and indicates where the path should install dependencies
## calls projectroot/Codebase/Scripts/setup.sh --abspath
##
## --update is the setup being run as JUST an updater. Verifies git/bins/etc to ensure all
## calls projectroot/Codebase/Scripts/update.sh
##
## --uninstall is the setup being run as JUST an uninstaller.
## calls projectroot/Codebase/Scripts/uninstall.sh

_realpath() {
  if command -v realpath >/dev/null 2>&1; then
    realpath "$1"
  else
    python3 -c "import os,sys;print(os.path.abspath(sys.argv[1]))" "$1"
  fi
}

MODE=""
PATH_ARG=""
EXTRA_ARGS=()

while (( $# )); do
  case "$1" in
    --update|--uninstall)
      MODE="$1"
      shift
      ;;
    --abspath|--path)
      MODE="$1"
      PATH_ARG="$2"
      shift 2
      ;;
    *)
      EXTRA_ARGS+=("$1")
      shift
      ;;
  esac
done

case "${MODE:-}" in
  "")  # First-time setup
      echo "Starting setup"
      exec "$SETUP_SH" --path "$(_realpath "$DEFAULT_DEPS_DIR")" "${EXTRA_ARGS[@]}"
      ;;
  --path)
      echo "Starting setup (with path)"
      exec "$SETUP_SH" --path "$(_realpath "$PATH_ARG")" "${EXTRA_ARGS[@]}"
      ;;
  --abspath)
      echo "Starting setup (with absolute path)"
      case "$PATH_ARG" in
        /*) ABS="$PATH_ARG" ;;
        *)  ABS="$(_realpath "$PATH_ARG")" ;;
      esac
      exec "$SETUP_SH" --abspath "$ABS" "${EXTRA_ARGS[@]}"
      ;;
  --update)
      echo "Starting update"
      exec "$UPDATE_SH" "${EXTRA_ARGS[@]}"
      ;;
  --uninstall)
      echo "Starting uninstall"
      exec "$UNINSTALL_SH" "${EXTRA_ARGS[@]}"
      ;;
esac
