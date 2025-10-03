#!/bin/bash

# Test Suite Main Entry Point
# Provides easy access to all organized test scripts

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
    echo -e "${BLUE}WordPress Quickstart Test Suite${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "Usage: $0 <category> [script]"
    echo ""
    echo -e "${YELLOW}Categories:${NC}"
    echo ""
    echo -e "${GREEN}analysis${NC}     - Test analysis and coverage tools"
    echo -e "${GREEN}validation${NC}   - Environment and setup validation"
    echo -e "${GREEN}runners${NC}      - Test execution and runners"
    echo -e "${GREEN}integration${NC}  - Integration and workflow tests"
    echo -e "${GREEN}unit${NC}         - PHP unit tests (use: lando composer test)"
    echo -e "${GREEN}e2e${NC}          - End-to-end tests (use: lando npm test)"
    echo ""
    echo -e "${YELLOW}Available Scripts:${NC}"
    echo ""
    echo -e "${PURPLE}Analysis:${NC}"
    echo "  analyze-unit-tests    - Analyze PHP unit test structure and coverage"
    echo ""
    echo -e "${PURPLE}Validation:${NC}"
    echo "  validate-wordpress    - Validate WordPress installation"
    echo "  validate-woocommerce  - Validate WooCommerce setup"
    echo ""
    echo -e "${PURPLE}Runners:${NC}"
    echo "  run-unit-standalone   - Run PHPUnit tests standalone"
    echo "  run-wordpress-tests   - Run comprehensive WordPress test suite"
    echo ""
    echo -e "${PURPLE}Integration:${NC}"
    echo "  test-project-setup    - Test complete project functionality"
    echo "  test-wp-installation  - Test WordPress installation process"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0 analysis analyze-unit-tests"
    echo "  $0 validation validate-wordpress"
    echo "  $0 runners run-wordpress-tests"
    echo "  $0 integration test-project-setup"
    echo ""
    echo -e "${YELLOW}Quick Commands:${NC}"
    echo "  $0 all                - Run comprehensive test suite"
    echo "  $0 validate           - Run all validation scripts"
    echo "  $0 analyze            - Run all analysis scripts"
}

run_script() {
    local category="$1"
    local script="$2"
    local script_path=""

    case "$category" in
        "analysis")
            case "$script" in
                "analyze-unit-tests") script_path="$SCRIPT_DIR/analysis/analyze-unit-tests.sh" ;;
                *) echo -e "${RED}Unknown analysis script: $script${NC}"; exit 1 ;;
            esac
            ;;
        "validation")
            case "$script" in
                "validate-wordpress") script_path="$SCRIPT_DIR/validation/validate-wordpress-installation.sh" ;;
                "validate-woocommerce") script_path="$SCRIPT_DIR/validation/validate-woocommerce-setup.sh" ;;
                *) echo -e "${RED}Unknown validation script: $script${NC}"; exit 1 ;;
            esac
            ;;
        "runners")
            case "$script" in
                "run-unit-standalone") script_path="$SCRIPT_DIR/runners/run-unit-tests-standalone.sh" ;;
                "run-wordpress-tests") script_path="$SCRIPT_DIR/runners/run-wordpress-tests.sh" ;;
                *) echo -e "${RED}Unknown runner script: $script${NC}"; exit 1 ;;
            esac
            ;;
        "integration")
            case "$script" in
                "test-project-setup") script_path="$SCRIPT_DIR/integration/test-project-setup.sh" ;;
                "test-wp-installation") script_path="$SCRIPT_DIR/integration/test-wp-installation.sh" ;;
                *) echo -e "${RED}Unknown integration script: $script${NC}"; exit 1 ;;
            esac
            ;;
        *)
            echo -e "${RED}Unknown category: $category${NC}"
            exit 1
            ;;
    esac

    if [ ! -f "$script_path" ]; then
        echo -e "${RED}Script not found: $script_path${NC}"
        exit 1
    fi

    echo -e "${BLUE}Running: $script_path${NC}"
    bash "$script_path"
}

run_all_validation() {
    echo -e "${BLUE}Running all validation scripts...${NC}"
    run_script "validation" "validate-wordpress"
    echo ""
    run_script "validation" "validate-woocommerce"
}

run_all_analysis() {
    echo -e "${BLUE}Running all analysis scripts...${NC}"
    run_script "analysis" "analyze-unit-tests"
}

run_comprehensive_suite() {
    echo -e "${BLUE}Running comprehensive test suite...${NC}"
    # Run validation tests (CI-compatible)
    run_all_validation
    # Run analysis tests
    run_all_analysis
}

# Main logic
case "${1:-help}" in
    "help"|"-h"|"--help"|"")
        show_help
        ;;
    "all")
        run_comprehensive_suite
        ;;
    "validate")
        run_all_validation
        ;;
    "analyze")
        run_all_analysis
        ;;
    "analysis"|"validation"|"runners"|"integration")
        if [ $# -lt 2 ]; then
            echo -e "${RED}Error: Script name required for category '$1'${NC}"
            echo "Use '$0 help' to see available scripts."
            exit 1
        fi
        run_script "$1" "$2"
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "Use '$0 help' to see available commands."
        exit 1
        ;;
esac
