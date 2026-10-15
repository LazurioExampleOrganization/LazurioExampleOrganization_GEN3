#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "AgentMint GEN2 workspace update"
echo "Workspace root: ${ROOT_DIR}"
echo

if ! command -v git >/dev/null 2>&1; then
  echo "Missing dependency: git"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Missing dependency: jq"
  exit 1
fi

if [[ -n "$(git -C "${ROOT_DIR}" status --porcelain)" ]]; then
  echo "Root workspace is dirty. Refusing to run update automatically."
  exit 1
fi

git -C "${ROOT_DIR}" pull --ff-only

MANIFEST="${ROOT_DIR}/company/scripts/modules.manifest.json"
if [[ ! -f "${MANIFEST}" ]]; then
  echo "No modules manifest found. Nothing else to update."
  exit 0
fi

# Update each active nested repo declared in modules.manifest.json.
jq -r '.module_slots[] | select(.git.url? and .git.url != "") | [.path, .git.url, (.git.branch // "main")] | @tsv' "${MANIFEST}" |
while IFS=$'\t' read -r module url branch; do
  module_dir="${ROOT_DIR}/${module}"

  if [[ ! -d "${module_dir}/.git" && ! -f "${module_dir}/.git" ]]; then
    mkdir -p "$(dirname "${module_dir}")"
    if git clone --branch "${branch}" "${url}" "${module_dir}" >/dev/null 2>&1; then
      echo "[cloned] ${module}"
    else
      echo "[skipped_unavailable_or_no_access] ${module}"
    fi
    continue
  fi

  if [[ -n "$(git -C "${module_dir}" status --porcelain 2>/dev/null || true)" ]]; then
    echo "[skipped_dirty] ${module}"
    continue
  fi

  if git -C "${module_dir}" pull --ff-only origin "${branch}" >/dev/null 2>&1; then
    echo "[updated] ${module}"
  else
    echo "[skipped_unavailable_or_no_access] ${module}"
  fi
done
