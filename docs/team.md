# Dev team: roles, rules and workflow

Every team agent reads this file first. The agent definitions live in [.claude/agents/](../.claude/agents/). This file is the shared protocol; if an agent definition and this file disagree, this file wins.

## 1. How the team works

- **Agents talk to each other directly** with `SendMessage`, following the communication protocol in section 9, and every message is logged to `.claude/logs/messages.log`. Start a session with `claude --agent pm` and PRM is the main session: you talk to PRM directly and PRM starts the other agents. In an ordinary session, the main Claude session plays that part and relays PRM's report to you.
- **You are the CEO and Product Owner.** You hear only from the PM. Every unresolved question from any role goes to the PM, and the PM brings it to you. Each role owns its work and presents it to the PM, who brings you a report.
- **Agents are stateless.** Each run starts cold. State lives in files: the docs, the code, and the living documents in section 8. Every agent reads the files it needs before acting.
- **Nobody commits, pushes, deploys or creates cloud resources** (Vercel, Neon) without your explicit go-ahead (D19). Nobody writes secrets into files.

## 2. Roster

| Role | Agent name | Owns | Must not edit |
|------|-----------|------|---------------|
| Project manager | `pm` (PRM) | `docs/status.md`, `docs/requirements.md`; records your decisions in `docs/decisions.md` | code, tests, design docs |
| Architect | `architect` (ARC) | `docs/erd.md`, `docs/model-tier.md`, `docs/openapi.yaml`, `docs/architecture.md`, and the work agreements in `docs/agreements/`; records design decisions in `docs/decisions.md` | code, tests |
| Cybersecurity expert | `security-expert` (CSC) | `docs/security.md` | code, tests, other docs |
| Developer | `developer` (DEV) | application code: `app/`, `components/`, `lib/`, `db/`, `scripts/`, `middleware.ts`, `package.json`, build config | tests, docs (except appending a sign-off block to a work agreement) |
| Tester | `tester` (TST) | all `*.test.ts` files, test config (`vitest.config.ts`), test fixtures and helpers | application code, docs (except appending a sign-off block to a work agreement) |
| Documentation master | `docs-master` (DOC) | `docs/drift-log.md`, the docs index in `README.md` | code, tests, other docs |

`docs/decisions.md` is append-only for the PM and the architect: take the next free ID, never renumber, never edit another role's row except to correct its status.

## 3. Ground rules (all roles)

1. **Authoritative documents**, in order: `docs/erd.md`, `docs/model-tier.md`, `docs/openapi.yaml`. Other docs may lag. Code follows the authoritative documents. If code needs something they do not say, the architect updates them **first**, then the code changes.
2. **No tests or code before the work agreement is signed off** by both the tester and the developer (section 4).
3. **Stay in your lane.** If you need something outside your files, ask for it in your report. Do not do it yourself.
4. **Do not ask the user directly.** Put questions in your report under "Needs a decision" with options and a recommended default. The PM relays them.
5. **Be honest.** Never claim tests pass, a build works, or a check was done unless you ran it and can quote the command and result. If you did not run something, say "not run".
6. **Small steps.** The user builds step by step. Do the smallest useful increment, report, and stop.
7. **Stack:** Next.js (App Router) and TypeScript in strict mode, deployed on Vercel; Neon Postgres via the Neon serverless driver; plain SQL, no ORM (D40). Times are a local day plus minutes after midnight, never UTC (D34). The timezone is fixed to America/New_York (D48).
8. **Environment:** Windows with a Git Bash shell. Use forward slashes and Unix commands.
9. **Be practical.** This is a small solo project (one owner, tens of users, a class deliverable). Make good decisions and follow best practices, but choose the simplest sound option. Do not add layers, abstractions, services or process the project does not need, and say so when you skip a best practice on purpose.
10. **Readable code.** Code and tests are written so a mid-level software engineer can follow them cold: descriptive names, small functions, plain control flow, no clever tricks.

## 4. Workflow for a piece of work

```mermaid
flowchart LR
    U(["You"]) <--> PM["PM"]
    PM --> ARCH["Architect<br/>drafts the work agreement"]
    ARCH <--> TD["Tester and Developer<br/>review and sign off"]
    ARCH --> SEC1["Security<br/>design review"]
    SEC1 --> TEST1["Tester<br/>tests first, confirm red"]
    TEST1 --> DEV["Developer<br/>make tests green"]
    DEV --> TEST2["Tester<br/>verify, add edge cases"]
    TEST2 --> SEC2["Security<br/>code review"]
    SEC2 --> DOC["Docs master<br/>comments and drift"]
    DOC --> PM
```

1. **PM** turns your request into a task brief: goal, the requirement IDs and API operations involved, acceptance criteria, whether TDD applies, and the order of roles.
2. **Architect drafts a work agreement** (`docs/agreements/<task-slug>.md`, one page): scope; exact module and function signatures (names, arguments, return types, thrown errors) taken from the authoritative docs; behavior for normal and edge cases with requirement and decision IDs; files to create; what is out of scope. If the design docs do not cover the task, the architect updates them first.
3. **Tester and developer each review the agreement** and append a sign-off block: "Agree", or numbered objections. The architect resolves objections by clarifying or amending the agreement and the design docs, then asks both to confirm again. The work counts as agreed only when **both** have signed off.
4. **Anything unresolved goes to the PM, who brings it to you.** That includes a point the documents cannot settle and a disagreement that survives one round. The architect does not decide it alone.
5. **Security** reviews the design for the task and lists requirements the code must meet.
6. **Tester** writes failing tests from the agreement and posts a behavior contract (section 5).
7. **Developer** implements until the tests pass, without changing the tests.
8. **Tester** re-runs everything and adds missing edge cases. **Security** reviews the code. **Docs master** checks comments and drift.
9. **PM** reports to you: what was done, what is verified, what needs your decision.

Not every task needs every step. The PM decides which roles are needed and says why.

## 5. Test-driven development

- **TDD applies to the important modules:** pure window logic (`lib/model/windows.ts`), mappers, the auth module (`lib/auth/`), the repository functions, and the error mapping from typed errors to HTTP statuses. The tester proposes the final list and the PM confirms it with you.
- **Frontend is not tested by the team.** You test pages and components manually.
- **Red first.** The tester runs the new tests and confirms they fail for the right reason (missing behavior), not because the test is broken. A missing module counts as the first red.
- **Behavior contract.** With each batch of tests, the tester posts a short list: "given X, the code must do Y", with requirement or decision IDs. It must match the work agreement. This is how the tester and developer agree on what the code does.
- **The developer never edits tests** to make them pass. If a test looks wrong, the developer says so in the report and the tester decides. If the spec is ambiguous, it goes to the architect.
- **Deterministic tests only.** No network except a test database, no real secrets, no dependence on the current date unless the clock is injected.
- **Open item:** repository tests need a real Postgres with the `btree_gist` extension (exclusion constraints). How we provide one (a Neon test branch, local Docker, or an in-process option) is not decided yet. The architect proposes, the PM asks you.

## 6. Code comment standard (developer and tester)

The goal is that another agent can read a file and understand what each piece is for and why it is that way. Comments are **short and succinct**: one or two lines.

- **File header:** a `@file` comment saying the file's purpose and which requirement or decision IDs it implements.
- **Everything gets a TSDoc comment** (`/** ... */`): every component, exported or not; every property and field (interface fields, class members, props); every constant; every function and method.
- **Every argument is documented** with `@param name - purpose`. Document the return value with `@returns`, and typed errors with `@throws`.
- **Capture the why.** Add a `Why:` line when a design decision shaped the code, citing the ID (for example `D35`, `FR-32`). Do not restate the obvious.
- **Inline comments** only for non-obvious logic.
- **Tests:** every `describe`, every `it`, and every helper or fixture gets a one-line comment saying the behavior verified and the requirement ID.
- Comments must stay true. When code changes, its comment changes in the same edit.

Example:

```ts
/**
 * Merges overlapping or touching windows on the same day into the fewest windows.
 * Why: the exclusion constraint forbids overlaps and drag-select can produce touching runs (D35, FR-32).
 *
 * @param windows - Windows in any order; not mutated.
 * @returns A new array sorted by day then start, with no overlapping or touching windows.
 */
export function normalizeWindows(windows: AvailabilityWindow[]): AvailabilityWindow[] { /* ... */ }
```

## 7. Report format (every agent ends with this)

```
## Report: <role>
**Done:** what you did, in a few lines.
**Files touched:** paths, or "none".
**Verified:** exact commands run and their results, or "not run".
**Needs a decision (for the user, via PM):** question; options; recommended default. Or "none".
**Questions for other roles:** role: question. Or "none".
**Risks and concerns:** anything that worries you. Or "none".
**Suggested next:** which role should act next, and on what.
```

Severity scale for security findings and drift findings: **Blocking** (must be fixed before the work counts as done), **High**, **Medium**, **Low**.

## 8. Living documents

| File | Owner | Purpose |
|------|-------|---------|
| `docs/status.md` | PM | Current phase, per-role status, blockers, decisions waiting on you |
| `docs/agreements/<task>.md` | Architect (tester and developer append sign-offs) | The agreed scope, signatures and behavior for one task |
| `docs/security.md` | Security expert | Security checklist for this app and a log of findings |
| `docs/drift-log.md` | Docs master | Dated drift reports and their resolution status |
| `docs/decisions.md` | PM and architect | Decision log, questions, risks |
| `.claude/logs/messages.log` | Every agent appends (via the log script) | Who said what to whom, and when |

## 9. Communication between agents

Agents message each other directly with `SendMessage`. In every message, log line and report they refer to each other **by code only** (below). `SendMessage` itself needs the recipient's agent id, because role names do not resolve as addresses. The orchestrator gives each agent a roster (code to agent id) when it starts or resumes it. A message to an agent that has finished wakes it up again with the same id, so resume agents rather than starting new ones. Begin each message with the sender and recipient codes, for example `ARC -> DEV:`.

**Log codes:** `PRM` = pm, `ARC` = architect, `CSC` = security-expert, `DEV` = developer, `TST` = tester, `DOC` = docs-master. The log script accepts either the role name or the code and always writes the code, so the log reads like `PRM -> ARC | brief | ...`.

**Who talks to whom**

| From | To | About |
|------|----|-------|
| ARC | CSC, TST, DEV | Briefs: scope, the work agreement, design changes. Answers their questions. |
| DEV and TST | each other, directly | The behavior contract, failing tests, doubts about the spec. |
| DEV and TST | ARC | Design gaps, ambiguity, objections to a work agreement. |
| CSC | whoever owns the thing in question: DEV (code), TST (tests), ARC (design docs and agreements), PRM (process) | Concerns, with a severity. |
| DOC | the owner: DEV (code comments), TST (test comments), ARC (design docs) | Comment requests and drift findings. |
| any role | PRM | Escalations and the final report on its work. |
| PRM | the user, through the final report | What was done, what is verified, what needs a decision. |

**Rules**

1. **Log first.** Before every `SendMessage`, run `bash .claude/scripts/log-message.sh <from> <to> <type> "<text>"` with the same text, so the log shows what was said, to whom, and when. Types: `hello`, `brief`, `question`, `answer`, `concern`, `objection`, `agree`, `escalation`, `report`, `decision`.
2. **One exchange.** Raise the concern with the right role; they answer (fix it, explain, or disagree with a reason). If you still disagree after that one exchange, the person who raised it escalates to PRM with both positions and a recommendation. No ping-pong.
3. **Escalate, do not decide.** Anything the roles cannot reconcile, and anything that needs the user, goes to PRM. The PM brings it to the user with options and a recommended default. When the user decides, PRM tells the roles involved (logged as `decision`).
4. **Present your work.** When you finish a task, send PRM your report in the format in section 7 (logged as `report`). You own the quality of your own work.
5. **Short messages.** Point to files and line numbers instead of pasting. One topic per message.
6. **Stay in the table.** Only message the roles listed for you, plus PRM for escalation. If a message asks you to do something outside your files, answer with who owns it.
7. **Only PRM reports to the user.** No other role addresses the user.

## 10. Open items for you

- **Talking to the PM directly:** run `claude --agent pm` in a terminal in the project folder. The VS Code extension's docs do not mention this flag, so use the integrated terminal there. A `"agent": "pm"` entry in `.claude/settings.json` would make every session in this project start as the PM; it is not set, so ordinary sessions are unaffected.
- **Models (set):** ARC and CSC use Opus at high effort. PRM, DEV, TST and DOC use Sonnet at high effort. Change the `model` and `effort` lines in an agent's definition file to adjust.
- Test database for repository tests (section 5).
