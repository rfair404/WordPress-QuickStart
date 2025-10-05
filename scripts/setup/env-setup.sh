#!/bin/bash

# WordPress E-commerce Starter - Environment Setup Script
# This script sets up the development environment including .bashrc and VS Code workspace

# Automated mode: Set WQS_AUTO=1 to skip interactive prompts
# Control variables:
#   WQS_SETUP_BASHRC=1/0 (default: 1)
#   WQS_SETUP_VSCOD    if [[ "${WQS_AUTO:-0}" == "1" ]]; then
        if [[ "${WQS_SETUP_VSCODE:-1}" == "1" ]]; then
            echo "🔧 Automated mode: Setting up VS Code workspace (WQS_SETUP_VSCODE=1)"
            setup_vscode
        else
            echo "⏭️  Automated mode: Skipping VS Code workspace setup (WQS_SETUP_VSCODE=0)"(default: 1)

# Error handling and debugging options
DEBUG_MODE="${WQS_DEBUG:-0}"
ERROR_TOLERANT="${WQS_ERROR_TOLERANT:-0}"

# Set appropriate error handling based on mode
if [[ "$ERROR_TOLERANT" == "1" ]]; then
    set -uo pipefail  # Don't exit on errors
else
    #!/bin/bash

# Enhanced Environment Setup Script
# Configures development environment with dependency validation

set -euo pipefail

# Source Lando wrapper to ensure availability
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/lando-wrapper.sh" ]]; then
    source "$SCRIPT_DIR/lando-wrapper.sh" >/dev/null 2>&1 || true
fi  # Exit on errors (default)
fi

# Debug function
debug() {
    if [[ "$DEBUG_MODE" == "1" ]]; then
        echo -e "\033[0;36m[DEBUG]\033[0m $1" >&2
    fi
}

# Error handler
handle_error() {
    local exit_code=$?
    local line_number=$1
    echo -e "\033[0;31m[ERROR]\033[0m Script failed at line $line_number with exit code $exit_code" >&2
    if [[ "$DEBUG_MODE" == "1" ]]; then
        echo -e "\033[0;36m[DEBUG]\033[0m Call stack:" >&2
        local frame=0
        while caller $frame >&2; do
            ((frame++))
        done
    fi
    if [[ "$ERROR_TOLERANT" != "1" ]]; then
        exit $exit_code
    fi
}

# Set up error trap
trap 'handle_error $LINENO' ERR

# Usage function
show_usage() {
    echo "🔧 WordPress E-commerce Starter - Environment Setup"
    echo "=================================================="
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Interactive Mode (default):"
    echo "  ./scripts/setup/env-setup.sh"
    echo ""
    echo "Automated Mode (no prompts):"
    echo "  WQS_AUTO=1 ./scripts/setup/env-setup.sh"
    echo ""
    echo "Environment Variables:"
    echo "  WQS_AUTO=1           Enable automated mode (no interactive prompts)"
    echo "  WQS_QUIET=1          Reduce output verbosity"
    echo "  WQS_DEBUG=1          Enable debug output for troubleshooting"
    echo "  WQS_ERROR_TOLERANT=1 Continue on errors instead of exiting"
    echo "  WQS_SETUP_BASHRC=1   Set up .bashrc environment (default: 1)"
    echo "  WQS_SETUP_VSCODE=1   Set up VS Code workspace (default: 1)"
    echo ""
    echo "Examples:"
    echo "  WQS_AUTO=1 $0                                    # Set up both with defaults"
    echo "  WQS_AUTO=1 WQS_SETUP_VSCODE=0 $0               # Only set up .bashrc"
    echo "  WQS_AUTO=1 WQS_SETUP_BASHRC=0 $0               # Only set up VS Code"
    echo ""
    exit 0
}

# Check for help flag
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    show_usage
fi

# Check for quiet mode
QUIET_MODE="${WQS_QUIET:-0}"

if [[ "$QUIET_MODE" != "1" ]]; then
    echo "🔧 Setting up WordPress E-commerce Starter environment..."
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Create symlink to .bashrc with error handling
setup_bashrc_link() {
    debug "Starting .bashrc setup"
    debug "PROJECT_ROOT: $PROJECT_ROOT"
    debug "Home directory: $HOME"

    if [ ! -f ~/.bashrc ] || [ -L ~/.bashrc ]; then
        [[ "$QUIET_MODE" != "1" ]] && echo "📋 Creating .bashrc symlink..."
        debug "Creating symlink from $PROJECT_ROOT/.bashrc to ~/.bashrc"

        if ln -sf "$PROJECT_ROOT/.bashrc" ~/.bashrc 2>/dev/null; then
            echo "✅ .bashrc symlink created"
            debug ".bashrc symlink created successfully"
        else
            if [[ "$ERROR_TOLERANT" == "1" ]]; then
                echo "⚠️  Could not create .bashrc symlink, but continuing..."
                debug "Symlink creation failed but error tolerant mode enabled"
            else
                echo "❌ Failed to create .bashrc symlink"
                debug "Symlink creation failed and error tolerant mode disabled"
                return 1
            fi
        fi
    else
        [[ "$QUIET_MODE" != "1" ]] && echo "📋 Adding source command to existing .bashrc..."
        debug "Existing .bashrc detected, checking for source command"

        if ! grep -q "source.*\.bashrc" ~/.bashrc 2>/dev/null; then
            debug "Adding source command to existing .bashrc"
            if {
                echo ""
                echo "# Source WordPress E-commerce Starter environment"
                echo "if [ -f \"$PROJECT_ROOT/.bashrc\" ]; then"
                echo "    source \"$PROJECT_ROOT/.bashrc\""
                echo "fi"
            } >> ~/.bashrc 2>/dev/null; then
                echo "✅ .bashrc configuration added"
                debug ".bashrc configuration added successfully"
            else
                if [[ "$ERROR_TOLERANT" == "1" ]]; then
                    echo "⚠️  Could not modify .bashrc, but continuing..."
                    debug ".bashrc modification failed but error tolerant mode enabled"
                else
                    echo "❌ Failed to modify .bashrc"
                    debug ".bashrc modification failed and error tolerant mode disabled"
                    return 1
                fi
            fi
        else
            echo "ℹ️  .bashrc already configured"
            debug ".bashrc already contains source command"
        fi
    fi
}

# Set up VS Code workspace with error handling
setup_vscode_workspace() {
    debug "Starting VS Code workspace setup"

    if [ ! -d ".vscode" ]; then
        debug "Creating .vscode directory"
        if ! mkdir -p .vscode 2>/dev/null; then
            if [[ "$ERROR_TOLERANT" == "1" ]]; then
                echo "⚠️  Could not create .vscode directory, but continuing..."
                debug ".vscode directory creation failed but error tolerant mode enabled"
                return 0
            else
                echo "❌ Failed to create .vscode directory"
                debug ".vscode directory creation failed and error tolerant mode disabled"
                return 1
            fi
        fi
    fi

    # Create workspace settings if they don't exist
    if [ ! -f ".vscode/settings.json" ]; then
        cat > .vscode/settings.json << 'EOF'
{
    "php.validate.executablePath": "",
    "php.suggest.basic": false,
    "editor.tabSize": 4,
    "editor.insertSpaces": true,
    "files.eol": "\n",
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "eslint.workingDirectories": ["."],
    "prettier.configPath": "${workspaceFolder}/.config/formatting/.prettierrc",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": true
    },
    "emmet.includeLanguages": {
        "php": "html"
    }
}
EOF
        echo "✅ VS Code workspace settings created"
    else
        echo "ℹ️  VS Code workspace settings already exist"
    fi

    # Create tasks.json for Lando integration
    if [ ! -f ".vscode/tasks.json" ]; then
        cat > .vscode/tasks.json << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Lando Start",
            "type": "shell",
            "command": "lando start",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Lando Stop",
            "type": "shell",
            "command": "lando stop",
            "group": "build"
        },
        {
            "label": "Run PHP Tests",
            "type": "shell",
            "command": "lando composer test",
            "group": "test"
        },
        {
            "label": "PHP Lint",
            "type": "shell",
            "command": "lando composer lint",
            "group": "build"
        },
        {
            "label": "Format Code",
            "type": "shell",
            "command": "lando npm run format:all",
            "group": "build"
        }
    ]
}
EOF
        echo "✅ VS Code tasks configuration created"
    else
        echo "ℹ️  VS Code tasks configuration already exists"
    fi
}

# Set up Git Bash profile (Windows-specific)
setup_git_bash_profile() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        # Windows with Git Bash
        PROFILE_PATH="$HOME/.bash_profile"

        if [ ! -f "$PROFILE_PATH" ]; then
            touch "$PROFILE_PATH"
        fi

        if ! grep -q "source.*\.bashrc" "$PROFILE_PATH"; then
            [[ "$QUIET_MODE" != "1" ]] && echo "📋 Setting up Git Bash profile..."
            echo "" >> "$PROFILE_PATH"
            echo "# Source WordPress E-commerce Starter environment" >> "$PROFILE_PATH"
            echo "if [ -f \"$PROJECT_ROOT/.bashrc\" ]; then" >> "$PROFILE_PATH"
            echo "    source \"$PROJECT_ROOT/.bashrc\"" >> "$PROFILE_PATH"
            echo "fi" >> "$PROFILE_PATH"
            echo "✅ Git Bash profile configured"
        else
            echo "ℹ️  Git Bash profile already configured"
        fi
    fi
}

# Main setup
main() {
    cd "$PROJECT_ROOT"

    if [[ "$QUIET_MODE" != "1" ]]; then
        echo "📁 Project root: $PROJECT_ROOT"
        echo ""
    fi

    # Offer to set up .bashrc
    if [[ "${WQS_AUTO:-0}" == "1" ]]; then
        if [[ "${WQS_SETUP_BASHRC:-1}" == "1" ]]; then
            echo "🔧 Automated mode: Setting up .bashrc environment (WQS_SETUP_BASHRC=1)"
            setup_bashrc_link
            setup_git_bash_profile
        else
            echo "⏭️  Automated mode: Skipping .bashrc setup (WQS_SETUP_BASHRC=0)"
        fi
    else
        echo "Would you like to set up the .bashrc environment? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            setup_bashrc_link
            setup_git_bash_profile
        fi
    fi

    # Offer to set up VS Code workspace
    if [[ "$QUIET_MODE" != "1" ]]; then
        echo ""
    fi

    if [[ "${WQS_AUTO:-0}" == "1" ]]; then
        if [[ "${WQS_SETUP_VSCODE:-1}" == "1" ]]; then
            echo "🔧 Automated mode: Setting up VS Code workspace (WQS_SETUP_VSCODE=1)"
            setup_vscode_workspace
        else
            echo "⏭️  Automated mode: Skipping VS Code workspace setup (WQS_SETUP_VSCODE=0)"
        fi
    else
        echo "Would you like to set up VS Code workspace settings? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            setup_vscode_workspace
        fi
    fi

    # Offer to set up GitHub CLI
    if [[ "$QUIET_MODE" != "1" ]]; then
        echo ""
    fi

    if [[ "${WQS_AUTO:-0}" == "1" ]]; then
        if [[ "${WQS_SETUP_GHCLI:-1}" == "1" ]]; then
            echo "🔧 Automated mode: Setting up GitHub CLI (WQS_SETUP_GHCLI=1)"
            ./scripts/setup/github-cli-setup.sh
        else
            echo "⏭️  Automated mode: Skipping GitHub CLI setup (WQS_SETUP_GHCLI=0)"
        fi
    else
        echo "Would you like to set up GitHub CLI for development workflow? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            bash "$PROJECT_ROOT/scripts/setup/github-cli-setup.sh"
        fi
    fi

    if [[ "$QUIET_MODE" != "1" ]]; then
        echo ""
        echo "🎉 Environment setup complete!"
        echo ""
        echo "Next steps:"
        echo "1. Restart your terminal or run: source ~/.bashrc"
        echo "2. Run: wqs_help (to see available commands)"
        echo "3. Run: wqs_setup (to set up the development environment)"
        echo "4. Open VS Code in this directory for enhanced experience"
        echo "5. If you installed GitHub CLI, run: gh auth login (if not done already)"
        echo ""
    fi
}

# Run main function
main "$@"
