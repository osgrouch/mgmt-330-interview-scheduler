# MGMT 330 Interview Software

An application for my MGMT 330 class project to setup interviews.

Senior Year, Fall 2026

## Design documents

Code is written against these. The first three are **authoritative**, in this order (decision D51); the rest may lag behind them.

| Document | What it is |
|----------|------------|
| [docs/erd.md](docs/erd.md) | Data model (authoritative) |
| [docs/model-tier.md](docs/model-tier.md) | How the tables live in the Next.js app: types, repository functions, SQL schema (authoritative) |
| [docs/openapi.yaml](docs/openapi.yaml) | API contract (authoritative) |
| [docs/requirements.md](docs/requirements.md) | User, functional and non-functional requirements |
| [docs/decisions.md](docs/decisions.md) | Decision log, resolved questions and risks |
| [docs/api-report.md](docs/api-report.md) | Report on the API spec |
| [docs/architecture.md](docs/architecture.md) | Architecture diagrams (Mermaid; render on GitHub) |
| [docs/team.md](docs/team.md) | The dev team: roles, rules, TDD workflow, code comment standard |

The team's agents are defined in [.claude/agents/](.claude/agents/).
