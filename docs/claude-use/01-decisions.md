# Team decisions

Decisions about **how the agent team works**: roles, workflow, who commits, what reaches the user, and team conventions. Decisions about the app itself are in [04-decisions.md](../software-app/04-decisions.md).

Both files share one ID sequence (D19, D55-D57 and D64-D72 live here; the rest live there). Take the next free ID across the two files, and never renumber: IDs are cited from other docs. The protocol these decisions produced is [00-workflow.md](00-workflow.md).

Status key: **Confirmed** (the user has agreed; the Source column says who proposed it) | **Process** (a working rule).

## Decisions

| ID | Req ref | Decision | Status | Source | Cost if wrong |
|----|---------|----------|--------|--------|---------------|
| D19 | n/a | I will not deploy, push, or create cloud resources (Vercel/Neon) without an explicit go-ahead. | **Process** | Outward-facing actions | n/a |
| D55 | Process | The dev team is subagents defined in `.claude/agents/` (six at first; nine since D66: PM, architect, security-expert, developer-1, developer-2, tester-1, tester-2, reviewer, docs-master). The shared protocol is [00-workflow.md](00-workflow.md). The main session orchestrates; the PM is the user's point of contact. | **Confirmed** | User | n/a |
| D56 | Process | Test-driven development for the important modules (pure window logic, mappers, auth module, repository functions, error mapping). The tester writes tests first; the developer never edits tests. The frontend is not tested by the team; the user tests it manually. | **Confirmed** | User | n/a |
| D57 | Process | Code comment standard: a short TSDoc comment on every component, property, constant, function and argument, plus a `Why:` line citing decision IDs where a design decision shaped the code. Tests are commented the same way. Defined in 00-workflow.md section 6. | **Confirmed** | User | n/a |
| D64 | Process | **Workflow weight.** ARCH's work agreements are per tier (about seven), each signed off by the developers and testers involved. DOCM checks comments and drift once per group of agreements. UI pages get no agreement; the user tests them by hand. | **Confirmed** | User, on DOCM proposal (2026-11-09) | Low. |
| D65 | Process | **Only the user commits** (and pushes and deploys). No agent runs `git commit`, `git add` for the purpose of committing, or push. REVW only helps write commit messages. | **Confirmed** | User (2026-11-09) | n/a |
| D66 | Process | **Team change.** Two developers, DEV1 and DEV2 (DEV renamed DEV1), with identical instructions; they split the implementation into independent modules and then integrate. Two testers, TES1 and TES2 (TST renamed TES1): TES1 tests DEV1's work, TES2 tests DEV2's. A new reviewer, REVW, enforces formatting, lint and build checks on the developers' code before big features reach the user, and helps the user write commit messages; those checks move from DEV to REVW. The four builders may coordinate directly and decide best practices among themselves. | **Confirmed** | User (2026-11-09) | n/a |
| D67 | Process | **Technical disagreements between DEV1, DEV2, TES1 and TES2 escalate to ARCH, whose decision is final.** The user is not part of that chain and is not told about them. Replaces the "unresolved goes to the user" step in 00-workflow.md for these four roles. What still reaches the user is in D68. | **Confirmed** | User (2026-11-09) | Low. |
| D68 | Process | **What still reaches the user (Q19):** only scope or requirement changes, anything that costs money or creates cloud resources (D19), commits (D65), and a Blocking finding from CSEC that ARCH wants to overrule. All other technical disagreements stay inside the team (D67). | **Confirmed** | User (2026-11-09) | Low. |
| D69 | Process | **The user edits the team files** (`.claude/agents/*.md`, `docs/claude-use/00-workflow.md`, `.claude/scripts/log-message.sh`) to make the D66 team change. PMAN does not edit them. | **Confirmed** | User (2026-11-09) | n/a |
| D70 | Process | **Team change details.** Agent codes: PMAN, ARCH, CSEC, DEV1, DEV2, TES1, TES2, REVW, DOCM (the user renamed ARC, CSC and DOC). Agent file names: `developer-1`, `developer-2`, `tester-1`, `tester-2`, `reviewer`. The work agreement gives every file one owner, so builders never edit the same file; DEV1 owns `package.json` and the lockfile. REVW owns the Prettier, ESLint and EditorConfig files; runs the gate (`format:check`, `lint`, `typecheck`, `build`) on integrated code before a big feature reaches the user and again after later code changes; may apply formatter and mechanical `--fix` changes and tells the file's owner; sends everything else to the owner; never commits. REVW drafts commit messages in Conventional Commits style for the user to run (D65). ARCH also settles disagreements between a builder and CSEC, DOCM or REVW, but never overrules a Blocking CSEC finding alone (D68). The four builders may talk to each other directly at any time. | **Confirmed** | User asked for the roles and confirmed the details (Q20, 2026-11-09) | Low. |
| D71 | Process | **PRM is renamed PMAN.** Codes are now PMAN, ARCH, CSEC, DEV1, DEV2, TES1, TES2, REVW, DOCM. | **Confirmed** | User (2026-11-09) | n/a |
| D72 | Process | **The PMAN agent is named `project-manager`** (was `pm`): file `.claude/agents/project-manager.md`, started with `claude --agent project-manager`. The log script still accepts `pm` as an alias. | **Confirmed** | User (2026-11-09) | n/a |

## Resolved questions

| ID | Question | Answer |
|----|----------|--------|
| Q19 | What still reaches the user despite D67? | Only: scope or requirement changes, anything costing money or creating cloud resources (D19), commits (D65), and a Blocking finding from CSEC that ARCH wants to overrule. Everything else stays inside the team (D68). |
| Q20 | Confirm D70: Conventional Commits, REVW may apply formatter and mechanical lint fixes, the gate runs before CSEC's code review, DEV1 owns `package.json`. | Yes to all four (D70). |
