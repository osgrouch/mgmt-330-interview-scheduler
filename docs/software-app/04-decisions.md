# Decisions Log and Open Questions

Companion to the other design docs. **Authoritative documents:** [01-erd.md](01-erd.md), [02-model-tier.md](02-model-tier.md) and [03-openapi.yaml](03-openapi.yaml), in that order (D51). The rest ([06-requirements.md](06-requirements.md), [05-architecture.md](05-architecture.md), this log) may lag behind them. If code needs something the authoritative documents don't say, update them first.

Status key: **Confirmed** (the user has agreed; where Claude proposed it, the Source column says so) | **Process** (a working rule) | **Open** (needs an answer)

All previously assumed decisions were confirmed by the user on 2026-11-09.

This log holds decisions about **the app being built**. Decisions about how the agent team works (roles, workflow, who commits, what reaches the user) are in [01-decisions.md](../claude-use/01-decisions.md). Both files share one ID sequence: take the next free ID across the two, and IDs never change when a row moves. Team-environment rows that used to be here: D19, D55-D57, D64-D72, Q19, Q20.

## 1. Decision log

| ID | Req ref | Decision | Status | Source | Cost if wrong |
|----|---------|----------|--------|--------|---------------|
| D1 | A1 | **No interviewer entity in v1.** The admin schedules everyone. The admin's teammates will conduct interviews and get logins in a future release; there may be one or more interviewers. This deliverable's focus is the endpoint where interviewees submit availability. | **Confirmed** | User (Q1, Q2) | High, but planned: a future release adds interviewer tables, logins and matching. |
| D2 | A2 | App does not send email. The admin UI shows each candidate's link with a "Copy link" button and the admin sends it. | **Confirmed** | User (Q4: "just show me the link and I will send the email") | Low: add an email service and one route later. |
| D3 | A3 | A single event/poll at a time (one config row). | **Confirmed** | Claude; confirmed | Medium: add an event picker. |
| D4 | A4 | 30-minute grid cells. Interview length is configurable by the admin (see D37). | **Confirmed** | User | n/a |
| D5 | A5 | One timezone, America/New_York, for everyone. Times are stored as local day + minutes (D34). | **Confirmed** | User (Q5: "we are all in America/New_York") | n/a |
| D6 | A6 | Candidates can edit until the admin closes the poll. | **Confirmed** | Claude; confirmed | Low. |
| D7 | A7 | Candidate link shows their assigned time once assigned. | **Confirmed** | Claude; confirmed | Low. |
| D8 | A8 | Neon Postgres via Vercel Marketplace. | **Confirmed** | Claude; confirmed. Vercel's filesystem is ephemeral, so SQLite won't persist. | Low-medium: swap the driver. |
| D9 | A9 | Admin auth is one shared password (env var) with a signed HttpOnly cookie. | **Confirmed** | Claude; confirmed | Low. |
| D10 | n/a | Candidates are pre-registered by the admin by email. There is no self-signup. | **Confirmed** | User ("I know the emails") | Low. |
| D11 | n/a | Candidates need no sign-in; the link token is the credential. | **Confirmed** | User | n/a |
| D12 | n/a | Token is 192-bit random even though the user judged risk low. | **Confirmed** | Claude; confirmed | None. |
| D13 | n/a | `GET /c/{token}` never changes data. Email security scanners prefetch links. | **Confirmed** | Claude; confirmed | None. |
| D14 | n/a | The day runs 8:00 AM-8:00 PM; the last 30-minute cell is 7:30-8:00 PM. Hours are constants, not admin-editable. | **Confirmed** | User (8 AM-8 PM) | Low. |
| D15 | n/a | Admin picks individual calendar days (weekends allowed), max 14. | **Confirmed** | Claude; confirmed | Low. |
| D16 | n/a | Candidates can't see other candidates' availability or names. | **Confirmed** | Claude; confirmed | Low. |
| D17 | n/a | Importing existing When2meet data is out of scope for now. The schema (email + availability windows of candidate, day, start, end) is import-friendly. | **Confirmed** | User ("I'll figure out how to extract that at a later step") | n/a |
| D18 | n/a | No deadline, reminders or notifications in v1. | **Confirmed** | Claude; confirmed | Low. |
| D20 | n/a | Unknown or invalid tokens get one generic "link not valid" page. | **Confirmed** | Claude; confirmed | None. |
| D21 | UR-11 | Candidate password is optional and chosen by the candidate. | **Confirmed** | User | n/a |
| D22 | FR-22 | Any password is accepted on the first try (1-128 characters, no strength rules). | **Confirmed** | User | n/a |
| D23 | FR-24 | Candidates can never change or remove the password after it is set. | **Confirmed** | User | n/a |
| D24 | FR-26 | The password gates **saving/editing only**. Viewing the link does not require it. | **Confirmed** | Claude; confirmed (Q12) | Medium: add an unlock step and gate the GET. |
| D25 | FR-27 | The password can be set only on the **first save**. A candidate who skipped it cannot add one later. | **Confirmed** | Claude; confirmed (Q13) | Low. |
| D26 | FR-29 | The admin can reset a candidate's password, which is the only recovery path. | **Confirmed** | Claude; confirmed (Q14) | Low. |
| D27 | NFR-14 | scrypt (Node built-in) with a per-candidate salt; only the hash is stored. | **Confirmed** | Claude; confirmed | None. |
| D28 | FR-28 | 5 wrong passwords lock saves for that candidate for 15 minutes. | **Confirmed** | Claude; confirmed | Low. |
| D29 | Architecture | The password is sent with each save (no session or cookie), so reloading the page means re-entering it. | **Confirmed** | Claude; confirmed | Low: add an unlock endpoint with a short-lived cookie. |
| D30 | FR-21 | The first-time password field is typed twice (UI check only) with a "cannot be changed" warning. | **Confirmed** | Claude; confirmed | None. |
| D31 | FR-7, FR-20 | No export feature (no CSV of links or schedule). The schedule is view-only. | **Confirmed** | User | None. |
| D32 | API | API contract is [03-openapi.yaml](03-openapi.yaml). Routes in the code must match it; change the spec first. | **Process** | User | n/a |
| D33 | ERD | Availability is stored as **windows** (candidate, day, start, end). A day can have any number of windows, and different days differ. | **Confirmed** | User ("varying slots of availability" per day) | n/a |
| D34 | ERD | Times are stored as local day + minutes after midnight, not UTC timestamps. The event timezone is for display only. | **Confirmed** | Claude; confirmed | Low: only matters if timezones ever differ per person. |
| D35 | ERD | Window edges are on 30-minute boundaries; overlapping or touching windows are merged on save rather than rejected. | **Confirmed** | User (30-minute edges); Claude (merge on save); confirmed | Low: loosen the multiple-of-30 check. |
| D36 | ERD | Days are their own table (EVENT_DATE); candidates carry an `event_id`. | **Confirmed** | Claude; confirmed | None. |
| D37 | ERD | Interview length is an event setting (`interview_minutes`), a multiple of 30, default 30, allowed range 30-180. | **Confirmed** | User (configurable); Claude (range); confirmed | Low. |
| D38 | ERD | An assignment stores its own start and end. Changing the interview length later does not move existing assignments. | **Confirmed** | Claude; confirmed | Low. |
| D39 | ERD | No-overlap for assignments (and for one candidate's windows) is enforced in Postgres with exclusion constraints (needs the `btree_gist` extension). Fallback if the host disallows it: lock the day row and check in SQL. Still to verify on Neon at migrate time (R9). | **Confirmed** | Claude; confirmed | Low. |
| D40 | Model tier | Plain SQL schema + typed repository functions + Neon serverless driver. No ORM. | **Confirmed** | Claude; confirmed | Medium: adopting an ORM later means rewriting the repo layer. |
| D41 | Model tier | Pure scheduling logic (windows, slots, formatting) is shared by server and browser. Database code is server-only. Heatmap expansion exists twice (TypeScript `windowsToSlots` and SQL in `getAggregate`); that is fine as long as both use one definition: a window `[s, e)` covers the cells `s, s+30, ..., e-30` (FR-34). | **Confirmed** | Claude; confirmed | None. |
| D42 | API | Times on the wire are `day` (`YYYY-MM-DD`) plus `startMinute`/`endMinute`, not UTC timestamps. | **Confirmed** | Claude; confirmed | Low. |
| D43 | API | No dedicated schedule or assignments-list endpoint; the schedule view is derived from `GET /api/admin/candidates`. | **Confirmed** | User | Low. |
| D44 | API | Saving accepts overlapping windows, merges them, and returns the stored result. Bad windows return `INVALID_WINDOWS` with per-window `issues`. | **Confirmed** | Claude; confirmed | Low. |
| D45 | API | The client sends only a start time when assigning; the server computes the end from `interviewMinutes`. | **Confirmed** | Claude; confirmed | Low. |
| D46 | API | Event endpoints have no id (single event). | **Confirmed** | Claude; confirmed | Low. |
| D47 | API | Candidate password lockout returns HTTP 423. There is **no admin login rate limiting** (NFR-5 dropped); the admin relies on a long random `ADMIN_PASSWORD`. | **Confirmed** | User (rate limiting dropped); Claude (423); confirmed | Low: add an attempts table later. |
| D48 | Event | The event timezone is fixed to America/New_York and never changes. It is not editable through the API or UI, and there is no relabeling or shifting logic. | **Confirmed** | User | n/a |
| D49 | FR-7 | Candidate links are built in the admin UI from the page's own origin plus `/c/{token}`. There is no base-URL env var. | **Confirmed** | Claude (doc review); confirmed | None. |
| D50 | API | Assigning an invalid time (day not in the event, start not a multiple of 30, or the interview would end after 8 PM) is a typed `InvalidWindowError(reason)` in the model tier and returns `400 INVALID_WINDOW`. (Renamed from the earlier "slot" wording.) Not to be confused with `INVALID_WINDOWS` (plural), which is for the save-availability request. | **Confirmed** | User | None. |
| D51 | Process | The authoritative documents are 01-erd.md, 02-model-tier.md and 03-openapi.yaml, in that order. Other docs may lag behind them. | **Process** | User | n/a |
| D52 | Model tier | Lockout boundary: the auth module decides what counts as a failed attempt and when to lock; the repo only persists counters. Constants live in `lib/model/constants.ts`: `MAX_FAILED_ATTEMPTS = 5`, `LOCK_MINUTES = 15`, `MAX_PASSWORD_LENGTH = 128`. A **wrong** password counts as a failed attempt; a **missing** password does not. | **Confirmed** | Claude (doc review); confirmed, except "missing does not count", which is a new choice to check | Low. |
| D53 | Process | The time plan was removed from the requirements. | **Confirmed** | User | n/a |
| D54 | Model tier / API | The API builds its event object from the model tier's `EventConfig` plus the day constants (`dayStartMinute`, `dayEndMinute`, `slotMinutes`) and drops `id`. | **Confirmed** | Claude (doc review); confirmed | None. |
| D58 | Scope | **MVP scope.** MVP = admin login, event settings (name, days, interview length, close/reopen), add/list/delete candidates with Copy link, the candidate availability grid (click-to-toggle, save, no password), the heatmap, assign/unassign, schedule view, and the assigned time on the candidate link. Built **right after the MVP**: candidate password, lockout and admin reset (FR-21 to FR-29), regenerate token, the `confirmDiscard` flow. Cut first if time runs short: drag-select, then the override-assign UI warning. The server-side `override` flag stays in the MVP. ARCH documents the phasing in the design docs before code. | **Confirmed** | User, on ARCH/DEV/DOCM proposals (2026-11-09) | Low. |
| D59 | Model tier / API | **Lockout rules (Q16, D52).** The 5th wrong password returns 401 with `attemptsRemaining: 0`; later attempts return 423 while locked; a correct password during lockout is refused. After the lock expires the failed-attempt counter restarts. A successful save resets it. A **missing** password does not count as a failed attempt (D52 confirmed). | **Confirmed** | User (2026-11-09) | Low. |
| D60 | Architecture | **Validation layer and file layout (Q17, Q18).** The route handler checks `closed`, runs `validateWindows`, validates event input and the basic request shape; the repo stays thin and DB constraints are the backstop. Add `lib/auth/password.ts`, `lib/auth/session.ts` and `lib/http/errors.ts` (typed error to HTTP mapping). **No `middleware.ts`:** a shared `requireAdmin()` helper is called at the top of every admin route handler and admin page. ARCH records these in 02-model-tier.md. | **Confirmed** | User, on ARCH/DEV/CSEC proposals (2026-11-09) | Low. |
| D61 | Database | **Neon dev and test branches** for development and repository tests, using the same Neon driver as production. The user creates the Neon project and Vercel project and the team gives exact steps (Q9). `DATABASE_URL` and `DATABASE_URL_TEST` live in `.env.local`, never in files. Pure modules are built first and need no database. R9 (`btree_gist`) is verified at the first migration. D19 still applies: no cloud resource is created by an agent. | **Confirmed** | User, on ARCH/DEV proposal (2026-11-09) | Low-medium. |
| D62 | Security | **Session and secrets.** Hand-written signed admin cookie (HMAC-SHA256 over an expiry, 7 days) using Node `crypto`; HttpOnly, SameSite=Lax, Secure except in local development. CSRF: SameSite=Lax plus JSON-only bodies. App-wide headers (Referrer-Policy no-referrer, noindex, nosniff, frame deny, no-store on API and candidate pages), no CSP. Fail closed if `ADMIN_PASSWORD` or `SESSION_SECRET` is missing or too short. The user generates both secrets and sets them for Production only in Vercel. | **Confirmed** | User, on CSEC proposal (2026-11-09) | Low. |
| D63 | Stack | **Tech stack.** Runtime: next, react, react-dom, @neondatabase/serverless, server-only, zod. Dev: typescript, vitest, eslint, Tailwind v4 and the matching @types. Latest versions at scaffold time. Any other package needs CSEC review. | **Confirmed** | User (2026-11-09) | Low. |

## 2. Questions

### Open

| ID | Question | Default |
|----|----------|---------|

### Resolved

| ID | Question | Answer |
|----|----------|--------|
| Q1 | Who is on the other side of each interview? | Teammates will conduct interviews; they get logins in a future release. Not modeled now (D1). |
| Q2 | One interviewer, or several / group interviews? | One or more interviewers, implemented later (D1). One candidate per interview time for now. |
| Q3 | Interview length? | Configurable by the admin (D37). |
| Q4 | Does the app send the emails? | No. The admin UI shows the link and the admin sends it (D2). |
| Q5 | Timezone? | America/New_York for everyone (D5, D48). |
| Q6 | Calendar of individual days or a range? | Individual days (D15). |
| Q7 | Should candidates see their assigned time? | Yes (D7). |
| Q8 | Deadline or reminders? | No; the dashboard status column is enough (D18). |
| Q9 | Vercel and Neon accounts, who provisions? | The user provisions; the team gives exact steps (D61). |
| Q16 | Lockout on the 5th wrong password? | 401 on the 5th, 423 after, correct password refused while locked, counter restarts after the lock expires (D59). |
| Q17 | Which layer validates a save? | The route handler (D60). |
| Q18 | Auth module file names? | `lib/auth/password.ts`, `lib/auth/session.ts`, plus `lib/http/errors.ts` and no `middleware.ts` (D60). |
| Q10 | Data retention? | Admin can delete candidates; no automatic purge. |
| Q11 | Production URL and base-URL env var? | Default `*.vercel.app` domain; links come from the page origin, so no env var (D49). |
| Q12 | Does the password also hide saved data? | No, it only blocks edits (D24). |
| Q13 | Can a candidate add a password after the first save? | No (D25). |
| Q14 | Is admin "Reset password" acceptable? | Yes (D26). |
| Q15 | Admin login rate limiting? | Dropped (D47). |

## 3. Risks and uncertainties

| ID | Risk | Mitigation |
|----|------|------------|
| R1 | A short build window is tight for deploy plus a drag-select grid on touch devices. | Build the grid with click-to-toggle first; add drag after. Cut order: override-assign, then drag-select. |
| R2 | Links in email can be forwarded; anyone with the link can edit that candidate's availability. | Accepted per user ("safe enough"). Candidates can opt into a password (D21). Admin can regenerate a token (FR-6). |
| R3 | Email scanners may open links. | D13: `GET` has no side effects. |
| R4 | ~~Timezone/DST bugs.~~ **Retired.** | Times are stored as local day + minutes (D34) and the timezone is fixed (D48), so there is no DST math. |
| R5 | Mermaid diagrams won't render in plain VS Code. | View on GitHub or install a Mermaid preview extension. |
| R6 | A candidate who never saved yet (no password set) can be pre-empted: whoever uses the link first can set the password. | Accepted. The link is the secret; admin can reset the password and regenerate the token. |
| R7 | A forgotten password locks the candidate out of editing. | Admin reset (D26). |
| R8 | The admin password could be guessed because login has no rate limit. | Accepted (D47). Use a long random `ADMIN_PASSWORD`. |
| R9 | The `btree_gist` extension, which the exclusion constraints need, is not yet verified on Neon. | Fallback in D39. The migration fails loudly if the extension is unavailable. |
