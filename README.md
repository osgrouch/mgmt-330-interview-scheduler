# MGMT 330 Interview Software

An application for my MGMT 330 class project to setup interviews.

Senior Year, Fall 2026

## The team

The app is built by a team of nine Claude Code agents. Start a session with `claude --agent project-manager` to talk to PMAN, who is your single point of contact and the only agent that reports to you. The team's rules and workflow are in [docs/claude-use/00-workflow.md](docs/claude-use/00-workflow.md); every message between agents is logged in `.claude/logs/messages.log`.

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

## Documents

The full index is [docs/README.md](docs/README.md). Code is written against the design documents in [docs/software-app/](docs/software-app/); the first three are **authoritative**, in this order (decision D51), and the rest may lag behind them.

| Document | What it is |
|----------|------------|
| [01-erd.md](docs/software-app/01-erd.md) | Data model (authoritative) |
| [02-model-tier.md](docs/software-app/02-model-tier.md) | How the tables live in the Next.js app: types, repository functions, SQL schema (authoritative) |
| [03-openapi.yaml](docs/software-app/03-openapi.yaml) | API contract (authoritative) |
| [04-decisions.md](docs/software-app/04-decisions.md) | Decisions about the app: decision log, resolved questions and risks |
| [05-architecture.md](docs/software-app/05-architecture.md) | Architecture diagrams (Mermaid; render on GitHub) |
| [06-requirements.md](docs/software-app/06-requirements.md) | User, functional and non-functional requirements |

How the agent team works is in [docs/claude-use/](docs/claude-use/): [00-workflow.md](docs/claude-use/00-workflow.md) (roles, rules, workflow, code comment standard) and [01-decisions.md](docs/claude-use/01-decisions.md) (decisions about the team). The agent definitions are in [.claude/agents/](.claude/agents/).
