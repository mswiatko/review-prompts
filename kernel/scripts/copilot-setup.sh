#!/bin/bash
#
# Copilot setup for Linux kernel development
#
# Installs:
#   - Kernel skill to .github/skills/SKILL.md
#   - Slash commands to .github/prompts/
#
# The prompts directory is determined from this script's location.

set -e

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The review-prompts directory is the parent of the scripts directory
PROMPTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Review prompts directory: $PROMPTS_DIR"
echo ""

# --- Install Skill ---

if [ -n "$1" ]; then
    SKILL_DIR="$1/.github/skills/kernel"
else
    SKILL_DIR="$HOME/.copilot/skills/kernel"
fi

SKILL_FILE="$SKILL_DIR/SKILL.md"
SOURCE_SKILL="$PROMPTS_DIR/skills/kernel.md"

if [ ! -f "$SOURCE_SKILL" ]; then
    echo "Error: Source skill file not found: $SOURCE_SKILL"
    exit 1
fi

mkdir -p "$SKILL_DIR"

sed "s|{{KERNEL_REVIEW_PROMPTS_DIR}}|$PROMPTS_DIR|g" "$SOURCE_SKILL" > "$SKILL_FILE"

echo "Installed skill:"
echo "  $SKILL_FILE"

# --- Install Slash Commands ---

if [ -n "$1" ]; then
    COMMANDS_DIR="$1/.github/prompts"
else
    echo "Error: Copilot supports only repo wide slash commands, skipping"
    exit 0
fi

SLASH_COMMANDS_SRC="$PROMPTS_DIR/slash-commands"

if [ ! -d "$SLASH_COMMANDS_SRC" ]; then
    echo "Warning: slash-commands directory not found, skipping"
else
    mkdir -p "$COMMANDS_DIR"

    echo ""
    echo "Installed slash commands:"

    for cmd_file in "$SLASH_COMMANDS_SRC"/*.md; do
        if [ -f "$cmd_file" ]; then
            cmd_name=$(basename "$cmd_file")
            sed "s|REVIEW_DIR|$PROMPTS_DIR|g" "$cmd_file" > "$COMMANDS_DIR/$cmd_name"
            echo "  /$cmd_name"
        fi
    done
fi

echo ""
echo "Setup complete!"
echo ""
echo "Available commands:"
echo "  /kreview    - Review a single commit for regressions"
echo "  /kseries    - Review an entire patch series (git range) commit-by-commit"
echo "  /korcreview - Deep dive regression analysis using ORC agent"
echo "  /kdebug     - Debug kernel crashes and warnings"
echo "  /kverify    - Verify findings against false positive patterns"
echo ""
echo "The kernel skill loads automatically in kernel trees."
