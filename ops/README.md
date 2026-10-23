# Operations scripts

Every repeated procedure is a script in `ops/bin/`, so agents cannot drift from it. Conventions (copy
`ops/bin/_template`):

- Prints one `PASS` / `FAIL` line per check and a final `SUMMARY PASS|FAIL <n> checks` line.
- Exits non-zero on any failure.
- Anything that changes state takes `--dry-run`.
- A script that fails or lacks an option is reported, not bypassed (RULES rule 6).

| script | what it does |
|---|---|
| `lock` | Acquire, release and show named locks on shared resources (RULES rule 5) |
| `_template` | Starting point for a new script |
