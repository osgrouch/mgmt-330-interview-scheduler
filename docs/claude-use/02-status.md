# Status

Owner: PMAN. Last updated: 2026-11-09 (repo state refreshed after the docs restructure; the restructure is still uncommitted). The earlier status file was deleted in the restructure, so per-role history before this point is not recorded here.

## Current phase

Design docs are done (ERD, model tier, API, architecture, requirements). No application code exists. The agent team was reworked (nine agents, new codes, new docs layout) and **operations are paused until OSCR says to resume**. No agent is running.

## Repo state (read 2026-11-09 with `git status`, `git log`, `git diff --stat`, `ls`)

- **Commits:** 4 on the branch; the latest is `d68b8c5 feat(claude): adding more claude agents to the team`. The restructure after it is **not committed** (the user commits, D65).
- **Uncommitted, mixed staged and unstaged:**
  - All nine agent files in `.claude/agents/` are modified (`project-manager.md` and `reviewer.md` also have staged changes), plus `.claude/logs/README.md` and `.claude/scripts/log-message.sh`.
  - The old flat docs (`docs/erd.md`, `model-tier.md`, `openapi.yaml`, `architecture.md`, `api-report.md`, `decisions.md`, `requirements.md`, `team.md`, `team-decisions.md`) show as **deleted** in the working tree.
  - Their replacements are **untracked**: `docs/README.md`, `docs/software-app/` (01-erd, 02-model-tier, 03-openapi, 04-decisions, 05-architecture, 06-requirements) and `docs/claude-use/` (00-workflow, 01-decisions, 02-status, 03-security, 04-drift-log, 05-architectural-decisions, `dev-agreements/`).
  - Root `README.md` is modified.
- **Not read by PMAN:** the contents of the design docs after the move, `03-security.md`, `04-drift-log.md` and `05-architectural-decisions.md`. I checked only that they exist and that D58-D72 and Q19/Q20 are present and consistent across `04-decisions.md` and `01-decisions.md`.
- **Code:** none. Still no `package.json`, `.gitignore`, `app/`, `lib/` or tests at the repo root. CSEC's High gap (no `.gitignore`) is still open.
- **Team files:** the shuffle is in the working tree. Agent types now available are `project-manager`, `architect`, `security-expert`, `developer-1`, `developer-2`, `tester-1`, `tester-2`, `reviewer`, `docs-master`. The old `developer` and `tester` types are gone.
- **Message log:** `.claude/logs/messages.log` still holds only my five readiness briefs, written under the old codes (`PRM -> ARC`, and so on). It is not rewritten.
- **`.claude/settings.local.json`** was in the folder earlier today and is not there now. Cause not checked.
- **Old agent ids** from the readiness check (the five original agents) belong to the old roster. Treat them as dead; new agents get new ids.

**Watch-out for the commit:** if the user stages only part of this, the old docs could be committed as deleted while the new `docs/software-app/` and `docs/claude-use/` stay untracked. Add both new folders and the deletions in the same commit (REVW can draft the message once running).

## Roster (code to agent id)

PMAN gives each agent this roster when it starts or resumes it, because `SendMessage` needs ids. Update it whenever an agent is started.

| Code | Agent | Agent id |
|------|-------|----------|
| PMAN | `project-manager` | (main session) |
| ARCH | `architect` | (not started) |
| CSEC | `security-expert` | (not started) |
| DEV1 | `developer-1` | (not started) |
| DEV2 | `developer-2` | (not started) |
| TES1 | `tester-1` | (not started) |
| TES2 | `tester-2` | (not started) |
| REVW | `reviewer` | (not started) |
| DOCM | `docs-master` | (not started) |
| OSCR | the owner | n/a |

## Per role

| Role | Last report | Date |
|------|-------------|------|
| ARCH | None since the restructure. Carried over from the earlier readiness check: design gaps G1-G9 to fix in the design docs; proposes about 7 work agreements, starting with `pure-window-logic`. The full report was not saved. | n/a |
| CSEC | None since the restructure. Carried over: 16 MVP security must-haves, no `.gitignore` yet, session design missing (since settled in D62). | n/a |
| DEV1, DEV2 | None. | n/a |
| TES1, TES2 | None. | n/a |
| REVW | None. | n/a |
| DOCM | None since the restructure. Carried over: 12 drift findings (2 High) from the earlier readiness check; none blocked the pure window logic. | n/a |

## Blockers

- Everything is paused until OSCR says to resume.
- Database and API work needs ARCH to close the design gaps (G1-G9) and a Neon project (D61). The pure window logic needs neither.

## Risks

See the risk table in [../software-app/04-decisions.md](../software-app/04-decisions.md). `btree_gist` on Neon (R9) is unverified until the first migration.

## Waiting on OSCR

- Tell PMAN when to resume.
- Later: create the Neon project (D61) when the team asks. An agent never creates it (D19).
