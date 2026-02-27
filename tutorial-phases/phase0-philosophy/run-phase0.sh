#!/bin/bash

# Phase 0: Philosophy Foundation
# Transforms users from traditional to agentic development mindset
# Mandatory first step with 80% assessment gate

set -euo pipefail

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source progress tracker
source "$PROJECT_ROOT/shared/progress-tracker.sh"

# Color definitions
CYAN='\033[0;36m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Phase 0 Header
display_phase_header() {
    echo -e "${BOLD}${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                          PHASE 0: PHILOSOPHY FOUNDATION                  ║"
    echo "║                                                                           ║"
    echo "║   🧠 Transform Your Mindset: Traditional → Agentic Development            ║"
    echo "║                                                                           ║"
    echo "║   Before you learn tools and techniques, you must understand the          ║"
    echo "║   fundamental shift from human-centric to AI-human collaborative         ║"
    echo "║   development. This is not optional—it's the foundation for everything.  ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"
}

# Display phase goals
display_phase_goals() {
    echo -e "${BLUE}${BOLD}Phase 0 Learning Objectives:${NC}"
    echo -e "${GREEN}✓ ${NC}Understand the core VibeOps philosophy"
    echo -e "${GREEN}✓ ${NC}Grasp the bottleneck shift: coding speed → judgment capacity"
    echo -e "${GREEN}✓ ${NC}Learn the VibeOps development cycle (Envision → Explore → Execute → Evolve)"
    echo -e "${GREEN}✓ ${NC}Internalize 'proof beats progress' verification mindset"
    echo -e "${GREEN}✓ ${NC}Recognize the new role of humans in agentic development"
    echo -e "${YELLOW}🎯 Pass assessment with 80% (4/5 questions correct) to proceed${NC}"
    echo
}

# Guide user through manifesto
guide_manifesto_reading() {
    echo -e "${BLUE}${BOLD}Step 1: Understanding the VibeOps Manifesto${NC}"
    echo
    echo -e "${YELLOW}The Agentic Development Manifesto is your philosophical foundation.${NC}"
    echo -e "${YELLOW}Please take time to read and reflect on it carefully.${NC}"
    echo

    local manifesto_path="$PROJECT_ROOT/AGENTIC_DEVELOPMENT_MANIFESTO.md"

    if [[ -f "$manifesto_path" ]]; then
        echo -e "${CYAN}📖 Manifesto location: ${BOLD}$manifesto_path${NC}"
        echo
        echo -e "${BLUE}Key sections to focus on:${NC}"
        echo -e "  ${GREEN}• The Four Pillars of VibeOps${NC}"
        echo -e "  ${GREEN}• Core Principles${NC}"
        echo -e "  ${GREEN}• The VibeOps Development Cycle${NC}"
        echo -e "  ${GREEN}• Transformation Stages${NC}"
        echo
        echo -e "${YELLOW}Take your time. This isn't just reading—it's mindset transformation.${NC}"
        echo

        read -p "Press Enter when you've finished reading the manifesto..."
        echo
    else
        echo -e "${RED}❌ Manifesto not found at expected location!${NC}"
        echo -e "${RED}Expected: $manifesto_path${NC}"
        return 1
    fi
}

# Present comparison document
present_comparison() {
    echo -e "${BLUE}${BOLD}Step 2: Traditional vs Agentic Mindset Comparison${NC}"
    echo
    echo -e "${YELLOW}Now let's see concrete examples of how thinking changes...${NC}"
    echo

    local comparison_path="$SCRIPT_DIR/old-vs-new.md"

    if [[ -f "$comparison_path" ]]; then
        echo -e "${CYAN}📊 Comparison document: ${BOLD}$comparison_path${NC}"
        echo
        echo -e "${BLUE}This document shows:${NC}"
        echo -e "  ${GREEN}• Side-by-side comparison of traditional vs agentic approaches${NC}"
        echo -e "  ${GREEN}• Real-world example: Adding user authentication${NC}"
        echo -e "  ${GREEN}• The critical bottleneck shift${NC}"
        echo -e "  ${GREEN}• Why this mindset change matters${NC}"
        echo
        echo -e "${YELLOW}Pay special attention to the 'bottleneck shift' section.${NC}"
        echo -e "${YELLOW}This is often the hardest concept for experienced developers.${NC}"
        echo

        read -p "Press Enter when you've finished reviewing the comparison..."
        echo
    else
        echo -e "${RED}❌ Comparison document not found!${NC}"
        echo -e "${RED}Expected: $comparison_path${NC}"
        return 1
    fi
}

# Run assessment with retry mechanism
run_assessment() {
    echo -e "${BLUE}${BOLD}Step 3: Manifesto Understanding Assessment${NC}"
    echo
    echo -e "${YELLOW}Time to verify your understanding of VibeOps principles.${NC}"
    echo -e "${YELLOW}This assessment ensures you've internalized the key concepts.${NC}"
    echo
    echo -e "${CYAN}📝 Assessment Details:${NC}"
    echo -e "  ${GREEN}• 5 multiple choice questions${NC}"
    echo -e "  ${GREEN}• Tests core manifesto concepts${NC}"
    echo -e "  ${GREEN}• 80% required to pass (4/5 correct)${NC}"
    echo -e "  ${GREEN}• Immediate feedback on each answer${NC}"
    echo -e "  ${GREEN}• Can retake if needed${NC}"
    echo

    local max_attempts=3
    local attempt=1
    local passed=false

    while [[ $attempt -le $max_attempts ]] && [[ "$passed" == "false" ]]; do
        if [[ $attempt -gt 1 ]]; then
            echo -e "${YELLOW}Attempt ${attempt}/${max_attempts}${NC}"
            echo
        fi

        echo -e "${BLUE}Starting assessment...${NC}"
        echo

        # Run the assessment Python script
        if cd "$SCRIPT_DIR" && python3 assessment.py; then
            passed=true
            echo
            echo -e "${GREEN}${BOLD}🎉 Assessment PASSED! 🎉${NC}"
            echo -e "${GREEN}You've demonstrated solid understanding of VibeOps principles.${NC}"

            # Update progress tracking
            echo
            echo -e "${BLUE}Updating progress tracking...${NC}"
            update_phase_status "philosophy" "completed" "true"
            update_phase_status "philosophy" "score" "80"

            # Move to next phase
            set_current_phase "frame"

            echo -e "${GREEN}✅ Phase 0 completed successfully!${NC}"
            return 0
        else
            echo
            echo -e "${RED}Assessment not passed this attempt.${NC}"
            ((attempt++))

            if [[ $attempt -le $max_attempts ]]; then
                echo
                echo -e "${YELLOW}Don't worry! You can try again.${NC}"
                echo -e "${BLUE}Review the areas you missed and retake when ready.${NC}"
                echo
                echo -e "${CYAN}💡 Study Tips:${NC}"
                echo -e "  ${GREEN}• Re-read the manifesto sections related to questions you missed${NC}"
                echo -e "  ${GREEN}• Focus on understanding WHY, not just memorizing facts${NC}"
                echo -e "  ${GREEN}• Pay attention to the bottleneck shift concept${NC}"
                echo -e "  ${GREEN}• Consider how the VibeOps cycle differs from traditional cycles${NC}"
                echo

                read -p "Press Enter when ready to try again (or Ctrl+C to exit)..."
                echo
            else
                echo
                echo -e "${RED}Maximum attempts (${max_attempts}) reached.${NC}"
                echo -e "${YELLOW}Please take more time to study the manifesto and comparison document.${NC}"
                echo -e "${BLUE}You can restart this phase anytime by running: ./tutorial-phases/phase0-philosophy/run-phase0.sh${NC}"
                return 1
            fi
        fi
    done
}

# Phase completion summary
display_completion() {
    echo
    echo -e "${BOLD}${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                     PHASE 0 COMPLETE: MINDSET TRANSFORMED!               ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    echo -e "${GREEN}🧠 You've successfully transformed your development mindset!${NC}"
    echo
    echo -e "${BLUE}${BOLD}What you've accomplished:${NC}"
    echo -e "  ${GREEN}✅ Mastered VibeOps philosophical foundation${NC}"
    echo -e "  ${GREEN}✅ Understood the critical bottleneck shift${NC}"
    echo -e "  ${GREEN}✅ Internalized verification-first thinking${NC}"
    echo -e "  ${GREEN}✅ Ready for practical agentic development${NC}"
    echo

    echo -e "${YELLOW}${BOLD}What's Next:${NC}"
    echo -e "${BLUE}Phase 1: Frame - Learn to define problems and success criteria${NC}"
    echo -e "${BLUE}This is where philosophy becomes practice.${NC}"
    echo

    echo -e "${CYAN}Run the orchestrator to continue: ${BOLD}./onboard.sh${NC}"
    echo

    # Show progress summary
    echo -e "${PURPLE}Current Progress:${NC}"
    get_progress_summary
}

# Error handling
handle_error() {
    local line_num=$1
    local error_code=$2
    echo
    echo -e "${RED}❌ Error on line $line_num (exit code: $error_code)${NC}"
    echo -e "${YELLOW}Phase 0 was interrupted. You can restart anytime with:${NC}"
    echo -e "${CYAN}./tutorial-phases/phase0-philosophy/run-phase0.sh${NC}"
    exit $error_code
}

# Set up error handling
trap 'handle_error ${LINENO} $?' ERR

# Main execution flow
main() {
    # Initialize progress tracking if needed
    if [[ ! -f "$(get_progress_file)" ]]; then
        echo -e "${BLUE}Initializing progress tracking...${NC}"
        init_progress
        echo
    fi

    # Display header and goals
    display_phase_header
    display_phase_goals

    # Phase workflow
    echo -e "${CYAN}${BOLD}Phase 0 Workflow:${NC}"
    echo -e "${BLUE}This phase follows the VibeOps principles it teaches:${NC}"
    echo -e "  ${GREEN}1. Envision: Understand the philosophical foundation${NC}"
    echo -e "  ${GREEN}2. Explore: Compare traditional vs agentic approaches${NC}"
    echo -e "  ${GREEN}3. Execute: Take assessment to verify understanding${NC}"
    echo -e "  ${GREEN}4. Evolve: Proceed with transformed mindset${NC}"
    echo
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo

    # Execute phase steps
    guide_manifesto_reading
    present_comparison
    run_assessment
    display_completion
}

# Handle script interruption
trap_exit() {
    echo
    echo -e "${YELLOW}Phase 0 interrupted. Progress has been saved.${NC}"
    echo -e "${BLUE}Resume anytime with: ./tutorial-phases/phase0-philosophy/run-phase0.sh${NC}"
    exit 0
}

trap trap_exit INT TERM

# Check if being sourced or run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi