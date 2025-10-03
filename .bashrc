# WordPress Quickstart - Development Environment Configuration
# This .bashrc file sets up paths and aliases for the project

# ============================================================================
# Environment Variables
# ============================================================================

export WQS_PROJECT_ROOT="$(pwd)"

# Project structure paths
export WQS_SRC_DIR="$WQS_PROJECT_ROOT/src"
export WQS_TESTS_DIR="$WQS_PROJECT_ROOT/tests"
export WQS_SCRIPTS_DIR="$WQS_PROJECT_ROOT/scripts"
export WQS_CONFIG_DIR="$WQS_PROJECT_ROOT/.config"
export WQS_DOCS_DIR="$WQS_PROJECT_ROOT/docs"

# Add scripts to PATH
export PATH="$WQS_SCRIPTS_DIR:$WQS_SCRIPTS_DIR/setup:$PATH"

# ============================================================================
# Helper Functions
# ============================================================================

wqs_info() {
    echo "📊 WordPress QuickStart - Project Information"
    echo "=========================================="
    echo "📁 Project Root: $WQS_PROJECT_ROOT"
    echo "📦 Repository: $(basename "$(pwd)")"
    echo "🌍 Environment: Local Development"
    echo "🔍 Tools: Lando, Docker, WordPress, WooCommerce"
    echo "📄 PHP Files: $(find src/ -name '*.php' 2>/dev/null | wc -l)"
    echo "📦 Tests: $(find tests/ -name '*.php' 2>/dev/null | wc -l)"
    echo "📊 Current Status: Development Setup Complete"
}

wqs_setup() {
    echo "🚀 Running complete development setup..."
    echo "========================================="

    echo "🔍 Step 1: Installing development tools..."
    if command -v lando &> /dev/null; then
        echo "✅ Lando already installed"
    else
        echo "📦 Installing Lando and Docker..."
        ./scripts/setup/install-lando-docker.sh
    fi

    echo
    echo "🔍 Step 2: Setting up environment..."
    ./scripts/setup/env-setup.sh

    echo
    echo "🔍 Step 3: Running tests..."
    ./scripts/setup/test-setup.sh

    echo
    echo "✅ Development setup complete!"
    if command -v lando &> /dev/null; then
        wqs_info
    fi
}

wqs_test() {
    echo "🧪 Running all tests..."
    echo "======================="

    echo "🔍 Running PHP unit tests..."
    if command -v lando &> /dev/null; then
        lando composer test
    else
        composer test
    fi

    echo
    echo "🔍 Running JavaScript tests..."
    if command -v lando &> /dev/null; then
        lando npm test
    else
        npm test
    fi
}

wqs_clean() {
    echo "🧺 Cleaning development environment..."
    echo "==================================="

    echo "🗑️ Removing temporary files..."
    find . -name '.DS_Store' -delete 2>/dev/null || true
    find . -name 'Thumbs.db' -delete 2>/dev/null || true
    find . -name '*.log' -path './logs/*' -delete 2>/dev/null || true

    echo "🗑️ Cleaning Lando..."
    if command -v lando &> /dev/null; then
        lando poweroff
    fi

    echo "🗑️ Cleaning Composer cache..."
    if command -v composer &> /dev/null; then
        composer clear-cache
    fi

    echo "🗑️ Cleaning npm cache..."
    if command -v npm &> /dev/null; then
        npm cache clean --force
    fi

    echo "✅ Environment cleanup complete!"
}

wqs_help() {
    echo "📚 WordPress QuickStart - Available Commands"
    echo "==========================================="
    echo
    echo "  wqs_info          - Show project information"
    echo "  wqs_setup         - Complete development setup"
    echo "  wqs_test          - Run all tests"
    echo "  wqs_clean         - Clean development environment"
    echo "  wqs_help          - Show this help"
    echo
    echo "📁 Quick Navigation:"
    echo "  goto-src          - Go to src/ directory"
    echo "  goto-tests        - Go to tests/ directory"
    echo "  goto-scripts      - Go to scripts/ directory"
    echo "  goto-root         - Go to project root"
    echo
}

# ============================================================================
# Additional Environment Setup
# ============================================================================
export WQS_SRC_DIR="$WQS_PROJECT_ROOT/src"
export WQS_TESTS_DIR="$WQS_PROJECT_ROOT/tests"
export WQS_SCRIPTS_DIR="$WQS_PROJECT_ROOT/scripts"
export WQS_CONFIG_DIR="$WQS_PROJECT_ROOT/.config"
export WQS_DOCS_DIR="$WQS_PROJECT_ROOT/docs"

# Add project scripts to PATH
export PATH="$WQS_SCRIPTS_DIR:$WQS_SCRIPTS_DIR/setup:$PATH"

# Add Docker and Lando to PATH if not already available
if ! command -v docker &> /dev/null; then
    # Check common Docker installation paths
    if [ -f "/c/Program Files/Docker/Docker/resources/bin/docker.exe" ]; then
        export PATH="/c/Program Files/Docker/Docker/resources/bin:$PATH"
    elif [ -f "/c/Program Files/Docker/Docker/Docker Desktop.exe" ]; then
        export PATH="/c/Program Files/Docker/Docker:$PATH"
    fi
fi

# Add Lando to PATH with multiple fallback options
if ! command -v lando &> /dev/null; then
    # Primary: Check ~/.local/bin/lando.exe
    if [ -f "$HOME/.local/bin/lando.exe" ]; then
        export PATH="$HOME/.local/bin:$PATH"
        echo "Added Lando from ~/.local/bin to PATH"
    # Secondary: Check ~/.lando/bin/lando.cmd
    elif [ -f "$HOME/.lando/bin/lando.cmd" ]; then
        export PATH="$HOME/.lando/bin:$PATH"
        echo "Added Lando from ~/.lando/bin to PATH"
    # Tertiary: Check AppData/Local/Lando version
    elif [ -f "$HOME/AppData/Local/Lando/v3.25.6/lando.exe" ]; then
        export PATH="$HOME/AppData/Local/Lando/v3.25.6:$PATH"
        echo "Added Lando from AppData to PATH"
    fi
fi

# Create lando alias if the command still isn't available
if ! command -v lando &> /dev/null; then
    if [ -f "$HOME/.local/bin/lando.exe" ]; then
        alias lando="$HOME/.local/bin/lando.exe"
        echo "Created lando alias to ~/.local/bin/lando.exe"
    fi
fi

# WordPress development paths (when using Lando)
export WP_CONTENT_DIR="$WQS_PROJECT_ROOT/wp-content"
export WP_PLUGINS_DIR="$WP_CONTENT_DIR/plugins"
export WP_THEMES_DIR="$WP_CONTENT_DIR/themes"

# Node.js and npm configuration
export NODE_ENV="development"
export NPM_CONFIG_CACHE="$WQS_PROJECT_ROOT/.npm-cache"

# ============================================================================
# Development Tool Aliases
# ============================================================================

# Lando shortcuts
alias lando-start='lando start'
alias lando-stop='lando stop'
alias lando-restart='lando restart'
alias lando-rebuild='lando rebuild -y'
alias lando-info='lando info'
alias lando-logs='lando logs -f'
alias lando-status='lando list'
alias lando-version='lando version'

# Composer shortcuts (using Lando when available)
if command -v lando &> /dev/null && [ -f ".lando.yml" ]; then
    alias composer='lando composer'
    alias php='lando php'
    alias wp='lando wp'
    alias npm='lando npm'
    alias node='lando node'
    alias phpcs='lando phpcs'
    alias phpcbf='lando phpcbf'
    alias phpunit='lando composer test'
fi

# Development workflow aliases
alias dev-setup='composer dev:setup && npm install'
alias dev-test='composer test && npm test'
alias dev-lint='composer lint && npm run lint:js && npm run lint:css'
alias dev-fix='composer lint:fix && npm run lint:js:fix && npm run lint:css:fix'
alias dev-format='npm run format:all'
alias dev-build='npm run build'
alias dev-watch='npm run start'

# Git workflow aliases
alias git-hooks-setup='./scripts/setup/git-hooks.sh'
alias git-status='git status --short'
alias git-log-pretty='git log --oneline --graph --decorate --all'
alias git-branch-clean='git branch --merged | grep -v "\*\|main\|develop" | xargs -n 1 git branch -d'

# Testing aliases
alias test-all='composer analyze && npm test'
alias test-php='composer test:coverage-text'
alias test-js='npm test'
alias test-watch='npm run test:watch'
alias test-setup='./scripts/setup/test-setup.sh'

# File navigation aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Project-specific navigation
alias goto-src='cd $WQS_SRC_DIR'
alias goto-tests='cd $WQS_TESTS_DIR'
alias goto-scripts='cd $WQS_SCRIPTS_DIR'
alias goto-config='cd $WQS_CONFIG_DIR'
alias goto-docs='cd $WQS_DOCS_DIR'
alias goto-root='cd $WQS_PROJECT_ROOT'

# WordPress development aliases
alias wp-plugins='cd $WP_PLUGINS_DIR'
alias wp-themes='cd $WP_THEMES_DIR'
alias wp-uploads='cd $WP_CONTENT_DIR/uploads'

# ============================================================================
# Helper Functions
# ============================================================================

# Function to display project information
wqs_info() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 WordPress E-commerce Starter - Dev Environment"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📁 Project Root: $WQS_PROJECT_ROOT"
    echo "🐳 Lando Status: $(lando info --format json 2>/dev/null | jq -r '.[] | select(.service=="appserver") | .urls[0]' 2>/dev/null || echo 'Not running')"
    echo "🔧 Node Version: $(node --version 2>/dev/null || echo 'Not available')"
    echo "🐘 PHP Version: $(php --version 2>/dev/null | head -n1 || echo 'Not available')"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Function to run full development setup
wqs_setup() {
    echo "🔧 Setting up WordPress E-commerce Starter development environment..."

    # Check if Lando is available
    if command -v lando &> /dev/null && [ -f ".lando.yml" ]; then
        echo "📦 Starting Lando environment..."
        lando start

        echo "📋 Installing dependencies..."
        lando composer dev:setup
        lando npm install

        echo "🎣 Setting up git hooks..."
        ./scripts/setup/git-hooks.sh

        echo "✅ Development environment setup complete!"
        wqs_info
    else
        echo "❌ Lando not found. Please install Lando and Docker Desktop first."
        echo "📖 See README.md for installation instructions."
    fi
}

# Function to run all tests
wqs_test() {
    echo "🧪 Running all tests for WordPress E-commerce Starter..."

    echo "🔍 Running PHP tests..."
    composer test

    echo "🔍 Running JavaScript tests..."
    npm test

    echo "🔍 Running code analysis..."
    composer analyze

    echo "✅ All tests completed!"
}

# Function to clean development environment
wqs_clean() {
    echo "🧹 Cleaning WordPress E-commerce Starter development environment..."

    # Remove dependency directories
    rm -rf node_modules vendor coverage .npm-cache

    # Remove build artifacts
    rm -rf build dist

    # Remove logs
    rm -f *.log

    echo "✅ Development environment cleaned!"
}

# Function to show available commands
wqs_help() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    }

wqs_help() {
    echo "� WordPress QuickStart - Available Commands"
    echo "==========================================="
    echo
    echo "  wqs_info          - Show project information"
    echo "  wqs_setup         - Complete development setup"
    echo "  wqs_test          - Run all tests"
    echo "  wqs_clean         - Clean development environment"
    echo "  wqs_help          - Show this help"
}

# ============================================================================
# Prompt Customization
# ============================================================================

# Custom prompt with project information
if [ "$PS1" ]; then
    # Colors
    RED='\[\033[0;31m\]'
    GREEN='\[\033[0;32m\]'
    YELLOW='\[\033[1;33m\]'
    BLUE='\[\033[0;34m\]'
    PURPLE='\[\033[0;35m\]'
    CYAN='\[\033[0;36m\]'
    WHITE='\[\033[1;37m\]'
    RESET='\[\033[0m\]'

    # Function to get git branch
    git_branch() {
        git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }

    # Function to get Lando status
    lando_status() {
        if command -v lando &> /dev/null && [ -f ".lando.yml" ]; then
            if lando info &> /dev/null; then
                echo "🐳"
            else
                echo "💤"
            fi
        fi
    }

    # Set custom prompt
    PS1="${BLUE}[WES]${RESET} ${GREEN}\u@\h${RESET}:${CYAN}\w${RESET} ${YELLOW}\$(git_branch)${RESET} \$(lando_status) ${WHITE}\$${RESET} "
fi

# ============================================================================
# Auto-completion
# ============================================================================

# Enable bash completion for git (if available)
if [ -f /usr/share/bash-completion/completions/git ]; then
    source /usr/share/bash-completion/completions/git
fi

# Enable bash completion for npm (if available)
if command -v npm &> /dev/null; then
    source <(npm completion bash 2>/dev/null) 2>/dev/null
fi

# ============================================================================
# Welcome Message
# ============================================================================

# Show welcome message when starting new shell
if [ "$PS1" ]; then
    echo ""
    wqs_info
    echo ""
    echo "💡 Type 'wqs_help' to see available commands"
    echo "🚀 Type 'wqs_setup' to set up the development environment"
    echo ""
fi

# ============================================================================
# Local Customizations
# ============================================================================

# Source local .bashrc if it exists (for user-specific customizations)
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi
