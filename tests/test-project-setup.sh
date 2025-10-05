#!/bin/bash
# WordPress QuickStart - Project Setup Test
# This script validates the project structure and configuration

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Function to print colored output
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    if eval "$test_command" >/dev/null 2>&1; then
        log_success "$test_name"
        ((TESTS_PASSED++))
        return 0
    else
        log_error "$test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Function to test basic project structure
test_project_structure() {
    log_info "Testing project structure..."
    
    run_test "composer.json exists" "[ -f 'composer.json' ]"
    run_test "package.json exists" "[ -f 'package.json' ]"
    run_test "phpunit.xml exists" "[ -f '.config/testing/phpunit.xml' ]"
    run_test "README.md exists" "[ -f 'README.md' ]"
    run_test ".gitignore exists" "[ -f '.gitignore' ]"
    run_test "src/ directory exists" "[ -d 'src' ]"
    run_test "tests/ directory exists" "[ -d 'tests' ]"
    run_test "scripts/ directory exists" "[ -d 'scripts' ]"
    run_test ".github/workflows/ directory exists" "[ -d '.github/workflows' ]"
}

# Function to test WordPress structure
test_wordpress_structure() {
    log_info "Testing WordPress structure..."
    
    run_test "wp/ directory exists" "[ -d 'wp' ]"
    run_test "custom/ directory exists" "[ -d 'custom' ]"
    run_test "custom/plugins/ directory exists" "[ -d 'custom/plugins' ]"
    run_test "custom/themes/ directory exists" "[ -d 'custom/themes' ]"
    run_test "custom/uploads/ directory exists" "[ -d 'custom/uploads' ]"
}

# Function to test configuration files
test_configuration_files() {
    log_info "Testing configuration files..."
    
    run_test ".lando.yml exists" "[ -f '.lando.yml' ]"
    run_test "phpunit.xml configured correctly" "grep -q 'tests/unit/' .config/testing/phpunit.xml"
    run_test "composer.json has required scripts" "grep -q 'test:unit' composer.json"
    run_test "package.json has required scripts" "grep -q 'lint:js' package.json"
}

# Function to test scripts
test_scripts() {
    log_info "Testing scripts..."
    
    run_test "wp-config-generator.php exists" "[ -f 'scripts/wp-config-generator.php' ]"
    run_test "wp-manager.sh exists" "[ -f 'scripts/wp-manager.sh' ]"
    run_test "gh-wrapper.sh exists" "[ -f 'scripts/gh-wrapper.sh' ]"
    run_test "env-setup.sh exists" "[ -f 'scripts/setup/env-setup.sh' ]"
}

# Function to test linting configuration
test_linting_config() {
    log_info "Testing linting configuration..."
    
    run_test ".config/linting/phpcs.xml exists" "[ -f '.config/linting/phpcs.xml' ]"
    run_test ".config/linting/.eslintrc.js exists" "[ -f '.config/linting/.eslintrc.js' ]"
    run_test ".config/formatting/.prettierrc exists" "[ -f '.config/formatting/.prettierrc' ]"
    run_test ".markdownlint.json exists" "[ -f '.config/linting/.markdownlint.json' ]"
}

# Function to test GitHub workflows
test_github_workflows() {
    log_info "Testing GitHub workflows..."
    
    run_test "CI/CD workflow exists" "[ -f '.github/workflows/ci-cd.yml' ]"
    run_test "Pull request workflow exists" "[ -f '.github/workflows/pull-request.yml' ]"
    run_test "Pull request validation workflow exists" "[ -f '.github/workflows/pr-validation.yml' ]"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "🧪 WordPress QuickStart - Project Setup Test"
    echo "============================================"
    echo -e "${NC}"
    echo "Validating project structure and configuration..."
    echo ""

    # Run all test suites
    test_project_structure
    test_wordpress_structure
    test_configuration_files
    test_scripts
    test_linting_config
    test_github_workflows

    # Final results
    echo ""
    echo "=================================="
    echo "Test Results Summary:"
    echo "Tests Passed: $TESTS_PASSED"
    echo "Tests Failed: $TESTS_FAILED"

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✅ All project setup tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}❌ Some tests failed. Please check your project setup.${NC}"
        exit 1
    fi
}

# Run the main function
main "$@"