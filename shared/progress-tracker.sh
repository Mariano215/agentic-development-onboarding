#!/bin/bash

# VibeOps Progress Tracker
# JSON-based state management for agentic development onboarding
# Following verification-first principles

set -euo pipefail

# Configuration
CLAUDE_ONBOARDING_DIR="${CLAUDE_ONBOARDING_DIR:-$HOME/.claude-onboarding}"

# Get progress file path (supports dynamic directory changes)
get_progress_file() {
    echo "$CLAUDE_ONBOARDING_DIR/progress.json"
}

# Color definitions for output
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Initialize progress tracking system
init_progress() {
    # Update paths in case CLAUDE_ONBOARDING_DIR was set after script loading
    local progress_file="$CLAUDE_ONBOARDING_DIR/progress.json"

    echo -e "${BLUE}Initializing VibeOps progress tracking system...${NC}"

    # Create base directory
    if [[ ! -d "$CLAUDE_ONBOARDING_DIR" ]]; then
        mkdir -p "$CLAUDE_ONBOARDING_DIR"
        echo -e "${GREEN}Created progress directory: $CLAUDE_ONBOARDING_DIR${NC}"
    fi

    # Create subdirectories
    mkdir -p "$CLAUDE_ONBOARDING_DIR/assessments"
    mkdir -p "$CLAUDE_ONBOARDING_DIR/demo-project"
    mkdir -p "$CLAUDE_ONBOARDING_DIR/verification-history"

    # Initialize progress JSON if it doesn't exist
    if [[ ! -f "$progress_file" ]]; then
        cat > "$progress_file" <<EOF
{
    "phases": {
        "philosophy": {"completed": false, "score": 0},
        "frame": {"completed": false, "tests_passing": false},
        "model": {"completed": false, "threat_model_approved": false},
        "generate": {"completed": false, "code_verified": false},
        "verify_observe": {"completed": false, "production_ready": false}
    },
    "last_updated": "$(date -Iseconds)",
    "current_phase": "philosophy"
}
EOF
        echo -e "${GREEN}Created progress tracking file: $progress_file${NC}"
    else
        echo -e "${YELLOW}Progress file already exists: $progress_file${NC}"
    fi

    echo -e "${GREEN}VibeOps progress tracking initialized successfully${NC}"
}

# Get the status of a specific phase
get_phase_status() {
    local phase="$1"

    if [[ ! -f "$(get_progress_file)" ]]; then
        echo "error: progress file not found"
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo "error: jq not installed - required for JSON processing"
        return 1
    fi

    # Check if phase exists
    if ! jq -e ".phases.${phase}" "$(get_progress_file)" >/dev/null 2>&1; then
        echo "error: phase '$phase' not found"
        return 1
    fi

    # Return phase status as JSON
    jq ".phases.${phase}" "$(get_progress_file)"
}

# Update phase status
update_phase_status() {
    local phase="$1"
    local field="$2"
    local value="$3"

    if [[ ! -f "$(get_progress_file)" ]]; then
        echo "error: progress file not found - run init_progress first"
        return 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        echo "error: jq not installed - required for JSON processing"
        return 1
    fi

    # Validate phase exists
    if ! jq -e ".phases.${phase}" "$(get_progress_file)" >/dev/null 2>&1; then
        echo "error: phase '$phase' not found"
        return 1
    fi

    # Create a temporary file for atomic updates
    local temp_file
    temp_file=$(mktemp)

    # Update the specific field and timestamp
    if [[ "$value" =~ ^[0-9]+$ ]] || [[ "$value" == "true" ]] || [[ "$value" == "false" ]]; then
        # Numeric or boolean value - no quotes
        jq ".phases.${phase}.${field} = ${value} | .last_updated = \"$(date -Iseconds)\"" "$(get_progress_file)" > "$temp_file"
    else
        # String value - add quotes
        jq ".phases.${phase}.${field} = \"${value}\" | .last_updated = \"$(date -Iseconds)\"" "$(get_progress_file)" > "$temp_file"
    fi

    # Atomic update
    if mv "$temp_file" "$(get_progress_file)"; then
        echo "Updated ${phase}.${field} = ${value}"
    else
        echo "error: failed to update progress file"
        rm -f "$temp_file"
        return 1
    fi
}

# Update metadata
update_metadata() {
    local field="$1"
    local value="$2"

    if [[ ! -f "$(get_progress_file)" ]]; then
        echo "error: progress file not found - run init_progress first"
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    if [[ "$value" =~ ^[0-9]+$ ]] || [[ "$value" == "true" ]] || [[ "$value" == "false" ]]; then
        jq ".${field} = ${value}" "$(get_progress_file)" > "$temp_file"
    else
        jq ".${field} = \"${value}\"" "$(get_progress_file)" > "$temp_file"
    fi

    mv "$temp_file" "$(get_progress_file)"
}

# Get current phase
get_current_phase() {
    if [[ ! -f "$(get_progress_file)" ]]; then
        echo "philosophy"
        return
    fi

    jq -r '.current_phase' "$(get_progress_file)" 2>/dev/null || echo "philosophy"
}

# Set current phase
set_current_phase() {
    local phase="$1"
    update_metadata "current_phase" "$phase"
    echo "Current phase set to: $phase"
}

# Check if phase is completed
is_phase_completed() {
    local phase="$1"

    if [[ ! -f "$(get_progress_file)" ]]; then
        echo "false"
        return
    fi

    local completed
    completed=$(jq -r ".phases.${phase}.completed" "$(get_progress_file)" 2>/dev/null)
    echo "${completed:-false}"
}

# Get overall progress summary
get_progress_summary() {
    if [[ ! -f "$(get_progress_file)" ]]; then
        echo "Progress not initialized"
        return
    fi

    echo -e "${CYAN}=== VibeOps Progress Summary ===${NC}"
    echo

    local current_phase
    current_phase=$(get_current_phase)
    echo -e "${BLUE}Current Phase: ${YELLOW}${current_phase}${NC}"

    echo -e "\n${BLUE}Phase Completion Status:${NC}"

    # Check each phase
    local phases=("philosophy" "frame" "model" "generate" "verify_observe")
    local completed_count=0

    for phase in "${phases[@]}"; do
        local completed
        completed=$(is_phase_completed "$phase")

        if [[ "$completed" == "true" ]]; then
            echo -e "  ✅ ${phase}: ${GREEN}Completed${NC}"
            ((completed_count++))
        elif [[ "$phase" == "$current_phase" ]]; then
            echo -e "  🔄 ${phase}: ${YELLOW}In Progress${NC}"
        else
            echo -e "  ⏸️  ${phase}: ${RED}Pending${NC}"
        fi
    done

    local total_phases=${#phases[@]}
    local progress_percent=$((completed_count * 100 / total_phases))

    echo
    echo -e "${BLUE}Overall Progress: ${YELLOW}${completed_count}/${total_phases} phases (${progress_percent}%)${NC}"

    # Show last updated
    local last_updated
    last_updated=$(jq -r '.last_updated' "$(get_progress_file)" 2>/dev/null)
    echo -e "${BLUE}Last Updated: ${NC}${last_updated}"
}

# Verify progress system integrity
verify_progress_system() {
    echo -e "${BLUE}Verifying VibeOps progress system...${NC}"

    # Check directory structure
    if [[ ! -d "$CLAUDE_ONBOARDING_DIR" ]]; then
        echo -e "${RED}❌ Progress directory missing${NC}"
        return 1
    fi

    # Check subdirectories
    for subdir in assessments demo-project verification-history; do
        if [[ ! -d "$CLAUDE_ONBOARDING_DIR/$subdir" ]]; then
            echo -e "${RED}❌ Missing subdirectory: $subdir${NC}"
            return 1
        fi
    done

    # Check progress file
    if [[ ! -f "$(get_progress_file)" ]]; then
        echo -e "${RED}❌ Progress file missing${NC}"
        return 1
    fi

    # Verify JSON structure
    if ! jq -e '.phases' "$(get_progress_file)" >/dev/null 2>&1; then
        echo -e "${RED}❌ Invalid progress file structure${NC}"
        return 1
    fi

    # Check required phases
    local required_phases=("philosophy" "frame" "model" "generate" "verify_observe")
    for phase in "${required_phases[@]}"; do
        if ! jq -e ".phases.${phase}" "$(get_progress_file)" >/dev/null 2>&1; then
            echo -e "${RED}❌ Missing phase: $phase${NC}"
            return 1
        fi
    done

    echo -e "${GREEN}✅ Progress system verification complete${NC}"
    return 0
}

# Reset progress (with confirmation)
reset_progress() {
    echo -e "${YELLOW}⚠️  This will reset all VibeOps progress data.${NC}"
    echo -e "${YELLOW}Are you sure you want to continue? (type 'yes' to confirm)${NC}"
    read -r confirmation

    if [[ "$confirmation" != "yes" ]]; then
        echo -e "${BLUE}Reset cancelled${NC}"
        return 0
    fi

    # Backup existing progress
    if [[ -f "$(get_progress_file)" ]]; then
        local backup_file="$CLAUDE_ONBOARDING_DIR/progress_backup_$(date +%Y%m%d_%H%M%S).json"
        cp "$(get_progress_file)" "$backup_file"
        echo -e "${BLUE}Progress backed up to: $backup_file${NC}"
    fi

    # Remove and recreate with safety guards
    if [[ -n "$CLAUDE_ONBOARDING_DIR" ]] && [[ "$CLAUDE_ONBOARDING_DIR" != "/" ]] && [[ "$CLAUDE_ONBOARDING_DIR" != "$HOME" ]]; then
        rm -rf "$CLAUDE_ONBOARDING_DIR"
    else
        echo "ERROR: Invalid directory path for deletion: '$CLAUDE_ONBOARDING_DIR'"
        return 1
    fi
    init_progress

    echo -e "${GREEN}VibeOps progress reset complete${NC}"
}

# Export functions for sourcing
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced - export functions
    export -f init_progress get_phase_status update_phase_status update_metadata
    export -f get_current_phase set_current_phase is_phase_completed
    export -f get_progress_summary verify_progress_system reset_progress
fi

# If run directly, show help
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    cat <<EOF
VibeOps Progress Tracker

Usage: source progress-tracker.sh
Then call functions:

  init_progress              - Initialize progress tracking system
  get_phase_status <phase>   - Get status of specific phase
  update_phase_status <phase> <field> <value> - Update phase field
  get_current_phase          - Get currently active phase
  set_current_phase <phase>  - Set active phase
  is_phase_completed <phase> - Check if phase is completed
  get_progress_summary       - Show overall progress
  verify_progress_system     - Verify system integrity
  reset_progress             - Reset all progress (with confirmation)

Phases: philosophy, frame, model, generate, verify_observe

Example:
  source shared/progress-tracker.sh
  init_progress
  update_phase_status philosophy completed true
  get_progress_summary
EOF
fi