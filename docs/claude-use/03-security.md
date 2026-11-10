# Security

Owner: CSEC. The checklist is kept current; the findings log is append-only.

This is a small solo project: one admin, tens of candidates. Rate severity honestly and do not demand enterprise controls the app cannot justify. When a risk is accepted on purpose, say so with the reason.

Severity: **Blocking** (fix before the work counts as done), **High**, **Medium**, **Low**.

## 1. Checklist for this app

Built from the requirements and decisions. Every item starts as **Not reviewed**; CSEC updates the status as design and code are reviewed (`Pass`, `Fail` with a finding ID, `Accepted` with a reason, or `N/A`).

| # | Check | Source | Status |
|---|-------|--------|--------|
| 1 | Candidate tokens are 192-bit, from `crypto.randomBytes`, base64url, never derived from email, never logged | NFR-1, D12 | Not reviewed |
| 2 | Token lookup is by indexed equality; an unknown token gets one generic 404 | NFR-1, D20 | Not reviewed |
| 3 | `GET /c/{token}` never changes data (email scanners prefetch links) | D13 | Not reviewed |
| 4 | Candidate endpoints read and write only the candidate who owns the token | NFR-3 | Not reviewed |
| 5 | Candidate passwords use scrypt with a per-candidate salt, constant-time compare, length capped at 128; never logged or returned | NFR-14, NFR-15, D27 | Not reviewed |
| 6 | Lockout: a wrong password counts, a missing one does not, 5 tries lock for 15 minutes, 423 while locked, correct password accepted | D28, D59 | Not reviewed |
| 7 | No password hash, lockout counter or `CandidateRecord` field reaches any response; only the mapped view types | model tier, NFR-3 | Not reviewed |
| 8 | Admin session: signed cookie (HMAC-SHA256, 7-day expiry), HttpOnly, SameSite=Lax, Secure outside local development; fails closed if `ADMIN_PASSWORD` or `SESSION_SECRET` is missing or short | D62, NFR-2 | Not reviewed |
| 9 | Every admin route handler and admin page calls `requireAdmin()` first | D60 | Not reviewed |
| 10 | Admin password compared in constant time; no login rate limit is an accepted risk | D47, R8 | Accepted (D47) |
| 11 | All SQL parameterized through the driver's tagged template; no string-built SQL | model tier | Not reviewed |
| 12 | Request bodies validated (shape, lengths, ranges) before use; windows validated server-side | NFR-9, D60 | Not reviewed |
| 13 | App-wide headers: Referrer-Policy no-referrer, noindex, nosniff, frame deny, no-store on API and candidate pages | D62, NFR-4 | Not reviewed |
| 14 | No secrets in the repo, logs or client bundles; `.env*` is in `.gitignore`; only the documented env vars | NFR-10 | Not reviewed |
| 15 | Database access code is server-only (`import 'server-only'`) and not importable from client code | model tier | Not reviewed |
| 16 | Dependencies are the approved set; any other package is reviewed by CSEC first; `npm audit` run once a lockfile exists | D63 | Not reviewed |
| 17 | Error responses leak no stack traces or internals | NFR-3 | Not reviewed |

## 2. Findings log

Append one row per finding. IDs are `SEC-1`, `SEC-2` and so on. Do not delete rows; mark them Resolved.

| ID | Date | Severity | Location | Finding | Recommended fix | Status |
|----|------|----------|----------|---------|-----------------|--------|
| | | | | None recorded yet. | | |
