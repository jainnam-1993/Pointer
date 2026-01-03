#!/bin/bash
# Install git hooks for Pointer project
# Run once after cloning: ./scripts/setup-hooks.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_SOURCE="$SCRIPT_DIR/hooks"

# Handle worktree vs regular repo
if [ -f ".git" ]; then
    # Worktree: .git is a file pointing to the real git dir
    GIT_DIR=$(cat .git | sed 's/gitdir: //')
else
    GIT_DIR=".git"
fi

HOOKS_TARGET="$GIT_DIR/hooks"

# Create hooks directory if it doesn't exist (worktrees may not have it)
mkdir -p "$HOOKS_TARGET"

echo "Installing git hooks..."
echo "  Source: $HOOKS_SOURCE"
echo "  Target: $HOOKS_TARGET"

# Install pre-commit hook
if [ -f "$HOOKS_SOURCE/pre-commit" ]; then
    ln -sf "$HOOKS_SOURCE/pre-commit" "$HOOKS_TARGET/pre-commit"
    chmod +x "$HOOKS_TARGET/pre-commit"
    echo "  ✓ pre-commit hook installed"
else
    echo "  ✗ pre-commit hook not found"
fi

echo "Done. Hooks will run automatically on git commit."
