# Team message log

`messages.log` records every message the team agents send each other, one line each, in the order sent:

```
YYYY-MM-DD HH:MM:SS | FROM -> TO | TYPE | TEXT
```

Each agent appears under a code: `PMAN` project-manager, `ARCH` architect, `CSEC` security-expert, `DEV1` developer-1, `DEV2` developer-2, `TES1` tester-1, `TES2` tester-2, `REVW` reviewer, `DOCM` docs-master. The script accepts a role name or a code and always writes the code.

Agents append to it with `bash .claude/scripts/log-message.sh FROM TO TYPE TEXT` just before sending. The protocol is in `docs/team.md` section 9. `user` appears as a recipient when the PM's report goes to you.
