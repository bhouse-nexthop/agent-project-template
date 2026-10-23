# Rules

The only rules file. README and briefs point at rule numbers; they never restate a rule, so the text cannot drift.
Every rule carries its **Why** (the incident that created it, with a date). Agents apply a rule with a reason to cases
it does not spell out. When a new failure happens, add or sharpen a rule here with the date, the cost and the fix.
Cap: `scripts/caps.conf`. Settled decisions that no longer guide work go to `archive/`.

The seed "Why" lines come from the project this template was built from; replace them as your own incidents happen.

## 1. Hard rules (everyone, including subagents)

1. **Commits** end with `Signed-off-by: <Name> <email>`. No `Co-Authored-By`. Never mention an AI, an assistant or a
   session in commits, PRs, comments, branch names or code.
2. **Never `git commit --no-verify`.** When `scripts/check.sh` fails, archive or trim (rule 22), then commit.
   *Why:* caps that only an agent is asked to check were 5x over within two busy days.
3. **A denied command: stop and report it exactly.** Never work around it.
4. **Outward-facing actions need the owner's go-ahead:** <PRs, review comments, tickets, messages, anything upstream
   or public>. **Resources we hold are ours to break:** <claimed test machines, scratch VMs, our branches>.
5. **Shared resources only through their lock or queue** (`ops/bin/lock`, <build queue>). One heavy job at a time on
   <host>.
6. **Use `ops/bin/` scripts instead of hand-run steps.** A script that fails or lacks an option is reported, not
   bypassed. Never name a shell function after a command it calls (it recurses).
7. **Retract in place.** When a conclusion turns out wrong, correct it where it is written and say so. A confidently
   wrong record is worse than a thin one.

## 2. Orchestrator (the main session)

8. **Heartbeat first.** The first tool call of a session creates the heartbeat (README prompt), and every resume
   checks `CronList`. *Why:* <2026-09-19: 11 hours idle and both test machines lost while the agent believed it was
   complying>.
9. **The scarce resource is never idle.** The check is factual: `<IDLE_CHECK>`. If it says idle and the Queue is not
   empty, launch before writing anything. Documentation turns are the danger: confirm it is busy, then write while it
   runs. *Why:* "arm a continuation" let a finished background task count as busy; violated six times.
10. **Work autonomously.** Never end a turn with "want me to continue?". If you can name the next action, take it.
    Stop only for a decision that is the owner's.
11. **Never call something a blocker if it can be attempted.** "Exhausted" means tried, not "looks hard".
12. **Delegate** reviews, long runs, traces and write-ups to subagents (README brief template). Keep only their
    conclusions. The orchestrator owns the Queue, the decisions and this directory.
13. **Queue vs Candidates.** New ideas and follow-ups go to `CANDIDATES.md`. Only the owner moves one to the Queue.
14. **Prioritising is not starting.** While the owner sets priorities, turn each decision into a Queue item (scope,
    done-when, location) and stop: no builds, branches, claims or outward edits until the owner says start.
15. **Batch and right-size validation.** One build and one test session per group of ready changes, not per fix.
    Test only the paths a change touches, with one control and one decisive variant per question. Write down what was
    deliberately not run and why. *Why:* a 4-variant run took 75 min where one on/off pair settled it.

## 3. Before spending an expensive run (probes and code changes)

16. **Predict first.** Every probe or test script starts with a "how to read this" section: what each outcome means.
17. **Break-it review** by a subagent before deploying or running ([`REVIEW.md`](REVIEW.md)). Fix its BLOCKERs first.
    *Why:* twelve plausible but wrong probes in one day.
18. **Smoke-test every gate, instrument and positive control** once before the first destructive step. *Why:* three
    restarts lost to untested gates in one day.
19. **Re-confirm the control before believing a negative result.** A broken baseline looks exactly like a failure.
20. **Sanity-check the arithmetic** (REVIEW.md) before reading any result as data.

## 4. Record-keeping

21. **Write as you go.** State changes go to the area's `STATUS.md`; a dead hypothesis goes to `RULED-OUT.md` the
    moment it dies, with how it was killed. Any repro run twice becomes a script in the area's `scripts/` with its
    expected-good output.
22. **Archive, don't grow; never delete.** Move settled text verbatim to `archive/` and leave a one-line pointer.
    Caps and the queue format are enforced by the pre-commit hook.
23. **Queue items are short and live.** At most 3 lines; a finished item leaves the Queue and becomes one dated Log
    line (enforced). *Why:* finished items left in the Queue made "launch the first unfinished item" depend on
    parsing paragraph-long lines.
24. **External state carries `Last verified: YYYY-MM-DD`** (PR states, ticket states, machine claims). Re-verify
    before acting on it when `scripts/check.sh` reports it stale. No hand-maintained "Updated" headers: git log says
    that. *Why:* headers reading "updated 10-17" and "verified 10-03" sat over 10-23 content.
25. **With several agents editing:** read a file fully before writing it, and commit your own lines at once.

## 5. Subagents

26. Read only the files and sections your brief names.
27. Record into the plan file your brief names. At most 3 lines in `WORKLIST.md` or a `STATUS.md`.
28. If a run will take an hour or more, write a Handoff block in the plan file and stop. Wait for a run with one
    blocking background command, never by polling.
29. Report: the result, the evidence (counts as "N passed (of M)"), and what was not run and why.

## 6. Decisions (dated, by the owner)

- <YYYY-MM-DD> <decision>. *Why:* <reason>.
