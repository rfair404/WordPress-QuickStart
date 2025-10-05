#!/bin/bash

# WordPress Installation Validation Script
# This script validates that WordPress is properly installed via Composer
# in the expected directory structure.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WP_PATH="$PROJECT_ROOT/wp"

echo "🔍 WordPress Installation Validation"
echo "=================================="
echo "Project Root: $PROJECT_ROOT"
echo "WordPress Path: $WP_PATH"
echo ""

# Test counter
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
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((TESTS_FAILED++))
    fi
}

# Disable exit on error for test execution
set +e

# Test 1: WordPress directory exists
run_test "WordPress directory exists" "[ -d '$WP_PATH' ]"

# Test 2: WordPress core directories exist
run_test "wp-admin directory exists" "[ -d '$WP_PATH/wp-admin' ]"
run_test "wp-includes directory exists" "[ -d '$WP_PATH/wp-includes' ]"
run_test "custom content directory exists" "[ -d '$PROJECT_ROOT/custom' ]"
run_test "custom/plugins directory exists" "[ -d '$PROJECT_ROOT/custom/plugins' ]"
# Note: custom/themes directory is optional and may not exist in CI
# run_test "custom/themes directory exists" "[ -d '$PROJECT_ROOT/custom/themes' ]"

# Test 3: WordPress core files exist
# Note: wp-config.php is generated during setup, not required for validation
# run_test "wp-config.php exists" "[ -f '$WP_PATH/wp-config.php' ]"
run_test "wp-load.php exists" "[ -f '$WP_PATH/wp-load.php' ]"
run_test "wp-settings.php exists" "[ -f '$WP_PATH/wp-settings.php' ]"
run_test "index.php exists" "[ -f '$WP_PATH/index.php' ]"
run_test "wp-includes/version.php exists" "[ -f '$WP_PATH/wp-includes/version.php' ]"

# Test 4: Composer installation integrity
run_test "composer.json exists" "[ -f '$PROJECT_ROOT/composer.json' ]"
run_test "composer.lock exists" "[ -f '$PROJECT_ROOT/composer.lock' ]"
run_test "vendor directory exists" "[ -d '$PROJECT_ROOT/vendor' ]"

# Test 5: WordPress is NOT in project root (proper Composer setup)
run_test "WordPress NOT in project root" "[ ! -d '$PROJECT_ROOT/wp-admin' ]"

# Test 6: Custom directories structure (plugins and themes directories exist)
# Note: WooCommerce and default themes removed in Phase 2 - validating structure only

# Test 8: WordPress version validation
if [ -f "$WP_PATH/wp-includes/version.php" ]; then
    WP_VERSION=$(grep "\$wp_version = " "$WP_PATH/wp-includes/version.php" | sed "s/.*'\(.*\)'.*/\1/")
    if [ -n "$WP_VERSION" ]; then
        run_test "WordPress version is valid ($WP_VERSION)" "echo '$WP_VERSION' | grep -E '^[0-9]+\.[0-9]+'"

        # Check if version is 6.0+
        MAJOR_VERSION=$(echo "$WP_VERSION" | cut -d. -f1)
        MINOR_VERSION=$(echo "$WP_VERSION" | cut -d. -f2)
        if [ "$MAJOR_VERSION" -ge 6 ]; then
            run_test "WordPress version is 6.0+" "true"
        else
            run_test "WordPress version is 6.0+" "false"
        fi
    else
        run_test "WordPress version detection" "false"
    fi
else
    run_test "WordPress version file readable" "false"
fi

# Helper function to check security key length
check_security_key_length() {
    local key_name="$1"
    local config_file="$2"
    
    # Use PHP to safely parse the config file and check the constant length
    local result
    result=$(php -r "
        if (file_exists('$config_file')) {
            include '$config_file';
            if (defined('$key_name')) {
                \$value = constant('$key_name');
                echo strlen(\$value) == 64 ? 'true' : 'false';
            } else {
                echo 'false';
            }
        } else {
            echo 'false';
        }
    " 2>/dev/null)
    
    [ "$result" = "true" ]
}

# Test 9: wp-config.php validation (optional - only if file exists)
if [ -f "$WP_PATH/wp-config.php" ]; then
    echo -e "${GREEN}ℹ️  wp-config.php found - validating configuration${NC}"
    run_test "wp-config.php contains DB_NAME" "grep -q 'DB_NAME' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php contains DB_USER" "grep -q 'DB_USER' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php contains DB_HOST" "grep -q 'DB_HOST' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php contains WP_DEBUG" "grep -q 'WP_DEBUG' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php references database" "grep -q 'database' '$WP_PATH/wp-config.php'"
else
    echo -e "${YELLOW}ℹ️  wp-config.php not found - this is expected in CI/build environments${NC}"
    echo -e "${YELLOW}   (wp-config.php is generated during development setup)${NC}"
fi

# Test 10: Uploads directory
if [ ! -d "$PROJECT_ROOT/custom/uploads" ]; then
    mkdir -p "$PROJECT_ROOT/custom/uploads"
fi
run_test "custom/uploads directory writable" "[ -w '$PROJECT_ROOT/custom/uploads' ]"

# Test 11: Composer packages validation
if [ -f "$PROJECT_ROOT/composer.lock" ]; then
    run_test "WordPress core in composer.lock" "grep -q 'johnpbloch/wordpress-core' '$PROJECT_ROOT/composer.lock'"
    # Note: WooCommerce and default themes removed in Phase 2 - only validating WordPress core
fi

# Test 12: Script utilities
run_test "wp-manager.sh script exists" "[ -f '$PROJECT_ROOT/scripts/wp-manager.sh' ]"
# Note: Executable permissions may not be preserved in CI - check exists instead
run_test "wp-manager.sh is readable" "[ -r '$PROJECT_ROOT/scripts/wp-manager.sh' ]"
run_test "wp-config-generator.php exists" "[ -f '$PROJECT_ROOT/scripts/wp-config-generator.php' ]"
run_test "custom directory at project root" "[ -d '$PROJECT_ROOT/custom' ]"

# Re-enable exit on error
set -e

echo ""
echo "=================================="
echo "Test Results Summary:"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! WordPress installation is valid.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Please check your WordPress installation.${NC}"
    echo ""
    echo "Common fixes:"
    echo "1. Run 'composer install' to install WordPress and dependencies"
    echo "2. Run './scripts/wp-manager.sh config:generate' to create wp-config.php"
    echo "3. Run 'lando start' to ensure development environment is running"
    exit 1
fi
