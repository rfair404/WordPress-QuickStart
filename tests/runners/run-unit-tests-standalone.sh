#!/bin/bash

# Standalone Unit Test Runner
# This script attempts to run unit tests without requiring Lando to be running
# It provides validation and suggestions for proper test environment setup

echo "🧪 Standalone PHP Unit Test Validation"
echo "======================================"
echo ""

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

# Check if required files exist
echo "🔍 Checking Test Environment..."
echo ""

# Check test files
if [ -f "$PROJECT_ROOT/tests/unit/SampleTest.php" ]; then
    print_status "SUCCESS" "SampleTest.php found"
else
    print_status "ERROR" "SampleTest.php not found"
    exit 1
fi

if [ -f "$PROJECT_ROOT/tests/unit/WordPressInstallationTest.php" ]; then
    print_status "SUCCESS" "WordPressInstallationTest.php found"
else
    print_status "ERROR" "WordPressInstallationTest.php not found"
    exit 1
fi

# Check PHPUnit configuration
if [ -f "$PROJECT_ROOT/phpunit.xml" ]; then
    print_status "SUCCESS" "PHPUnit configuration found"
else
    print_status "ERROR" "PHPUnit configuration not found"
    exit 1
fi

# Check bootstrap file
if [ -f "$PROJECT_ROOT/tests/bootstrap.php" ]; then
    print_status "SUCCESS" "Bootstrap file found"
else
    print_status "ERROR" "Bootstrap file not found"
    exit 1
fi

# Check composer.json
if [ -f "$PROJECT_ROOT/composer.json" ]; then
    print_status "SUCCESS" "composer.json found"
else
    print_status "ERROR" "composer.json not found"
    exit 1
fi

echo ""
echo "🔧 Environment Check..."
echo ""

# Check for PHP
PHP_CMD=""
if command -v php &> /dev/null; then
    PHP_CMD="php"
    PHP_VERSION=$(php -v | head -n1)
    print_status "SUCCESS" "PHP found: $PHP_VERSION"
elif command -v php.exe &> /dev/null; then
    PHP_CMD="php.exe"
    PHP_VERSION=$(php.exe -v | head -n1)
    print_status "SUCCESS" "PHP found: $PHP_VERSION"
else
    print_status "ERROR" "PHP not found in PATH"
    echo ""
    print_status "INFO" "To run PHP unit tests, you need:"
    echo "  1. PHP 8.1+ installed and in PATH, OR"
    echo "  2. Lando running with 'lando start'"
    echo ""
    print_status "INFO" "If you have Lando, try:"
    echo "  lando composer install"
    echo "  lando composer test:unit"
    echo ""
    exit 1
fi

# Check for Composer
COMPOSER_CMD=""
if command -v composer &> /dev/null; then
    COMPOSER_CMD="composer"
    print_status "SUCCESS" "Composer found"
elif command -v composer.phar &> /dev/null; then
    COMPOSER_CMD="composer.phar"
    print_status "SUCCESS" "Composer found (phar)"
else
    print_status "WARNING" "Composer not found in PATH"
    print_status "INFO" "Using Lando is recommended for this project"
fi

# Check vendor directory (composer dependencies)
if [ -d "$PROJECT_ROOT/vendor" ]; then
    print_status "SUCCESS" "Vendor directory found (composer dependencies installed)"

    # Check for PHPUnit
    if [ -f "$PROJECT_ROOT/vendor/bin/phpunit" ]; then
        print_status "SUCCESS" "PHPUnit found in vendor/bin/"

        echo ""
        echo "🧪 Running Unit Tests..."
        echo ""

        # Try to run the tests
        cd "$PROJECT_ROOT"
        if [ -n "$PHP_CMD" ]; then
            echo "Running: $PHP_CMD vendor/bin/phpunit --configuration phpunit.xml tests/unit/"
            $PHP_CMD vendor/bin/phpunit --configuration phpunit.xml tests/unit/
            TEST_EXIT_CODE=$?

            echo ""
            if [ $TEST_EXIT_CODE -eq 0 ]; then
                print_status "SUCCESS" "All unit tests passed!"
            else
                print_status "ERROR" "Some unit tests failed (exit code: $TEST_EXIT_CODE)"
            fi
        fi
    else
        print_status "ERROR" "PHPUnit not found in vendor/bin/"
    fi
else
    print_status "WARNING" "Vendor directory not found (composer dependencies not installed)"
    echo ""
    print_status "INFO" "To install dependencies and run tests:"
    if [ -n "$COMPOSER_CMD" ]; then
        echo "  $COMPOSER_CMD install"
        echo "  $COMPOSER_CMD test:unit"
    else
        echo "  lando composer install"
        echo "  lando composer test:unit"
    fi
fi

echo ""
echo "📋 Test Files Validation..."
echo ""

# Validate PHP syntax of test files
for test_file in "$PROJECT_ROOT/tests/unit"/*.php; do
    if [ -f "$test_file" ]; then
        filename=$(basename "$test_file")
        if [ -n "$PHP_CMD" ]; then
            if $PHP_CMD -l "$test_file" >/dev/null 2>&1; then
                print_status "SUCCESS" "$filename syntax is valid"
            else
                print_status "ERROR" "$filename has syntax errors"
                $PHP_CMD -l "$test_file"
            fi
        else
            print_status "INFO" "$filename found (syntax check skipped - no PHP)"
        fi
    fi
done

echo ""
echo "📖 Test Summary..."
echo ""

# Count test methods
SAMPLE_TEST_METHODS=$(grep -c "public function test_" "$PROJECT_ROOT/tests/unit/SampleTest.php" 2>/dev/null || echo "0")
WP_TEST_METHODS=$(grep -c "public function test_" "$PROJECT_ROOT/tests/unit/WordPressInstallationTest.php" 2>/dev/null || echo "0")
TOTAL_TESTS=$((SAMPLE_TEST_METHODS + WP_TEST_METHODS))

print_status "INFO" "SampleTest.php: $SAMPLE_TEST_METHODS test methods"
print_status "INFO" "WordPressInstallationTest.php: $WP_TEST_METHODS test methods"
print_status "INFO" "Total test methods: $TOTAL_TESTS"

echo ""
echo "🎯 Next Steps..."
echo ""

if [ ! -d "$PROJECT_ROOT/vendor" ]; then
    print_status "INFO" "1. Install composer dependencies:"
    echo "     lando composer install"
    echo "     OR composer install (if you have PHP/Composer locally)"
fi

print_status "INFO" "2. Run the full test suite:"
echo "     lando composer test:unit"
echo "     OR composer test:unit (if you have PHP/Composer locally)"

print_status "INFO" "3. Run with coverage:"
echo "     lando composer test:coverage-text"

print_status "INFO" "4. Run WordPress-specific tests:"
echo "     lando composer test:wordpress"

echo ""
print_status "SUCCESS" "Test environment validation completed!"
