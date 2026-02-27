#!/bin/bash

# Quality Verification Pipeline
# Implements test coverage checking, code complexity analysis, and test execution

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DRY_RUN=false
PROJECT_DIR=""
VERBOSE=false
RESULTS_DIR="$HOME/.claude-onboarding/verification-history"
MIN_COVERAGE_RATIO=0.5  # 50% test coverage ratio

# Counters
CHECKS_RUN=0
CHECKS_PASSED=0
CHECKS_FAILED=0

# Ensure results directory exists
mkdir -p "$RESULTS_DIR"

# Helper functions
log_header() {
    echo -e "\n${BLUE}═══ $1 ═══${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_check() {
    echo -e "${YELLOW}[CHECK]${NC} $1"
    ((CHECKS_RUN++))
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((CHECKS_PASSED++))
}

log_failure() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((CHECKS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_dry_run() {
    echo -e "${CYAN}[DRY-RUN]${NC} $1"
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Quality verification pipeline for agentic development"
    echo ""
    echo "Options:"
    echo "  --dry-run              Show what would be checked without running"
    echo "  --project-dir <path>   Directory to analyze (default: current directory)"
    echo "  --verbose              Enable verbose output"
    echo "  --help                 Show this help message"
    echo ""
    echo "Exit codes:"
    echo "  0  All quality checks passed"
    echo "  1  One or more quality checks failed"
    echo "  2  Error in execution"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --project-dir)
            PROJECT_DIR="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            usage
            exit 2
            ;;
    esac
done

# Set default project directory
if [ -z "$PROJECT_DIR" ]; then
    PROJECT_DIR="$(pwd)"
fi

# Validate project directory
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Error: Project directory '$PROJECT_DIR' does not exist${NC}"
    exit 2
fi

PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"  # Get absolute path

# Quality check functions
check_test_coverage() {
    log_check "Analyzing test coverage ratio"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would analyze ratio of test files to source files (target: ≥50%)"
        log_success "Test coverage ratio check (dry-run)"
        return 0
    fi

    # Count source files
    local source_files=0
    local source_patterns=("*.py" "*.js" "*.ts" "*.jsx" "*.tsx" "*.go" "*.java" "*.cpp" "*.c" "*.cs" "*.rb" "*.php")

    for pattern in "${source_patterns[@]}"; do
        local count=$(find "$PROJECT_DIR" -name "$pattern" \
                     -not -path "*/test*" \
                     -not -path "*/*test*" \
                     -not -path "*/.git/*" \
                     -not -path "*/node_modules/*" \
                     -not -path "*/__pycache__/*" \
                     -not -path "*/dist/*" \
                     -not -path "*/build/*" \
                     2>/dev/null | wc -l)
        source_files=$((source_files + count))
    done

    # Count test files
    local test_files=0
    local test_patterns=("*test*.py" "*test*.js" "*test*.ts" "*test*.jsx" "*test*.tsx"
                         "test_*.py" "*.test.*" "*.spec.*" "*_test.*"
                         "test*.go" "*_test.go" "Test*.java" "*Test.java"
                         "*Tests.cs" "*Test.cs")

    for pattern in "${test_patterns[@]}"; do
        local count=$(find "$PROJECT_DIR" -name "$pattern" \
                     -not -path "*/.git/*" \
                     -not -path "*/node_modules/*" \
                     2>/dev/null | wc -l)
        test_files=$((test_files + count))
    done

    log_info "Source files found: $source_files"
    log_info "Test files found: $test_files"

    if [ $source_files -eq 0 ]; then
        log_warning "No source files detected"
        log_success "Test coverage ratio check (no source files to test)"
        return 0
    fi

    local coverage_ratio=$(echo "scale=2; $test_files / $source_files" | bc -l 2>/dev/null || echo "0")
    local coverage_percentage=$(echo "scale=1; $coverage_ratio * 100" | bc -l 2>/dev/null || echo "0")

    log_info "Test coverage ratio: $coverage_ratio ($coverage_percentage%)"

    # Check if coverage meets minimum threshold
    if (( $(echo "$coverage_ratio >= $MIN_COVERAGE_RATIO" | bc -l 2>/dev/null || echo "0") )); then
        log_success "Test coverage ratio meets minimum threshold (≥50%)"
        return 0
    else
        log_failure "Test coverage ratio below minimum threshold (≥50%)"
        return 1
    fi
}

check_code_complexity() {
    log_check "Analyzing code complexity"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would analyze function length (≤50 lines) and nesting depth"
        log_success "Code complexity check (dry-run)"
        return 0
    fi

    local complexity_issues=0
    local max_function_length=50

    # Check function length in various languages
    # Python functions
    if find "$PROJECT_DIR" -name "*.py" -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null | head -1 >/dev/null; then
        while IFS= read -r -d '' file; do
            if [ -f "$file" ]; then
                local long_functions=$(awk '
                    /^def / {
                        start=NR; name=$2; in_function=1; brace_count=0
                    }
                    in_function && /^[[:space:]]*def / && NR > start {
                        if(NR-start > '$max_function_length') print "Function " name " at line " start " (" (NR-start) " lines)"
                        start=NR; name=$2
                    }
                    in_function && /^[^[:space:]]/ && !/^def / {
                        if(NR-start > '$max_function_length') print "Function " name " at line " start " (" (NR-start) " lines)"
                        in_function=0
                    }
                    END {
                        if(in_function && NR-start > '$max_function_length') print "Function " name " at line " start " (" (NR-start) " lines)"
                    }
                ' "$file" 2>/dev/null)

                if [ -n "$long_functions" ]; then
                    if [ "$VERBOSE" = true ]; then
                        log_warning "Long functions in $file:"
                        echo "$long_functions" | while read -r line; do
                            echo "    $line"
                        done
                    fi
                    ((complexity_issues++))
                fi
            fi
        done < <(find "$PROJECT_DIR" -name "*.py" -not -path "*/.git/*" -not -path "*/node_modules/*" -print0 2>/dev/null)
    fi

    # JavaScript/TypeScript functions
    if find "$PROJECT_DIR" \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null | head -1 >/dev/null; then
        while IFS= read -r -d '' file; do
            if [ -f "$file" ]; then
                local long_functions=$(awk '
                    /function[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(/ ||
                    /[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*:[[:space:]]*function[[:space:]]*\(/ ||
                    /[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*=[[:space:]]*\([^)]*\)[[:space:]]*=>[[:space:]]*{/ ||
                    /[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*=[[:space:]]*function[[:space:]]*\(/ {
                        start=NR; in_function=1; brace_count=1
                    }
                    in_function && /{/ { brace_count++ }
                    in_function && /}/ {
                        brace_count--;
                        if(brace_count == 0) {
                            if(NR-start > '$max_function_length') print "Function at line " start " (" (NR-start) " lines)"
                            in_function=0
                        }
                    }
                ' "$file" 2>/dev/null)

                if [ -n "$long_functions" ]; then
                    if [ "$VERBOSE" = true ]; then
                        log_warning "Long functions in $file:"
                        echo "$long_functions" | while read -r line; do
                            echo "    $line"
                        done
                    fi
                    ((complexity_issues++))
                fi
            fi
        done < <(find "$PROJECT_DIR" \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) -not -path "*/.git/*" -not -path "*/node_modules/*" -print0 2>/dev/null)
    fi

    # Check for excessive nesting (more than 4 levels)
    local deep_nesting=$(find "$PROJECT_DIR" \( -name "*.py" -o -name "*.js" -o -name "*.ts" \) -not -path "*/.git/*" -not -path "*/node_modules/*" -exec grep -l "^[[:space:]]\{16,\}" {} \; 2>/dev/null | wc -l)

    if [ "$deep_nesting" -gt 0 ]; then
        log_warning "Files with deep nesting detected: $deep_nesting files"
        ((complexity_issues++))
    fi

    if [ $complexity_issues -eq 0 ]; then
        log_success "Code complexity check passed"
        return 0
    else
        log_failure "Code complexity issues detected ($complexity_issues issues)"
        return 1
    fi
}

check_test_execution() {
    log_check "Executing test suites"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would execute pytest, npm test, or other test runners found in project"
        log_success "Test execution (dry-run)"
        return 0
    fi

    local test_failures=0
    local tests_executed=false

    cd "$PROJECT_DIR"

    # Python tests with pytest
    if [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ] || find . -name "test_*.py" -o -name "*_test.py" | head -1 >/dev/null 2>&1; then
        log_info "Detected Python project, attempting to run tests..."
        tests_executed=true

        if command -v pytest &> /dev/null; then
            if ! pytest -v --tb=short -q 2>/dev/null; then
                log_warning "pytest found test failures"
                ((test_failures++))
            else
                log_info "Python tests passed"
            fi
        elif command -v python &> /dev/null; then
            if ! python -m pytest -v --tb=short -q 2>/dev/null; then
                if ! python -m unittest discover -s . -p "test_*.py" -q 2>/dev/null; then
                    log_warning "Python test execution failed or tests failed"
                    ((test_failures++))
                else
                    log_info "Python unittest tests passed"
                fi
            else
                log_info "Python pytest tests passed"
            fi
        else
            log_warning "Python not available, cannot run Python tests"
        fi
    fi

    # Node.js tests
    if [ -f "package.json" ]; then
        log_info "Detected Node.js project, attempting to run tests..."
        tests_executed=true

        if command -v npm &> /dev/null; then
            # Check if test script is defined
            if npm run | grep -q "test"; then
                if ! npm test 2>/dev/null; then
                    log_warning "npm test found test failures"
                    ((test_failures++))
                else
                    log_info "Node.js tests passed"
                fi
            else
                log_warning "No test script defined in package.json"
            fi
        else
            log_warning "npm not available, cannot run Node.js tests"
        fi
    fi

    # Go tests
    if [ -f "go.mod" ] || find . -name "*.go" | head -1 >/dev/null 2>&1; then
        log_info "Detected Go project, attempting to run tests..."
        tests_executed=true

        if command -v go &> /dev/null; then
            if ! go test ./... 2>/dev/null; then
                log_warning "Go tests failed"
                ((test_failures++))
            else
                log_info "Go tests passed"
            fi
        else
            log_warning "Go not available, cannot run Go tests"
        fi
    fi

    cd - > /dev/null

    if [ "$tests_executed" = false ]; then
        log_warning "No recognized test framework found"
        log_success "Test execution (no tests to run)"
        return 0
    fi

    if [ $test_failures -eq 0 ]; then
        log_success "All test executions passed"
        return 0
    else
        log_failure "Test execution failures detected ($test_failures test suites failed)"
        return 1
    fi
}

check_documentation_quality() {
    log_check "Checking documentation quality"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would check for README, API docs, and code comments"
        log_success "Documentation quality check (dry-run)"
        return 0
    fi

    local doc_issues=0

    # Check for README file
    if ! find "$PROJECT_DIR" -maxdepth 1 -iname "readme*" | head -1 >/dev/null 2>&1; then
        log_warning "No README file found"
        ((doc_issues++))
    else
        log_info "README file found"
    fi

    # Check for API documentation
    local has_api_docs=false
    if find "$PROJECT_DIR" -name "*.md" -o -name "*.rst" -o -name "docs" -type d | grep -i -E "(api|doc)" >/dev/null 2>&1; then
        has_api_docs=true
        log_info "API documentation found"
    fi

    # Check comment density in source files
    local commented_files=0
    local total_source_files=0

    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            ((total_source_files++))
            local total_lines=$(wc -l < "$file")
            local comment_lines=0

            # Count comments based on file type
            case "$file" in
                *.py)
                    comment_lines=$(grep -c "^[[:space:]]*#" "$file" 2>/dev/null || echo 0)
                    ;;
                *.js|*.ts|*.jsx|*.tsx|*.java|*.go|*.cpp|*.c|*.cs)
                    comment_lines=$(grep -c "^[[:space:]]*\/\/" "$file" 2>/dev/null || echo 0)
                    ;;
            esac

            if [ "$total_lines" -gt 0 ] && [ "$comment_lines" -gt 0 ]; then
                local comment_ratio=$(echo "scale=2; $comment_lines / $total_lines" | bc -l 2>/dev/null || echo 0)
                if (( $(echo "$comment_ratio >= 0.05" | bc -l 2>/dev/null || echo 0) )); then
                    ((commented_files++))
                fi
            fi
        fi
    done < <(find "$PROJECT_DIR" \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.java" -o -name "*.go" -o -name "*.cpp" -o -name "*.c" -o -name "*.cs" \) -not -path "*/.git/*" -not -path "*/node_modules/*" -print0 2>/dev/null)

    if [ "$total_source_files" -gt 0 ]; then
        local comment_percentage=$(echo "scale=1; $commented_files * 100 / $total_source_files" | bc -l 2>/dev/null || echo 0)
        log_info "Files with comments: $commented_files/$total_source_files ($comment_percentage%)"

        if (( $(echo "$commented_files * 2 < $total_source_files" | bc -l 2>/dev/null || echo 1) )); then
            log_warning "Low comment density in source files"
            ((doc_issues++))
        fi
    fi

    if [ $doc_issues -eq 0 ]; then
        log_success "Documentation quality check passed"
        return 0
    else
        log_failure "Documentation quality issues detected ($doc_issues issues)"
        return 1
    fi
}

# Main execution
main() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local results_file="$RESULTS_DIR/quality-$timestamp.json"

    log_header "Quality Verification Pipeline"
    log_info "Project directory: $PROJECT_DIR"
    log_info "Dry run mode: $DRY_RUN"
    log_info "Results will be logged to: $results_file"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Running in dry-run mode - no actual quality analysis will be performed"
    fi

    echo ""

    # Run quality checks
    local check_results=()

    # Test coverage
    if check_test_coverage; then
        check_results+=("test_coverage:PASS")
    else
        check_results+=("test_coverage:FAIL")
    fi

    echo ""

    # Code complexity
    if check_code_complexity; then
        check_results+=("code_complexity:PASS")
    else
        check_results+=("code_complexity:FAIL")
    fi

    echo ""

    # Test execution
    if check_test_execution; then
        check_results+=("test_execution:PASS")
    else
        check_results+=("test_execution:FAIL")
    fi

    echo ""

    # Documentation quality
    if check_documentation_quality; then
        check_results+=("documentation_quality:PASS")
    else
        check_results+=("documentation_quality:FAIL")
    fi

    # Generate JSON results
    local overall_status="PASS"
    if [ $CHECKS_FAILED -gt 0 ]; then
        overall_status="FAIL"
    fi

    cat > "$results_file" << EOF
{
    "timestamp": "$timestamp",
    "pipeline": "quality",
    "project_directory": "$PROJECT_DIR",
    "dry_run": $DRY_RUN,
    "overall_status": "$overall_status",
    "summary": {
        "checks_run": $CHECKS_RUN,
        "checks_passed": $CHECKS_PASSED,
        "checks_failed": $CHECKS_FAILED
    },
    "checks": {
EOF

    local first=true
    for result in "${check_results[@]}"; do
        IFS=':' read -r check_name status <<< "$result"
        if [ "$first" = false ]; then
            echo "," >> "$results_file"
        fi
        echo "        \"$check_name\": \"$status\"" >> "$results_file"
        first=false
    done

    cat >> "$results_file" << EOF
    },
    "recommendations": [
        "Maintain test coverage ratio above 50%",
        "Keep functions under 50 lines and avoid deep nesting",
        "Run tests regularly and fix failures promptly",
        "Document APIs and maintain good comment density"
    ]
}
EOF

    # Final summary
    log_header "Quality Pipeline Summary"
    log_info "Total checks run: $CHECKS_RUN"
    log_info "Checks passed: $CHECKS_PASSED"
    log_info "Checks failed: $CHECKS_FAILED"

    if [ $CHECKS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}✓ All quality checks passed!${NC}"
        log_info "Results logged to: $results_file"
        exit 0
    else
        echo -e "\n${RED}✗ $CHECKS_FAILED quality check(s) failed${NC}"
        log_info "Results logged to: $results_file"
        exit 1
    fi
}

# Run main function
main "$@"