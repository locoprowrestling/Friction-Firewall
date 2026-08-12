# Local policy (filled-out example)

This is a worked example, not a template to copy verbatim. It shows the level
of specificity each field needs. Replace every line with your own systems,
owners, and locations before using the firewall for real work. See
`LOCAL-POLICY.md` for the blank version.

Fictional organization used here: "Riverbend Coffee Co.," a small business
with a public marketing site, an online ordering app, and a customer database.
None of the values below are real.

```text
Organization: Riverbend Coffee Co.

Protected assets:
- Production database (customer orders, loyalty accounts)
- Published marketing site (riverbendcoffee.example)
- Brand assets folder (approved logos, photography, style guide)
- Signed vendor contracts (contracts/ shared drive, PDF originals)

Production systems:
- Ordering app: prod branch on GitHub, deployed via Vercel
- Database: managed Postgres (Neon), production project
- Payments: Stripe live mode
- Email: transactional sender via Postmark

Destructive actions:
- Any DELETE or TRUNCATE against the production database
- git push --force to main or any release branch
- Deleting or overwriting brand assets in the shared drive
- Publishing/unpublishing the live marketing site
- Rotating or revoking Stripe/Postmark API keys

Approval owners:
- Database schema changes: Dana (engineering lead)
- Marketing site content/publish: Priya (marketing)
- Payments/billing config: Dana
- Vendor contracts: Owner (Sam)

Backup locations:
- Database: automated daily Neon snapshot, 7-day retention; manual pg_dump
  before any migration, saved to backups/YYYY-MM-DD/ on the shared drive
- Brand assets: versioned in the shared drive's built-in revision history
- Site: previous deploy always redeployable from Vercel's deployment history

Required verification checks:
- Any schema migration: run against a branch database first, verify row
  counts before and after
- Any site publish: check the staging preview URL before promoting to prod
- Any payments-config change: run one $0 test transaction in Stripe test mode

Progress update interval: every 30 minutes on any task expected to run
longer than that, or immediately on hitting a blocker
```

Do not copy this example's protected-asset list, owners, or systems into your
own `LOCAL-POLICY.md`. It is illustrative only, for a fictional business.
