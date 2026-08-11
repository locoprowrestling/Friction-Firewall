# Friction Firewall

The Friction Firewall is a lightweight operating system for reducing avoidable mistakes in assisted work. It makes the important decision surface visible before execution: what was requested, what must be read, what is protected, what can go wrong, how the work can be rolled back, and what happens next.

It is designed for teams using AI assistants, automation, contractors, or any other workflow where speed can hide assumptions. It is generic by design: adapt the nouns and approval boundaries to your organization.

## Set it up

See [SETUP.md](SETUP.md) for the complete setup guide. It includes a runnable installer for people who want to set up a local copy without an LLM, optional project-scoped Claude hook installation, plus instructions for customizing protected assets and approval boundaries.

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

### Stop before live or destructive changes

Pause before deleting, overwriting, force-writing, publishing, scheduling, uploading, changing permissions, spending money, or modifying a production or customer-facing system. Name the risk, identify the rollback, and obtain the required approval for the environment.

### Protect the baseline

Treat approved releases, production masters, source material, customer records, and canonical data as protected. Work in a branch, copy, draft, staging area, or isolated successor until the result has been reviewed and promoted.

### Keep progress visible

For work expected to take more than five minutes, provide a heartbeat plan: expected duration, process or task identifier, log location, next update time, and the condition for abandoning a weak approach.

### Expose meaningful choices

When a decision is strategic, aesthetic, or irreversible, show the viable options and recommend one. Do not hide a reasonable alternative by making the choice implicitly.

### Reframe repeated failure

After two failed attempts at the same defect, stop parameter-tuning. Compare approaches, change the framing, or request an independent review.

### Verify the artifact

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

Suggested rollout:

1. Use the preflight on one recurring workflow.
2. Record the friction it catches and the friction it misses.
3. Add only rules that prevent a demonstrated failure.
4. Review the rules periodically and remove obsolete ones.

## License

This project is released under the MIT License. See [LICENSE](LICENSE).
