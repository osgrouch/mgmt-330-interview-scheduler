# MGMT 330 Interview Software

An application for my MGMT 330 class project to setup interviews.

Senior Year, Fall 2026

## The team

The app is built by a team of nine Claude Code agents. Start a session with `claude --agent project-manager` to talk to PMAN, who is your single point of contact and the only agent that reports to you. The team's rules and workflow are in [docs/team.md](docs/team.md); every message between agents is logged in `.claude/logs/messages.log`.

| Codename | Agent | Job |
|----------|-------|-----|
| PMAN | `project-manager` | Turns your requests into task briefs, tracks status and open questions, and is the only agent that reports to you. |
| ARCH | `architect` | Owns the design docs, writes the work agreement for each task, splits modules between the developers, and has the final say on technical disagreements. |
| CSEC | `security-expert` | Reviews designs and code for security and flags concerns with a severity. |
| DEV1 | `developer-1` | Writes the modules the work agreement assigns to DEV1, with a comment on every part of the code. |
| DEV2 | `developer-2` | Identical to DEV1; builds the other half of the modules, then integrates with DEV1. |
| TES1 | `tester-1` | Writes tests first for DEV1's modules and posts the behavior contract DEV1 codes against. |
| TES2 | `tester-2` | Identical to TES1; tests DEV2's modules, and writes integration tests with TES1. |
| REVW | `reviewer` | Runs the format, lint, type and build checks before a big feature reaches you, and drafts your commit messages. |
| DOCM | `docs-master` | Checks that code comments are complete and accurate and reports drift between the code and the docs. |

## Design documents

Code is written against these. The first three are **authoritative**, in this order (decision D51); the rest may lag behind them.

| Document | What it is |
|----------|------------|
| [docs/erd.md](docs/erd.md) | Data model (authoritative) |
| [docs/model-tier.md](docs/model-tier.md) | How the tables live in the Next.js app: types, repository functions, SQL schema (authoritative) |
| [docs/openapi.yaml](docs/openapi.yaml) | API contract (authoritative) |
| [docs/requirements.md](docs/requirements.md) | User, functional and non-functional requirements |
| [docs/decisions.md](docs/decisions.md) | Decisions about the app: decision log, resolved questions and risks |
| [docs/team-decisions.md](docs/team-decisions.md) | Decisions about how the agent team works |
| [docs/api-report.md](docs/api-report.md) | Report on the API spec |
| [docs/architecture.md](docs/architecture.md) | Architecture diagrams (Mermaid; render on GitHub) |
| [docs/team.md](docs/team.md) | The dev team: roles, rules, workflow, code comment standard |
| [docs/status.md](docs/status.md) | Current status, agent roster and what is waiting on you |

The agent definitions are in [.claude/agents/](.claude/agents/).
