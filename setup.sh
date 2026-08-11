#!/usr/bin/env bash
set -euo pipefail

force=0
if [[ "${1:-}" == "--force" ]]; then
  force=1
  shift
fi

destination="${1:-}"
if [[ "$destination" == "--help" || "$destination" == "-h" ]]; then
  echo "Usage: $0 [--force] DESTINATION"
  exit 0
fi
if [[ -z "$destination" ]]; then
  echo "Usage: $0 [--force] DESTINATION" >&2
  echo "Install a local Friction Firewall pack without external services." >&2
  exit 2
fi

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
mkdir -p "$destination"

for file in FRICTION-FIREWALL.md LOCAL-POLICY.md TASK-PREFLIGHT.md; do
  target="$destination/$file"
  if [[ -e "$target" && "$force" -ne 1 ]]; then
    echo "Refusing to overwrite existing file: $target" >&2
    echo "Use --force only if replacing it is intentional." >&2
    exit 1
  fi
  cp "$script_dir/$file" "$target"
done

echo "Installed Friction Firewall pack in: $destination"
echo "Next: edit $destination/LOCAL-POLICY.md"
