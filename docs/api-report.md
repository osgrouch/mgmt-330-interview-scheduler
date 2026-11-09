# API report

Report on [openapi.yaml](openapi.yaml) v0.2.0-draft. It follows the approved [erd.md](erd.md) and the drafted [model-tier.md](model-tier.md).
Status: **Updated after the document review.** The spec itself is authoritative (D51); this report may lag behind it.

## 1. Summary

The API has **14 operations on 10 paths**: 2 for candidates (called from the emailed link) and 12 for the admin. It was rewritten from the first draft so that availability is a list of windows (several per day, each day different), interview length is configurable, and assignments carry an end time.

The file passes an OpenAPI 3.1 validator. No code exists yet, so nothing has been tested against an implementation.

## 2. Operations

| Method and path | Who | Purpose | Model-tier function | Tables |
|-----------------|-----|---------|---------------------|--------|
| `GET /api/c/{token}` | Candidate | Load event, saved windows, password state, assignment | `findCandidateByToken`, `getWindows`, `getAssignment`, `getEvent` | event, event_date, candidate, availability_window, assignment (read only) |
| `PUT /api/c/{token}` | Candidate | Save windows, optionally set the password | `saveAvailability` (+ password check in auth module) | availability_window, candidate |
| `POST /api/admin/login` | Admin | Log in with the shared password | auth module | none |
| `POST /api/admin/logout` | Admin | Clear the session cookie | auth module | none |
| `GET /api/admin/event` | Admin | Read settings | `getEvent` | event, event_date |
| `PUT /api/admin/event` | Admin | Edit name, timezone, days, interview length, closed | `updateEvent` | event, event_date (cascades) |
| `GET /api/admin/candidates` | Admin | List with status, token, assignment | `listCandidates` | candidate, assignment |
| `POST /api/admin/candidates` | Admin | Add by email | `addCandidates` | candidate |
| `DELETE /api/admin/candidates/{id}` | Admin | Remove a candidate | `deleteCandidate` | candidate (cascades) |
| `POST .../{id}/regenerate-token` | Admin | New link, old one dies | `regenerateToken` | candidate |
| `POST .../{id}/reset-password` | Admin | Clear the password so it can be set again | `resetPassword` | candidate |
| `GET /api/admin/availability` | Admin | Heatmap: per-slot list of free candidates | `getAggregate` | availability_window |
| `PUT /api/admin/assignments/{candidateId}` | Admin | Assign or move an interview | `assign` | assignment |
| `DELETE /api/admin/assignments/{candidateId}` | Admin | Unassign | `unassign` | assignment |

## 3. Key design points

1. **Times on the wire are `day` + minutes**, for example `{ "day": "2026-11-16", "startMinute": 720, "endMinute": 840 }` is 12-2 PM. No UTC timestamps, matching the database (D34).
2. **Your scenario** (8-9 AM, 12-2 PM, 7-8 PM on one day) is three entries in one `windows` array. Another day simply has other entries, or none.
3. **Save replaces everything.** `PUT /api/c/{token}` sends the whole set of windows. The server merges overlapping or touching ones and returns what it stored, so the grid can redraw from the response.
4. **Assignments send only a start.** The server computes the end from the event's interview length and stores it (D45). Changing the length later does not move people already scheduled (D38).
5. **The candidate and admin views are different schemas.** `CandidateView` never includes other people's data. `CandidateSummary` (admin) never includes the password hash or lockout counters.
6. **No separate schedule endpoint.** `GET /api/admin/candidates` already carries each assignment, so the dashboard schedule view is derived from it.
7. **The GET on the candidate link never changes data**, so email scanners that open links are harmless (D13).

## 4. Errors

All errors look like `{ "error": { "code", "message" } }`, with extra fields where listed.

| HTTP | Code | Where | Model-tier source |
|------|------|-------|-------------------|
| 400 | `INVALID_WINDOWS` (+ `issues[]`: `BAD_EDGE`, `OUT_OF_HOURS`, `EMPTY_RANGE`, `DAY_NOT_IN_EVENT`) | PUT candidate | `WindowsInvalidError` |
| 400 | `INVALID_PASSWORD` | PUT candidate | request validation |
| 400 | `INVALID_EVENT`, `INVALID_REQUEST` | admin PUT/POST | request validation |
| 400 | `INVALID_WINDOW` (singular; assigning an invalid time) | PUT assignment | `InvalidWindowError` (D50). Not to be confused with `INVALID_WINDOWS` (plural) on the save-availability request. |
| 401 | `PASSWORD_REQUIRED`, `PASSWORD_INCORRECT` (+ `attemptsRemaining`) | PUT candidate | auth module |
| 401 | `INVALID_CREDENTIALS`, `UNAUTHENTICATED` | admin | auth module |
| 403 | `POLL_CLOSED` | PUT candidate | `PollClosedError` |
| 404 | `INVALID_LINK` (generic, deliberately) | candidate | `findCandidateByToken` returns null |
| 404 | `NOT_FOUND` | admin by id | `NotFoundError` |
| 409 | `SLOT_TAKEN` (+ `takenBy`) | assign | `SlotTakenError` (Postgres exclusion violation) |
| 409 | `NOT_AVAILABLE` | assign | `NotAvailableError` |
| 409 | `DATES_HAVE_RESPONSES` (+ counts) | event PUT | `DatesHaveResponsesError` |
| 423 | `LOCKED` (+ `lockedUntil`) | PUT candidate | lockout policy |

## 5. Requirements coverage

Every functional requirement is either served by an operation or is pure UI:

- **Served by the API:** FR-1 to FR-6 (event, candidates, links, regenerate, delete), FR-8, FR-10 to FR-15, FR-17 to FR-19, FR-21 to FR-29 (the password feature, including `canSetPassword` and admin reset).
- **UI only, no endpoint:** FR-7 (copy link), FR-9 (drag on the grid), FR-16 (highlight a candidate, done by filtering `candidateIds` in the browser), FR-20 (schedule view, derived from the candidate list).

## 6. What changed since the first draft

| Before (v0.1) | Now (v0.2) |
|---------------|------------|
| `slots` as UTC timestamps | `windows` as `{ day, startMinute, endMinute }` |
| `slotStart` / `slotEnd` on assignments | `day`, `startMinute`, `endMinute` |
| Fixed 30-minute interview | `interviewMinutes` on the event (30-180, multiples of 30) |
| `Event` schema | `EventConfig` (matches the model tier; `Event` is a browser global) |
| `AdminCandidate` | `CandidateSummary` (matches the model tier) |
| Save returned only `submittedAt` | Save also returns the merged windows |
| Export endpoint | Removed (D31) |
| Timezone editable on the event | Fixed to America/New_York; not in the update request (D48) |
| `INVALID_SLOT` | `INVALID_WINDOW` (D50) |
| Logout had no 401 | Logout now returns 401 when not logged in |

## 7. Assumptions I made

Entries in [decisions.md](decisions.md): D42 to D48 (D49 to D54 came later from the document review). In short: wire times are day plus minutes; no separate schedule endpoint; the save accepts overlapping windows and merges them; the server computes the interview end; the event endpoints have no id because there is a single event; lockout is HTTP 423. (Admin login rate limiting was dropped, D47.)

## 8. Open issues

1. ~~Admin login rate limiting has no home.~~ **Resolved: dropped (option b).** NFR-5 and the `429` response are removed; the admin relies on a long random `ADMIN_PASSWORD`.
2. ~~Stale documents.~~ **Resolved:** requirements.md and decisions.md were reconciled with the ERD, model tier and this API after a review by a separate agent. [architecture.md](architecture.md) is being rewritten by another agent.
3. **No CSRF token on admin writes.** They rely on the `SameSite=Lax` cookie and JSON-only bodies. That is reasonable for one admin at this scale.
4. **No pagination** on the candidate list. Fine for tens of candidates.
5. ~~Changing the event timezone only changes the label.~~ **Ignored by decision:** the timezone never changes (D48).
6. **The password lockout counts per candidate, not per IP.** Someone with a link can lock that candidate out for 15 minutes by guessing wrong. Acceptable given the link is already the secret (R6).

## 9. Verification performed

- The YAML parses and passes the `openapi-spec-validator` for OpenAPI 3.1.
- All `$ref`s resolve (the validator checks this).
- **Not done:** the request and response examples were not run against the schemas, and there is no implementation to test against.

## 10. Questions for you

Both answered: admin login rate limiting is dropped (Q15), and deriving the schedule view from the candidate list is fine (D43 confirmed).
