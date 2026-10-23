#!/usr/bin/env bash
# Sets up a new project copied from this template: git repo, pre-commit hook, first check.
# Usage: either "Use this template" on GitHub and clone the new repo, or start from a plain copy:
#   git clone --depth 1 https://github.com/bhouse-nexthop/agent-project-template ~/git/<project>
#   rm -rf ~/git/<project>/.git && ~/git/<project>/scripts/init.sh
set -eu
cd "$(dirname "$0")/.."

if [[ $(git remote get-url origin 2>/dev/null) == *agent-project-template* ]]; then
  echo "FAIL this is the template's own clone: remove .git first (see Usage)" >&2
  exit 1
fi
[[ -d .git ]] || git init -q -b main
git config core.hooksPath scripts/hooks
chmod +x scripts/check.sh scripts/hooks/pre-commit ops/bin/*
mkdir -p archive/log archive/plan archive/review
scripts/check.sh
echo "Next: fill in the <placeholders> in README.md, RULES.md and CLAUDE.md, copy areas/_template/ per area,"
echo "then commit with your Signed-off-by trailer."
