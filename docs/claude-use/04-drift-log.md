# Drift log

Owner: DOCM. Dated reports of drift between the code, its comments, and the documents.

**Drift** is any place where two sources disagree or one is stale: code against `software-app/02-model-tier.md` or `03-openapi.yaml`, the SQL against the ERD, a comment against what its code does, one document against another, or a file edited by someone who does not own it.

Which side is right is decided by the authoritative order: [01-erd.md](../software-app/01-erd.md), [02-model-tier.md](../software-app/02-model-tier.md), [03-openapi.yaml](../software-app/03-openapi.yaml). Other documents may lag.

## How to add an entry

Append a dated section. Do not delete history; mark earlier findings Resolved when the fix is confirmed.

Each finding has an ID `DR-1`, `DR-2` and so on, a short title, a severity (**Blocking**, **High**, **Medium**, **Low**), both locations with a short quote, 2 or 3 reconciliation options labelled A/B/C with one recommended and the file that should change, and a status (**Open** or **Resolved**).

## Findings

| ID | Date | Severity | Title | Status |
|----|------|----------|-------|--------|
| | | | None recorded yet. | |

## Reports

No drift reports yet. The drift findings from the earlier readiness check were not saved.
