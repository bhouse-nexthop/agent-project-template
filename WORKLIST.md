# Worklist

The heartbeat launches the **first item in Queue** and nothing else. Items in [`CANDIDATES.md`](CANDIDATES.md) never
run until the owner moves one here. The Queue is in priority order, highest first.

Item format (enforced by `scripts/check.sh`): `N. [area] **title**: done when <measurable result>. Plan:
plan/<file>.md`, at most 3 lines. When an item finishes, delete it from Queue and add one dated line to Log. Detail
lives in the plan file, not here.

## Queue

1. [area] **<title>**: done when <measurable result>. Plan: plan/<file>.md

## Waiting (on people or external events; never launched)

- [area] **<title>**: waiting on <who/what> since <YYYY-MM-DD>. Plan: plan/<file>.md

## Log (newest first; one dated line per event; older lines to archive/log/)

- <YYYY-MM-DD> <event>.
