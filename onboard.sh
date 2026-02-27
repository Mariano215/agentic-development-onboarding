#!/bin/bash

# VibeOps Onboarding Orchestrator
# Main entry point for agentic development journey
# Following verification-first principles and AI partnership philosophy

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# Source the progress tracker
source "$PROJECT_ROOT/shared/progress-tracker.sh"

# Source the quick setup wizard
source "$PROJECT_ROOT/shared/quick-setup.sh"

# Color definitions
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
VIBEOPS_VERSION="1.0"
MANIFESTO_FILE="$PROJECT_ROOT/AGENTIC_DEVELOPMENT_MANIFESTO.md"

# Phase script paths (maps phase names to their run scripts)
declare -A PHASE_SCRIPTS=(
    [philosophy]="$PROJECT_ROOT/tutorial-phases/phase0-philosophy/run-phase0.sh"
    [frame]="$PROJECT_ROOT/tutorial-phases/phase1-frame/run-phase1.sh"
    [model]="$PROJECT_ROOT/tutorial-phases/phase2-model/run-phase2.sh"
    [generate]="$PROJECT_ROOT/tutorial-phases/phase3-generate/run-phase3.sh"
    [verify_observe]="$PROJECT_ROOT/tutorial-phases/phase4-verify-observe/run-phase4.sh"
)

declare -A PHASE_NAMES=(
    [philosophy]="Philosophy Foundation"
    [frame]="Frame the Problem"
    [model]="Model Security & Threats"
    [generate]="Generate with AI Partnership"
    [verify_observe]="Verify & Observe"
)

# Ordered list of phases for sequential progression
PHASE_ORDER=("philosophy" "frame" "model" "generate" "verify_observe")

# Get the next phase after the given one, or empty string if at the end
get_next_phase() {
    local current="$1"
    local found=false
    for p in "${PHASE_ORDER[@]}"; do
        if [[ "$found" == true ]]; then
            echo "$p"
            return
        fi
        if [[ "$p" == "$current" ]]; then
            found=true
        fi
    done
    echo ""
}

# Run a phase script, handling missing/unimplemented phases
# Automatically offers to continue to the next phase on success
run_phase() {
    local phase="$1"
    local script="${PHASE_SCRIPTS[$phase]:-}"

    if [[ -z "$script" ]]; then
        echo -e "${RED}Unknown phase: $phase${NC}"
        return 1
    fi

    if [[ ! -f "$script" ]]; then
        echo -e "${YELLOW}⚠️  Phase '${PHASE_NAMES[$phase]}' is not yet implemented.${NC}"
        echo -e "${BLUE}Coming soon! For now, only Phase 0 (Philosophy Foundation) is available.${NC}"
        echo
        read -p "Press Enter to return to the menu..."
        return 0
    fi

    if [[ ! -x "$script" ]]; then
        chmod +x "$script"
    fi

    if "$script"; then
        # Phase completed successfully — offer to continue to the next one
        local next_phase
        next_phase=$(get_next_phase "$phase")
        if [[ -n "$next_phase" ]]; then
            echo
            read -p "Continue to ${PHASE_NAMES[$next_phase]}? (Y/n): " continue_choice
            if [[ ! "$continue_choice" =~ ^[Nn]$ ]]; then
                run_phase "$next_phase"
            fi
        fi
    fi
}

# Display VibeOps header
show_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                          ${WHITE}✨ VibeOps Onboarding ✨${CYAN}                          ║${NC}"
    echo -e "${CYAN}║                    ${MAGENTA}Agentic Development Journey v${VIBEOPS_VERSION}${CYAN}                    ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${BLUE}🤝 Welcome to the future of human-AI collaborative development${NC}"
    echo -e "${BLUE}📋 This system will guide you through verification-first agentic practices${NC}"
    echo
}

# Display manifesto summary
show_manifesto_summary() {
    echo -e "${CYAN}=== VibeOps Philosophy Summary ===${NC}"
    echo
    echo -e "${BLUE}🏛️  Four Pillars:${NC}"
    echo -e "   1. ${GREEN}AI Partnership Over Tool Usage${NC} - Collaborate, don't just command"
    echo -e "   2. ${GREEN}Verification Over Implementation${NC} - Prove before you build"
    echo -e "   3. ${GREEN}Orchestration Over Coding${NC} - Guide systems, don't just write code"
    echo -e "   4. ${GREEN}Emergence Over Planning${NC} - Create conditions for solutions to arise"
    echo
    echo -e "${BLUE}🎯 Core Principle:${NC} ${YELLOW}Verification-first development with AI as your thinking partner${NC}"
    echo
}

# Show compact progress checklist
show_checklist() {
    echo -e "${CYAN}=== Your Progress ===${NC}"

    # Initialize if needed so we always have data to show
    if [[ ! -f "$CLAUDE_ONBOARDING_DIR/progress.json" ]]; then
        local pn=0
        for phase in "${PHASE_ORDER[@]}"; do
            if [[ "$phase" == "philosophy" ]]; then
                echo -e "  ➡️  Phase 0: ${PHASE_NAMES[$phase]} ${YELLOW}(up next)${NC}"
            else
                echo -e "  ⏸️  Phase ${pn}: ${PHASE_NAMES[$phase]}"
            fi
            pn=$((pn + 1))
        done
        echo -e "\n  ${BLUE}Progress: 0/5 phases (0%)${NC}"
        echo
        return
    fi

    local current_phase
    current_phase=$(get_current_phase)
    local completed_count=0
    local phase_num=0

    for phase in "${PHASE_ORDER[@]}"; do
        local completed
        completed=$(is_phase_completed "$phase")

        if [[ "$completed" == "true" ]]; then
            echo -e "  ${GREEN}✅ Phase ${phase_num}: ${PHASE_NAMES[$phase]}${NC}"
            completed_count=$((completed_count + 1))
        elif [[ "$phase" == "$current_phase" ]]; then
            echo -e "  ${YELLOW}➡️  Phase ${phase_num}: ${PHASE_NAMES[$phase]} (up next)${NC}"
        else
            echo -e "  ⏸️  Phase ${phase_num}: ${PHASE_NAMES[$phase]}"
        fi
        phase_num=$((phase_num + 1))
    done

    local progress_percent=$((completed_count * 100 / 5))
    echo
    echo -e "  ${BLUE}Progress: ${completed_count}/5 phases (${progress_percent}%)${NC}"
    echo
}

# Show main menu
show_menu() {
    echo -e "${CYAN}=== VibeOps Journey Menu ===${NC}"
    echo
    echo -e "${WHITE}1.${NC} ${GREEN}🚀 Start VibeOps Tutorial${NC} (Complete guided journey)"
    echo -e "${WHITE}2.${NC} ${BLUE}🎯 Jump to Phase${NC} (Advanced users)"
    echo -e "${WHITE}3.${NC} ${MAGENTA}⚡ Quick Setup${NC} (Install team skills, agents & MCP servers)"
    echo -e "${WHITE}4.${NC} ${YELLOW}🔍 Verify State${NC} (Run all verification gates)"
    echo -e "${WHITE}5.${NC} ${RED}🔄 Reset & Clean${NC} (Start fresh)"
    echo -e "${WHITE}6.${NC} ${CYAN}🚪 Exit${NC}"
    echo
    echo -e -n "${BLUE}Choose your path (1-6): ${NC}"
}

# Start complete VibeOps tutorial
start_vibeops_tutorial() {
    echo -e "${GREEN}🚀 Starting Complete VibeOps Tutorial${NC}"
    echo
    echo -e "${BLUE}This journey will take you through all five phases:${NC}"
    echo -e "  📚 Phase 0: Philosophy Foundation"
    echo -e "  🏗️  Phase 1: Frame the Problem"
    echo -e "  🛡️  Phase 2: Model Security & Threats"
    echo -e "  ⚡ Phase 3: Generate with AI Partnership"
    echo -e "  ✅ Phase 4: Verify & Observe"
    echo
    echo -e "${YELLOW}Each phase includes verification gates to ensure true understanding.${NC}"
    echo -e "${YELLOW}This is not about speed - it's about transformation.${NC}"
    echo
    read -p "Ready to begin your VibeOps transformation? (y/N): " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Initialize progress if needed
        if [[ ! -f "$CLAUDE_ONBOARDING_DIR/progress.json" ]]; then
            echo -e "${BLUE}Initializing your progress tracking...${NC}"
            init_progress
        fi

        # Start with the current phase (or philosophy if fresh)
        local current_phase
        current_phase=$(get_current_phase)
        set_current_phase "$current_phase"
        echo -e "${GREEN}✅ Tutorial initialized - starting with ${PHASE_NAMES[$current_phase]}${NC}"
        echo
        run_phase "$current_phase"
    else
        echo -e "${BLUE}Tutorial cancelled. Return anytime to begin your VibeOps journey.${NC}"
    fi
}

# Jump to specific phase
jump_to_phase() {
    echo -e "${BLUE}🎯 Jump to Specific Phase${NC}"
    echo
    echo -e "${YELLOW}Available phases:${NC}"
    echo -e "  ${WHITE}0${NC}. Philosophy Foundation"
    echo -e "  ${WHITE}1${NC}. Frame the Problem"
    echo -e "  ${WHITE}2${NC}. Model Security & Threats"
    echo -e "  ${WHITE}3${NC}. Generate with AI Partnership"
    echo -e "  ${WHITE}4${NC}. Verify & Observe"
    echo

    local current_phase
    current_phase=$(get_current_phase)
    echo -e "${BLUE}Current phase: ${YELLOW}${current_phase}${NC}"
    echo

    read -p "Enter phase number (0-4) or 'b' to go back: " phase_choice

    local phase_key=""
    case "$phase_choice" in
        0) phase_key="philosophy" ;;
        1) phase_key="frame" ;;
        2) phase_key="model" ;;
        3) phase_key="generate" ;;
        4) phase_key="verify_observe" ;;
        b|B) return ;;
        *)
            echo -e "${RED}Invalid selection. Please choose 0-4 or 'b'.${NC}"
            echo
            read -p "Press Enter to continue..."
            return
            ;;
    esac

    if [[ -n "$phase_key" ]]; then
        set_current_phase "$phase_key"
        echo -e "${GREEN}Starting ${PHASE_NAMES[$phase_key]}...${NC}"
        echo
        run_phase "$phase_key"
    fi
}

# Verify current state
verify_current_state() {
    echo -e "${YELLOW}🔍 Verifying Current State${NC}"
    echo
    echo -e "${BLUE}Running comprehensive VibeOps verification gates...${NC}"
    echo

    # Initialize if needed
    if [[ ! -f "$CLAUDE_ONBOARDING_DIR/progress.json" ]]; then
        echo -e "${BLUE}Initializing progress tracking...${NC}"
        init_progress
    fi

    # Verify progress system
    if verify_progress_system; then
        echo -e "${GREEN}✅ Progress system verified${NC}"
    else
        echo -e "${RED}❌ Progress system issues detected${NC}"
    fi

    # Check repository structure
    echo -e "\n${BLUE}Checking repository structure...${NC}"
    if [[ -f "$PROJECT_ROOT/tests/test-repo-structure.sh" ]]; then
        if "$PROJECT_ROOT/tests/test-repo-structure.sh"; then
            echo -e "${GREEN}✅ Repository structure verified${NC}"
        else
            echo -e "${YELLOW}⚠️  Repository structure issues detected${NC}"
        fi
    else
        echo -e "${RED}❌ Repository structure tests not found${NC}"
    fi

    # Run orchestrator tests
    echo -e "\n${BLUE}Testing orchestrator functionality...${NC}"
    if [[ -f "$PROJECT_ROOT/tests/test-orchestrator.sh" ]]; then
        if "$PROJECT_ROOT/tests/test-orchestrator.sh"; then
            echo -e "${GREEN}✅ Orchestrator tests passed${NC}"
        else
            echo -e "${YELLOW}⚠️  Some orchestrator tests failed${NC}"
        fi
    else
        echo -e "${RED}❌ Orchestrator tests not found${NC}"
    fi

    # Show current progress
    echo
    get_progress_summary

    echo
    read -p "Press Enter to continue..."
}


# Reset and clean
reset_and_clean() {
    echo -e "${RED}🔄 Reset & Clean${NC}"
    echo
    echo -e "${YELLOW}This will completely reset your VibeOps progress.${NC}"
    echo -e "${YELLOW}Your learning journey will start from the beginning.${NC}"
    echo
    echo -e "${RED}⚠️  This action cannot be undone (though we create backups).${NC}"
    echo

    read -p "Are you absolutely sure? Type 'RESET' to confirm: " confirm

    if [[ "$confirm" == "RESET" ]]; then
        echo -e "${BLUE}Resetting VibeOps progress...${NC}"
        reset_progress
        echo -e "${GREEN}✅ Reset complete. You can now start fresh.${NC}"
    else
        echo -e "${BLUE}Reset cancelled. Your progress is safe.${NC}"
    fi
    echo
    read -p "Press Enter to continue..."
}


# Main menu loop
main_loop() {
    while true; do
        show_header
        show_manifesto_summary
        show_checklist
        show_menu

        read -r choice
        echo

        case "$choice" in
            1)
                start_vibeops_tutorial
                ;;
            2)
                jump_to_phase
                ;;
            3)
                run_quick_setup
                ;;
            4)
                verify_current_state
                ;;
            5)
                reset_and_clean
                ;;
            6)
                echo -e "${CYAN}🚪 Exiting VibeOps Onboarding${NC}"
                echo -e "${BLUE}Remember: AI partnership is a journey, not a destination.${NC}"
                echo -e "${GREEN}Keep exploring, keep verifying, keep growing.${NC}"
                echo
                echo -e "${YELLOW}\"The best way to predict the future is to invent it.\"${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please select 1-6.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Startup checks
startup_checks() {
    # Check for required dependencies
    local missing_deps=()

    if ! command -v jq >/dev/null 2>&1; then
        missing_deps+=("jq")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Missing required dependencies:${NC}"
        printf ' - %s\n' "${missing_deps[@]}"
        echo
        echo -e "${BLUE}Please install missing dependencies and try again.${NC}"
        echo -e "${BLUE}For Ubuntu/Debian: sudo apt install jq${NC}"
        echo -e "${BLUE}For macOS: brew install jq${NC}"
        exit 1
    fi

    # Check repository structure
    if [[ ! -f "$MANIFESTO_FILE" ]]; then
        echo -e "${YELLOW}⚠️  Manifesto file not found. Some features may not work correctly.${NC}"
        echo
    fi
}

# Main entry point
main() {
    # Handle command line arguments
    case "${1:-}" in
        --help|-h)
            echo "VibeOps Onboarding Orchestrator v$VIBEOPS_VERSION"
            echo
            echo "Usage: $0 [OPTIONS]"
            echo
            echo "Options:"
            echo "  --help, -h     Show this help message"
            echo "  --version, -v  Show version information"
            echo "  --verify       Run verification checks only"
            echo "  --status       Show progress status only"
            echo "  --reset        Reset progress (with confirmation)"
            echo
            echo "Interactive mode (default):"
            echo "  $0"
            echo
            exit 0
            ;;
        --version|-v)
            echo "VibeOps Onboarding Orchestrator v$VIBEOPS_VERSION"
            echo "Agentic Development Journey"
            echo "Following verification-first principles"
            exit 0
            ;;
        --verify)
            startup_checks
            verify_current_state
            exit 0
            ;;
        --status)
            startup_checks
            get_progress_summary
            exit 0
            ;;
        --reset)
            startup_checks
            reset_and_clean
            exit 0
            ;;
        "")
            # No arguments - run interactive mode
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac

    # Run startup checks
    startup_checks

    # Welcome message for first-time users
    if [[ ! -d "$CLAUDE_ONBOARDING_DIR" ]]; then
        show_header
        echo -e "${GREEN}🎉 Welcome to your VibeOps journey!${NC}"
        echo
        echo -e "${BLUE}This appears to be your first time using the system.${NC}"
        echo -e "${BLUE}We'll guide you through verification-first agentic development.${NC}"
        echo
        echo -e "${YELLOW}Key principles you'll learn:${NC}"
        echo -e "  • AI as a thinking partner, not just a tool"
        echo -e "  • Verification before implementation"
        echo -e "  • Orchestration over direct coding"
        echo -e "  • Emergent solutions through collaboration"
        echo
        read -p "Press Enter to continue to the main menu..."
    fi

    # Start main interactive loop
    main_loop
}

# Execute main function with all arguments
main "$@"