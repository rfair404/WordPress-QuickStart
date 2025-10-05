#!/bin/bash

# WordPress E-commerce Starter - Comprehensive Test Runner
# This script tests all setup scripts with various error tolerance and debugging modes

echo "🧪 WordPress E-commerce Starter - Comprehensive Test Runner"
echo "=========================================================="
echo "Includes: Setup Scripts, Unit Tests, E2E Tests with Playwright"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test result tracking
test_result() {
    local test_name="$1"
    local exit_code="$2"

    ((TOTAL_TESTS++))

    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}✅ PASS${NC} $test_name"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}❌ FAIL${NC} $test_name (exit code: $exit_code)"
        ((FAILED_TESTS++))
    fi
}

# Run test with timeout and capture exit code
run_test() {
    local test_name="$1"
    local test_command="$2"
    local timeout_seconds="${3:-10}"

    echo -e "${BLUE}[TEST]${NC} Running: $test_name"
    echo -e "${CYAN}[CMD]${NC} $test_command"

    # Run with timeout and capture exit code
    if timeout "$timeout_seconds" bash -c "$test_command" >/dev/null 2>&1; then
        test_result "$test_name" 0
    else
        local exit_code=$?
        test_result "$test_name" $exit_code
    fi

    echo ""
}

echo "🔍 Testing script syntax validation..."
echo "------------------------------------"

# Test 1: Syntax validation
run_test "install-lando-docker.sh syntax" "bash -n ./scripts/setup/install-lando-docker.sh" 5
run_test "env-setup.sh syntax" "bash -n ./scripts/setup/env-setup.sh" 5
run_test "test-setup.sh syntax" "bash -n ./scripts/setup/test-setup.sh" 5

echo "📚 Testing help functions..."
echo "----------------------------"

# Test 2: Help functions
run_test "install-lando-docker.sh help" "./scripts/setup/install-lando-docker.sh --help" 5
run_test "env-setup.sh help" "./scripts/setup/env-setup.sh --help" 5

echo "🔧 Testing regular automation mode..."
echo "------------------------------------"

# Test 3: Regular automation (should work)
run_test "install script - regular auto" "WQS_AUTO=1 WQS_INSTALL_DOCKER=0 WQS_INSTALL_LANDO=0 ./scripts/setup/install-lando-docker.sh" 15
run_test "env script - regular auto" "WQS_AUTO=1 WQS_SETUP_BASHRC=0 WQS_SETUP_VSCODE=0 ./scripts/setup/env-setup.sh" 10

echo "🤫 Testing quiet mode..."
echo "------------------------"

# Test 4: Quiet mode
run_test "install script - quiet mode" "WQS_AUTO=1 WQS_QUIET=1 WQS_INSTALL_DOCKER=0 WQS_INSTALL_LANDO=0 ./scripts/setup/install-lando-docker.sh" 15
run_test "env script - quiet mode" "WQS_AUTO=1 WQS_QUIET=1 WQS_SETUP_BASHRC=0 WQS_SETUP_VSCODE=0 ./scripts/setup/env-setup.sh" 10

echo "🐛 Testing debug mode..."
echo "------------------------"

# Test 5: Debug mode
run_test "install script - debug mode" "WQS_AUTO=1 WQS_DEBUG=1 WQS_INSTALL_DOCKER=0 WQS_INSTALL_LANDO=0 ./scripts/setup/install-lando-docker.sh" 15
run_test "env script - debug mode" "WQS_AUTO=1 WQS_DEBUG=1 WQS_SETUP_BASHRC=0 WQS_SETUP_VSCODE=0 ./scripts/setup/env-setup.sh" 10

echo "💪 Testing error tolerant mode..."
echo "---------------------------------"

# Test 6: Error tolerant mode
run_test "install script - error tolerant" "WQS_AUTO=1 WQS_ERROR_TOLERANT=1 WQS_INSTALL_DOCKER=0 WQS_INSTALL_LANDO=0 ./scripts/setup/install-lando-docker.sh" 15
run_test "env script - error tolerant" "WQS_AUTO=1 WQS_ERROR_TOLERANT=1 WQS_SETUP_BASHRC=0 WQS_SETUP_VSCODE=0 ./scripts/setup/env-setup.sh" 10

echo "🔍 Testing combined modes..."
echo "----------------------------"

# Test 7: Combined modes
run_test "install - quiet + debug + tolerant" "WQS_AUTO=1 WQS_QUIET=1 WQS_DEBUG=1 WQS_ERROR_TOLERANT=1 WQS_INSTALL_DOCKER=0 WQS_INSTALL_LANDO=0 ./scripts/setup/install-lando-docker.sh" 15
run_test "env - quiet + debug + tolerant" "WQS_AUTO=1 WQS_QUIET=1 WQS_DEBUG=1 WQS_ERROR_TOLERANT=1 WQS_SETUP_BASHRC=0 WQS_SETUP_VSCODE=0 ./scripts/setup/env-setup.sh" 10

# Run E2E Tests if Playwright is available
echo "🎭 Testing E2E with Playwright..."
echo "--------------------------------"

if command -v npx >/dev/null 2>&1 && [ -f "tests/playwright.config.js" ]; then
    # Install Playwright browsers if needed
    run_test "playwright browsers install" "npx playwright install chromium --with-deps" 30

    # Run Playwright tests (skip by default - requires running WordPress)
    if [[ "${WQS_RUN_E2E:-0}" == "1" ]]; then
            run_test "playwright e2e tests" "npx playwright test --config=tests/playwright.config.js --reporter=line" 120
    else
        echo "ℹ️  E2E tests available but skipped (set WQS_RUN_E2E=1 to run)"
        echo "   Make sure your WordPress site is running first:"
        echo "   lando start && WQS_RUN_E2E=1 ./scripts/setup/test-runner.sh"
    fi
else
    echo "ℹ️  Playwright E2E tests not available (install: npm install)"
fi

echo ""
echo "📊 Test Summary"
echo "==============="
echo -e "Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"

if [[ $FAILED_TESTS -eq 0 ]]; then
    echo -e "\n${GREEN}🎉 All tests passed!${NC}"
    echo ""
    echo "📖 Usage Examples:"
    echo "  Setup Tests:"
    echo "    Regular mode:     ./scripts/setup/install-lando-docker.sh"
    echo "    Automated:        WQS_AUTO=1 ./scripts/setup/install-lando-docker.sh"
    echo "    Quiet:            WQS_AUTO=1 WQS_QUIET=1 ./scripts/setup/install-lando-docker.sh"
    echo "    Debug:            WQS_AUTO=1 WQS_DEBUG=1 ./scripts/setup/install-lando-docker.sh"
    echo "    Error tolerant:   WQS_AUTO=1 WQS_ERROR_TOLERANT=1 ./scripts/setup/install-lando-docker.sh"
    echo ""
    echo "  E2E Tests:"
    echo "    npm run test:e2e                # Run all Playwright tests"
    echo "    npm run test:e2e:headed         # Run with browser UI"
    echo "    npm run test:e2e:debug          # Debug mode"
    echo "    npm run test:e2e:wordpress      # WordPress-only tests"
    echo "    (No storefront-specific E2E tests included by default)"
    echo ""
    echo "  Full Test Suite:"
    echo "    lando start && WQS_RUN_E2E=1 ./scripts/setup/test-runner.sh"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Check the output above for details.${NC}"
    exit 1
fi
