#!/bin/bash

# WordPress Quickstart - GitHub CLI Setup Script
# This script installs and configures GitHub CLI for development workflow

# Automated mode: Set WQS_AUTO=1 to skip interactive prompts
# Additional options:
#   WQS_INSTALL_GHCLI=1/0 (default: 1)
#   WQS_SETUP_AUTH=1/0 (default: 1)
#   WQS_QUIET=1/0 (default: 0)

# Set error handling
set -euo pipefail

# Configuration
INSTALL_GHCLI="${WQS_INSTALL_GHCLI:-1}"
SETUP_AUTH="${WQS_SETUP_AUTH:-1}"
AUTO_MODE="${WQS_AUTO:-0}"
QUIET_MODE="${WQS_QUIET:-0}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log() {
    if [[ "$QUIET_MODE" != "1" ]]; then
        echo -e "${GREEN}[INFO]${NC} $1"
    fi
}

warn() {
    if [[ "$QUIET_MODE" != "1" ]]; then
        echo -e "${YELLOW}[WARN]${NC} $1" >&2
    fi
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    if [[ "$QUIET_MODE" != "1" ]]; then
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    fi
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        echo "windows"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Function to check if GitHub CLI is installed
check_gh_cli() {
    if command -v gh &> /dev/null; then
        local version=$(gh --version | head -n1 | cut -d' ' -f3)
        log "GitHub CLI v$version is already installed"
        return 0
    else
        log "GitHub CLI is not installed"
        return 1
    fi
}

# Function to install GitHub CLI
install_gh_cli() {
    local os=$(detect_os)

    log "Installing GitHub CLI for $os..."

    case $os in
        "windows")
            if command -v winget &> /dev/null; then
                log "Using winget to install GitHub CLI..."
                winget install --id GitHub.cli --accept-package-agreements --accept-source-agreements
            else
                error "winget not available. Please install GitHub CLI manually from: https://cli.github.com/"
                return 1
            fi
            ;;
        "macos")
            if command -v brew &> /dev/null; then
                log "Using Homebrew to install GitHub CLI..."
                brew install gh
            else
                error "Homebrew not available. Please install GitHub CLI manually from: https://cli.github.com/"
                return 1
            fi
            ;;
        "linux")
            if command -v apt &> /dev/null; then
                log "Using apt to install GitHub CLI..."
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt update
                sudo apt install gh
            elif command -v yum &> /dev/null; then
                log "Using yum to install GitHub CLI..."
                sudo dnf install 'dnf-command(config-manager)'
                sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
                sudo dnf install gh
            else
                error "No suitable package manager found. Please install GitHub CLI manually from: https://cli.github.com/"
                return 1
            fi
            ;;
        *)
            error "Unsupported operating system: $os"
            error "Please install GitHub CLI manually from: https://cli.github.com/"
            return 1
            ;;
    esac

    # Verify installation
    if check_gh_cli; then
        success "GitHub CLI installed successfully!"
        return 0
    else
        error "GitHub CLI installation failed"
        return 1
    fi
}

# Function to setup GitHub CLI authentication
setup_gh_auth() {
    log "Setting up GitHub CLI authentication..."

    # Check if already authenticated
    if gh auth status &> /dev/null; then
        log "GitHub CLI is already authenticated"
        gh auth status
        return 0
    fi

    if [[ "$AUTO_MODE" == "1" ]]; then
        warn "Auto mode enabled but GitHub CLI authentication requires interactive setup"
        warn "Run 'gh auth login' manually after this script completes"
        return 0
    fi

    log "Starting GitHub CLI authentication process..."
    log "You'll be prompted to authenticate with GitHub"

    # Start authentication
    gh auth login

    # Verify authentication
    if gh auth status &> /dev/null; then
        success "GitHub CLI authentication successful!"
        return 0
    else
        error "GitHub CLI authentication failed"
        return 1
    fi
}

# Function to setup useful aliases
setup_gh_aliases() {
    log "Setting up GitHub CLI aliases..."

    # Create useful aliases for development workflow
    gh alias set actions 'run list --limit 10' 2>/dev/null || true
    gh alias set logs 'run view --log-failed' 2>/dev/null || true
    gh alias set latest 'run view $(gh run list --json databaseId --jq ".[0].databaseId")' 2>/dev/null || true
    gh alias set status 'run list --status' 2>/dev/null || true

    success "GitHub CLI aliases configured"
}

# Function to test GitHub CLI functionality
test_gh_cli() {
    log "Testing GitHub CLI functionality..."

    # Test basic commands
    if ! gh --version &> /dev/null; then
        error "GitHub CLI not working properly"
        return 1
    fi

    # Test repository access (if authenticated)
    if gh auth status &> /dev/null; then
        if gh repo view &> /dev/null; then
            log "GitHub CLI can access repository successfully"
        else
            warn "GitHub CLI installed but cannot access repository (this is normal if not in a repo directory)"
        fi
    else
        warn "GitHub CLI not authenticated - some features will be limited"
    fi

    success "GitHub CLI is working correctly"
}

# Main function
main() {
    log "Starting GitHub CLI setup for WordPress Quickstart..."

    # Check if already installed
    if check_gh_cli; then
        if [[ "$AUTO_MODE" != "1" ]]; then
            echo
            read -p "GitHub CLI is already installed. Do you want to reinstall it? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log "Skipping GitHub CLI installation"
                INSTALL_GHCLI=0
            fi
        else
            log "GitHub CLI already installed, skipping installation"
            INSTALL_GHCLI=0
        fi
    fi

    # Install GitHub CLI if needed
    if [[ "$INSTALL_GHCLI" == "1" ]]; then
        if ! install_gh_cli; then
            error "Failed to install GitHub CLI"
            exit 1
        fi
    fi

    # Setup authentication if requested
    if [[ "$SETUP_AUTH" == "1" ]]; then
        setup_gh_auth
    fi

    # Setup aliases
    setup_gh_aliases

    # Test functionality
    test_gh_cli

    # Show helpful information
    echo
    log "${CYAN}GitHub CLI Setup Complete!${NC}"
    echo
    log "Available commands:"
    log "  ${MAGENTA}gh --version${NC}           - Show GitHub CLI version"
    log "  ${MAGENTA}gh auth login${NC}          - Authenticate with GitHub"
    log "  ${MAGENTA}gh run list${NC}            - List recent workflow runs"
    log "  ${MAGENTA}gh run view --log-failed${NC} - View failed run logs"
    log "  ${MAGENTA}gh repo view${NC}           - View repository information"
    echo
    log "Composer shortcuts:"
    log "  ${MAGENTA}lando composer gh:check${NC}   - Check GitHub CLI status"
    log "  ${MAGENTA}lando composer gh:actions${NC} - List recent actions"
    log "  ${MAGENTA}lando composer gh:auth${NC}    - Check authentication status"
    echo
    log "npm shortcuts:"
    log "  ${MAGENTA}lando npm run gh:check${NC}        - Check GitHub CLI status"
    log "  ${MAGENTA}lando npm run gh:actions:latest${NC} - View latest run"
    log "  ${MAGENTA}lando npm run gh:actions:logs${NC}   - View latest run logs"
    echo

    success "GitHub CLI is ready for development workflow!"
}

# Show usage information
show_usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  --no-install            Skip GitHub CLI installation"
    echo "  --no-auth               Skip authentication setup"
    echo "  --auto                  Run in automated mode (no prompts)"
    echo "  --quiet                 Minimize output"
    echo
    echo "Environment variables:"
    echo "  WQS_AUTO=1              Enable automated mode"
    echo "  WQS_INSTALL_GHCLI=0     Skip installation"
    echo "  WQS_SETUP_AUTH=0        Skip authentication"
    echo "  WQS_QUIET=1             Enable quiet mode"
    echo
    echo "Examples:"
    echo "  $0                      # Interactive installation"
    echo "  $0 --auto --quiet       # Silent installation"
    echo "  WQS_AUTO=1 $0           # Automated installation"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        --no-install)
            INSTALL_GHCLI=0
            shift
            ;;
        --no-auth)
            SETUP_AUTH=0
            shift
            ;;
        --auto)
            AUTO_MODE=1
            shift
            ;;
        --quiet)
            QUIET_MODE=1
            shift
            ;;
        *)
            error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Run main function
main
