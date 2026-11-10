#!/usr/bin/env bash
# Appends one line to the team message log (.claude/logs/messages.log).
# Every agent runs this BEFORE it sends a message to another agent, so the log shows
# who said what to whom, and when, in the order it happened.
#
# Usage: bash .claude/scripts/log-message.sh FROM TO TYPE TEXT...
#   FROM, TO  a role name or its code; the log always shows the code:
#             project-manager=PMAN  architect=ARCH  security-expert=CSEC  developer-1=DEV1  developer-2=DEV2
#             tester-1=TES1  tester-2=TES2  reviewer=REVW  docs-master=DOCM
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
    project-manager|pm|prm|pman)    echo "PMAN" ;;
    architect|arc|arch)             echo "ARCH" ;;
    security-expert|cybersecurity|csc|csec) echo "CSEC" ;;
    developer-1|dev1)               echo "DEV1" ;;
    developer-2|dev2)               echo "DEV2" ;;
    tester-1|tes1)                  echo "TES1" ;;
    tester-2|tes2)                  echo "TES2" ;;
    reviewer|revw)                  echo "REVW" ;;
    docs-master|doc|docs|docm)      echo "DOCM" ;;
    *)                              echo "$1" ;;
  esac
}

from="$(code "$1")"; to="$(code "$2")"; type="$3"; shift 3
text="$*"
text="${text//$'\n'/ }"   # keep one message on one line
text="${text//|/-}"       # the pipe is the column separator

root="$(cd "$(dirname "$0")/.." && pwd)"   # the .claude directory
mkdir -p "$root/logs"
printf '%s | %-4s -> %-4s | %s | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$from" "$to" "$type" "$text" >> "$root/logs/messages.log"
