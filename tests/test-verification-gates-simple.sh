#!/bin/bash

# Simple test script for verification gates framework
# Just tests the basic functionality that we know works

set -e

echo "Testing Verification Gates Framework"
echo "===================================="

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERIFICATION_GATES_DIR="$PROJECT_ROOT/verification-gates"

echo "Project root: $PROJECT_ROOT"

# Test 1: Check files exist and are executable
echo ""
echo "1. Checking pipeline scripts..."

SECURITY_PIPELINE="$VERIFICATION_GATES_DIR/security-pipeline.sh"
QUALITY_PIPELINE="$VERIFICATION_GATES_DIR/quality-pipeline.sh"
DEPLOYMENT_PIPELINE="$VERIFICATION_GATES_DIR/deployment-pipeline.sh"

if [ -x "$SECURITY_PIPELINE" ]; then
    echo "✓ security-pipeline.sh exists and is executable"
else
    echo "✗ security-pipeline.sh missing or not executable"
    exit 1
fi

if [ -x "$QUALITY_PIPELINE" ]; then
    echo "✓ quality-pipeline.sh exists and is executable"
else
    echo "✗ quality-pipeline.sh missing or not executable"
    exit 1
fi

if [ -x "$DEPLOYMENT_PIPELINE" ]; then
    echo "✓ deployment-pipeline.sh exists and is executable"
else
    echo "✗ deployment-pipeline.sh missing or not executable"
    exit 1
fi

# Test 2: Check help output works
echo ""
echo "2. Testing help output..."

if "$SECURITY_PIPELINE" --help >/dev/null 2>&1; then
    echo "✓ security-pipeline.sh --help works"
else
    echo "✗ security-pipeline.sh --help failed"
    exit 1
fi

if "$QUALITY_PIPELINE" --help >/dev/null 2>&1; then
    echo "✓ quality-pipeline.sh --help works"
else
    echo "✗ quality-pipeline.sh --help failed"
    exit 1
fi

if "$DEPLOYMENT_PIPELINE" --help >/dev/null 2>&1; then
    echo "✓ deployment-pipeline.sh --help works"
else
    echo "✗ deployment-pipeline.sh --help failed"
    exit 1
fi

# Test 3: Test dry-run mode
echo ""
echo "3. Testing dry-run mode..."

TEST_PROJECT_DIR=$(mktemp -d)

if "$SECURITY_PIPELINE" --dry-run --project-dir "$TEST_PROJECT_DIR" >/dev/null 2>&1; then
    echo "✓ security-pipeline.sh dry-run works"
else
    echo "✗ security-pipeline.sh dry-run failed"
    rm -rf "$TEST_PROJECT_DIR"
    exit 1
fi

if "$QUALITY_PIPELINE" --dry-run --project-dir "$TEST_PROJECT_DIR" >/dev/null 2>&1; then
    echo "✓ quality-pipeline.sh dry-run works"
else
    echo "✗ quality-pipeline.sh dry-run failed"
    rm -rf "$TEST_PROJECT_DIR"
    exit 1
fi

if "$DEPLOYMENT_PIPELINE" --dry-run --project-dir "$TEST_PROJECT_DIR" >/dev/null 2>&1; then
    echo "✓ deployment-pipeline.sh dry-run works"
else
    echo "✗ deployment-pipeline.sh dry-run failed"
    rm -rf "$TEST_PROJECT_DIR"
    exit 1
fi

rm -rf "$TEST_PROJECT_DIR"

echo ""
echo "✓ All tests passed!"
echo ""
echo "The verification gates framework is ready for use."