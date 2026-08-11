# Friction Firewall

Before non-trivial work begins, state the following:

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

Stop before deleting, overwriting, force-writing, publishing, scheduling, uploading, changing permissions, spending money, or modifying production/customer-facing state. Name the risk, identify the rollback, and obtain the required approval.

Protect approved releases, production masters, source material, customer records, and canonical data. Use a branch, copy, draft, staging area, or isolated successor until reviewed.

For work expected to take more than five minutes, state the expected duration, task or process identifier, log location, next update time, and fallback condition.

After two failed attempts at the same defect, stop tuning and reframe the approach or request an independent review.

Verify the actual artifact, not only its filename, dimensions, metadata, exit code, or generated text.
