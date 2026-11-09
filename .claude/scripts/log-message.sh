#!/usr/bin/env bash
# Appends one line to the team message log (.claude/logs/messages.log).
# Every agent runs this BEFORE it sends a message to another agent, so the log shows
# who said what to whom, and when, in the order it happened.
#
# Usage: bash .claude/scripts/log-message.sh FROM TO TYPE TEXT...
#   FROM, TO  a role name or its code; the log always shows the code:
#             pm=PRM  architect=ARC  security-expert=CSC  developer=DEV  tester=TST  docs-master=DOC
#             (anything else, such as "user", is written as given)
#   TYPE      hello | brief | question | answer | concern | objection | agree | escalation | report | decision
#   TEXT      the message, or a faithful short version of it
# Line format: YYYY-MM-DD HH:MM:SS | FROM -> TO | TYPE | TEXT
set -eu

if [ "$#" -lt 4 ]; then
  echo "usage: log-message.sh FROM TO TYPE TEXT..." >&2
  exit 2
fi

# Maps a role name (any case) or code to the agent's code shown in the log.
code() {
  case "${1,,}" in
    pm|prm)                         echo "PRM" ;;
    architect|arc)                  echo "ARC" ;;
    security-expert|cybersecurity|csc) echo "CSC" ;;
    developer|dev)                  echo "DEV" ;;
    tester|tst)                     echo "TST" ;;
    docs-master|doc|docs)               echo "DOC" ;;
    *)                              echo "$1" ;;
  esac
}

from="$(code "$1")"; to="$(code "$2")"; type="$3"; shift 3
text="$*"
text="${text//$'\n'/ }"   # keep one message on one line
text="${text//|/-}"       # the pipe is the column separator

root="$(cd "$(dirname "$0")/.." && pwd)"   # the .claude directory
mkdir -p "$root/logs"
printf '%s | %-3s -> %-3s | %s | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$from" "$to" "$type" "$text" >> "$root/logs/messages.log"
