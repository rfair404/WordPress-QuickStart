#!/bin/bash

# WordPress Test Runner
# Comprehensive test suite for WordPress installation validation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}🧪 WordPress Installation Test Suite${NC}"
echo "=================================="
echo ""

# Function to run test suites
run_test_suite() {
    local suite_name="$1"
    local test_command="$2"

    echo -e "${BLUE}Running: $suite_name${NC}"
    echo "----------------------------------------"

    if eval "$test_command"; then
        echo -e "${GREEN}✅ $suite_name PASSED${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}❌ $suite_name FAILED${NC}"
        echo ""
        return 1
    fi
}

# Track test results
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=0

# Test Suite 1: Shell Script Validation
((TOTAL_SUITES++))
if run_test_suite "WordPress Installation Validation (Shell)" "bash tests/validation/validate-wordpress-installation.sh"; then
    ((PASSED_SUITES++))
else
    ((FAILED_SUITES++))
fi

# Test Suite 2: PHPUnit WordPress Tests
((TOTAL_SUITES++))
if run_test_suite "WordPress Installation Tests (PHPUnit)" "composer test:wp-unit"; then
    ((PASSED_SUITES++))
else
    ((FAILED_SUITES++))
fi

# Test Suite 3: Standard PHPUnit Tests
((TOTAL_SUITES++))
if run_test_suite "Standard Unit Tests (PHPUnit)" "composer test:unit"; then
    ((PASSED_SUITES++))
else
    ((FAILED_SUITES++))
fi

# Test Suite 4: Code Quality
((TOTAL_SUITES++))
if run_test_suite "Code Quality (PHPCS)" "composer lint:phpcs"; then
    ((PASSED_SUITES++))
else
    ((FAILED_SUITES++))
fi

# Optional: E2E Tests (if Playwright is available and Lando is running)
if command -v npm >/dev/null 2>&1 && [ -f "playwright.config.js" -o -f "tests/playwright.config.js" ]; then
    echo -e "${YELLOW}Checking if Lando is running for E2E tests...${NC}"

    if lando info >/dev/null 2>&1; then
        ((TOTAL_SUITES++))
        if run_test_suite "WordPress E2E Tests (Playwright)" "npm run test:e2e:wordpress"; then
            ((PASSED_SUITES++))
        else
            ((FAILED_SUITES++))
        fi
    else
        echo -e "${YELLOW}⚠ Skipping E2E tests - Lando not running${NC}"
        echo "Run 'lando start' to enable E2E tests"
        echo ""
    fi
else
    echo -e "${YELLOW}⚠ Skipping E2E tests - Playwright not configured${NC}"
    echo ""
fi

# Final Results
echo "=================================="
echo -e "${BLUE}Test Suite Results Summary:${NC}"
echo -e "Total Test Suites: $TOTAL_SUITES"
echo -e "Passed: ${GREEN}$PASSED_SUITES${NC}"
echo -e "Failed: ${RED}$FAILED_SUITES${NC}"

if [ $FAILED_SUITES -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 All test suites passed! WordPress installation is fully validated.${NC}"
    echo ""
    echo "Your WordPress installation is ready for development!"
    echo ""
    echo "Next steps:"
    echo "1. Run 'lando start' to start your development environment"
    echo "2. Visit your site to complete WordPress setup"
    echo "3. Begin developing your WordPress application"
    exit 0
else
    echo ""
    echo -e "${RED}❌ Some test suites failed. Please review the output above.${NC}"
    echo ""
    echo "Common fixes:"
    echo "1. Run 'composer install' to ensure all dependencies are installed"
    echo "2. Run './scripts/wp-manager.sh config:generate' to create wp-config.php"
    echo "3. Check that your .lando.yml configuration is correct"
    echo "4. Verify file permissions are correct"
    echo ""
    echo "For detailed help, see the README.md file."
    exit 1
fi
