#!/bin/bash

# test-repo-structure.sh
# Test script to validate repository structure for agentic onboarding system
# Following TDD principles - this test should fail initially

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "🧪 Testing repository structure for agentic onboarding system..."

# Test 1: Required files exist
echo "Checking required files..."
required_files=(
    "README.md"
    "AGENTIC_DEVELOPMENT_MANIFESTO.md"
)

for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "❌ FAIL: Required file missing: $file"
        exit 1
    fi
    echo "✅ Found: $file"
done

# Test 2: Directory structure is correct
echo "Checking directory structure..."
required_dirs=(
    "tutorial-phases"
    "verification-gates"
    "manifesto-integration"
    "shared"
    "examples"
    "tests"
)

for dir in "${required_dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
        echo "❌ FAIL: Required directory missing: $dir"
        exit 1
    fi
    echo "✅ Found directory: $dir"
done

# Test 3: README contains manifesto reference
echo "Checking README manifesto reference..."
if ! grep -q "AGENTIC_DEVELOPMENT_MANIFESTO" README.md; then
    echo "❌ FAIL: README.md does not reference the manifesto"
    exit 1
fi
echo "✅ README contains manifesto reference"

# Test 4: README contains VibeOps journey phases
echo "Checking README VibeOps journey content..."
if ! grep -q "Phase 0" README.md || ! grep -q "VibeOps" README.md; then
    echo "❌ FAIL: README.md does not contain VibeOps journey phases"
    exit 1
fi
echo "✅ README contains VibeOps journey phases"

# Test 5: README contains onboard script reference
echo "Checking README onboard script reference..."
if ! grep -q "./onboard.sh" README.md; then
    echo "❌ FAIL: README.md does not reference ./onboard.sh"
    exit 1
fi
echo "✅ README references onboard script"

# Test 6: Manifesto file has content
echo "Checking manifesto content..."
if [[ ! -s "AGENTIC_DEVELOPMENT_MANIFESTO.md" ]]; then
    echo "❌ FAIL: AGENTIC_DEVELOPMENT_MANIFESTO.md is empty or missing"
    exit 1
fi
echo "✅ Manifesto file has content"

echo ""
echo "🎉 All repository structure tests passed!"
echo "Repository is ready for agentic development onboarding system."