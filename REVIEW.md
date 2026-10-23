# Break-it review: before every probe and every code change under test

A review takes minutes and no scarce resource. A wrong probe or an unreviewed change costs a full run, and a pass on a
change that was never active looks the same as a real pass. There is no case where skipping it pays.

## Probes

1. **Write the script, including its "how to read this" section** (RULES rule 16). Stating in advance what each
   outcome means is half the review.
2. **Hand the design to a subagent told to break it, not improve it.** The prompt includes the actual inputs, the
   measurement geometry and the expected counts: that is where the errors live.
3. **Fix what it finds, then smoke-test** each gate, instrument and positive control once against the real target
   before the first destructive step (rule 18).
4. **Apply the arithmetic checks** below to the result before reading it as data.

## Code changes (review before the build is deployed)

1. Commit the change (the reviewed diff is the deployed diff) and start the build. Review and build run in parallel.
2. A subagent reviews the commit to break it and backs every claim with a `file:line` trace. The prompt names the
   goal, the base, and what "unchanged when off" means.
3. It returns defects marked **BLOCKER / MINOR**, plus a "checked, fine" list with evidence so coverage is visible.
4. Fix the BLOCKERs and rebuild. A fix that changes the design gets a second review, of the changed lines only.
   Record in the area's `STATUS.md` which review the deployed commit passed.

What to attack: **is the change active on the target** (flag read, code path reached)? What happens when it is off?
Error and teardown paths, restart and replay, resource leaks, ordering between components.

## Right-size the validation

Before a run, write down: what the change touches; the minimum set (one baseline suite for that area against its
recorded baseline, probes for the touched paths only, one control, one decisive variant per question); and what is
deliberately not run, and why. That last list goes in the record and the PR. Add more only when a result is
ambiguous or the change reaches further than expected.

## Arithmetic checks (every result, before it is read)

- Do the counts add up (sent = received + dropped + counted elsewhere)?
- Did the control behave as recorded last time?
- Is the delta per cycle, per run or once? Run twice and compare.
- Would this number look the same if the feature were off?

## The checklist (one line per trap)

Every line is something that actually went wrong in this project, with its date. Ask each one of the design under
review. Long stories go to `archive/review/`.

- <YYYY-MM-DD> <trap>: <how to catch it>.
