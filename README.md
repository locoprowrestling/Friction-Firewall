# Friction Firewall

Install into a project:

```sh
./setup.sh --claude-hooks /path/to/my-project/.friction-firewall
```

That command copies the Friction Firewall files and creates project-scoped Claude hooks. It does not install global hooks, contact external services, or require an LLM.

## What it does

The Friction Firewall reduces avoidable mistakes in assisted work by making the execution boundary visible before action:

1. What was requested.
2. What must be read first.
3. What is protected.
4. What can go wrong.
5. How the work can be rolled back.

It is designed for teams using AI assistants, automation, contractors, or any workflow where speed can hide assumptions. It is generic by design: adapt the nouns and approval boundaries to your organization.

## Setup path

1. Clone or download this repository.
2. Run `./setup.sh --claude-hooks /path/to/my-project/.friction-firewall`.
3. Edit `/path/to/my-project/.friction-firewall/LOCAL-POLICY.md`.
4. Start the next non-trivial task with the preflight block.

See [SETUP.md](SETUP.md) for the complete setup guide.

## Hook behavior

When Claude project hooks are installed:

1. `UserPromptSubmit` prints the preflight fields at the start of each prompt.
2. `PreToolUse` checks Bash commands before execution.
3. Obvious risky commands are blocked unless they name backup/rollback language or include `FIREWALL_OK`.
4. Existing Claude hook entries are preserved.
5. The same Friction Firewall hook commands are not added twice.

## The core preflight

Before non-trivial work begins, state these fields plainly:

```text
Friction Firewall:
- Ask: <what was requested>
- Read first: <relevant docs, records, or context>
- Protected assets: <baselines, source material, customer data, or live state>
- Destructive or live risk: <yes/no; name the risk>
- Backup/rollback: <backup path, recovery method, or why none is needed>
- Estimate: <measured range or UNMEASURED>
- Next action: <one action only>
```

If a field cannot be filled, the next action is to inspect, read, or ask for the missing fact. Do not silently improvise through an unknown.

## Operating rules

### 1. Stop before live or destructive changes

Pause before deleting, overwriting, force-writing, publishing, scheduling, uploading, changing permissions, spending money, or modifying a production or customer-facing system. Name the risk, identify the rollback, and obtain the required approval for the environment.

### 2. Protect the baseline

Treat approved releases, production masters, source material, customer records, and canonical data as protected. Work in a branch, copy, draft, staging area, or isolated successor until the result has been reviewed and promoted.

### 3. Keep progress visible

For work expected to take more than five minutes, provide a heartbeat plan: expected duration, process or task identifier, log location, next update time, and the condition for abandoning a weak approach.

### 4. Expose meaningful choices

When a decision is strategic, aesthetic, or irreversible, show the viable options and recommend one. Do not hide a reasonable alternative by making the choice implicitly.

### 5. Reframe repeated failure

After two failed attempts at the same defect, stop parameter-tuning. Compare approaches, change the framing, or request an independent review.

### Verify before done

Do not call work complete from an exit code, filename, dimensions, metadata, or generated text alone. Inspect the actual result using the appropriate check: preview the image, inspect representative video frames, listen to audio or perform a concrete audio check, read back live state, or reopen the saved document.

## Risk levels

Use the smallest level that accurately describes the work:

| Level | Typical work | Required behavior |
| --- | --- | --- |
| Low | Read-only inspection, reversible local draft | State the preflight and run a focused check |
| Medium | Multi-file edits, generated assets, internal data changes | Preserve a rollback point and verify the artifact |
| High | Production changes, external communication, privacy, money, deletion | Stop at the approval boundary; require explicit authorization |

## Adoption

Start with the preflight block in the team’s task template or assistant instructions. Add local rules for protected systems and approval owners. Keep the generic core stable, and put organization-specific details in a separate policy or adapter document.

Next action after installation: edit `LOCAL-POLICY.md`, then run one small reversible task through the firewall.

## License

This project is released under the MIT License. See [LICENSE](LICENSE).
