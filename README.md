# <Project name>

**Goal:** <one sentence: what has to be true at the end>.
**Done means:** <a measured outcome, e.g. "traffic measured on hardware", "N passed (of M) on the target suite">, never
"the call returned success".
**Owner:** <name>. Only the owner moves work from Candidates to the Queue and approves outward-facing actions.

This directory is the project's working state, not a report written at the end. Sessions are disposable: anything not
written here is lost when a session ends. It has local git history only. Commit as you go (`RULES.md` rule 1).

## Resume (at every session start and after every compaction)

1. Read this file, then [`RULES.md`](RULES.md) (the only rules file), then [`WORKLIST.md`](WORKLIST.md).
2. `CronList`; if the heartbeat is missing, create it (rule 8, prompt below).
3. Run `scripts/check.sh`. If it fails, fix the records first (archive; see rule 22).
4. Open an area's `STATUS.md` / `RULED-OUT.md` or a plan file only when the Queue item you are working on needs it.

## Where things live

| what | where |
|---|---|
| Why this layout works, in plain English (for people, not read on resume) | [`LESSONS.md`](LESSONS.md) |
| Rules and the owner's decisions (the only rules file) | [`RULES.md`](RULES.md) |
| The queue the heartbeat runs, waiting items, the log | [`WORKLIST.md`](WORKLIST.md) |
| Ideas and follow-ups the owner has not prioritised | [`CANDIDATES.md`](CANDIDATES.md) |
| Per area: current state, dead ends, scripts | `areas/<area>/STATUS.md`, `RULED-OUT.md`, `scripts/` (copy [`areas/_template/`](areas/_template/)) |
| One plan or record file per work item | `plan/<item>-<slug>.md` (copy [`plan/_TEMPLATE.md`](plan/_TEMPLATE.md)) |
| Break-it review protocol and the trap checklist | [`REVIEW.md`](REVIEW.md) |
| Scripts for repeated procedures (PASS/FAIL, `--dry-run`) | [`ops/bin/`](ops/bin/), index in [`ops/README.md`](ops/README.md) |
| Settled history, never loaded on resume | [`archive/`](archive/README.md) |
| Size caps, queue format, freshness checks (pre-commit hook) | `scripts/check.sh`, caps in `scripts/caps.conf` |

## Heartbeat prompt (rule 8)

`CronCreate` with `cron: "*/5 * * * *"`, `recurring: true`, and this prompt (fill in the idle check):

```
Check <path>/WORKLIST.md. Run the idle check: <IDLE_CHECK, e.g. ps -ef | grep -c "[r]un-suite">.
If <the scarce resource> is idle and the WORKLIST Queue is not empty, start the first Queue item
now. Do not ask permission. Do not reply with a plan - launch it. If the Queue is empty, say so in
one line and stop.
```

The cron is session-only and expires after 7 days; it fires only while the session is idle. That is why step 2 of
Resume checks for it every time.

## How to brief a subagent

Point it at sections, not whole files. Template:

```
Task: <one paragraph: what to do and the done-when>.
Read: RULES.md sections 1 and 5; plan/<item>.md "State" and "Handoff"; <named sections only>.
Record into: plan/<item>.md (results, evidence, what was deliberately not run and why).
WORKLIST.md / STATUS.md: at most 3 lines each. Commit your own lines at once.
Allowed: <what it may change, e.g. the claimed bench, pushes to its own <github-username>.<x> branches>.
Not allowed without the owner: <outward-facing actions>.
If a run will take an hour or more: write a Handoff block in the plan file and stop.
Report back: the result, the evidence (counts as "N passed (of M)"), and what you did not run.
```
