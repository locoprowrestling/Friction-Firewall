#!/usr/bin/env bash
set -euo pipefail

force=0
install_claude_hooks=auto

while [[ "${1:-}" == --* ]]; do
  case "$1" in
    --force)
      force=1
      shift
      ;;
    --claude-hooks)
      install_claude_hooks=1
      shift
      ;;
    --no-hooks)
      install_claude_hooks=0
      shift
      ;;
    --help)
      echo "Usage: $0 [--force] [--claude-hooks|--no-hooks] DESTINATION"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--force] [--claude-hooks|--no-hooks] DESTINATION" >&2
      exit 2
      ;;
  esac
done

destination="${1:-}"
if [[ "$destination" == "-h" ]]; then
  echo "Usage: $0 [--force] [--claude-hooks|--no-hooks] DESTINATION"
  exit 0
fi
if [[ -z "$destination" ]]; then
  echo "Usage: $0 [--force] [--claude-hooks|--no-hooks] DESTINATION" >&2
  echo "Install a local Friction Firewall pack without external services." >&2
  exit 2
fi

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
mkdir -p "$destination"

for file in FRICTION-FIREWALL.md LOCAL-POLICY.md TASK-PREFLIGHT.md friction-firewall-hook.mjs; do
  target="$destination/$file"
  if [[ -e "$target" && "$force" -ne 1 ]]; then
    echo "Refusing to overwrite existing file: $target" >&2
    echo "Use --force only if replacing it is intentional." >&2
    exit 1
  fi
  cp "$script_dir/$file" "$target"
done
chmod +x "$destination/friction-firewall-hook.mjs"

destination_abs="$(CDPATH= cd -- "$destination" && pwd)"
project_dir="$destination_abs"
if [[ "$(basename -- "$destination_abs")" == ".friction-firewall" ]]; then
  project_dir="$(dirname -- "$destination_abs")"
fi

claude_settings="$project_dir/.claude/settings.local.json"
if [[ "$install_claude_hooks" == "auto" ]]; then
  if [[ -d "$project_dir/.claude" || -f "$claude_settings" ]]; then
    install_claude_hooks=1
  else
    install_claude_hooks=0
  fi
fi

if [[ "$install_claude_hooks" -eq 1 ]]; then
  mkdir -p "$project_dir/.claude"
  SETTINGS_PATH="$claude_settings" HOOK_PATH="$destination_abs/friction-firewall-hook.mjs" node <<'NODE'
const fs = require("node:fs");

const settingsPath = process.env.SETTINGS_PATH;
const hookPath = process.env.HOOK_PATH;
const promptCommand = `node "${hookPath}" prompt`;
const pretoolCommand = `node "${hookPath}" pretool`;

let settings = {};
if (fs.existsSync(settingsPath)) {
  settings = JSON.parse(fs.readFileSync(settingsPath, "utf8"));
}

settings.hooks = settings.hooks && typeof settings.hooks === "object" ? settings.hooks : {};

function ensureHook(eventName, matcher, command) {
  const entries = Array.isArray(settings.hooks[eventName]) ? settings.hooks[eventName] : [];
  const alreadyPresent = entries.some((entry) =>
    Array.isArray(entry.hooks) &&
    entry.hooks.some((hook) => hook && hook.type === "command" && hook.command === command)
  );
  if (!alreadyPresent) {
    entries.push({
      matcher,
      hooks: [
        {
          type: "command",
          command,
          timeout: 5,
        },
      ],
    });
  }
  settings.hooks[eventName] = entries;
}

ensureHook("UserPromptSubmit", "", promptCommand);
ensureHook("PreToolUse", "Bash", pretoolCommand);

fs.writeFileSync(settingsPath, `${JSON.stringify(settings, null, 2)}\n`);
NODE
fi

echo "Installed Friction Firewall pack in: $destination_abs"
if [[ "$install_claude_hooks" -eq 1 ]]; then
  echo "Merged Claude project hooks into: $claude_settings"
else
  echo "No Claude project hooks found; skipped hook merge."
  echo "Use --claude-hooks to create $claude_settings."
fi
echo "Next: edit $destination_abs/LOCAL-POLICY.md"
