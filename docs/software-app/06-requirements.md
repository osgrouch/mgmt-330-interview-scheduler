# Requirements: MGMT 330 Interview Scheduler

Status: **Reconciled with the ERD, model tier and API spec.** For the data model and API, the authoritative documents are [01-erd.md](01-erd.md), [02-model-tier.md](02-model-tier.md) and [03-openapi.yaml](03-openapi.yaml); this document may lag behind them (D51).

**Scope of this deliverable:** the page and endpoint where an interviewee submits their availability, plus the admin view that shows who has responded, shows everyone's availability together, and assigns interview times. Logins for interviewers (the admin's teammates) are a future release (D1).

## 1. Summary

The admin (coordinator) creates an availability poll for a set of candidates. Each candidate gets a unique, unguessable link and, with no sign-in, marks when they are free as **windows** (one or more per day, different on each day) between 8 AM and 8 PM, on a When2meet-style grid with 30-minute cells. The admin sees who has responded, views everyone's availability on one heatmap, and assigns each candidate an interview time. The admin sends the links to candidates themselves (the app does not send email).

## 2. Settled assumptions (all confirmed by the user; details in [04-decisions.md](04-decisions.md))

| # | Assumption | Decision |
|---|-----------|----------|
| A1 | **No interviewer entity in v1.** The admin schedules everyone. The admin's teammates will conduct interviews and get logins in a future release (one or more interviewers). No two candidates may have overlapping interview times. | D1 |
| A2 | **The app does not send email.** The admin UI shows each candidate's link with a "Copy link" button, and the admin sends it. | D2 |
| A3 | **One event at a time** (a single configuration), not multiple concurrent polls. | D3 |
| A4 | The grid has **30-minute cells**. Interview length is **configurable by the admin** (a multiple of 30, default 30). | D4, D37 |
| A5 | **One timezone, America/New_York, for everyone, fixed.** Times are stored as a local day plus minutes after midnight, never as UTC. | D5, D34, D48 |
| A6 | Candidates can **edit their availability any time** until the admin closes the poll. | D6 |
| A7 | Once assigned, the candidate's link **shows their interview time**. | D7 |
| A8 | **Database: Neon Postgres** (Vercel Marketplace). SQLite and local files don't persist on Vercel. | D8 |
| A9 | **Admin auth: single shared password** from an env var, stored in a signed HttpOnly cookie. | D9 |

**Build phasing (D58).** The MVP is everything above **except** the candidate password block (UR-11 to UR-13, FR-21 to FR-29), token regeneration (FR-6, regenerate part) and drag-select and the override-assign warning in the UI (FR-9 drag part, FR-19 UI). Those are built right after the MVP, in that order; drag-select and the override warning are cut first if time runs short.

## 3. User requirements

**Candidate (interviewee)**
- UR-1: I open the link from my email and land directly on my availability page (no account; a password is optional, see UR-11).
- UR-2: I can quickly mark when I'm free on a grid (click or drag, works on a phone), including several separate windows on the same day (for example 8-9 AM, 12-2 PM and 7-8 PM), and different windows on different days.
- UR-3: I can come back via the same link, see what I submitted, and change it.
- UR-4: After I'm scheduled, I can see my interview time.

**Admin (coordinator)**
- UR-5: I can set the poll's days and how long each interview is, and the app limits times to 8 AM-8 PM.
- UR-6: I can add candidates by email and get a unique link for each.
- UR-7: I can see at a glance who has and hasn't submitted.
- UR-8: I can see everyone's availability at once and find the best overlaps.
- UR-9: I can assign each candidate an interview time, with the app preventing overlapping interviews.
- UR-10: I can see the final schedule (who is interviewed when) on the dashboard.

**Candidate password (optional)**
- UR-11 (candidate): When I first submit my availability, I can optionally choose a password, so that someone else who gets hold of my link can't edit my availability.
- UR-12 (candidate): Whatever password I pick is accepted right away, and it can't be changed afterwards.
- UR-13 (admin): I can see which candidates are password-protected, and reset a protected candidate who is locked out.

## 4. Functional requirements

**Event configuration**
- FR-1: Admin sets the event name, the selectable days (individual calendar days, at most 14) and the interview length (a multiple of 30 between 30 and 180, default 30). The timezone is fixed to America/New_York and is not editable. The day window is fixed at 8:00-20:00 and is a constant, not a setting.
- FR-2: Changing the days after responses exist must warn the admin; responses on removed days are discarded.
- FR-3: Admin can close/reopen the poll. A closed poll makes candidate links read-only.

**Candidate management**
- FR-4: Admin can add candidates by pasting emails (one per line or comma-separated); duplicates are reported, not added.
- FR-5: Each candidate gets a server-generated token (192-bit random, URL-safe). The link is `/c/{token}`.
- FR-6: Admin can regenerate a candidate's token (invalidates the old link) and delete a candidate.
- FR-7: The admin UI shows each candidate's full link (built from the page's own origin, D49) with a one-click "Copy link" button. There is no export and no email sending (D2, D31).

**Candidate availability**
- FR-8: `/c/{token}` shows the candidate's email, the event name, and a day x time grid of 30-minute cells.
- FR-9: Click/drag toggles cells; contiguous selected cells become one window. "Select all / clear day" shortcuts are provided.
- FR-10: Save replaces the candidate's full set of windows atomically and records `submitted_at`.
- FR-11: Invalid or unknown token returns a generic "link not valid" page (no information leak).
- FR-12: Page shows the assigned interview time if one exists.

**Availability windows**
- FR-30: A candidate may have any number of separate windows on any day, and each day is independent. Zero windows on a day means not free that day.
- FR-31: A window is stored as a day plus start and end minutes after local midnight (480 is 8:00 AM, 1200 is 8:00 PM). Edges are multiples of 30, inside 480-1200, and a window cannot cross days.
- FR-32: The server merges overlapping or touching windows on save and returns the stored result.
- FR-33: Below the grid, the page lists each day's windows as text (for example "8:00-9:00 AM, 12:00-2:00 PM, 7:00-8:00 PM") so the candidate can check what they entered.
- FR-34: A window `[s, e)` covers the 30-minute cells `s, s+30, ..., e-30`. The heatmap and the assignment fit check both use this one definition (D41).

**Admin dashboard**
- FR-13: Admin login with password; logout.
- FR-14: Candidate table: email, status (Invited / Submitted / Scheduled), submitted_at, link actions.
- FR-15: Aggregate heatmap: for every 30-minute cell, the count (and names) of candidates whose windows cover it.
- FR-16: Selecting a candidate highlights the cells they are free for on the grid.
- FR-17: Assign a candidate an interview start time; the interview lasts the event's interview length. The whole range should sit inside one of the candidate's windows. Admin can unassign.
- FR-18: Assignment rejects a time range that overlaps another candidate's interview on the same day (server-enforced).
- FR-19: Admin can override-assign a time not covered by the candidate's windows, with a visible warning.
- FR-20: Schedule view on the dashboard: email, date, start-end time, sorted by time. View only, no export.

**Candidate password (optional)**
- FR-21: On the candidate's first save only, the page offers an optional "Set a password" field (typed twice, UI-only check, to avoid typos). The UI warns it cannot be changed or recovered by the candidate.
- FR-22: Any password of 1-128 characters is accepted on the first try. No strength rules.
- FR-23: The server stores only a salted scrypt hash, never the password.
- FR-24: After the first save, no candidate-facing endpoint can change or remove the password.
- FR-25: If a password exists, every later save must include it. A wrong or missing password returns 401 and saves no availability data.
- FR-26: Opening and viewing the link does not require the password. The page shows a lock indicator and asks for the password when the candidate saves.
- FR-27: A candidate who saved without a password cannot add one later.
- FR-28: After 5 consecutive wrong passwords, saves for that candidate are locked for 15 minutes (a correct password resets the counter). The 5th wrong attempt returns 401; later attempts return 423, and a correct password is refused while locked. When the lock expires the counter restarts. A missing password is not a guess and does not count (D52, D59).
- FR-29: The admin candidate table shows a lock icon for protected candidates, and an admin-only "Reset password" action clears the password and lets the candidate set one again on their next save. Availability is kept.

## 5. Non-functional requirements

| ID | Category | Requirement |
|----|----------|-------------|
| NFR-1 | Security | Tokens: 192-bit crypto-random; never derived from email; compared by DB lookup on a unique index. |
| NFR-2 | Security | Admin routes and APIs check the signed session cookie server-side; cookie is HttpOnly, Secure, SameSite=Lax. |
| NFR-3 | Security | Candidate endpoints may only read/write the candidate that owns the token. Tokens are never logged. |
| NFR-4 | Privacy | Candidate pages send `noindex` and `Referrer-Policy: no-referrer`. Only email is stored as PII. |
| NFR-5 | Security | **Dropped (D47).** No rate limit on admin login; rely on a long random `ADMIN_PASSWORD`. |
| NFR-6 | Performance | Candidate page interactive in under 2 s on mobile 4G; save under 500 ms for up to 14 days with up to 12 windows per day. |
| NFR-7 | Scale | Designed for tens of candidates, one admin. No caching or queueing infrastructure. |
| NFR-8 | Usability | Grid works with touch and mouse; responsive down to 360 px width. |
| NFR-9 | Reliability | Saves are transactional (all-or-nothing). Server validates every submitted window is on an event day, has 30-minute edges, and lies inside 8:00-20:00. |
| NFR-10 | Deployability | One Vercel project; secrets via env vars (`DATABASE_URL`, `ADMIN_PASSWORD`, `SESSION_SECRET`). Zero manual DB steps beyond running a migration script. |
| NFR-11 | Maintainability | TypeScript strict; single SQL schema file; module layout as in [02-model-tier.md](02-model-tier.md) section 11. |
| NFR-12 | Accessibility | Grid cells are keyboard-toggleable with labels (e.g. "Tue Nov 17, 2:00 PM, available"). |
| NFR-13 | Out of scope | OAuth, calendar sync, email sending, multi-event, interviewer logins (planned for a future release), i18n, candidate-initiated password change or recovery. |
| NFR-14 | Security | Passwords hashed with scrypt (Node `crypto`, per-candidate random salt), verified with `timingSafeEqual`. Passwords never logged or returned. Hashing cost kept low enough for Vercel serverless (under ~100 ms). |
| NFR-15 | Security | Password length capped at 128 characters so hashing can't be abused for denial of service. |
