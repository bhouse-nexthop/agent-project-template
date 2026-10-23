#!/usr/bin/env bash
# Sets up a new project copied from this template: git repo, pre-commit hook, first check.
# Usage: cp -r ~/git/agent-project-template ~/git/<project> && ~/git/<project>/scripts/init.sh
set -eu
cd "$(dirname "$0")/.."

[[ -d .git ]] || git init -q
git config core.hooksPath scripts/hooks
chmod +x scripts/check.sh scripts/hooks/pre-commit ops/bin/*
mkdir -p archive/log archive/plan archive/review
scripts/check.sh
echo "Next: fill in the <placeholders> in README.md, RULES.md and CLAUDE.md, copy areas/_template/ per area,"
echo "then commit with your Signed-off-by trailer."
