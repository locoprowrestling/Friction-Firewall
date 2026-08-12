#!/usr/bin/env bash
set -euo pipefail

force=0
install_claude_hooks=auto
install_codex=auto

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
    --codex)
      install_codex=1
      shift
      ;;
    --no-codex)
      install_codex=0
      shift
      ;;
    --help)
      echo "Usage: $0 [--force] [--claude-hooks|--no-hooks] [--codex|--no-codex] DESTINATION"
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
  echo "Usage: $0 [--force] [--claude-hooks|--no-hooks] [--codex|--no-codex] DESTINATION"
  exit 0
fi
if [[ -z "$destination" ]]; then
  echo "Usage: $0 [--force] [--claude-hooks|--no-hooks] [--codex|--no-codex] DESTINATION" >&2
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

if [[ "$install_codex" == "auto" ]]; then
  if [[ -f "$project_dir/AGENTS.md" ]]; then install_codex=1; else install_codex=0; fi
fi

codex_agents="$project_dir/AGENTS.md"
codex_start="<!-- friction-firewall:codex:start -->"
codex_end="<!-- friction-firewall:codex:end -->"
if [[ "$install_codex" -eq 1 ]]; then
  if [[ ! -e "$codex_agents" ]]; then
    printf '# Agent Instructions\n\n' > "$codex_agents"
  fi
  CODEX_AGENTS_PATH="$codex_agents" CODEX_HOOK_PATH="$destination_abs/friction-firewall-hook.mjs" CODEX_START="$codex_start" CODEX_END="$codex_end" node <<'NODE'
const fs = require("node:fs");
const file = process.env.CODEX_AGENTS_PATH;
const hook = process.env.CODEX_HOOK_PATH;
const start = process.env.CODEX_START;
const end = process.env.CODEX_END;
let content = fs.readFileSync(file, "utf8");
const block = `${start}
## Friction Firewall for Codex

Before non-trivial work, run:

\`\`\`sh
node "${hook}" prompt
\`\`\`

Then state Ask, Read first, Protected assets, Destructive or live risk,
Backup/rollback, Estimate, and Next action. Prepare a Ready Packet before
handing a human a live UI or manual workflow. Use machine-first handoffs,
verify actual artifacts or live readbacks, and stop after two failed attempts
on the same defect to question the approach. Codex does not have a universal
harness-enforced pretool hook, so treat destructive and live-state commands as
manual hard stops requiring a named rollback and approval when appropriate.
${end}`;
const escaped = start.replace(/[.*+?^${}()|[\\]\\\\]/g, "\\\\$&");
const pattern = new RegExp(`${escaped}[\\s\\S]*?${end.replace(/[.*+?^${}()|[\\]\\\\]/g, "\\\\$&")}`);
if (pattern.test(content)) content = content.replace(pattern, block);
else content = `${content.trimEnd()}\n\n${block}\n`;
fs.writeFileSync(file, content);
NODE
fi

echo "Installed Friction Firewall pack in: $destination_abs"
if [[ "$install_claude_hooks" -eq 1 ]]; then
  echo "Merged Claude project hooks into: $claude_settings"
else
  echo "No Claude project hooks found; skipped hook merge."
  echo "Use --claude-hooks to create $claude_settings."
fi
if [[ "$install_codex" -eq 1 ]]; then
  echo "Merged Codex instructions into: $codex_agents"
else
  echo "Skipped Codex instructions. Use --codex to create or update $codex_agents."
fi
echo "Next: edit $destination_abs/LOCAL-POLICY.md"
