#!/bin/bash

# Comprehensive Project Test Suite
# Tests all project functionality without requiring Docker/Lando

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${PURPLE}🔄 $1${NC}"
}

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper function to run tests
run_test() {
    local test_name="$1"
    local test_command="$2"

    echo -n "Testing: $test_name... "

    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        # Show error for debugging
        echo "    Debug: $test_command failed"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test project structure
test_project_structure() {
    log_step "Testing project structure..."

    run_test "composer.json exists" "[ -f 'composer.json' ]"
    run_test ".lando.yml exists" "[ -f '.lando.yml' ]"
    run_test "README.md exists" "[ -f 'README.md' ]"
    run_test ".gitignore exists" "[ -f '.gitignore' ]"
    run_test "package.json exists" "[ -f 'package.json' ]"

    run_test "scripts directory exists" "[ -d 'scripts' ]"
    run_test "src directory exists" "[ -d 'src' ]"
    run_test "tests directory exists" "[ -d 'tests' ]"
    run_test "docs directory exists" "[ -d 'docs' ]"
}

# Test script files
test_script_files() {
    log_step "Testing script files..."

    run_test "wp-manager.sh exists" "[ -f 'scripts/wp-manager.sh' ]"
    run_test "wp-manager.sh is executable" "[ -x 'scripts/wp-manager.sh' ]"
    run_test "wp-install.sh exists" "[ -f 'scripts/wp-install.sh' ]"
    run_test "wp-install.sh is executable" "[ -x 'scripts/wp-install.sh' ]"
    run_test "wp-config-generator.php exists" "[ -f 'scripts/wp-config-generator.php' ]"

    run_test "validate-wordpress-installation.sh exists" "[ -f 'tests/validation/validate-wordpress-installation.sh' ]"
    run_test "validate-wordpress-installation.sh is executable" "[ -x 'tests/validation/validate-wordpress-installation.sh' ]"
    run_test "test-wp-installation.sh exists" "[ -f 'tests/test-wp-installation.sh' ]"
    run_test "test-wp-installation.sh is executable" "[ -x 'tests/test-wp-installation.sh' ]"
    run_test "run-wordpress-tests.sh exists" "[ -f 'tests/runners/run-wordpress-tests.sh' ]"
    run_test "run-wordpress-tests.sh is executable" "[ -x 'tests/runners/run-wordpress-tests.sh' ]"
}

# Test script syntax
test_script_syntax() {
    log_step "Testing script syntax..."

    run_test "wp-manager.sh syntax" "bash -n scripts/wp-manager.sh"
    run_test "wp-install.sh syntax" "bash -n scripts/wp-install.sh"
    run_test "validate-wordpress-installation.sh syntax" "bash -n tests/validation/validate-wordpress-installation.sh"
    run_test "test-wp-installation.sh syntax" "bash -n tests/test-wp-installation.sh"
    run_test "run-wordpress-tests.sh syntax" "bash -n tests/runners/run-wordpress-tests.sh"
}

# Test configuration files
test_configuration_files() {
    log_step "Testing configuration files..."

    # Test JSON syntax
    if command -v python > /dev/null 2>&1; then
        run_test "composer.json syntax" "python -c 'import json; json.load(open(\"composer.json\"))'"
        run_test "package.json syntax" "python -c 'import json; json.load(open(\"package.json\"))'"
    else
        log_warning "Python not available, skipping JSON syntax tests"
    fi

    # Test basic file content
    run_test "composer.json has WordPress core" "grep -q 'johnpbloch/wordpress-core' composer.json"
    run_test "composer.json has WooCommerce" "grep -q 'wpackagist-plugin/woocommerce' composer.json"
    run_test "composer.json has custom installer paths" "grep -q 'custom/plugins' composer.json"

    run_test ".lando.yml has WordPress recipe" "grep -q 'recipe: wordpress' .lando.yml"
    run_test ".lando.yml has wp-cli tooling" "grep -q 'wp:' .lando.yml"
    run_test ".lando.yml has custom webroot" "grep -q 'webroot: wp' .lando.yml"
}

# Test WordPress manager commands
test_wp_manager_commands() {
    log_step "Testing wp-manager.sh commands..."

    # Test help command
    run_test "wp-manager.sh help works" "./scripts/wp-manager.sh help > /dev/null"
    run_test "wp-manager.sh shows install:full command" "./scripts/wp-manager.sh help | grep -q 'install:full'"

    # Test error handling
    run_test "wp-manager.sh handles invalid commands" "./scripts/wp-manager.sh invalid-command 2>&1 | grep -q 'Unknown command'"

    # Test status command (should show not installed)
    run_test "wp-manager.sh status shows not installed" "./scripts/wp-manager.sh status 2>&1 | grep -q 'not installed'"
}

# Test file permissions and structure
test_file_permissions() {
    log_step "Testing file permissions..."

    # All shell scripts should be executable
    for script in scripts/*.sh tests/*.sh; do
        if [ -f "$script" ]; then
            script_name=$(basename "$script")
            run_test "$script_name is executable" "[ -x '$script' ]"
        fi
    done

    # PHP files should be readable
    for php_file in scripts/*.php; do
        if [ -f "$php_file" ]; then
            php_name=$(basename "$php_file")
            run_test "$php_name is readable" "[ -r '$php_file' ]"
        fi
    done
}

# Test README content
test_documentation() {
    log_step "Testing documentation..."

    run_test "README has quick start section" "grep -q '### 🚀 Quick Start Commands' README.md"
    run_test "README has WordPress management section" "grep -q '### 🛠️ WordPress Installation Methods' README.md"
    run_test "README mentions install:full command" "grep -q 'install:full' README.md"
    run_test "README has custom directory documentation" "grep -q 'custom/' README.md"
    run_test "README has testing section" "grep -q 'WordPress Installation Testing' README.md"
}

# Test .gitignore patterns
test_gitignore() {
    log_step "Testing .gitignore patterns..."

    run_test ".gitignore ignores wp directory" "grep -q '/wp/' .gitignore"
    run_test ".gitignore ignores custom uploads" "grep -q 'custom/uploads/' .gitignore"
    run_test ".gitignore ignores custom cache" "grep -q 'custom/cache/' .gitignore"
    run_test ".gitignore ignores node_modules" "grep -q 'node_modules/' .gitignore"
    run_test ".gitignore ignores vendor" "grep -q '/vendor/' .gitignore"
}

# Test test files structure
test_test_structure() {
    log_step "Testing test files structure..."

    run_test "PHPUnit test files exist" "[ -f 'tests/unit/WordPressInstallationTest.php' ]"
    run_test "E2E test files exist" "[ -f 'tests/e2e/wordpress/installation.spec.js' ]"
    run_test "Playwright config exists" "[ -f 'tests/playwright.config.js' ]"
    run_test "Test bootstrap exists" "[ -f 'tests/bootstrap.php' ]"
}

# Test composer scripts
test_composer_scripts() {
    log_step "Testing composer scripts..."

    if [ -f "composer.json" ]; then
        run_test "composer.json has wp:install script" "grep -q 'wp:install' composer.json"
        run_test "composer.json has wp:install:full script" "grep -q 'wp:install:full' composer.json"
        run_test "composer.json has test:wordpress script" "grep -q 'test:wordpress' composer.json"
        run_test "composer.json has validate:wordpress script" "grep -q 'validate:wordpress' composer.json"
    fi
}

# Main test function
main() {
    echo -e "${BLUE}"
    echo "🧪 Comprehensive Project Test Suite"
    echo "===================================="
    echo -e "${NC}"
    echo "Testing WordPress Quickstart configuration..."
    echo ""

    # Run all test suites
    test_project_structure
    test_script_files
    test_script_syntax
    test_configuration_files
    test_wp_manager_commands
    test_file_permissions
    test_documentation
    test_gitignore
    test_test_structure
    test_composer_scripts

    # Final results
    echo ""
    echo "======================================"
    echo -e "${BLUE}Test Results Summary:${NC}"
    echo -e "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

    if [ $TESTS_FAILED -eq 0 ]; then
        echo ""
        echo -e "${GREEN}🎉 All tests passed! Project is properly configured.${NC}"
        echo ""
        echo "✅ Project structure is correct"
        echo "✅ All scripts are executable and syntactically valid"
        echo "✅ Configuration files are properly formatted"
        echo "✅ WordPress management commands are working"
        echo "✅ Documentation is complete"
        echo "✅ Testing infrastructure is in place"
        echo ""
        echo "Next steps:"
        echo "1. Run 'lando start' to start the development environment"
        echo "2. Run './scripts/wp-manager.sh install:full' for complete WordPress setup"
        echo "3. Visit https://wordpress-ecommerce-starter.lndo.site to see your site"
        exit 0
    else
        echo ""
        echo -e "${RED}❌ Some tests failed. Please review the issues above.${NC}"
        echo ""
        echo "Common fixes:"
        echo "1. Make sure all scripts have proper execute permissions"
        echo "2. Check file syntax for any errors"
        echo "3. Verify all required files are present"
        echo "4. Review configuration file formatting"
        exit 1
    fi
}

# Run main function
main "$@"
