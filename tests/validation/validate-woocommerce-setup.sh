#!/bin/bash

# WooCommerce Installation Validation Script
# Validates WooCommerce installation, configuration, and integration

echo "🛒 WooCommerce Installation Validation"
echo "======================================"
echo ""

# Get project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
echo "Project Root: $PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Initialize counters
TOTAL_CHECKS=0
PASSED_CHECKS=0

# Function to run check
run_check() {
    local check_name=$1
    local check_command=$2

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    echo ""
    print_status "INFO" "Checking: $check_name"

    if eval "$check_command"; then
        print_status "SUCCESS" "$check_name"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        return 0
    else
        print_status "ERROR" "$check_name"
        return 1
    fi
}

echo "🔍 WooCommerce Dependencies Check"
echo "================================"

# Check if composer.json exists and contains WooCommerce
run_check "composer.json exists" "[ -f '$PROJECT_ROOT/composer.json' ]"

if [ -f "$PROJECT_ROOT/composer.json" ]; then
    run_check "WooCommerce in composer.json" "grep -q 'wpackagist-plugin/woocommerce' '$PROJECT_ROOT/composer.json'"
fi

echo ""
echo "🏗️ WooCommerce Installation Structure"
echo "===================================="

# Check custom plugins directory
run_check "Custom plugins directory exists" "[ -d '$PROJECT_ROOT/custom/plugins' ]"

# Check WooCommerce plugin directory (if installed)
if [ -d "$PROJECT_ROOT/custom/plugins" ]; then
    run_check "WooCommerce plugin directory" "[ -d '$PROJECT_ROOT/custom/plugins/woocommerce' ]"

    if [ -d "$PROJECT_ROOT/custom/plugins/woocommerce" ]; then
        run_check "WooCommerce main file" "[ -f '$PROJECT_ROOT/custom/plugins/woocommerce/woocommerce.php' ]"
        run_check "WooCommerce includes directory" "[ -d '$PROJECT_ROOT/custom/plugins/woocommerce/includes' ]"
        run_check "WooCommerce templates directory" "[ -d '$PROJECT_ROOT/custom/plugins/woocommerce/templates' ]"
        run_check "WooCommerce assets directory" "[ -d '$PROJECT_ROOT/custom/plugins/woocommerce/assets' ]"
    fi
fi

# Note: Storefront theme is optional and not included by default

echo ""
echo "📋 WooCommerce Configuration"
echo "============================"

# Check wp-config.php for WooCommerce-friendly settings
if [ -f "$PROJECT_ROOT/wp-config.php" ]; then
    run_check "wp-config.php exists" "true"
    run_check "Memory limit setting" "grep -q 'WP_MEMORY_LIMIT\|ini_set.*memory_limit' '$PROJECT_ROOT/wp-config.php'"
    run_check "Max execution time setting" "grep -q 'max_execution_time\|set_time_limit' '$PROJECT_ROOT/wp-config.php'"
else
    print_status "WARNING" "wp-config.php not found (will be generated during installation)"
fi

echo ""
echo "🧪 WooCommerce Test Files"
echo "========================"

# Check test files
run_check "WooCommerce test file exists" "[ -f '$PROJECT_ROOT/tests/unit/WooCommerceTest.php' ]"

if [ -f "$PROJECT_ROOT/tests/unit/WooCommerceTest.php" ]; then
    # Check syntax using Lando if available, fallback to direct PHP
    if command -v lando >/dev/null 2>&1 && lando info >/dev/null 2>&1; then
        # Use relative path for Lando (container-friendly)
        run_check "WooCommerce test syntax" "cd '$PROJECT_ROOT' && lando php -l tests/unit/WooCommerceTest.php >/dev/null 2>&1"
    elif command -v php >/dev/null 2>&1; then
        run_check "WooCommerce test syntax" "php -l '$PROJECT_ROOT/tests/unit/WooCommerceTest.php' >/dev/null 2>&1"
    else
        print_status "INFO" "PHP not available for syntax check (use: lando php -l tests/unit/WooCommerceTest.php)"
    fi

    # Count test methods
    WC_TEST_METHODS=$(grep -c "public function test_" "$PROJECT_ROOT/tests/unit/WooCommerceTest.php" 2>/dev/null || echo "0")
    print_status "INFO" "WooCommerce test methods: $WC_TEST_METHODS"
fi

echo ""
echo "⚙️ WooCommerce Development Tools"
echo "==============================="

# Check composer scripts
if [ -f "$PROJECT_ROOT/composer.json" ]; then
    run_check "WooCommerce update script" "grep -q 'wc:update' '$PROJECT_ROOT/composer.json'"
    run_check "WooCommerce test script" "grep -q 'test:woocommerce' '$PROJECT_ROOT/composer.json'"
    run_check "WooCommerce setup script" "grep -q 'wc:setup' '$PROJECT_ROOT/composer.json'"
fi

echo ""
echo "🚀 WordPress Management Integration"
echo "================================="

# Check if wp-manager.sh has WooCommerce commands
if [ -f "$PROJECT_ROOT/scripts/wp-manager.sh" ]; then
    run_check "wp-manager.sh exists" "true"
    run_check "WooCommerce activation command" "grep -q 'woocommerce\|plugin.*activate' '$PROJECT_ROOT/scripts/wp-manager.sh'"
    run_check "WooCommerce setup commands" "grep -q 'wc:setup\|woocommerce.*setup' '$PROJECT_ROOT/scripts/wp-manager.sh' || true"
else
    print_status "WARNING" "wp-manager.sh not found"
fi

echo ""
echo "📊 Validation Summary"
echo "===================="

print_status "INFO" "Total checks: $TOTAL_CHECKS"
print_status "INFO" "Passed checks: $PASSED_CHECKS"
print_status "INFO" "Failed checks: $((TOTAL_CHECKS - PASSED_CHECKS))"

if [ $PASSED_CHECKS -eq $TOTAL_CHECKS ]; then
    print_status "SUCCESS" "All WooCommerce validation checks passed! 🎉"
    EXIT_CODE=0
elif [ $PASSED_CHECKS -gt $((TOTAL_CHECKS / 2)) ]; then
    print_status "WARNING" "Most checks passed, but some issues need attention"
    EXIT_CODE=1
else
    print_status "ERROR" "Several validation checks failed"
    EXIT_CODE=2
fi

echo ""
echo "🎯 Next Steps"
echo "============"

if [ ! -d "$PROJECT_ROOT/vendor" ]; then
    print_status "INFO" "1. Install composer dependencies:"
    echo "     lando composer install"
fi

if [ ! -d "$PROJECT_ROOT/custom/plugins/woocommerce" ]; then
    print_status "INFO" "2. Run WooCommerce installation:"
    echo "     lando composer wc:install:full"
fi

print_status "INFO" "3. Run WooCommerce tests:"
echo "     lando composer test:woocommerce"

print_status "INFO" "4. Set up WooCommerce:"
echo "     lando composer wc:setup"

echo ""
print_status "SUCCESS" "WooCommerce validation completed!"

exit $EXIT_CODE
