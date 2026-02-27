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

# Show main menu
show_menu() {
    echo -e "${CYAN}=== VibeOps Journey Menu ===${NC}"
    echo
    echo -e "${WHITE}1.${NC} ${GREEN}🚀 Start VibeOps Tutorial${NC} (Complete guided journey)"
    echo -e "${WHITE}2.${NC} ${BLUE}🎯 Jump to Phase${NC} (Advanced users)"
    echo -e "${WHITE}3.${NC} ${YELLOW}🔍 Verify State${NC} (Run all verification gates)"
    echo -e "${WHITE}4.${NC} ${RED}🔄 Reset & Clean${NC} (Start fresh)"
    echo -e "${WHITE}5.${NC} ${CYAN}🚪 Exit${NC}"
    echo
    echo -e -n "${BLUE}Choose your path (1-5): ${NC}"
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

        # Start with philosophy phase
        set_current_phase "philosophy"
        echo -e "${GREEN}✅ Tutorial initialized - starting with Philosophy Foundation${NC}"
        echo -e "${BLUE}Run: ./tutorial-phases/phase-0-philosophy.sh${NC}"
        echo
        read -p "Press Enter to continue..."
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

    case "$phase_choice" in
        0)
            set_current_phase "philosophy"
            echo -e "${GREEN}Switched to Philosophy Foundation${NC}"
            echo -e "${BLUE}Run: ./tutorial-phases/phase-0-philosophy.sh${NC}"
            ;;
        1)
            set_current_phase "frame"
            echo -e "${GREEN}Switched to Frame the Problem${NC}"
            echo -e "${BLUE}Run: ./tutorial-phases/phase-1-frame.sh${NC}"
            ;;
        2)
            set_current_phase "model"
            echo -e "${GREEN}Switched to Model Security & Threats${NC}"
            echo -e "${BLUE}Run: ./tutorial-phases/phase-2-model.sh${NC}"
            ;;
        3)
            set_current_phase "generate"
            echo -e "${GREEN}Switched to Generate with AI Partnership${NC}"
            echo -e "${BLUE}Run: ./tutorial-phases/phase-3-generate.sh${NC}"
            ;;
        4)
            set_current_phase "verify_observe"
            echo -e "${GREEN}Switched to Verify & Observe${NC}"
            echo -e "${BLUE}Run: ./tutorial-phases/phase-4-verify-observe.sh${NC}"
            ;;
        b|B)
            return
            ;;
        *)
            echo -e "${RED}Invalid selection. Please choose 0-4 or 'b'.${NC}"
            ;;
    esac
    echo
    read -p "Press Enter to continue..."
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
                verify_current_state
                ;;
            4)
                reset_and_clean
                ;;
            5)
                echo -e "${CYAN}🚪 Exiting VibeOps Onboarding${NC}"
                echo -e "${BLUE}Remember: AI partnership is a journey, not a destination.${NC}"
                echo -e "${GREEN}Keep exploring, keep verifying, keep growing.${NC}"
                echo
                echo -e "${YELLOW}\"The best way to predict the future is to invent it.\"${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please select 1-5.${NC}"
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