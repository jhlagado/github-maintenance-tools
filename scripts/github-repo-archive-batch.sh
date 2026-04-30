#!/usr/bin/env bash
#
# Archive many repos under one owner using gh.
# Requires: gh auth with permission to archive those repositories.
#
# Usage:
#   OWNER=jhlagado bash scripts/github-repo-archive-batch.sh repo1 repo2 ...
#   printf '%s\n' repo1 repo2 | OWNER=jhlagado bash scripts/github-repo-archive-batch.sh
#
# Lines starting with # and empty lines are ignored when reading stdin.
#
set -euo pipefail

owner="${OWNER:-jhlagado}"

declare -a names=()
if [[ $# -gt 0 ]]; then
  names=("$@")
else
  while IFS= read -r line || [[ -n "${line:-}" ]]; do
    [[ -z "${line// /}" || "${line}" =~ ^# ]] && continue
    names+=("$line")
  done
fi

if [[ ${#names[@]} -eq 0 ]]; then
  exec >&2
  echo "No repository names given."
  echo "Usage: OWNER=${owner} bash $0 <name> [<name> ...]"
  echo "   or: printf '%s\\n' name ... | OWNER=${owner} bash $0"
  exit 1
fi

for r in "${names[@]}"; do
  [[ -z "${r// /}" ]] && continue
  full="${owner}/${r}"
  echo "Archiving ${full}..." >&2
  gh repo archive "${full}" -y
done

echo "Done. Archived ${#names[@]} repo(s) under ${owner}." >&2
