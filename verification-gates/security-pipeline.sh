#!/bin/bash

# Security Verification Pipeline
# Implements OWASP LLM Top 10 security checks, secrets detection, and dependency vulnerability scanning

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
    echo "Security verification pipeline for agentic development"
    echo ""
    echo "Options:"
    echo "  --dry-run              Show what would be checked without running"
    echo "  --project-dir <path>   Directory to scan (default: current directory)"
    echo "  --verbose              Enable verbose output"
    echo "  --help                 Show this help message"
    echo ""
    echo "Exit codes:"
    echo "  0  All security checks passed"
    echo "  1  One or more security checks failed"
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

# Security check functions
check_secrets_detection() {
    log_check "Scanning for secrets and sensitive data"

    local secrets_found=false
    local secret_patterns=(
        "password\s*=\s*['\"][^'\"]{3,}['\"]"
        "api[_-]key\s*[=:]\s*['\"][^'\"]{10,}['\"]"
        "secret\s*[=:]\s*['\"][^'\"]{10,}['\"]"
        "token\s*[=:]\s*['\"][^'\"]{10,}['\"]"
        "-----BEGIN.*PRIVATE.*KEY-----"
        "AKIA[0-9A-Z]{16}"
        "sk_live_[0-9a-zA-Z]{24,}"
        "xox[baprs]-[0-9a-zA-Z-]+"
    )

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would scan for secrets using patterns: password, api_key, secret, token, private keys"
        log_success "Secrets detection (dry-run)"
        return 0
    fi

    for pattern in "${secret_patterns[@]}"; do
        if grep -r -i -E "$pattern" "$PROJECT_DIR" \
           --exclude-dir=.git \
           --exclude-dir=node_modules \
           --exclude-dir=.env \
           --exclude="*.log" \
           --exclude="security-pipeline.sh" 2>/dev/null; then
            secrets_found=true
            break
        fi
    done

    if [ "$secrets_found" = true ]; then
        log_failure "Secrets or sensitive data detected in codebase"
        return 1
    else
        log_success "No secrets detected"
        return 0
    fi
}

check_dependency_vulnerabilities() {
    log_check "Checking dependency vulnerabilities"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would run npm audit, pip-audit, or equivalent dependency scanners"
        log_success "Dependency vulnerability check (dry-run)"
        return 0
    fi

    local vuln_found=false

    # Check Node.js dependencies
    if [ -f "$PROJECT_DIR/package.json" ]; then
        log_info "Found package.json, running npm audit..."
        if command -v npm &> /dev/null; then
            cd "$PROJECT_DIR"
            if ! npm audit --audit-level moderate 2>/dev/null; then
                log_warning "npm audit found vulnerabilities"
                vuln_found=true
            fi
            cd - > /dev/null
        else
            log_warning "npm not available, skipping Node.js dependency check"
        fi
    fi

    # Check Python dependencies
    if [ -f "$PROJECT_DIR/requirements.txt" ] || [ -f "$PROJECT_DIR/setup.py" ] || [ -f "$PROJECT_DIR/pyproject.toml" ]; then
        log_info "Found Python project files..."
        if command -v pip-audit &> /dev/null; then
            cd "$PROJECT_DIR"
            if ! pip-audit 2>/dev/null; then
                log_warning "pip-audit found vulnerabilities"
                vuln_found=true
            fi
            cd - > /dev/null
        else
            log_warning "pip-audit not available, skipping Python dependency check"
        fi
    fi

    if [ "$vuln_found" = true ]; then
        log_failure "Dependency vulnerabilities detected"
        return 1
    else
        log_success "No dependency vulnerabilities detected"
        return 0
    fi
}

check_owasp_llm_compliance() {
    log_check "OWASP LLM Top 10 compliance checks"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would check for prompt injection protection, output validation, and LLM-specific security patterns"
        log_success "OWASP LLM compliance check (dry-run)"
        return 0
    fi

    local compliance_issues=0

    # Check for prompt injection protection
    if grep -r -i "prompt\|llm\|ai" "$PROJECT_DIR" \
       --include="*.py" --include="*.js" --include="*.ts" \
       --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null | \
       grep -v -i "sanitiz\|validat\|escap\|filter" >/dev/null; then

        # Look for actual prompt handling without obvious sanitization
        local unsafe_patterns=(
            "user_input.*prompt"
            "request.*prompt"
            "\.format.*user"
            "f\".*{.*user"
        )

        for pattern in "${unsafe_patterns[@]}"; do
            if grep -r -i -E "$pattern" "$PROJECT_DIR" \
               --include="*.py" --include="*.js" --include="*.ts" \
               --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null; then
                log_warning "Potential prompt injection vulnerability detected"
                ((compliance_issues++))
                break
            fi
        done
    fi

    # Check for output validation
    if grep -r -i "response\|output\|result" "$PROJECT_DIR" \
       --include="*.py" --include="*.js" --include="*.ts" \
       --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null | \
       grep -v -i "validat\|sanitiz\|escap\|check" >/dev/null 2>&1; then

        if [ "$VERBOSE" = true ]; then
            log_info "Consider implementing output validation for LLM responses"
        fi
    fi

    # Check for API key exposure in LLM calls
    if grep -r -i -E "(openai|claude|gpt|llm).*api.*key" "$PROJECT_DIR" \
       --include="*.py" --include="*.js" --include="*.ts" \
       --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null; then
        log_warning "Potential API key exposure in LLM integration"
        ((compliance_issues++))
    fi

    if [ $compliance_issues -eq 0 ]; then
        log_success "OWASP LLM compliance checks passed"
        return 0
    else
        log_failure "OWASP LLM compliance issues detected ($compliance_issues issues)"
        return 1
    fi
}

check_file_permissions() {
    log_check "Checking file permissions and sensitive file exposure"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would check for overly permissive file permissions and exposed sensitive files"
        log_success "File permissions check (dry-run)"
        return 0
    fi

    local permission_issues=0

    # Check for world-writable files
    if find "$PROJECT_DIR" -type f -perm -002 2>/dev/null | grep -v "/tmp\|/var/tmp" | head -1 >/dev/null; then
        log_warning "World-writable files detected"
        ((permission_issues++))
    fi

    # Check for sensitive files in version control
    sensitive_files=(".env" ".env.local" "id_rsa" "id_dsa" "*.key" "*.pem")
    for file_pattern in "${sensitive_files[@]}"; do
        if find "$PROJECT_DIR" -name "$file_pattern" -not -path "*/.git/*" 2>/dev/null | head -1 >/dev/null; then
            log_warning "Potentially sensitive file detected: $file_pattern"
            ((permission_issues++))
        fi
    done

    if [ $permission_issues -eq 0 ]; then
        log_success "File permissions check passed"
        return 0
    else
        log_failure "File permission issues detected ($permission_issues issues)"
        return 1
    fi
}

# Main execution
main() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local results_file="$RESULTS_DIR/security-$timestamp.json"

    log_header "Security Verification Pipeline"
    log_info "Project directory: $PROJECT_DIR"
    log_info "Dry run mode: $DRY_RUN"
    log_info "Results will be logged to: $results_file"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Running in dry-run mode - no actual security scans will be performed"
    fi

    echo ""

    # Run security checks
    local check_results=()

    # Secrets detection
    if check_secrets_detection; then
        check_results+=("secrets_detection:PASS")
    else
        check_results+=("secrets_detection:FAIL")
    fi

    echo ""

    # Dependency vulnerabilities
    if check_dependency_vulnerabilities; then
        check_results+=("dependency_vulnerabilities:PASS")
    else
        check_results+=("dependency_vulnerabilities:FAIL")
    fi

    echo ""

    # OWASP LLM compliance
    if check_owasp_llm_compliance; then
        check_results+=("owasp_llm_compliance:PASS")
    else
        check_results+=("owasp_llm_compliance:FAIL")
    fi

    echo ""

    # File permissions
    if check_file_permissions; then
        check_results+=("file_permissions:PASS")
    else
        check_results+=("file_permissions:FAIL")
    fi

    # Generate JSON results
    local overall_status="PASS"
    if [ $CHECKS_FAILED -gt 0 ]; then
        overall_status="FAIL"
    fi

    cat > "$results_file" << EOF
{
    "timestamp": "$timestamp",
    "pipeline": "security",
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
        "Regularly update dependencies to fix security vulnerabilities",
        "Implement input validation and sanitization for LLM prompts",
        "Use environment variables for sensitive configuration",
        "Review file permissions and avoid committing sensitive files"
    ]
}
EOF

    # Final summary
    log_header "Security Pipeline Summary"
    log_info "Total checks run: $CHECKS_RUN"
    log_info "Checks passed: $CHECKS_PASSED"
    log_info "Checks failed: $CHECKS_FAILED"

    if [ $CHECKS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}✓ All security checks passed!${NC}"
        log_info "Results logged to: $results_file"
        exit 0
    else
        echo -e "\n${RED}✗ $CHECKS_FAILED security check(s) failed${NC}"
        log_info "Results logged to: $results_file"
        exit 1
    fi
}

# Run main function
main "$@"