#!/usr/bin/env bash
# Records that the current tree passed analyze and the full suite: writes
# $(git rev-parse --git-common-dir)/tested-trees/<tree>. Run only after a green
# `flutter analyze` and `flutter test --concurrency=16` on a clean tree. The
# marker lives in the shared git dir, so every worktree sees it; a merge whose
# tree has a marker needs no rerun.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
  echo "mark_tested: tracked files differ from HEAD; commit first so the tree is the one tested" >&2
  exit 1
fi
tree=$(git rev-parse 'HEAD^{tree}')
dir="$(git rev-parse --git-common-dir)/tested-trees"
mkdir -p "$dir"
printf '%s %s %s\n' "$(git rev-parse HEAD)" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "${1:-}" > "$dir/$tree"
echo "$dir/$tree"
