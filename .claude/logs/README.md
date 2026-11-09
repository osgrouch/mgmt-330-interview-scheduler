# Team message log

`messages.log` records every message the team agents send each other, one line each, in the order sent:

```
YYYY-MM-DD HH:MM:SS | FROM -> TO | TYPE | TEXT
```

Each agent appears under a code: `PRM` pm, `ARC` architect, `CSC` security-expert, `DEV` developer, `TST` tester, `DOC` docs-master. The script accepts a role name or a code and always writes the code.

Agents append to it with `bash .claude/scripts/log-message.sh FROM TO TYPE TEXT` just before sending. The protocol is in `docs/team.md` section 9. `user` appears as a recipient when the PM's report goes to you.
