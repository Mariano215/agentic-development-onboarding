#!/bin/bash
set -e

# VibeOps Current Project Integration Script
# Integrates VibeOps with existing Claude Code projects

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    echo "Usage: $0 [--dry-run] <target_directory>"
    echo ""
    echo "Integrates VibeOps onboarding system with existing Claude Code projects"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be done without making changes"
    echo "  -h, --help   Show this help message"
    echo ""
    echo "Arguments:"
    echo "  target_directory  The project directory to integrate with (can be main Projects dir or subproject)"
    echo ""
    echo "Examples:"
    echo "  $0 /home/mmattei/Projects"
    echo "  $0 /home/mmattei/Projects/my-awesome-project"
    echo "  $0 --dry-run /home/mmattei/Projects"
    exit 1
}

error() {
    echo "ERROR: $1" >&2
    exit 1
}

info() {
    echo "INFO: $1"
}

warning() {
    echo "WARNING: $1" >&2
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

# Convert to absolute path and validate
if [[ ! -d "$TARGET_DIR" ]]; then
    error "Target directory does not exist: $TARGET_DIR"
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

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

# Function to show what would be written to file
show_file_update() {
    local file="$1"
    local description="$2"

    if [[ "$DRY_RUN" == true ]]; then
        echo "WOULD UPDATE: $description"
        echo "  File: $file"
    else
        info "$description at $file"
    fi
}

if [[ "$DRY_RUN" == true ]]; then
    echo "DRY RUN - Would perform the following actions:"
    echo ""
fi

# Analyze target directory
info "Analyzing target directory: $TARGET_DIR"

# Check if this is the main Projects directory or a subproject
IS_MAIN_PROJECTS=false
if [[ "$TARGET_DIR" == *"/Projects" ]] && [[ "$(basename "$TARGET_DIR")" == "Projects" ]]; then
    IS_MAIN_PROJECTS=true
    if [[ "$DRY_RUN" == true ]]; then
        echo "DETECTED: Main Projects directory"
    else
        info "Detected main Projects directory"
    fi
else
    if [[ "$DRY_RUN" == true ]]; then
        echo "DETECTED: Individual project directory"
    else
        info "Detected individual project directory"
    fi
fi

# Check for existing Claude Code setup
CLAUDE_DIR="$TARGET_DIR/.claude"
INIT_SCRIPT="$TARGET_DIR/init-claude-code.sh"

if [[ -f "$INIT_SCRIPT" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        echo "FOUND: Existing init-claude-code.sh script"
    else
        info "Found existing init-claude-code.sh script"
    fi
else
    if [[ "$DRY_RUN" == true ]]; then
        echo "NOT FOUND: init-claude-code.sh script"
    else
        info "No existing init-claude-code.sh script found"
    fi
fi

# 1. Integrate manifesto using the dedicated script
execute "'$SCRIPT_DIR/manifesto-integration/add-to-project.sh' $(if [[ '$DRY_RUN' == true ]]; then echo '--dry-run'; fi) '$TARGET_DIR'" "Integrate VibeOps manifesto and daily practices"

if [[ "$DRY_RUN" == false ]]; then
    echo ""
fi

# 2. Create or update init-claude-code.sh with manifesto reference
if [[ -f "$INIT_SCRIPT" ]]; then
    # Check if already has manifesto reference
    if grep -q "AGENTIC_DEVELOPMENT_MANIFESTO" "$INIT_SCRIPT" 2>/dev/null; then
        if [[ "$DRY_RUN" == true ]]; then
            echo "WOULD SKIP: init-claude-code.sh already has manifesto reference"
        else
            info "init-claude-code.sh already has manifesto reference, skipping"
        fi
    else
        # Add manifesto reference to existing script
        MANIFESTO_ADDITION="

# VibeOps Integration
if [[ -f \"\$PROJECT_DIR/AGENTIC_DEVELOPMENT_MANIFESTO.md\" ]]; then
    echo \"VibeOps manifesto available: \$PROJECT_DIR/AGENTIC_DEVELOPMENT_MANIFESTO.md\"
    echo \"Daily checklist available: \$PROJECT_DIR/.claude/daily-checklist.md\"
    echo \"Follow VibeOps principles for high-quality agentic development\"
    echo \"\"
fi"

        if [[ "$DRY_RUN" == true ]]; then
            echo "WOULD ADD: VibeOps reference to existing init-claude-code.sh"
        else
            info "Adding VibeOps reference to existing init-claude-code.sh"
            echo "$MANIFESTO_ADDITION" >> "$INIT_SCRIPT"
        fi
    fi
else
    # Create new init-claude-code.sh script
    INIT_SCRIPT_CONTENT="#!/bin/bash
# Claude Code Initialization with VibeOps Integration

set -e

SCRIPT_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")\" && pwd)\"
PROJECT_DIR=\"\$SCRIPT_DIR\"

echo \"Initializing Claude Code environment...\"
echo \"Project directory: \$PROJECT_DIR\"
echo \"\"

# Create .claude directory if it doesn't exist
mkdir -p \"\$PROJECT_DIR/.claude\"

# VibeOps Integration
if [[ -f \"\$PROJECT_DIR/AGENTIC_DEVELOPMENT_MANIFESTO.md\" ]]; then
    echo \"VibeOps manifesto available: \$PROJECT_DIR/AGENTIC_DEVELOPMENT_MANIFESTO.md\"
    echo \"Daily checklist available: \$PROJECT_DIR/.claude/daily-checklist.md\"
    echo \"Follow VibeOps principles for high-quality agentic development\"
    echo \"\"
fi

# Standard Claude Code setup
echo \"Claude Code environment ready!\"
echo \"\"
echo \"Next steps:\"
echo \"1. Review VibeOps manifesto for development principles\"
echo \"2. Use daily checklist for maintaining quality practices\"
echo \"3. Set up verification gates for your specific technology stack\"
echo \"4. Start developing with Frame first, Model threats approach\"

echo \"\"
echo \"Happy coding with VibeOps!\"
"

    show_file_update "$INIT_SCRIPT" "Create new init-claude-code.sh with VibeOps integration"
    if [[ "$DRY_RUN" == false ]]; then
        echo "$INIT_SCRIPT_CONTENT" > "$INIT_SCRIPT"
        chmod +x "$INIT_SCRIPT"
    fi
fi

# 3. Copy verification gates to target with helper script
GATES_DIR="$TARGET_DIR/.claude/verification-gates"
execute "mkdir -p '$GATES_DIR'" "Create verification gates directory"

# Copy all verification gates
for gate in "$SCRIPT_DIR/verification-gates"/*; do
    if [[ -f "$gate" ]]; then
        gate_name=$(basename "$gate")
        execute "cp '$gate' '$GATES_DIR/$gate_name'" "Copy $(basename "$gate") verification gate"
    fi
done

# Create run-all-gates.sh helper script
RUN_ALL_GATES_SCRIPT="$GATES_DIR/run-all-gates.sh"
RUN_ALL_GATES_CONTENT="#!/bin/bash
# VibeOps - Run All Verification Gates

set -e

GATES_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")\" && pwd)\"
PROJECT_ROOT=\"\$(cd \"\$GATES_DIR/../..\" && pwd)\"

echo \"Running VibeOps verification gates...\"
echo \"Project: \$PROJECT_ROOT\"
echo \"\"

# Track results
TOTAL_GATES=0
PASSED_GATES=0
FAILED_GATES=0

# Run each gate
for gate in \"\$GATES_DIR\"/*.sh; do
    if [[ -f \"\$gate\" ]] && [[ \"\$gate\" != \"\$GATES_DIR/run-all-gates.sh\" ]]; then
        gate_name=\$(basename \"\$gate\" .sh)
        echo \"Running \$gate_name gate...\"

        TOTAL_GATES=\$((TOTAL_GATES + 1))

        if \"\$gate\" \"\$PROJECT_ROOT\"; then
            echo \"✓ \$gate_name PASSED\"
            PASSED_GATES=\$((PASSED_GATES + 1))
        else
            echo \"✗ \$gate_name FAILED\"
            FAILED_GATES=\$((FAILED_GATES + 1))
        fi
        echo \"\"
    fi
done

# Summary
echo \"========================================\"
echo \"Verification Gates Summary\"
echo \"========================================\"
echo \"Total gates: \$TOTAL_GATES\"
echo \"Passed: \$PASSED_GATES\"
echo \"Failed: \$FAILED_GATES\"
echo \"\"

if [[ \$FAILED_GATES -eq 0 ]]; then
    echo \"🎉 ALL GATES GREEN! Ready for deployment.\"
    exit 0
else
    echo \"⚠️  Some gates failed. Address issues before deployment.\"
    exit 1
fi
"

show_file_update "$RUN_ALL_GATES_SCRIPT" "Create run-all-gates.sh helper script"
if [[ "$DRY_RUN" == false ]]; then
    echo "$RUN_ALL_GATES_CONTENT" > "$RUN_ALL_GATES_SCRIPT"
    chmod +x "$RUN_ALL_GATES_SCRIPT"
fi

# 4. Create integration summary and next steps
INTEGRATION_SUMMARY="$TARGET_DIR/.claude/vibeops-integration-summary.md"
SUMMARY_CONTENT="# VibeOps Integration Summary

Integration completed on $(date)

## What was added:

### Core Files
- \`AGENTIC_DEVELOPMENT_MANIFESTO.md\` - Core VibeOps principles
- \`.claude/daily-checklist.md\` - Daily development practices
- \`README.md\` updated with VibeOps section (or created if missing)

### Scripts
- \`init-claude-code.sh\` - Enhanced/created with VibeOps integration
- \`.claude/verification-gates/run-all-gates.sh\` - Run all quality gates

### Verification Gates
- \`.claude/verification-gates/basic-quality-gate.sh\` - Basic code quality
- \`.claude/verification-gates/documentation-gate.sh\` - Documentation standards
- \`.claude/verification-gates/security-gate.sh\` - Security checks
- \`.claude/verification-gates/test-coverage-gate.sh\` - Test coverage requirements
- \`.claude/verification-gates/performance-gate.sh\` - Performance validation

## Next Steps:

### Immediate (Today)
1. \`cat AGENTIC_DEVELOPMENT_MANIFESTO.md\` - Read and internalize the principles
2. \`cat .claude/daily-checklist.md\` - Review daily practices
3. \`./init-claude-code.sh\` - Initialize your development environment
4. Start your next feature using \"Frame first, Model threats\" approach

### This Week
1. Configure verification gates for your specific tech stack
2. Run \`.claude/verification-gates/run-all-gates.sh\` to see current status
3. Set up your development workflow to include daily checklist
4. Share VibeOps principles with your team

### Ongoing
1. Use daily checklist for every development session
2. Run verification gates before every commit/deployment
3. Conduct weekly reviews using the checklist framework
4. Continuously improve your quality gates based on project needs

## Project-Specific Customization:

### Technology Stack
- Customize verification gates for your specific languages and frameworks
- Add project-specific quality metrics to gates
- Configure CI/CD integration with VibeOps gates

### Team Integration
- Share manifesto and daily practices with team members
- Establish team standards based on VibeOps principles
- Create project-specific threat models and quality definitions

### Monitoring and Observability
- Implement logging and monitoring as specified in manifesto
- Set up error tracking and performance monitoring
- Create debugging runbooks and incident response procedures

## Success Indicators:

You'll know VibeOps is working when:
- Code reviews become discussions about architecture and maintainability
- Bugs are caught earlier in development through threat modeling
- Deployments are confident because all gates are green
- Technical debt decreases over time through proactive quality practices
- Team knowledge and skills continuously improve through reflection

## Support:

- Review the manifesto regularly to stay aligned with principles
- Use the daily checklist as a guide, not a rigid requirement
- Adapt practices to your project's specific needs
- Focus on the mindset and outcomes, not just the processes

Remember: **Quality is not negotiable. Speed comes from skill, not shortcuts.**
"

show_file_update "$INTEGRATION_SUMMARY" "Create VibeOps integration summary"
if [[ "$DRY_RUN" == false ]]; then
    echo "$SUMMARY_CONTENT" > "$INTEGRATION_SUMMARY"
fi

# Final output
if [[ "$DRY_RUN" == true ]]; then
    echo ""
    echo "DRY RUN COMPLETE - No changes made"
    echo ""
    echo "This would integrate VibeOps with: $TARGET_DIR"
    if [[ "$IS_MAIN_PROJECTS" == true ]]; then
        echo "Type: Main Projects directory integration"
    else
        echo "Type: Individual project integration"
    fi
else
    echo ""
    echo "========================================="
    echo "🎉 VibeOps Integration Complete!"
    echo "========================================="
    echo ""
    echo "Integrated with: $TARGET_DIR"
    if [[ "$IS_MAIN_PROJECTS" == true ]]; then
        echo "Type: Main Projects directory"
    else
        echo "Type: Individual project"
    fi
    echo ""
    echo "✅ Manifesto and daily practices added"
    echo "✅ Claude Code initialization enhanced"
    echo "✅ Verification gates installed"
    echo "✅ Integration summary created"
    echo ""
    echo "Next steps:"
    echo "1. cd \"$TARGET_DIR\""
    echo "2. cat AGENTIC_DEVELOPMENT_MANIFESTO.md"
    echo "3. cat .claude/daily-checklist.md"
    echo "4. ./init-claude-code.sh"
    echo "5. .claude/verification-gates/run-all-gates.sh"
    echo ""
    echo "See .claude/vibeops-integration-summary.md for detailed guidance"
    echo ""
    echo "Welcome to VibeOps - Quality through principle, not process!"
fi