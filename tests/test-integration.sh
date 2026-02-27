#!/bin/bash
set -e

# Test 5: Integration with Current Setup
echo "Running Task 5 integration tests..."

# Test directory setup
TEST_DIR="/tmp/vibeops-integration-test-$$"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# Test 1: setup-current-project.sh exists and is executable
echo "Test 1: Checking setup-current-project.sh..."
if [[ ! -f "$CURRENT_DIR/setup-current-project.sh" ]]; then
    echo "ERROR: setup-current-project.sh does not exist"
    exit 1
fi
if [[ ! -x "$CURRENT_DIR/setup-current-project.sh" ]]; then
    echo "ERROR: setup-current-project.sh is not executable"
    exit 1
fi
echo "✓ setup-current-project.sh exists and is executable"

# Test 2: manifesto integration script exists and is executable
echo "Test 2: Checking manifesto integration script..."
if [[ ! -f "$CURRENT_DIR/manifesto-integration/add-to-project.sh" ]]; then
    echo "ERROR: manifesto-integration/add-to-project.sh does not exist"
    exit 1
fi
if [[ ! -x "$CURRENT_DIR/manifesto-integration/add-to-project.sh" ]]; then
    echo "ERROR: manifesto-integration/add-to-project.sh is not executable"
    exit 1
fi
echo "✓ manifesto integration script exists and is executable"

# Test 3: Daily checklist exists with proper content
echo "Test 3: Checking daily checklist..."
if [[ ! -f "$CURRENT_DIR/manifesto-integration/daily-checklist.md" ]]; then
    echo "ERROR: manifesto-integration/daily-checklist.md does not exist"
    exit 1
fi

# Check for required sections in daily checklist
CHECKLIST_FILE="$CURRENT_DIR/manifesto-integration/daily-checklist.md"
required_sections=(
    "Before starting any feature"
    "Frame first"
    "Model threats"
    "During development"
    "Human judgment"
    "Verification gates"
    "Before deployment"
    "All gates green"
    "Observable"
    "End of day reflection"
    "Proof over progress"
    "Weekly review"
)

for section in "${required_sections[@]}"; do
    if ! grep -q "$section" "$CHECKLIST_FILE"; then
        echo "ERROR: Daily checklist missing required section: $section"
        exit 1
    fi
done
echo "✓ Daily checklist exists with all required content"

# Test 4: manifesto integration functionality
echo "Test 4: Testing manifesto integration functionality..."
mkdir -p "$TEST_DIR/test-project"
echo "# Test Project" > "$TEST_DIR/test-project/README.md"

# Test dry-run mode
"$CURRENT_DIR/manifesto-integration/add-to-project.sh" --dry-run "$TEST_DIR/test-project" > /dev/null
if [[ $? -ne 0 ]]; then
    echo "ERROR: manifesto integration dry-run failed"
    exit 1
fi

# Test actual integration
"$CURRENT_DIR/manifesto-integration/add-to-project.sh" "$TEST_DIR/test-project"
if [[ $? -ne 0 ]]; then
    echo "ERROR: manifesto integration failed"
    exit 1
fi

# Check integration results
if [[ ! -f "$TEST_DIR/test-project/AGENTIC_DEVELOPMENT_MANIFESTO.md" ]]; then
    echo "ERROR: Manifesto not copied to project"
    exit 1
fi
if [[ ! -f "$TEST_DIR/test-project/.claude/daily-checklist.md" ]]; then
    echo "ERROR: Daily checklist not copied to project .claude directory"
    exit 1
fi
if ! grep -q "VibeOps" "$TEST_DIR/test-project/README.md"; then
    echo "ERROR: README not updated with VibeOps principles"
    exit 1
fi
echo "✓ Manifesto integration functionality works"

# Test 5: setup-current-project.sh functionality with dry-run
echo "Test 5: Testing main setup script functionality..."
mkdir -p "$TEST_DIR/test-main-project"
echo "# Main Test Project" > "$TEST_DIR/test-main-project/README.md"

# Test dry-run mode
"$CURRENT_DIR/setup-current-project.sh" --dry-run "$TEST_DIR/test-main-project" > /dev/null
if [[ $? -ne 0 ]]; then
    echo "ERROR: setup-current-project.sh dry-run failed"
    exit 1
fi
echo "✓ Main setup script dry-run works"

# Test 6: Integration with actual /home/mmattei/Projects directory (dry-run only)
echo "Test 6: Testing integration with actual Projects directory..."
if [[ -d "/home/mmattei/Projects" ]]; then
    "$CURRENT_DIR/setup-current-project.sh" --dry-run "/home/mmattei/Projects" > /dev/null
    if [[ $? -ne 0 ]]; then
        echo "ERROR: Real Projects directory integration dry-run failed"
        exit 1
    fi
    echo "✓ Real Projects directory integration dry-run works"
else
    echo "WARNING: /home/mmattei/Projects does not exist, skipping real integration test"
fi

# Test 7: Error handling for invalid directories
echo "Test 7: Testing error handling..."
set +e  # Allow command to fail without exiting script
"$CURRENT_DIR/setup-current-project.sh" "/nonexistent/directory" 2>/dev/null
RESULT=$?
set -e  # Re-enable exit on error
if [[ $RESULT -eq 0 ]]; then
    echo "ERROR: Should fail for nonexistent directory"
    exit 1
fi
echo "✓ Error handling works correctly"

# Test 8: Scripts handle target directories correctly
echo "Test 8: Testing directory handling..."
mkdir -p "$TEST_DIR/nested/project"
"$CURRENT_DIR/setup-current-project.sh" --dry-run "$TEST_DIR/nested/project" > /dev/null
if [[ $? -ne 0 ]]; then
    echo "ERROR: Should handle nested directories"
    exit 1
fi
echo "✓ Directory handling works correctly"

echo "All integration tests passed!"
echo "Integration system is ready for deployment!"