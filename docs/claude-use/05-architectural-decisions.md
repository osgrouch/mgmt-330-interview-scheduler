# Architectural decisions log

Owner: ARCH. The architecture choices behind the app, with the reasoning and the alternatives, in one place. Each entry points to the decision rows in [04-decisions.md](../software-app/04-decisions.md) for the status, and to the design documents for the detail. This log does not replace them.

IDs are `AD-1`, `AD-2` and so on, separate from the `D` sequence. Entries are append-only. To change a decision, add a new entry that supersedes the old one and mark the old one **Superseded by AD-n**.

## How to add an entry

| Field | What to write |
|-------|---------------|
| Decision | One sentence. |
| Why | The reason, in a line or two, for a small solo project. |
| Alternatives | What was considered and why it lost. Write "not recorded" rather than guessing. |
| Consequences | What this makes easy or hard later. |
| Related | The `D` rows and the design document sections. |

## Log

Seeded from decisions already made and recorded elsewhere. Status of all seeded entries: **Accepted**, 2026-11-09.

| ID | Decision | Why | Alternatives | Consequences | Related |
|----|----------|-----|--------------|--------------|---------|
| AD-1 | Neon Postgres, reached over HTTPS with the Neon serverless driver. | Vercel's filesystem is ephemeral, and the data is relational with constraints that matter. | SQLite or a local file: rejected because it does not persist on Vercel. | The database is a separate hosted service; a dev and a test branch are needed (AD-8). | D8, D40, D61 |
| AD-2 | Plain SQL schema with typed repository functions; no ORM. | Five tables, and the constraints live in SQL anyway. | Drizzle or another ORM: rejected because ORMs model exclusion constraints poorly. | An ORM later means rewriting the repository layer. | D40, 02-model-tier.md |
| AD-3 | Availability is stored as windows (candidate, day, start, end), many per day. | It matches how candidates describe free time. | One row per 30-minute slot (the first design): replaced when windows were requested. | The heatmap is derived by expanding windows into slots. | D33, D35, 01-erd.md |
| AD-4 | Times are a local day plus minutes after midnight, never UTC. The timezone is fixed to America/New_York and used for display only. | One timezone for everyone, so no UTC or daylight-saving bugs. | UTC timestamps: rejected as unnecessary risk for a single timezone. | Supporting other timezones later needs real work. | D34, D42, D48 |
| AD-5 | Interviews cannot overlap, enforced by a Postgres exclusion constraint on the assignment range, and one candidate's windows by another. | Correct under concurrent requests without application code. | A unique key on the start: rejected because it cannot catch overlapping ranges once interviews can be longer than one slot. Fallback if `btree_gist` is unavailable: lock the day row and check in SQL. | Needs the `btree_gist` extension, still unverified on Neon (R9). | D39, 01-erd.md |
| AD-6 | Pure scheduling logic (windows, slots, formatting) is shared by the server and the browser. Database and secret-handling code is server-only. | One tested definition of how a window covers its slots. | not recorded | Shared files must stay free of server imports. | D41, 02-model-tier.md |
| AD-7 | The route handler validates input and checks the poll's `closed` flag; the repository stays thin and database constraints are the backstop. Admin routes call a shared `requireAdmin()` helper; there is no `middleware.ts`. | Keeps one visible place for each check. | A `middleware.ts` guard: rejected in favor of an explicit helper at the top of each admin handler and page. | Each new admin route must remember to call `requireAdmin()`; CSEC checks this. | D60 |
| AD-8 | The admin session is a hand-written signed cookie (HMAC-SHA256 over an expiry, 7 days) using Node `crypto`. Candidates need no session: their token is the credential, and the optional password is sent with each save. | No sign-in for candidates, and one admin only. | not recorded | The candidate re-enters their password after a page reload (D29). | D29, D62 |
