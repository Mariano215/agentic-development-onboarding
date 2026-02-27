#!/bin/bash
set -e

# VibeOps Manifesto Integration Script
# Adds VibeOps manifesto and practices to any project

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ONBOARDING_DIR="$(dirname "$SCRIPT_DIR")"

usage() {
    echo "Usage: $0 [--dry-run] <target_directory>"
    echo ""
    echo "Integrates VibeOps manifesto and practices into a project"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be done without making changes"
    echo "  -h, --help   Show this help message"
    echo ""
    echo "Arguments:"
    echo "  target_directory  The project directory to integrate with"
    exit 1
}

error() {
    echo "ERROR: $1" >&2
    exit 1
}

info() {
    echo "INFO: $1"
}

# Parse arguments
DRY_RUN=false
TARGET_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            if [[ -z "$TARGET_DIR" ]]; then
                TARGET_DIR="$1"
            else
                error "Too many arguments. Use --help for usage."
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$TARGET_DIR" ]]; then
    error "Target directory is required. Use --help for usage."
fi

# Convert to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || error "Target directory '$TARGET_DIR' does not exist"

# Validate target directory
if [[ ! -d "$TARGET_DIR" ]]; then
    error "Target directory does not exist: $TARGET_DIR"
fi

# Check for required source files
MANIFESTO_FILE="$ONBOARDING_DIR/AGENTIC_DEVELOPMENT_MANIFESTO.md"
CHECKLIST_FILE="$SCRIPT_DIR/daily-checklist.md"

if [[ ! -f "$MANIFESTO_FILE" ]]; then
    error "Manifesto file not found: $MANIFESTO_FILE"
fi

if [[ ! -f "$CHECKLIST_FILE" ]]; then
    error "Daily checklist file not found: $CHECKLIST_FILE"
fi

if [[ "$DRY_RUN" == true ]]; then
    echo "DRY RUN - Would perform the following actions:"
    echo ""
fi

# Function to execute or show commands
execute() {
    local cmd="$1"
    local description="$2"

    if [[ "$DRY_RUN" == true ]]; then
        echo "WOULD RUN: $description"
        echo "  Command: $cmd"
    else
        info "$description"
        eval "$cmd"
    fi
}

# 1. Copy manifesto to target directory
DEST_MANIFESTO="$TARGET_DIR/AGENTIC_DEVELOPMENT_MANIFESTO.md"
if [[ -f "$DEST_MANIFESTO" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        echo "WOULD SKIP: Manifesto already exists at $DEST_MANIFESTO"
    else
        info "Manifesto already exists at $DEST_MANIFESTO, skipping"
    fi
else
    execute "cp '$MANIFESTO_FILE' '$DEST_MANIFESTO'" "Copy manifesto to project directory"
fi

# 2. Create .claude directory and copy daily checklist
CLAUDE_DIR="$TARGET_DIR/.claude"
DEST_CHECKLIST="$CLAUDE_DIR/daily-checklist.md"

execute "mkdir -p '$CLAUDE_DIR'" "Create .claude directory"
execute "cp '$CHECKLIST_FILE' '$DEST_CHECKLIST'" "Copy daily checklist to .claude directory"

# 3. Update project README with VibeOps principles
README_FILE="$TARGET_DIR/README.md"
if [[ -f "$README_FILE" ]]; then
    # Check if VibeOps section already exists
    if grep -q "## VibeOps" "$README_FILE" 2>/dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "WOULD SKIP: VibeOps section already exists in README.md"
        else
            info "VibeOps section already exists in README.md, skipping"
        fi
    else
        # Add VibeOps section to README
        VIBEOPS_SECTION="

## VibeOps - Agentic Development Practices

This project follows VibeOps principles for high-quality agentic development:

- **Frame first** - Clear problem definition before coding
- **Model threats** - Proactive risk and failure mode analysis
- **Human judgment** - Code review and thoughtful design decisions
- **Verification gates** - Comprehensive testing and quality checks
- **All gates green** - No deployment without passing all checks
- **Observable** - Built-in monitoring, logging, and debugging
- **Proof over progress** - Evidence-based quality validation

See [AGENTIC_DEVELOPMENT_MANIFESTO.md](./AGENTIC_DEVELOPMENT_MANIFESTO.md) for complete principles.

### Daily Practices

Use the [daily checklist](./.claude/daily-checklist.md) to maintain VibeOps practices:
- Pre-feature planning and threat modeling
- Development verification gates
- Pre-deployment quality checks
- Daily reflection and learning
- Weekly pattern analysis and improvement"

        if [[ "$DRY_RUN" == true ]]; then
            echo "WOULD ADD: VibeOps section to README.md"
        else
            info "Adding VibeOps section to README.md"
            echo "$VIBEOPS_SECTION" >> "$README_FILE"
        fi
    fi
else
    # Create basic README with VibeOps section
    README_CONTENT="# $(basename "$TARGET_DIR")

## VibeOps - Agentic Development Practices

This project follows VibeOps principles for high-quality agentic development:

- **Frame first** - Clear problem definition before coding
- **Model threats** - Proactive risk and failure mode analysis
- **Human judgment** - Code review and thoughtful design decisions
- **Verification gates** - Comprehensive testing and quality checks
- **All gates green** - No deployment without passing all checks
- **Observable** - Built-in monitoring, logging, and debugging
- **Proof over progress** - Evidence-based quality validation

See [AGENTIC_DEVELOPMENT_MANIFESTO.md](./AGENTIC_DEVELOPMENT_MANIFESTO.md) for complete principles.

### Daily Practices

Use the [daily checklist](./.claude/daily-checklist.md) to maintain VibeOps practices:
- Pre-feature planning and threat modeling
- Development verification gates
- Pre-deployment quality checks
- Daily reflection and learning
- Weekly pattern analysis and improvement"

    if [[ "$DRY_RUN" == true ]]; then
        echo "WOULD CREATE: README.md with VibeOps section"
    else
        info "Creating README.md with VibeOps section"
        echo "$README_CONTENT" > "$README_FILE"
    fi
fi

if [[ "$DRY_RUN" == true ]]; then
    echo ""
    echo "DRY RUN COMPLETE - No changes made"
else
    echo ""
    info "VibeOps integration complete!"
    echo ""
    echo "Added to project:"
    echo "  - AGENTIC_DEVELOPMENT_MANIFESTO.md (core principles)"
    echo "  - .claude/daily-checklist.md (daily practices)"
    echo "  - README.md updated with VibeOps section"
    echo ""
    echo "Next steps:"
    echo "  1. Review the manifesto: cat AGENTIC_DEVELOPMENT_MANIFESTO.md"
    echo "  2. Start using daily checklist: cat .claude/daily-checklist.md"
    echo "  3. Integrate verification gates into your development workflow"
    echo "  4. Share VibeOps practices with your team"
fi