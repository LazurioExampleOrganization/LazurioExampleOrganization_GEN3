#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This bootstrap script is intended for macOS."
  exit 1
fi

DOCTOR="${SCRIPT_DIR}/doctor.sh"
if [[ ! -x "${DOCTOR}" ]]; then
  echo "Missing executable doctor: ${DOCTOR}"
  exit 2
fi

echo "AgentMint GEN2 bootstrap for macOS"
echo "Delegating workspace initialization to doctor init."
echo

"${DOCTOR}" init "$@"
