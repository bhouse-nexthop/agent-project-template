# Running long agent projects: lessons learned

The main agent should never do the work itself. It hands every task to a subagent and keeps only the result. That one
habit is what let a four-week hardware project run day and night across many sessions, with about 1,600 recorded
steps, without the agent losing track. The rest of this page covers the other practices that made it work, and what to
fix when you copy it. This template is built from those lessons.

**Contents**

- [1. The main agent only delegates](#1-the-main-agent-only-delegates)
- [2. The files are the memory](#2-the-files-are-the-memory)
- [3. A queue and a heartbeat keep work moving](#3-a-queue-and-a-heartbeat-keep-work-moving)
- [4. Rules come from mistakes](#4-rules-come-from-mistakes)
- [5. Try to break it before you spend on it](#5-try-to-break-it-before-you-spend-on-it)
- [6. Scripts, locks and clear permissions](#6-scripts-locks-and-clear-permissions)
- [7. What went wrong, and how to prevent it](#7-what-went-wrong-and-how-to-prevent-it)
- [8. Start your own](#8-start-your-own)

## 1. The main agent only delegates

The main agent's context is the scarcest thing in a long project. Every file it reads, every log it scrolls through
and every test output it parses fills that context. Once it is full, the session gets summarized and detail is lost.
If the main agent does the work itself, it runs out within hours. If it only hands out work, it lasts for days.

```
  +------------------+
  |      Owner       |
  | sets priorities  |
  +--------+---------+
           |
           v
  +------------------+   short brief   +---------------------+  all the detail  +---------------+
  |    Main agent    | --------------> |  Subagents, one per | ---------------> | Project files |
  | picks next item  |                 |  task:              |                  |  plan files   |
  | writes briefs    |   result only   |   code change       |                  |  STATUS.md    |
  | records decisions| <-------------- |   test run          |                  |  RULED-OUT.md |
  | talks to owner   |                 |   break-it review   |                  |  WORKLIST.md  |
  +--------+---------+                 |   research, logs    |                  +---------------+
           ^                           +---------------------+              the next agent reads these
           |
  +------------------+
  |    Heartbeat     |
  | every 5 minutes  |
  +------------------+
```

**What the main agent does:**

- Owns the queue: picks the next item and decides what happens next.
- Writes a short brief and starts a subagent for each task.
- Reads the subagent's short report and records the decision.
- Talks to the person who owns the project.

**What subagents do:** everything else: code changes, test runs, log digging, reviews, research, write-ups. A subagent
can read 50 files and a 10,000-line log. All of that disappears when it finishes. Only its report comes back.

**A good brief is short and points; it does not explain.** It names:

1. The task, and how we will know it is done.
2. Which sections of which files to read. Never "read everything".
3. Which file to write its results into (its own plan file).
4. What it may change, and what needs the owner's OK.
5. What to report back: the result, the evidence as counts ("10 passed (of 10)"), and what it chose not to test.

The brief template is in [`README.md`](README.md) "How to brief a subagent".

**Results go into files, not into the main agent.** The subagent writes the detail into its plan file and returns a
few lines. The main agent keeps the conclusion; the detail is still there for the next agent who needs it.

**Long jobs end with a handoff, not a wait.** If a test run will take an hour, the subagent writes down what is
running, where the output goes and the next step, then stops. A later agent picks it up from the file.

## 2. The files are the memory

A session will end, crash or get summarized. Anything not written to a file is lost when it does. So the project lives
in a small folder under git, and every session starts by reading the same few files in the same order.

| File | What it holds | Size limit |
|---|---|---|
| `README.md` | The goal, what "done" means, where things live, how to resume | 8 KB |
| `RULES.md` | Every rule and every owner decision, with dates. The only rules file | 10 KB |
| `WORKLIST.md` | The queue (in priority order), items waiting on people, a short log | 8 KB |
| `CANDIDATES.md` | Ideas found along the way. Only the owner moves one into the queue | 8 KB |
| `areas/<area>/STATUS.md` | Current state of one area: open problems, latest numbers | 8 KB |
| `areas/<area>/RULED-OUT.md` | Every idea that was tested and failed, and how it was disproved | none |
| `plan/<item>.md` | One file per task: plan, results, handoff | 8 KB |
| `archive/` | Finished history, moved here word for word. Never read on resume | none |

**Keep the files small.** These files are read at every start and every heartbeat. A worklist that grows from 8 KB to
45 KB costs that much more on every read, and the important line gets buried. Move finished text to `archive/` with a
one-line pointer. Never delete it.

**Write it down as you go, not at the end.** Update the status when a number changes. Add to `RULED-OUT.md` the moment
an idea fails. Of all the files, `RULED-OUT.md` saves the most time: it stops the next agent from repeating a dead end.

**Fix wrong conclusions where they are written.** Say that it was wrong and why. A confident wrong note does more harm
than a short one.

## 3. A queue and a heartbeat keep work moving

The most expensive thing in the project was the test hardware sitting idle. Two simple pieces kept it busy without a
person watching.

**The queue.** `WORKLIST.md` has a Queue section in priority order. The agent always takes the first item. Each item is
at most three lines: what to do, how we know it is done, and which plan file has the detail. Finished items leave the
queue right away and become one dated line in the log.

**The heartbeat.** A timer wakes the main agent every 5 minutes with the same short prompt: check whether the test
machine is busy, and if it is idle and the queue is not empty, start the next item. Do not ask, do not plan, start it.

**Check facts, not intentions.** "Is it busy?" is answered by a command (is the test process running?), not by the
agent's memory of starting something. Early on, an agent counted a finished job as still running. The machines sat
idle for 11 hours and both were lost to other users.

**Writing notes is when work stops.** Agents tend to stop and write up results while the machine waits. The rule:
confirm the next run has started, then write.

**The owner sets priorities; the agent does the work.** New ideas go to `CANDIDATES.md`. Only the owner moves one into
the queue. This keeps the agent from growing the scope, and keeps the owner in charge of what matters.

In Claude Code, the heartbeat is a session timer (`CronCreate` or `/loop`). It ends with the session and expires after
7 days, so every resume checks that it still exists.

## 4. Rules come from mistakes

Every rule in the project was written after something went wrong. Each one says what happened, when, and what it cost.
For example:

> **The test machine is never idle.** *Why:* an agent counted a finished job as running; 11 idle hours, both machines
> lost. Broken six times since.

The reason matters more than the rule. An agent that knows *why* a rule exists can apply it to a case the rule never
mentions. An agent that only has the rule follows it word for word, and misses the case next to it.

How to keep rules useful:

- **One rules file.** Other files point to rule numbers and never copy the text. Copies drift apart.
- **Date every rule and every owner decision.** Later readers can tell old from new.
- **Add or sharpen a rule after each new mistake.** That is how the process gets better over time.
- **Keep the review checklist the same way.** Every line is a trap that actually happened, so reviewers check real
  risks, not imagined ones.

## 5. Try to break it before you spend on it

A review takes a few minutes. A test run on shared hardware takes 10 to 60 minutes, and a bad one teaches nothing. On
one early day, twelve tests that looked right turned out to be wrong. So every test and every code change goes through
these steps first ([`REVIEW.md`](REVIEW.md)):

1. **Predict the result.** Before running, write down what each possible outcome would mean. This alone catches many
   mistakes.
2. **Ask a subagent to break it.** Tell it to find what is wrong, not to improve it. For code, it must back each claim
   with a file and line. It returns problems marked BLOCKER or MINOR, plus a list of what it checked and found fine.
3. **Fix the blockers.** A big fix gets a second review of just the changed lines.
4. **Test the measuring tools first.** Run each gate, counter and capture once before the real run. One day, three
   restarts were wasted on tools that did not work.
5. **Check the control before you trust a failure.** A broken baseline looks just like a failed feature.
6. **Check that the numbers add up** before you believe them: sent = received + dropped.

**Test only what the change touches.** Too much testing costs as much as too little when there is one test machine.
Pick one baseline suite, one control and one decisive test per question. Write down what you skipped and why, so nobody
mistakes a skipped test for a missed one.

**Batch the work.** Group the fixes that are ready at the same time into one build and one test session, not one per
fix.

## 6. Scripts, locks and clear permissions

**Turn every repeated step into a script.** Agents drift from written steps; they cannot drift from a script. Every
script in `ops/bin/` follows the same pattern:

- Prints `PASS` or `FAIL` for each check and a final `SUMMARY` line.
- Exits with an error if anything failed.
- Takes `--dry-run` if it changes anything.
- If a script fails or is missing an option, the agent reports it. It never works around it.

**Use locks and queues for anything shared.** One lock per test machine; one build at a time on the build host.
Several agents ran at once without stepping on each other because of this.

**Be clear about what needs permission.**

| The agent may do this without asking | The agent must ask the owner first |
|---|---|
| Anything on test machines it has claimed, including breaking them | Opening pull requests or posting review comments |
| Code changes on its own branches | Anything sent to outside or upstream projects |
| Builds, test runs, reading logs | Creating tickets or sending messages |
| Writing to the project folder | Changing the priority of work |

With that line drawn, the agent can work alone for hours on the left side and never surprise anyone on the right side.

**A refused command means stop.** If a command is denied, the agent reports exactly what was denied and does not look
for another way to do it.

## 7. What went wrong, and how to prevent it

The process held for about three weeks, then started to strain during a busy two-day stretch. Each problem below was a
rule the agents were *asked* to follow but nothing *enforced*.

| Problem | What happened | How this template prevents it |
|---|---|---|
| Files grew past their limits | The worklist went from 9 KB to 45 KB in two days; four files ended up over their limits | A git pre-commit hook refuses the commit when a file is over its limit |
| Finished work stayed in the queue | "Take the first unfinished item" meant reading long paragraphs to find it | The same hook refuses a queue item marked done, or longer than three lines |
| Headers went stale | "Updated Oct 17" sat above Oct 23 content; the start page still pointed to a pause note from three weeks earlier | No hand-written "updated" dates (git has them); facts from outside carry a "Last verified" date that the check flags when old |
| Rules spread over many files | Rules lived in seven files, partly copied | One rules file; everything else points to it by number |
| Some records were never committed | Two important incident notes existed only on disk | Commit your own lines right away; check for uncommitted files at each resume |

**The lesson:** a rule that matters must be checked by a script, not left to an agent's memory. Agents follow rules
well when things are calm and skip them when they are busy, which is exactly when it matters most.

## 8. Start your own

This template has all the files above, ready to fill in. It also includes the checks the original project was missing:
size limits, the queue format, and stale "Last verified" dates, all enforced by a git pre-commit hook
(`scripts/check.sh`, limits in `scripts/caps.conf`).

1. Make a new repo with GitHub's "Use this template" button and clone it, or clone this repo and delete its `.git`
   folder. Then run `scripts/init.sh`. It creates the git repo if needed, turns on the hook and runs the first check.
   It also removes this file from the new project, so its agents never spend context on it.
2. Fill in the goal, what "done" means and who the owner is in `README.md`.
3. In `RULES.md`, fill in what the agent may do alone and what needs your OK. Replace the example reasons with your own
   as mistakes happen.
4. Fill in the idle check for your scarce resource (a test machine, a build host, a CI queue) in the heartbeat prompt in
   `README.md`.
5. Add one `areas/<name>/` folder per part of the work, copied from `areas/_template/`.
6. Put the first two or three items in the Queue, start a session and tell it to read `README.md`.

**Signs it is working:** the main session runs for days without losing track; restarting a session takes minutes;
nobody repeats a failed idea; the scarce resource is rarely idle; and the owner spends time choosing what matters, not
explaining state.
