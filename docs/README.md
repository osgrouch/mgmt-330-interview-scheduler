# Docs

Documents for the MGMT 330 interview scheduler, in two folders: what we are building, and how the agent team builds it.

| Folder | What it holds |
|--------|---------------|
| [software-app/](software-app/) | The app: data model, how it is built, API contract, requirements and decisions. |
| [claude-use/](claude-use/) | The Claude agent team: how it works and the decisions about it. |

## software-app/

Numbered in the order the design was built. The first three are **authoritative**: when code or another document disagrees with them, they win (D51).

| File | What it is | Owner |
|------|------------|-------|
| [01-erd.md](software-app/01-erd.md) | Data model (authoritative) | ARCH |
| [02-model-tier.md](software-app/02-model-tier.md) | How the tables live in the Next.js app: types, repository functions, SQL schema (authoritative) | ARCH |
| [03-openapi.yaml](software-app/03-openapi.yaml) | API contract (authoritative) | ARCH |
| [04-decisions.md](software-app/04-decisions.md) | Decisions about the app: decision log, resolved questions, risks | PMAN, ARCH |
| [05-architecture.md](software-app/05-architecture.md) | Architecture diagrams, derived from the three authoritative files | ARCH |
| [06-requirements.md](software-app/06-requirements.md) | User, functional and non-functional requirements | PMAN |

## claude-use/

How the agent team works, plus the team's living documents. Numbered in reading order.

| File | What it is | Owner |
|------|------------|-------|
| [00-workflow.md](claude-use/00-workflow.md) | The team: roles, rules, workflow, communication, code comment standard | PMAN |
| [01-decisions.md](claude-use/01-decisions.md) | Decisions about how the team works | PMAN |
| [02-status.md](claude-use/02-status.md) | Current status, agent roster, and what is waiting on the owner | PMAN |
| [03-security.md](claude-use/03-security.md) | Security checklist and findings log | CSEC |
| [04-drift-log.md](claude-use/04-drift-log.md) | Drift reports between code, comments and docs | DOCM |
| [05-architectural-decisions.md](claude-use/05-architectural-decisions.md) | The architecture choices, with reasons and alternatives | ARCH |
| [dev-agreements/](claude-use/dev-agreements/) | One work agreement per task, with developer and tester sign-offs | ARCH |

## Notes

- Decision IDs (D1, D58 and so on) are cited across these files. The two decision logs share one ID sequence, so an ID never changes when a row moves between them.
- Removed from the old layout: the API report (`api-report.md`). The decision log, requirements and architecture no longer refer to it.
- The project overview and the table of agents are in the repository [README](../README.md). Agent definitions are in [.claude/agents/](../.claude/agents/), and the team's message log is `.claude/logs/messages.log`.
