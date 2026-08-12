# Friction Firewall setup guide

Run this from a checkout of the repository:

```sh
./setup.sh --claude-hooks --codex /path/to/my-project/.friction-firewall
```

That is the fastest complete setup for a Claude Code project. It copies the files and creates project-scoped hooks.

Time needed: about 2 minutes to install, 10 to 20 minutes to fill in the local policy.

## Quick install

For a project with Claude hooks:

```sh
./setup.sh --claude-hooks --codex /path/to/my-project/.friction-firewall
```

For a project where `.claude/` already exists, this also works:

```sh
./setup.sh /path/to/my-project/.friction-firewall
```

For files only, with no hook changes:

```sh
./setup.sh --no-hooks /path/to/my-project/.friction-firewall
```

The installer creates:

```text
<destination>/
├── FRICTION-FIREWALL.md  # operating rules and preflight
├── LOCAL-POLICY.md       # fill in your organization’s specifics
├── TASK-PREFLIGHT.md     # copy for each non-trivial task
└── friction-firewall-hook.mjs
```

## Hook install behavior

When hooks are enabled, `setup.sh` edits `/path/to/my-project/.claude/settings.local.json`.

It does five things:

1. Creates `/path/to/my-project/.claude/` if `--claude-hooks` is used.
2. Preserves existing hook entries.
3. Adds one `UserPromptSubmit` hook for the preflight reminder.
4. Adds one `PreToolUse` Bash hook for risky command checks.
5. Avoids adding duplicate Friction Firewall hooks on repeat installs.

It does not add global hooks.

## What gets blocked

The Bash hook blocks obvious risky commands when they do not name rollback or approval language. Examples include recursive force deletion, hard git resets, forced pushes, broad recursive ownership changes, and deployment/delete commands from common CLIs.

To proceed after the approval boundary is satisfied, name the rollback in the command or include `FIREWALL_OK`:

```sh
FIREWALL_OK git push --force-with-lease
```

Use the override only after the backup, rollback, or approval is real.

## Overwrite behavior

It does not contact an external service, install dependencies, or overwrite existing files. To replace files intentionally, use `--force`:

```sh
./setup.sh --force /path/to/my-project/.friction-firewall
```

## First setup pass

1. Run `./setup.sh --claude-hooks --codex /path/to/my-project/.friction-firewall`.
2. Open `/path/to/my-project/.friction-firewall/LOCAL-POLICY.md`.
3. Fill in protected assets, approval owners, rollback locations, and verification checks.
4. Run one small reversible task using the preflight.
5. Record what the firewall caught or missed.

Do not begin with a live deployment, irreversible migration, customer communication, or deletion test.

## Manual setup

If you do not want to use the installer, copy `FRICTION-FIREWALL.md`, `LOCAL-POLICY.md`, and `TASK-PREFLIGHT.md` into the place where your team keeps operating procedures. If you use an AI assistant, place the firewall instructions in the assistant's project instructions or task template. If you use human operators, make the preflight block a required section in the work-request form.

Keep the generic README unchanged when possible. Put organization-specific rules in a separate local document so updates to the core firewall can be pulled in cleanly.

## Local policy fields

Create a short local policy answering these questions:

```text
Organization:
Protected assets:
Production systems:
Destructive actions:
Approval owners:
Backup locations:
Required verification checks:
Progress update interval:
```

Examples of protected assets include production databases, approved brand files, customer records, release branches, financial data, and source footage. Examples of approval owners include the project owner, release manager, data owner, or account administrator.

See [LOCAL-POLICY.example.md](LOCAL-POLICY.example.md) for a filled-out,
anonymized example of a completed policy at this level of detail.

Do not copy another organization’s protected-asset list blindly. The list is useful only if it matches your actual systems and responsibilities.

## Preflight block

Put this block at the beginning of every non-trivial task:

```text
Friction Firewall:
- Ask: <what was requested>
- Read first: <relevant docs, records, or context>
- Protected assets: <what must not be harmed>
- Destructive or live risk: <yes/no; name the risk>
- Backup/rollback: <how the change can be undone>
- Estimate: <measured range or UNMEASURED>
- Next action: <one action only>
```

For an AI assistant, require the assistant to show this block before it edits files, calls an external service, or changes live state. For a human team, make the block a required section in the ticket or task description.

## Approval boundaries

Mark which actions can proceed automatically and which require a named approval. At minimum, require approval before:

- deleting or overwriting data;
- publishing, scheduling, uploading, or sending external communications;
- changing privacy, permissions, production configuration, or paid services;
- modifying an approved baseline or canonical source;
- taking an action whose rollback is unknown.

The firewall does not replace your security, privacy, legal, or change-management policies. It is the checkpoint that makes those policies visible at the moment of action.

## First test record

After the first reversible task, record:

```text
Task:
Friction caught:
Risk that was clarified:
Verification performed:
Rule to add or remove:
```

## Maintenance

Review the local adapter after incidents, near misses, or changes to your systems. Add a rule only when it prevents a demonstrated failure or closes a real ambiguity. Remove rules that no longer match reality. Keep the core preflight short enough that people will actually use it.

## Definition of ready

A team is ready to use the Friction Firewall when it has:

- a local protected-assets and approval list;
- a named rollback or backup convention;
- the preflight embedded in its task workflow;
- a first reversible task completed with artifact verification;
- an owner for reviewing the rules.
