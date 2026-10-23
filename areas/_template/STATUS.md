# <area>: status

The file the next agent reads first for this area. State only; settled detail goes to `archive/` (cap in
`scripts/caps.conf`).

Last verified: YYYY-MM-DD (against <the source of truth, e.g. the test machine, the PR list>)

## Open defects and state

- **<defect>**: <current state, latest measurement, narrowed hypothesis>. Record: plan/<file>.md

## Changes on shared resources to revert

- <YYYY-MM-DD> <machine>: <change>, revert with <command>.

## Deployed builds and the review each passed

- <build id>: <commit>, reviewed <YYYY-MM-DD> (<record>).
