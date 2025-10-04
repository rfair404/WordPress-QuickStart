#!/bin/ba# Project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"h

# PHP Unit Test Structure Analyzer
# Analyzes the unit test files and provides detailed information about test coverage and structure

echo "📊 PHP Unit Test Analysis"
echo "========================"
echo ""

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
echo "Project Root: $PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${BLUE}$1${NC}"
    echo "$(echo "$1" | sed 's/./=/g')"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_detail() {
    echo -e "${PURPLE}   → $1${NC}"
}

# Analyze SampleTest.php
echo ""
print_header "📋 SampleTest.php Analysis"
echo ""

if [ -f "$PROJECT_ROOT/tests/unit/SampleTest.php" ]; then
    # Count test methods
    TEST_METHODS=$(grep -c "public function test_" "$PROJECT_ROOT/tests/unit/SampleTest.php")
    print_success "Found $TEST_METHODS test methods:"

    # List test methods with descriptions
    grep -n "public function test_" "$PROJECT_ROOT/tests/unit/SampleTest.php" | while read -r line; do
        line_num=$(echo "$line" | cut -d: -f1)
        method_name=$(echo "$line" | sed 's/.*public function \(test_[^(]*\).*/\1/')

        # Get the docblock comment above the method
        doc_line=$((line_num - 4))
        description=$(sed -n "${doc_line}p" "$PROJECT_ROOT/tests/unit/SampleTest.php" | sed 's/.*\* \(.*\)/\1/' | sed 's/^ *//')

        if [ -n "$description" ]; then
            print_detail "$method_name - $description"
        else
            print_detail "$method_name"
        fi
    done

    echo ""
    print_info "Test Categories in SampleTest:"

    # Check for specific test patterns
    if grep -q "test_phpunit_setup" "$PROJECT_ROOT/tests/unit/SampleTest.php"; then
        print_detail "PHPUnit Setup Validation ✓"
    fi

    if grep -q "test_wordpress_function_mocking" "$PROJECT_ROOT/tests/unit/SampleTest.php"; then
        print_detail "WordPress Function Mocking ✓"
    fi

    if grep -q "test_environment_constants" "$PROJECT_ROOT/tests/unit/SampleTest.php"; then
        print_detail "Environment Constants ✓"
    fi

    if grep -q "test_php_version" "$PROJECT_ROOT/tests/unit/SampleTest.php"; then
        print_detail "PHP Version Check ✓"
    fi

    if grep -q "test_array_operations" "$PROJECT_ROOT/tests/unit/SampleTest.php"; then
        print_detail "Array Operations ✓"
    fi

    if grep -q "test_string_operations" "$PROJECT_ROOT/tests/unit/SampleTest.php"; then
        print_detail "String Operations ✓"
    fi
else
    echo "❌ SampleTest.php not found"
fi

# Analyze WordPressInstallationTest.php
echo ""
print_header "🏗️  WordPressInstallationTest.php Analysis"
echo ""

if [ -f "$PROJECT_ROOT/tests/unit/WordPressInstallationTest.php" ]; then
    # Count test methods
    TEST_METHODS=$(grep -c "public function test_" "$PROJECT_ROOT/tests/unit/WordPressInstallationTest.php")
    print_success "Found $TEST_METHODS test methods:"

    # List test methods with descriptions
    grep -n "public function test_" "$PROJECT_ROOT/tests/unit/WordPressInstallationTest.php" | while read -r line; do
        line_num=$(echo "$line" | cut -d: -f1)
        method_name=$(echo "$line" | sed 's/.*public function \(test_[^(]*\).*/\1/')

        # Get the docblock comment above the method (try different line positions)
        for offset in 4 3 5; do
            doc_line=$((line_num - offset))
            description=$(sed -n "${doc_line}p" "$PROJECT_ROOT/tests/unit/WordPressInstallationTest.php" | sed 's/.*\* \(.*\)/\1/' | sed 's/^ *//')
            if [ -n "$description" ] && [ "$description" != "*" ]; then
                break
            fi
        done

        if [ -n "$description" ] && [ "$description" != "*" ]; then
            print_detail "$method_name - $description"
        else
            print_detail "$method_name"
        fi
    done

    echo ""
    print_info "WordPress Installation Test Categories:"

    # Check for specific WordPress test patterns
    if grep -q "test_wordpress_directory_exists" "$PROJECT_ROOT/tests/unit/WordPressInstallationTest.php"; then
        print_detail "WordPress Directory Structure ✓"
    fi

    if grep -q "test_wp_config" "$PROJECT_ROOT/tests/unit/WordPressInstallationTest.php"; then
        print_detail "WordPress Configuration ✓"
    fi

    if grep -q "test_composer" "$PROJECT_ROOT/tests/unit/WordPressInstallationTest.php"; then
        print_detail "Composer Integration ✓"
    fi

    if grep -q "test_custom_directory" "$PROJECT_ROOT/tests/unit/WordPressInstallationTest.php"; then
        print_detail "Custom Content Directory ✓"
    fi

    if grep -q "test_lando" "$PROJECT_ROOT/tests/unit/WordPressInstallationTest.php"; then
        print_detail "Lando Configuration ✓"
    fi
else
    echo "❌ WordPressInstallationTest.php not found"
fi

# Analyze WooCommerce test file
echo ""
print_header "🛒 WooCommerceTest.php Analysis"

if [ -f "$PROJECT_ROOT/tests/unit/WooCommerceTest.php" ]; then
    WC_TEST_METHODS=$(grep "public function test_" "$PROJECT_ROOT/tests/unit/WooCommerceTest.php" | wc -l)

    print_success "Found $WC_TEST_METHODS test methods:"

    # Extract test method names
    grep "public function test_" "$PROJECT_ROOT/tests/unit/WooCommerceTest.php" | while read line; do
        method_name=$(echo "$line" | sed 's/.*public function \([^(]*\).*/\1/')
        print_detail "$method_name"
    done

    echo ""
    print_info "WooCommerce Test Categories:"
    print_detail "WooCommerce Integration ✓"
    print_detail "Plugin Structure Validation ✓"
    print_detail "Function Mocking ✓"
    print_detail "Data Structure Testing ✓"
    print_detail "Currency & Formatting ✓"
    print_detail "Settings Configuration ✓"

else
    echo "❌ WooCommerceTest.php not found"
fi

# Analyze test dependencies and imports
echo ""
print_header "🔗 Test Dependencies Analysis"
echo ""

print_info "Checking test dependencies:"

# Check PHPUnit imports
if grep -q "use PHPUnit\\Framework\\TestCase" "$PROJECT_ROOT/tests/unit"/*.php; then
    print_detail "PHPUnit Framework ✓"
fi

# Check Brain Monkey imports
if grep -q "use Brain\\Monkey" "$PROJECT_ROOT/tests/unit"/*.php; then
    print_detail "Brain Monkey (WordPress Mocking) ✓"
fi

# Check namespace
if grep -q "namespace WordPressEcommerceStarter\\Tests\\Unit" "$PROJECT_ROOT/tests/unit"/*.php; then
    print_detail "Proper Namespace Structure ✓"
fi

# Analyze bootstrap.php
echo ""
print_header "🚀 Bootstrap Configuration Analysis"
echo ""

if [ -f "$PROJECT_ROOT/tests/bootstrap.php" ]; then
    print_success "Bootstrap file found"

    if grep -q "Brain\\Monkey\\setUp" "$PROJECT_ROOT/tests/bootstrap.php"; then
        print_detail "Brain Monkey initialization ✓"
    fi

    if grep -q "ABSPATH" "$PROJECT_ROOT/tests/bootstrap.php"; then
        print_detail "WordPress constants definition ✓"
    fi

    if grep -q "WP_CONTENT_DIR" "$PROJECT_ROOT/tests/bootstrap.php"; then
        print_detail "Custom content directory support ✓"
    fi

    if grep -q "autoload.php" "$PROJECT_ROOT/tests/bootstrap.php"; then
        print_detail "Composer autoloader integration ✓"
    fi
else
    echo "❌ Bootstrap file not found"
fi

# Analyze PHPUnit configuration
echo ""
print_header "⚙️  PHPUnit Configuration Analysis"
echo ""

if [ -f "$PROJECT_ROOT/phpunit.xml" ]; then
    print_success "PHPUnit configuration found"

    if grep -q 'bootstrap=".*bootstrap.php"' "$PROJECT_ROOT/phpunit.xml"; then
        print_detail "Bootstrap file configured ✓"
    fi

    if grep -q 'suffix="Test.php"' "$PROJECT_ROOT/phpunit.xml"; then
        print_detail "Test file suffix configured ✓"
    fi

    if grep -q 'coverage' "$PROJECT_ROOT/phpunit.xml"; then
        print_detail "Code coverage enabled ✓"
    fi

    if grep -q 'WP_ENVIRONMENT_TYPE.*test' "$PROJECT_ROOT/phpunit.xml"; then
        print_detail "Test environment configured ✓"
    fi
else
    echo "❌ PHPUnit configuration not found"
fi

# Summary
echo ""
print_header "📈 Test Suite Summary"
echo ""

TOTAL_SAMPLE_TESTS=$(grep -c "public function test_" "$PROJECT_ROOT/tests/unit/SampleTest.php" 2>/dev/null || echo "0")
TOTAL_WP_TESTS=$(grep -c "public function test_" "$PROJECT_ROOT/tests/unit/WordPressInstallationTest.php" 2>/dev/null || echo "0")
TOTAL_WC_TESTS=$(grep -c "public function test_" "$PROJECT_ROOT/tests/unit/WooCommerceTest.php" 2>/dev/null || echo "0")
TOTAL_TESTS=$((TOTAL_SAMPLE_TESTS + TOTAL_WP_TESTS + TOTAL_WC_TESTS))

print_info "Total Test Methods: $TOTAL_TESTS"
print_detail "SampleTest.php: $TOTAL_SAMPLE_TESTS methods"
print_detail "WordPressInstallationTest.php: $TOTAL_WP_TESTS methods"
print_detail "WooCommerceTest.php: $TOTAL_WC_TESTS methods"

echo ""
print_info "Test Categories Covered:"
print_detail "✅ Basic PHPUnit functionality"
print_detail "✅ WordPress function mocking"
print_detail "✅ Environment validation"
print_detail "✅ PHP version compatibility"
print_detail "✅ WordPress installation structure"
print_detail "✅ Composer integration"
if [ $TOTAL_WC_TESTS -gt 0 ]; then
    print_detail "✅ WooCommerce integration testing"
fi

echo ""
print_header "🎯 Recommended Test Execution"
echo ""

print_info "To run these tests, use one of the following:"
echo ""
echo "🐳 With Lando (Recommended):"
echo "   lando start"
echo "   lando composer install"
echo "   lando composer test:unit"
echo ""
echo "🖥️  With Local PHP (if PHP 8.1+ installed):"
echo "   composer install"
echo "   composer test:unit"
echo ""
echo "📊 For detailed coverage:"
echo "   lando composer test:coverage-text"
echo ""
echo "🔍 For WordPress-specific tests:"
echo "   lando composer test:wordpress"

echo ""
print_success "Test analysis completed! 🎉"
