# Friction Firewall setup guide

This guide is for a person or team adopting the Friction Firewall independently. The included installer creates a local policy pack; no LLM or account is required.

## Quick install

From a checkout of this repository, run:

```sh
./setup.sh "$HOME/friction-firewall"
```

Or choose any destination directory:

```sh
./setup.sh /path/to/my-project/.friction-firewall
```

The installer creates:

```text
<destination>/
├── FRICTION-FIREWALL.md  # operating rules and preflight
├── LOCAL-POLICY.md       # fill in your organization’s specifics
└── TASK-PREFLIGHT.md     # copy for each non-trivial task
```

It does not contact an external service, install dependencies, or overwrite existing files. To replace files intentionally, use `--force`:

```sh
./setup.sh --force /path/to/my-project/.friction-firewall
```

After installation, open `LOCAL-POLICY.md`, fill it in, and use `TASK-PREFLIGHT.md` at the start of your next reversible task.

## 1. Copy the core files

If you do not want to use the installer, copy `FRICTION-FIREWALL.md`, `LOCAL-POLICY.md`, and `TASK-PREFLIGHT.md` into the place where your team keeps operating procedures. If you use an AI assistant, place the firewall instructions in the assistant's project instructions or task template. If you use human operators, make the preflight block a required section in the work-request form.

Keep the generic README unchanged when possible. Put organization-specific rules in a separate local document so updates to the core firewall can be pulled in cleanly.

## 2. Define your local adapter

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

Do not copy another organization’s protected-asset list blindly. The list is useful only if it matches your actual systems and responsibilities.

## 3. Add the preflight to your workflow

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

## 4. Set approval boundaries

Mark which actions can proceed automatically and which require a named approval. At minimum, require approval before:

- deleting or overwriting data;
- publishing, scheduling, uploading, or sending external communications;
- changing privacy, permissions, production configuration, or paid services;
- modifying an approved baseline or canonical source;
- taking an action whose rollback is unknown.

The firewall does not replace your security, privacy, legal, or change-management policies. It is the checkpoint that makes those policies visible at the moment of action.

## 5. Run a first test

Choose a small, reversible task such as drafting an internal document or making a change on a feature branch. Have the operator complete the preflight, perform the work, and verify the actual result.

Record:

```text
Task:
Friction caught:
Risk that was clarified:
Verification performed:
Rule to add or remove:
```

Do not begin with a live deployment, irreversible migration, customer communication, or deletion test.

## 6. Maintain the system

Review the local adapter after incidents, near misses, or changes to your systems. Add a rule only when it prevents a demonstrated failure or closes a real ambiguity. Remove rules that no longer match reality. Keep the core preflight short enough that people will actually use it.

## Definition of ready

A team is ready to use the Friction Firewall when it has:

- a local protected-assets and approval list;
- a named rollback or backup convention;
- the preflight embedded in its task workflow;
- a first reversible task completed with artifact verification;
- an owner for reviewing the rules.
