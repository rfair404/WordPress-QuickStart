#!/bin/bash

# WordPress QuickStart - Playwright Setup Script
# Streamlined installation and configuration of Playwright dependencies

set -euo pipefail

echo "🎭 WordPress QuickStart - Playwright Setup"
echo "=========================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
INSTALL_ALL_BROWSERS="${WQS_PLAYWRIGHT_ALL_BROWSERS:-0}"
INSTALL_DEPS="${WQS_PLAYWRIGHT_INSTALL_DEPS:-0}"  # Default to no system deps to avoid sudo issues
SKIP_CONFIRMATION="${WQS_AUTO:-0}"
USE_SUDO="${WQS_PLAYWRIGHT_USE_SUDO:-auto}"  # auto, yes, no

# Check if we're in the right directory
if [[ ! -f "package.json" ]] || [[ ! -f "tests/playwright.config.js" ]]; then
    echo -e "${RED}❌ Error: Must be run from project root directory${NC}" >&2
    exit 1
fi

# Check if npm is available
if ! command -v npm >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: npm is not installed or not in PATH${NC}" >&2
    exit 1
fi

# Function to run npm through Lando if available
run_npm() {
    if command -v lando >/dev/null 2>&1 && [[ -f ".lando.yml" ]]; then
        echo -e "${CYAN}🐳 Using Lando environment...${NC}"
        lando npm "$@"
    elif [[ -f "/c/Users/Reuseum/.lando/bin/lando.cmd" ]]; then
        echo -e "${CYAN}🐳 Using Lando environment (Windows)...${NC}"
        /c/Users/Reuseum/.lando/bin/lando.cmd npm "$@"
    else
        echo -e "${BLUE}📦 Using system npm...${NC}"
        npm "$@"
    fi
}

# Function to check if Playwright browsers are installed
check_playwright_installation() {
    echo -e "${BLUE}🔍 Checking Playwright installation...${NC}"
    
    if run_npm list @playwright/test >/dev/null 2>&1; then
        echo -e "${GREEN}✅ @playwright/test is installed${NC}"
        
        # Check if browsers are installed
        if run_npm run test:e2e -- --version >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Playwright CLI is working${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  Playwright is installed but browsers may be missing${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ @playwright/test is not installed${NC}"
        return 1
    fi
}

# Function to check if sudo is available and needed
check_sudo_availability() {
    if [[ "$USE_SUDO" == "no" ]] || [[ "$INSTALL_DEPS" == "0" ]]; then
        return 1  # Don't use sudo
    fi
    
    if [[ "$USE_SUDO" == "yes" ]]; then
        return 0  # Force use sudo
    fi
    
    # Auto-detect: check if sudo is available
    if command -v sudo >/dev/null 2>&1; then
        return 0  # Use sudo
    else
        echo -e "${YELLOW}⚠️  sudo not available, installing without system dependencies${NC}"
        return 1  # Don't use sudo
    fi
}

# Function to install Playwright browsers
install_playwright_browsers() {
    echo -e "${BLUE}📦 Installing Playwright browsers...${NC}"
    
    if [[ "$INSTALL_ALL_BROWSERS" == "1" ]]; then
        echo -e "${CYAN}🌐 Installing all browsers (Chrome, Firefox, Safari)...${NC}"
        if [[ "$INSTALL_DEPS" == "1" ]] && check_sudo_availability; then
            echo -e "${YELLOW}🔒 Installing with system dependencies (requires sudo)...${NC}"
            run_npm run test:e2e:install:ci
        else
            echo -e "${CYAN}📦 Installing browsers only (no system dependencies)...${NC}"
            run_npm run test:e2e:install:ci:nodeps
        fi
    else
        echo -e "${CYAN}🔥 Installing Chromium only (recommended for development)...${NC}"
        if [[ "$INSTALL_DEPS" == "1" ]] && check_sudo_availability; then
            echo -e "${YELLOW}🔒 Installing with system dependencies (requires sudo)...${NC}"
            run_npm run test:e2e:install:chromium:deps
        else
            echo -e "${CYAN}📦 Installing Chromium only (no system dependencies)...${NC}"
            run_npm run test:e2e:install:chromium
        fi
    fi
}

# Function to verify installation
verify_installation() {
    echo -e "${BLUE}🧪 Verifying Playwright installation...${NC}"
    
    # Run the basic smoke test
    if run_npm run test:e2e:smoke >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Playwright is working correctly!${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Playwright installed but test verification failed${NC}"
        echo -e "${CYAN}💡 This might be normal if WordPress isn't running${NC}"
        return 1
    fi
}

# Function to show usage information
show_usage() {
    echo ""
    echo -e "${BLUE}📖 Usage Examples:${NC}"
    echo ""
    echo "  Basic setup (Chromium only):"
    echo "    ./scripts/setup/playwright-setup.sh"
    echo "    npm run test:e2e:setup"
    echo ""
    echo "  Full setup (all browsers):"
    echo "    WQS_PLAYWRIGHT_ALL_BROWSERS=1 ./scripts/setup/playwright-setup.sh"
    echo "    npm run setup:ci"
    echo ""
    echo "  Running tests:"
    echo "    npm run test:e2e:smoke        # Quick smoke test"
    echo "    npm run test:e2e              # All tests"
    echo "    npm run test:e2e:headed       # With browser UI"
    echo "    npm run test:e2e:debug        # Debug mode"
    echo ""
    echo "  Environment variables:"
    echo "    WQS_PLAYWRIGHT_ALL_BROWSERS=1  # Install all browsers"
    echo "    WQS_PLAYWRIGHT_INSTALL_DEPS=1  # Install system dependencies (requires sudo)"
    echo "    WQS_PLAYWRIGHT_USE_SUDO=yes    # Force use of sudo (auto/yes/no)"
    echo "    WQS_AUTO=1                     # Skip confirmations"
}

# Main execution
main() {
    echo ""
    
    # Show current configuration
    echo -e "${CYAN}Configuration:${NC}"
    echo "  Install all browsers: $([[ "$INSTALL_ALL_BROWSERS" == "1" ]] && echo "Yes" || echo "No (Chromium only)")"
    echo "  Install system deps:  $([[ "$INSTALL_DEPS" == "1" ]] && echo "Yes (requires sudo)" || echo "No (browsers only)")"
    echo "  Use sudo:            ${USE_SUDO}"
    echo "  Auto mode:           $([[ "$SKIP_CONFIRMATION" == "1" ]] && echo "Yes" || echo "No")"
    echo ""
    
    # Check current installation
    if check_playwright_installation; then
        echo -e "${GREEN}✅ Playwright appears to be already set up${NC}"
        
        if [[ "$SKIP_CONFIRMATION" != "1" ]]; then
            echo ""
            read -p "Do you want to reinstall/update browsers? (y/N): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${BLUE}ℹ️  Skipping installation${NC}"
                show_usage
                exit 0
            fi
        fi
    fi
    
    # Install browsers
    echo ""
    if install_playwright_browsers; then
        echo -e "${GREEN}✅ Browser installation completed${NC}"
    else
        echo -e "${RED}❌ Browser installation failed${NC}" >&2
        exit 1
    fi
    
    # Verify installation
    echo ""
    verify_installation
    
    # Show usage information
    show_usage
    
    echo ""
    echo -e "${GREEN}🎉 Playwright setup completed successfully!${NC}"
    echo ""
    echo -e "${CYAN}💡 Next steps:${NC}"
    echo "  1. Start your WordPress site: ${YELLOW}lando start${NC}"
    echo "  2. Run smoke tests: ${YELLOW}npm run test:e2e:smoke${NC}"
    echo "  3. Develop E2E tests in: ${YELLOW}tests/e2e/${NC}"
}

# Run main function
main "$@"