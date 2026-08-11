#!/usr/bin/env node
import fs from "node:fs";

const mode = process.argv[2] || "prompt";

function readStdin() {
  try {
    return fs.readFileSync(0, "utf8");
  } catch {
    return "";
  }
}

function parseInput(raw) {
  if (!raw.trim()) return {};
  try {
    return JSON.parse(raw);
  } catch {
    return { raw };
  }
}

function commandFromInput(input) {
  return [
    input.command,
    input.tool_input?.command,
    input.toolInput?.command,
    input.params?.command,
  ].find((value) => typeof value === "string") || "";
}

function hasRollbackLanguage(text) {
  return /\b(FIREWALL_OK|backup|rollback|restore|revert|trash|copy|staging|branch|snapshot)\b/i.test(text);
}

function looksRisky(command) {
  const patterns = [
    /\brm\s+(-[^\s]*r[^\s]*f|-rf|-fr)\b/,
    /\bgit\s+(reset\s+--hard|clean\s+-[^\n]*f|push\s+--force)\b/,
    /\b(chmod|chown)\s+-R\b/,
    /\b(drop\s+database|truncate\s+table)\b/i,
    /\b(curl|wget)\b[\s\S]*\|\s*(sh|bash)\b/,
    /\b(gh|vercel|netlify|firebase|supabase)\b[\s\S]*\b(deploy|delete|remove|publish|release)\b/i,
  ];
  return patterns.some((pattern) => pattern.test(command));
}

if (mode === "pretool") {
  const input = parseInput(readStdin());
  const command = commandFromInput(input);

  if (command && looksRisky(command) && !hasRollbackLanguage(command)) {
    console.error("Friction Firewall blocked a risky command.");
    console.error("Name the backup/rollback or include FIREWALL_OK when the approval boundary has been satisfied.");
    process.exit(2);
  }

  process.exit(0);
}

if (mode === "prompt") {
  console.error("Friction Firewall preflight for non-trivial work:");
  console.error("- Ask:");
  console.error("- Read first:");
  console.error("- Protected assets:");
  console.error("- Destructive or live risk:");
  console.error("- Backup/rollback:");
  console.error("- Estimate:");
  console.error("- Next action:");
  process.exit(0);
}

console.error(`Unknown Friction Firewall hook mode: ${mode}`);
process.exit(2);
