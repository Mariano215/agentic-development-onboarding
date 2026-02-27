#!/bin/bash

# Deployment Verification Pipeline
# Implements deployment configuration, observability, and rollback capability checks

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
    echo "Deployment verification pipeline for agentic development"
    echo ""
    echo "Options:"
    echo "  --dry-run              Show what would be checked without running"
    echo "  --project-dir <path>   Directory to analyze (default: current directory)"
    echo "  --verbose              Enable verbose output"
    echo "  --help                 Show this help message"
    echo ""
    echo "Exit codes:"
    echo "  0  All deployment checks passed"
    echo "  1  One or more deployment checks failed"
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

# Deployment check functions
check_deployment_configuration() {
    log_check "Verifying deployment configuration"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would check for Dockerfile, docker-compose.yml, .env.example, and deployment manifests"
        log_success "Deployment configuration check (dry-run)"
        return 0
    fi

    local config_issues=0
    local deployment_configs=()

    # Check for Docker configuration
    if [ -f "$PROJECT_DIR/Dockerfile" ]; then
        deployment_configs+=("Dockerfile")
        log_info "Found Dockerfile"

        # Validate Dockerfile best practices
        if ! grep -q "^USER " "$PROJECT_DIR/Dockerfile" 2>/dev/null; then
            log_warning "Dockerfile doesn't specify non-root user"
            ((config_issues++))
        fi

        if ! grep -q "HEALTHCHECK" "$PROJECT_DIR/Dockerfile" 2>/dev/null; then
            log_warning "Dockerfile missing health check"
            ((config_issues++))
        fi
    fi

    # Check for docker-compose
    if [ -f "$PROJECT_DIR/docker-compose.yml" ] || [ -f "$PROJECT_DIR/docker-compose.yaml" ]; then
        deployment_configs+=("docker-compose")
        log_info "Found docker-compose configuration"
    fi

    # Check for Kubernetes manifests
    if find "$PROJECT_DIR" -name "*.yaml" -o -name "*.yml" | xargs grep -l "apiVersion\|kind:" 2>/dev/null | head -1 >/dev/null; then
        deployment_configs+=("Kubernetes")
        log_info "Found Kubernetes manifests"
    fi

    # Check for environment configuration
    if [ -f "$PROJECT_DIR/.env.example" ] || [ -f "$PROJECT_DIR/.env.template" ]; then
        deployment_configs+=("environment-template")
        log_info "Found environment configuration template"
    else
        log_warning "No .env.example or .env.template found"
        ((config_issues++))
    fi

    # Check for production configuration
    local prod_configs=("production.yml" "prod.yml" "production.json" "prod.json" "production.config.js")
    local has_prod_config=false
    for config in "${prod_configs[@]}"; do
        if [ -f "$PROJECT_DIR/$config" ]; then
            has_prod_config=true
            break
        fi
    done

    if [ "$has_prod_config" = false ]; then
        log_warning "No production-specific configuration found"
        ((config_issues++))
    fi

    # Check for deployment scripts or CI/CD configuration
    local cicd_files=(".github/workflows" ".gitlab-ci.yml" "Jenkinsfile" "azure-pipelines.yml" ".circleci" "deploy.sh")
    local has_cicd=false
    for cicd in "${cicd_files[@]}"; do
        if [ -e "$PROJECT_DIR/$cicd" ]; then
            has_cicd=true
            deployment_configs+=("CI/CD")
            log_info "Found CI/CD configuration: $cicd"
            break
        fi
    done

    if [ "$has_cicd" = false ]; then
        log_warning "No CI/CD configuration found"
        ((config_issues++))
    fi

    if [ ${#deployment_configs[@]} -eq 0 ]; then
        log_failure "No deployment configuration found"
        return 1
    elif [ $config_issues -gt 2 ]; then
        log_failure "Too many deployment configuration issues ($config_issues issues)"
        return 1
    else
        log_success "Deployment configuration check passed"
        return 0
    fi
}

check_health_endpoints() {
    log_check "Checking for health check endpoints"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would check for health check endpoints and monitoring endpoints"
        log_success "Health endpoints check (dry-run)"
        return 0
    fi

    local health_found=false

    # Check for health endpoints in various file types
    local health_patterns=(
        "/health"
        "/healthz"
        "/alive"
        "/ready"
        "/status"
        "health_check"
        "healthcheck"
    )

    for pattern in "${health_patterns[@]}"; do
        if grep -r -i "$pattern" "$PROJECT_DIR" \
           --include="*.py" --include="*.js" --include="*.ts" \
           --include="*.go" --include="*.java" --include="*.yaml" --include="*.yml" \
           --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null | head -1 >/dev/null; then
            health_found=true
            log_info "Health endpoint pattern found: $pattern"
            break
        fi
    done

    # Check for monitoring/metrics endpoints
    local metrics_patterns=(
        "/metrics"
        "/prometheus"
        "/monitoring"
        "metrics_endpoint"
    )

    local metrics_found=false
    for pattern in "${metrics_patterns[@]}"; do
        if grep -r -i "$pattern" "$PROJECT_DIR" \
           --include="*.py" --include="*.js" --include="*.ts" \
           --include="*.go" --include="*.java" --include="*.yaml" --include="*.yml" \
           --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null | head -1 >/dev/null; then
            metrics_found=true
            log_info "Metrics endpoint pattern found: $pattern"
            break
        fi
    done

    if [ "$health_found" = false ]; then
        log_failure "No health check endpoints detected"
        return 1
    else
        log_success "Health endpoints check passed"
        if [ "$metrics_found" = true ]; then
            log_info "Bonus: Metrics endpoints also found"
        fi
        return 0
    fi
}

check_observability_setup() {
    log_check "Verifying observability and monitoring setup"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would check for logging configuration, error handling, and monitoring setup"
        log_success "Observability setup check (dry-run)"
        return 0
    fi

    local observability_score=0
    local max_score=4

    # Check for structured logging
    local logging_patterns=(
        "logging.getLogger"
        "console.log"
        "log.info"
        "logger"
        "winston"
        "bunyan"
        "logrus"
        "zap"
    )

    local has_logging=false
    for pattern in "${logging_patterns[@]}"; do
        if grep -r "$pattern" "$PROJECT_DIR" \
           --include="*.py" --include="*.js" --include="*.ts" \
           --include="*.go" --include="*.java" \
           --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null | head -1 >/dev/null; then
            has_logging=true
            break
        fi
    done

    if [ "$has_logging" = true ]; then
        log_info "Logging implementation found"
        ((observability_score++))
    else
        log_warning "No logging implementation detected"
    fi

    # Check for error handling
    local error_patterns=(
        "try.*except"
        "try.*catch"
        "error"
        "exception"
        "panic"
        "recover"
    )

    local has_error_handling=false
    for pattern in "${error_patterns[@]}"; do
        if grep -r -i "$pattern" "$PROJECT_DIR" \
           --include="*.py" --include="*.js" --include="*.ts" \
           --include="*.go" --include="*.java" \
           --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null | head -5 | head -1 >/dev/null; then
            has_error_handling=true
            break
        fi
    done

    if [ "$has_error_handling" = true ]; then
        log_info "Error handling patterns found"
        ((observability_score++))
    else
        log_warning "No error handling patterns detected"
    fi

    # Check for monitoring/alerting configuration
    local monitoring_files=(
        "prometheus.yml"
        "grafana"
        "datadog"
        "newrelic"
        "sentry"
        "monitoring"
        "alerts"
    )

    local has_monitoring_config=false
    for mon_file in "${monitoring_files[@]}"; do
        if find "$PROJECT_DIR" -name "*$mon_file*" -o -path "*/$mon_file/*" | head -1 >/dev/null 2>&1; then
            has_monitoring_config=true
            log_info "Monitoring configuration found: $mon_file"
            break
        fi
    done

    if [ "$has_monitoring_config" = true ]; then
        ((observability_score++))
    else
        log_warning "No monitoring configuration found"
    fi

    # Check for tracing/debugging
    local tracing_patterns=(
        "trace"
        "span"
        "jaeger"
        "zipkin"
        "opentelemetry"
        "debug"
    )

    local has_tracing=false
    for pattern in "${tracing_patterns[@]}"; do
        if grep -r -i "$pattern" "$PROJECT_DIR" \
           --include="*.py" --include="*.js" --include="*.ts" \
           --include="*.go" --include="*.java" --include="*.yaml" --include="*.yml" \
           --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null | head -1 >/dev/null; then
            has_tracing=true
            log_info "Tracing/debugging setup found"
            break
        fi
    done

    if [ "$has_tracing" = true ]; then
        ((observability_score++))
    fi

    log_info "Observability score: $observability_score/$max_score"

    if [ $observability_score -ge 2 ]; then
        log_success "Observability setup check passed"
        return 0
    else
        log_failure "Insufficient observability setup (score: $observability_score/$max_score)"
        return 1
    fi
}

check_rollback_capability() {
    log_check "Verifying rollback and recovery capabilities"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would check for versioning, feature flags, and configuration management"
        log_success "Rollback capability check (dry-run)"
        return 0
    fi

    local rollback_score=0
    local max_score=3

    # Check for version management
    local version_files=("VERSION" "version.txt" "package.json" "setup.py" "go.mod" "pom.xml" "Cargo.toml")
    local has_versioning=false
    for version_file in "${version_files[@]}"; do
        if [ -f "$PROJECT_DIR/$version_file" ]; then
            has_versioning=true
            log_info "Version management found: $version_file"
            break
        fi
    done

    if [ "$has_versioning" = true ]; then
        ((rollback_score++))
    else
        log_warning "No version management detected"
    fi

    # Check for feature flags
    local feature_flag_patterns=(
        "feature_flag"
        "featureFlag"
        "toggle"
        "feature_toggle"
        "flag"
        "flipper"
        "unleash"
        "launchdarkly"
    )

    local has_feature_flags=false
    for pattern in "${feature_flag_patterns[@]}"; do
        if grep -r -i "$pattern" "$PROJECT_DIR" \
           --include="*.py" --include="*.js" --include="*.ts" \
           --include="*.go" --include="*.java" --include="*.yaml" --include="*.yml" \
           --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null | head -1 >/dev/null; then
            has_feature_flags=true
            log_info "Feature flag system detected"
            break
        fi
    done

    if [ "$has_feature_flags" = true ]; then
        ((rollback_score++))
    else
        log_warning "No feature flag system detected"
    fi

    # Check for configuration management
    local config_patterns=(
        "config"
        "settings"
        "environment"
        "ENV"
        "CONFIG"
    )

    local has_config_management=false
    local config_files=0

    for pattern in "${config_patterns[@]}"; do
        local count=$(find "$PROJECT_DIR" -name "*$pattern*" -type f \
                     -not -path "*/.git/*" \
                     -not -path "*/node_modules/*" \
                     2>/dev/null | wc -l)
        config_files=$((config_files + count))
    done

    if [ $config_files -gt 1 ]; then
        has_config_management=true
        log_info "Configuration management detected ($config_files config files)"
    else
        log_warning "Limited configuration management detected"
    fi

    if [ "$has_config_management" = true ]; then
        ((rollback_score++))
    fi

    # Check for backup/disaster recovery documentation
    if find "$PROJECT_DIR" -name "*.md" -o -name "*.rst" -o -name "*.txt" | \
       xargs grep -l -i "backup\|disaster\|recovery\|rollback" 2>/dev/null | head -1 >/dev/null; then
        log_info "Recovery documentation found"
    fi

    log_info "Rollback capability score: $rollback_score/$max_score"

    if [ $rollback_score -ge 2 ]; then
        log_success "Rollback capability check passed"
        return 0
    else
        log_failure "Insufficient rollback capabilities (score: $rollback_score/$max_score)"
        return 1
    fi
}

check_security_deployment() {
    log_check "Checking deployment security configuration"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Would check for security headers, HTTPS configuration, and secure defaults"
        log_success "Deployment security check (dry-run)"
        return 0
    fi

    local security_issues=0

    # Check for HTTPS/SSL configuration
    local https_patterns=(
        "https://"
        "ssl"
        "tls"
        "443"
        "certificate"
        "cert"
    )

    local has_https_config=false
    for pattern in "${https_patterns[@]}"; do
        if grep -r -i "$pattern" "$PROJECT_DIR" \
           --include="*.yaml" --include="*.yml" --include="*.json" \
           --include="*.py" --include="*.js" --include="*.ts" \
           --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null | head -1 >/dev/null; then
            has_https_config=true
            break
        fi
    done

    if [ "$has_https_config" = false ]; then
        log_warning "No HTTPS/SSL configuration detected"
        ((security_issues++))
    else
        log_info "HTTPS/SSL configuration found"
    fi

    # Check for security headers configuration
    local security_headers=(
        "X-Frame-Options"
        "X-Content-Type-Options"
        "X-XSS-Protection"
        "Strict-Transport-Security"
        "Content-Security-Policy"
        "helmet"
        "CORS"
    )

    local has_security_headers=false
    for header in "${security_headers[@]}"; do
        if grep -r -i "$header" "$PROJECT_DIR" \
           --include="*.py" --include="*.js" --include="*.ts" \
           --include="*.yaml" --include="*.yml" --include="*.json" \
           --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null | head -1 >/dev/null; then
            has_security_headers=true
            log_info "Security headers configuration found"
            break
        fi
    done

    if [ "$has_security_headers" = false ]; then
        log_warning "No security headers configuration detected"
        ((security_issues++))
    fi

    # Check for secure defaults
    if grep -r -i "debug.*true\|debug.*=.*1" "$PROJECT_DIR" \
       --include="*.py" --include="*.js" --include="*.ts" \
       --include="*.yaml" --include="*.yml" --include="*.json" \
       --exclude-dir=.git --exclude-dir=node_modules 2>/dev/null | head -1 >/dev/null; then
        log_warning "Debug mode potentially enabled in production configuration"
        ((security_issues++))
    fi

    if [ $security_issues -le 1 ]; then
        log_success "Deployment security check passed"
        return 0
    else
        log_failure "Deployment security issues detected ($security_issues issues)"
        return 1
    fi
}

# Main execution
main() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local results_file="$RESULTS_DIR/deployment-$timestamp.json"

    log_header "Deployment Verification Pipeline"
    log_info "Project directory: $PROJECT_DIR"
    log_info "Dry run mode: $DRY_RUN"
    log_info "Results will be logged to: $results_file"

    if [ "$DRY_RUN" = true ]; then
        log_dry_run "Running in dry-run mode - no actual deployment validation will be performed"
    fi

    echo ""

    # Run deployment checks
    local check_results=()

    # Deployment configuration
    if check_deployment_configuration; then
        check_results+=("deployment_configuration:PASS")
    else
        check_results+=("deployment_configuration:FAIL")
    fi

    echo ""

    # Health endpoints
    if check_health_endpoints; then
        check_results+=("health_endpoints:PASS")
    else
        check_results+=("health_endpoints:FAIL")
    fi

    echo ""

    # Observability setup
    if check_observability_setup; then
        check_results+=("observability_setup:PASS")
    else
        check_results+=("observability_setup:FAIL")
    fi

    echo ""

    # Rollback capability
    if check_rollback_capability; then
        check_results+=("rollback_capability:PASS")
    else
        check_results+=("rollback_capability:FAIL")
    fi

    echo ""

    # Security deployment
    if check_security_deployment; then
        check_results+=("security_deployment:PASS")
    else
        check_results+=("security_deployment:FAIL")
    fi

    # Generate JSON results
    local overall_status="PASS"
    if [ $CHECKS_FAILED -gt 0 ]; then
        overall_status="FAIL"
    fi

    cat > "$results_file" << EOF
{
    "timestamp": "$timestamp",
    "pipeline": "deployment",
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
        "Implement comprehensive health check endpoints",
        "Set up structured logging and monitoring",
        "Configure feature flags for safe rollbacks",
        "Enable HTTPS and security headers in production"
    ]
}
EOF

    # Final summary
    log_header "Deployment Pipeline Summary"
    log_info "Total checks run: $CHECKS_RUN"
    log_info "Checks passed: $CHECKS_PASSED"
    log_info "Checks failed: $CHECKS_FAILED"

    if [ $CHECKS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}✓ All deployment checks passed!${NC}"
        log_info "Results logged to: $results_file"
        exit 0
    else
        echo -e "\n${RED}✗ $CHECKS_FAILED deployment check(s) failed${NC}"
        log_info "Results logged to: $results_file"
        exit 1
    fi
}

# Run main function
main "$@"