#!/usr/bin/env bash
# Record checks: size caps, WORKLIST queue format, and stale "Last verified:" dates.
# Usage: scripts/check.sh            check the working tree
#        scripts/check.sh --staged   check what is staged (the pre-commit hook uses this)
# Caps and limits: scripts/caps.conf. Fails on caps and queue format; stale dates only warn.
set -u
cd "$(dirname "$0")/.." || exit 2

staged=0
[[ ${1:-} == --staged ]] && staged=1

conf=scripts/caps.conf
fails=0

setting() {
  awk -v k="$1" '$1 == k { print $2 }' "$conf"
}

# Prints a file's content: the staged version under --staged, else the working tree.
content() {
  if ((staged)); then
    git show ":$1" 2>/dev/null
  else
    cat "$1" 2>/dev/null
  fi
}

# Lists the files to check: tracked (index) files under --staged, else files on disk.
files() {
  if ((staged)); then
    git ls-files
  else
    find . -type f -not -path './.git/*' | sed 's|^\./||'
  fi
}

skip() {
  [[ $1 == archive/* || $1 == *_TEMPLATE* || $1 == */_template/* ]]
}

# 1. Size caps.
printf '%-32s %8s %6s  %s\n' file size cap state
while read -r glob cap; do
  [[ -z $glob || $glob == \#* || ! $cap =~ ^[0-9]+$ ]] && continue
  while read -r f; do
    [[ -n $f ]] || continue
    skip "$f" && continue
    # shellcheck disable=SC2053 # $glob is a glob on purpose
    [[ $f == $glob ]] || continue
    bytes=$(content "$f" | wc -c)
    state=ok
    if ((bytes > cap * 1024)); then
      state=OVER
      fails=$((fails + 1))
    fi
    printf '%-32s %6.1fKB %4sKB  %s\n' "$f" "$(bc -l <<<"$bytes/1024")" "$cap" "$state"
  done < <(files)
done <"$conf"

# 2. WORKLIST queue format: short items, no finished items left in the Queue, a bounded Log.
max_lines=$(setting queue_item_max_lines)
max_chars=$(setting queue_item_max_chars)
log_max=$(setting log_max_lines)
queue_report=$(content WORKLIST.md | awk -v ml="$max_lines" -v mc="$max_chars" -v lm="$log_max" '
  function flush() {
    if (item == "") return
    if (lines > ml) printf "FAIL queue item %s: %d lines (max %d)\n", id, lines, ml
    if (length(item) > mc) printf "FAIL queue item %s: %d chars (max %d)\n", id, length(item), mc
    if (item ~ /DONE|CLOSED|FINISHED/) printf "FAIL queue item %s is finished: move it to Log as one line\n", id
    item = ""
  }
  /^## / { flush(); section = $0; next }
  section == "## Queue" && /^[0-9]+\. / { flush(); id = $1; sub(/\.$/, "", id); item = $0; lines = 1; next }
  section == "## Queue" && item != "" && NF { item = item " " $0; lines++; next }
  section ~ /^## Log/ && /^- / { logn++ }
  END {
    flush()
    if (logn > lm) printf "FAIL Log has %d lines (max %d): move older lines to archive/log/\n", logn, lm
  }')
if [[ -n $queue_report ]]; then
  echo "$queue_report"
  fails=$((fails + $(grep -c '^FAIL' <<<"$queue_report")))
fi

# 3. Stale "Last verified:" dates (warning only).
stale_days=$(setting stale_days)
today=$(date -u +%s)
while read -r f; do
  [[ $f == *.md ]] || continue
  skip "$f" && continue
  while read -r d; do
    [[ $d =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || continue
    age=$(((today - $(date -u -d "$d" +%s)) / 86400))
    if ((age > stale_days)); then
      echo "WARN $f: Last verified $d ($age days ago): re-verify before acting on it"
    fi
  done < <(content "$f" | sed -n 's/^Last verified: *\([0-9-]*\).*/\1/p')
done < <(files)

if ((fails)); then
  echo "SUMMARY FAIL $fails problem(s): archive settled text, don't grow (RULES rule 22). Never --no-verify."
  exit 1
fi
echo "SUMMARY PASS"
