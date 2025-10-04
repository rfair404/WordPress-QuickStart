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
run_test "custom/themes directory exists" "[ -d '$PROJECT_ROOT/custom/themes' ]"

# Test 3: WordPress core files exist
run_test "wp-config.php exists" "[ -f '$WP_PATH/wp-config.php' ]"
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

# Test 6: WooCommerce plugin is installed
run_test "WooCommerce plugin installed" "[ -d '$PROJECT_ROOT/custom/plugins/woocommerce' ]"
run_test "WooCommerce main file exists" "[ -f '$PROJECT_ROOT/custom/plugins/woocommerce/woocommerce.php' ]"

# Test 7: Default theme is installed
run_test "Twenty Twenty-Four theme installed" "[ -d '$PROJECT_ROOT/custom/themes/twentytwentyfour' ]"
run_test "Theme style.css exists" "[ -f '$PROJECT_ROOT/custom/themes/twentytwentyfour/style.css' ]"

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

# Test 9: wp-config.php validation
if [ -f "$WP_PATH/wp-config.php" ]; then
    run_test "wp-config.php contains DB_NAME" "grep -q 'DB_NAME' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php contains DB_USER" "grep -q 'DB_USER' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php contains DB_HOST" "grep -q 'DB_HOST' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php contains WP_DEBUG" "grep -q 'WP_DEBUG' '$WP_PATH/wp-config.php'"

    # Check each security key individually
    run_test "wp-config.php contains AUTH_KEY" "grep -q 'AUTH_KEY' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php contains SECURE_AUTH_KEY" "grep -q 'SECURE_AUTH_KEY' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php contains LOGGED_IN_KEY" "grep -q 'LOGGED_IN_KEY' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php contains NONCE_KEY" "grep -q 'NONCE_KEY' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php contains AUTH_SALT" "grep -q 'AUTH_SALT' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php contains SECURE_AUTH_SALT" "grep -q 'SECURE_AUTH_SALT' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php contains LOGGED_IN_SALT" "grep -q 'LOGGED_IN_SALT' '$WP_PATH/wp-config.php'"
    run_test "wp-config.php contains NONCE_SALT" "grep -q 'NONCE_SALT' '$WP_PATH/wp-config.php'"

    run_test "wp-config.php references Lando database" "grep -q 'database' '$WP_PATH/wp-config.php'"
else
    echo -e "${YELLOW}⚠ wp-config.php not found - run './scripts/wp-manager.sh config:generate' first${NC}"
fi

# Test 10: Uploads directory
if [ ! -d "$PROJECT_ROOT/custom/uploads" ]; then
    mkdir -p "$PROJECT_ROOT/custom/uploads"
fi
run_test "custom/uploads directory writable" "[ -w '$PROJECT_ROOT/custom/uploads' ]"

# Test 11: Composer packages validation
if [ -f "$PROJECT_ROOT/composer.lock" ]; then
    run_test "WordPress core in composer.lock" "grep -q 'johnpbloch/wordpress-core' '$PROJECT_ROOT/composer.lock'"
    run_test "WooCommerce in composer.lock" "grep -q 'wpackagist-plugin/woocommerce' '$PROJECT_ROOT/composer.lock'"
    run_test "Twenty Twenty-Four in composer.lock" "grep -q 'wpackagist-theme/twentytwentyfour' '$PROJECT_ROOT/composer.lock'"
fi

# Test 12: Script utilities
run_test "wp-manager.sh script exists" "[ -f '$PROJECT_ROOT/scripts/wp-manager.sh' ]"
run_test "wp-manager.sh is executable" "[ -x '$PROJECT_ROOT/scripts/wp-manager.sh' ]"
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
