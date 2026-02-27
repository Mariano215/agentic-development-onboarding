#!/bin/bash

# Test Phase 0 - Philosophy Foundation
# This test validates the Phase 0 functionality

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

# Function to run test
run_test() {
    local test_name="$1"
    local test_command="$2"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${YELLOW}Running test: $test_name${NC}"

    if eval "$test_command"; then
        echo -e "${GREEN}✓ PASS: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL: $test_name${NC}"
    fi
    echo
}

# Helper function to check file exists and is executable
check_executable() {
    [ -f "$1" ] && [ -x "$1" ]
}

# Helper function to check file exists and has content
check_file_content() {
    [ -f "$1" ] && [ -s "$1" ]
}

echo "=== Phase 0 Philosophy Foundation Tests ==="
echo

# Test 1: Phase runner script exists and is executable
run_test "Phase runner script exists and executable" \
    "check_executable '/home/mmattei/Projects/.worktrees/agentic-onboarding/tutorial-phases/phase0-philosophy/run-phase0.sh'"

# Test 2: Assessment script exists and is executable
run_test "Assessment script exists and executable" \
    "check_executable '/home/mmattei/Projects/.worktrees/agentic-onboarding/tutorial-phases/phase0-philosophy/assessment.py'"

# Test 3: Comparison document exists and has content
run_test "Old vs new comparison document exists" \
    "check_file_content '/home/mmattei/Projects/.worktrees/agentic-onboarding/tutorial-phases/phase0-philosophy/old-vs-new.md'"

# Test 4: Assessment scoring works correctly
run_test "Assessment script can be imported and has correct structure" \
    "cd '/home/mmattei/Projects/.worktrees/agentic-onboarding/tutorial-phases/phase0-philosophy' && python3 -c 'import assessment; assert hasattr(assessment, \"run_assessment\"), \"Missing run_assessment function\"'"

# Test 5: Assessment questions test manifesto understanding
run_test "Assessment has required number of questions" \
    "cd '/home/mmattei/Projects/.worktrees/agentic-onboarding/tutorial-phases/phase0-philosophy' && python3 -c 'import assessment; questions = assessment.get_questions(); assert len(questions) == 5, f\"Expected 5 questions, got {len(questions)}\"'"

# Test 6: Assessment scoring requires 80% to pass
run_test "Assessment scoring works correctly (80% threshold)" \
    "cd '/home/mmattei/Projects/.worktrees/agentic-onboarding/tutorial-phases/phase0-philosophy' && python3 -c 'import assessment; assert assessment.calculate_score(4, 5) >= 80, \"4/5 should pass\"; assert assessment.calculate_score(3, 5) < 80, \"3/5 should fail\"'"

# Test 7: Phase runner script contains required components
run_test "Phase runner script has proper structure" \
    "grep -q 'Phase 0.*Philosophy Foundation' '/home/mmattei/Projects/.worktrees/agentic-onboarding/tutorial-phases/phase0-philosophy/run-phase0.sh' && grep -q 'manifesto' '/home/mmattei/Projects/.worktrees/agentic-onboarding/tutorial-phases/phase0-philosophy/run-phase0.sh'"

# Test 8: Old vs new document has proper content structure
run_test "Old vs new document has comparison table" \
    "grep -q 'Traditional.*Agentic' '/home/mmattei/Projects/.worktrees/agentic-onboarding/tutorial-phases/phase0-philosophy/old-vs-new.md' && grep -q '|.*|.*|' '/home/mmattei/Projects/.worktrees/agentic-onboarding/tutorial-phases/phase0-philosophy/old-vs-new.md'"

# Test 9: Assessment creates proper progress directory
run_test "Assessment can create progress directory structure" \
    "cd '/home/mmattei/Projects/.worktrees/agentic-onboarding/tutorial-phases/phase0-philosophy' && python3 -c 'import assessment; import os; assessment.ensure_progress_dir(); assert os.path.exists(os.path.expanduser(\"~/.claude-onboarding/manifesto-assessment\")), \"Progress directory not created\"'"

echo "=== Test Results ==="
echo -e "Tests run: $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$((TESTS_RUN - TESTS_PASSED))${NC}"
echo

if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi