#!/bin/bash

# Test orchestrator functionality
# Following VibeOps principle: verification-first development

set -euo pipefail

# Color definitions for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0

# Test utility functions
test_assert() {
    local description="$1"
    local condition="$2"

    TESTS_RUN=$((TESTS_RUN + 1))
    echo -n "Testing: $description... "

    if eval "$condition"; then
        echo -e "${GREEN}PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Condition: $condition"
    fi
}

test_file_exists() {
    local file="$1"
    local description="$2"
    test_assert "$description" "[ -f '$file' ]"
}

test_file_executable() {
    local file="$1"
    local description="$2"
    test_assert "$description" "[ -x '$file' ]"
}

test_command_output_contains() {
    local command="$1"
    local expected="$2"
    local description="$3"
    test_assert "$description" "$command | grep -q '$expected'"
}

# Project root directory
PROJECT_ROOT="/home/mmattei/Projects/.worktrees/agentic-onboarding"
ONBOARD_SCRIPT="$PROJECT_ROOT/onboard.sh"
PROGRESS_TRACKER="$PROJECT_ROOT/shared/progress-tracker.sh"

echo "=== VibeOps Orchestrator Test Suite ==="
echo "Testing verification-first development principles"
echo

# Test 1: Main orchestrator exists and is executable
test_file_exists "$ONBOARD_SCRIPT" "onboard.sh exists"
test_file_executable "$ONBOARD_SCRIPT" "onboard.sh is executable"

# Test 2: Progress tracker exists and is executable
test_file_exists "$PROGRESS_TRACKER" "progress-tracker.sh exists"
test_file_executable "$PROGRESS_TRACKER" "progress-tracker.sh is executable"

# Test 3: Progress tracker functions are defined
if [ -f "$PROGRESS_TRACKER" ]; then
    test_command_output_contains "grep -E '^(init_progress|get_phase_status|update_phase_status)' '$PROGRESS_TRACKER'" "init_progress" "progress tracker has init_progress function"
    test_command_output_contains "grep -E '^(init_progress|get_phase_status|update_phase_status)' '$PROGRESS_TRACKER'" "get_phase_status" "progress tracker has get_phase_status function"
    test_command_output_contains "grep -E '^(init_progress|get_phase_status|update_phase_status)' '$PROGRESS_TRACKER'" "update_phase_status" "progress tracker has update_phase_status function"
fi

# Test 4: Progress tracker creates proper directory structure
if [ -x "$PROGRESS_TRACKER" ]; then
    # Clean up any existing test directory
    rm -rf ~/.claude-onboarding-test

    # Test directory creation
    test_assert "progress tracker creates base directory" "
        source '$PROGRESS_TRACKER' &&
        CLAUDE_ONBOARDING_DIR=~/.claude-onboarding-test init_progress &&
        [ -d ~/.claude-onboarding-test ]
    "

    # Test subdirectory creation
    test_assert "progress tracker creates subdirectories" "
        [ -d ~/.claude-onboarding-test/assessments ] &&
        [ -d ~/.claude-onboarding-test/demo-project ] &&
        [ -d ~/.claude-onboarding-test/verification-history ]
    "

    # Test JSON file creation
    test_assert "progress tracker creates progress.json" "
        [ -f ~/.claude-onboarding-test/progress.json ]
    "

    # Test JSON structure
    test_assert "progress.json has correct structure" "
        jq -e '.phases.philosophy' ~/.claude-onboarding-test/progress.json > /dev/null &&
        jq -e '.phases.frame' ~/.claude-onboarding-test/progress.json > /dev/null &&
        jq -e '.phases.model' ~/.claude-onboarding-test/progress.json > /dev/null &&
        jq -e '.phases.generate' ~/.claude-onboarding-test/progress.json > /dev/null &&
        jq -e '.phases.verify_observe' ~/.claude-onboarding-test/progress.json > /dev/null
    "

    # Clean up test directory
    rm -rf ~/.claude-onboarding-test
fi

# Test 5: Main orchestrator has required menu options
if [ -f "$ONBOARD_SCRIPT" ]; then
    test_command_output_contains "cat '$ONBOARD_SCRIPT'" "VibeOps Tutorial" "orchestrator has VibeOps Tutorial option"
    test_command_output_contains "cat '$ONBOARD_SCRIPT'" "Jump to" "orchestrator has Jump to Phase option"
    test_command_output_contains "cat '$ONBOARD_SCRIPT'" "Verify.*State" "orchestrator has Verify State option"
    test_command_output_contains "cat '$ONBOARD_SCRIPT'" "Reset.*Clean" "orchestrator has Reset & Clean option"
    test_command_output_contains "cat '$ONBOARD_SCRIPT'" "Exit" "orchestrator has Exit option"
fi

# Test 6: Orchestrator displays VibeOps branding and philosophy
if [ -f "$ONBOARD_SCRIPT" ]; then
    test_command_output_contains "cat '$ONBOARD_SCRIPT'" "VibeOps" "orchestrator mentions VibeOps"
    test_command_output_contains "cat '$ONBOARD_SCRIPT'" "verification.*first" "orchestrator mentions verification-first principle"
fi

# Test 7: Orchestrator integrates with progress tracker
if [ -f "$ONBOARD_SCRIPT" ]; then
    test_command_output_contains "cat '$ONBOARD_SCRIPT'" "progress-tracker" "orchestrator sources progress tracker"
fi

# Test 8: Color output support
if [ -f "$ONBOARD_SCRIPT" ]; then
    test_command_output_contains "cat '$ONBOARD_SCRIPT'" "\\\\033" "orchestrator uses color codes"
fi

# Summary
echo
echo "=== Test Results ==="
echo "Tests run: $TESTS_RUN"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $((TESTS_RUN - TESTS_PASSED))"

if [ $TESTS_PASSED -eq $TESTS_RUN ]; then
    echo -e "${GREEN}All tests passed! VibeOps verification complete.${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. VibeOps verification incomplete.${NC}"
    exit 1
fi