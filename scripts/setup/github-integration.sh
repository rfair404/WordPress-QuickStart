#!/bin/bash

# GitHub Integration Setup Script for VS Code
# Enables GitHub Actions monitoring, Pull Requests, and repository integration

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${BLUE}🔗 GitHub Integration Setup for VS Code${NC}"
echo "========================================"
echo ""

# Function to check if VS Code is installed
check_vscode() {
    if command -v code >/dev/null 2>&1; then
        echo -e "${GREEN}✅ VS Code is installed${NC}"
        return 0
    else
        echo -e "${RED}❌ VS Code is not installed or 'code' command is not in PATH${NC}"
        echo ""
        echo "Please install VS Code and ensure the 'code' command is available:"
        echo "1. Download VS Code from https://code.visualstudio.com/"
        echo "2. During installation, check 'Add to PATH' option"
        echo "3. Or manually add VS Code to your PATH"
        echo ""
        return 1
    fi
}

# Function to install VS Code extension
install_extension() {
    local extension_id="$1"
    local extension_name="$2"
    
    echo -e "${BLUE}Installing ${extension_name}...${NC}"
    
    if code --install-extension "$extension_id" --force; then
        echo -e "${GREEN}✅ ${extension_name} installed successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to install ${extension_name}${NC}"
        return 1
    fi
}

# Function to check if extension is already installed
check_extension() {
    local extension_id="$1"
    
    if code --list-extensions | grep -q "^${extension_id}$"; then
        return 0
    else
        return 1
    fi
}

# Function to setup GitHub authentication
setup_github_auth() {
    echo -e "${BLUE}Setting up GitHub authentication...${NC}"
    echo ""
    echo "You'll need to authenticate with GitHub to access:"
    echo "• Repository information"
    echo "• GitHub Actions status"
    echo "• Pull Request management"
    echo "• Issue tracking"
    echo ""
    echo -e "${YELLOW}Authentication options:${NC}"
    echo "1. Personal Access Token (Classic)"
    echo "2. Fine-grained Personal Access Token"
    echo "3. GitHub CLI (gh) authentication"
    echo ""
    
    # Check if GitHub CLI is available
    if command -v gh >/dev/null 2>&1; then
        echo -e "${GREEN}✅ GitHub CLI (gh) is available${NC}"
        echo ""
        read -p "Use GitHub CLI for authentication? (y/n): " use_gh_cli
        
        if [[ "$use_gh_cli" =~ ^[Yy]$ ]]; then
            echo ""
            echo -e "${BLUE}Checking GitHub CLI authentication...${NC}"
            
            if gh auth status >/dev/null 2>&1; then
                echo -e "${GREEN}✅ Already authenticated with GitHub CLI${NC}"
            else
                echo -e "${YELLOW}⚠️  Not authenticated with GitHub CLI${NC}"
                echo "Run: gh auth login"
                echo ""
                read -p "Run GitHub CLI authentication now? (y/n): " run_gh_auth
                
                if [[ "$run_gh_auth" =~ ^[Yy]$ ]]; then
                    gh auth login
                fi
            fi
            return 0
        fi
    fi
    
    echo ""
    echo -e "${YELLOW}Manual Token Setup Instructions:${NC}"
    echo ""
    echo "1. Go to GitHub Settings > Developer settings > Personal access tokens"
    echo "   URL: https://github.com/settings/tokens"
    echo ""
    echo "2. Click 'Generate new token (classic)'"
    echo ""
    echo "3. Select these scopes:"
    echo "   ☑️  repo (Full control of private repositories)"
    echo "   ☑️  workflow (Update GitHub Action workflows)"
    echo "   ☑️  read:org (Read org and team membership)"
    echo "   ☑️  user:email (Access user email addresses)"
    echo ""
    echo "4. Copy the generated token"
    echo ""
    echo "5. In VS Code:"
    echo "   • Press Ctrl+Shift+P (Cmd+Shift+P on Mac)"
    echo "   • Type 'GitHub: Sign In'"
    echo "   • Select 'Use Personal Access Token'"
    echo "   • Paste your token"
    echo ""
}

# Function to configure VS Code settings for GitHub integration
configure_vscode_settings() {
    echo -e "${BLUE}Configuring VS Code settings for GitHub integration...${NC}"
    
    local vscode_settings_dir
    local settings_file
    
    # Determine VS Code settings directory based on OS
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        # Windows (Git Bash/MSYS2)
        vscode_settings_dir="$APPDATA/Code/User"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        vscode_settings_dir="$HOME/Library/Application Support/Code/User"
    else
        # Linux
        vscode_settings_dir="$HOME/.config/Code/User"
    fi
    
    settings_file="$vscode_settings_dir/settings.json"
    
    # Create settings directory if it doesn't exist
    mkdir -p "$vscode_settings_dir"
    
    # Create or update settings.json
    if [ ! -f "$settings_file" ]; then
        echo "{}" > "$settings_file"
    fi
    
    # Add GitHub-specific settings using a temporary Python script
    cat > /tmp/update_vscode_settings.py << 'EOF'
import json
import sys
import os

settings_file = sys.argv[1]

# Load existing settings
try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = {}

# Add GitHub integration settings
github_settings = {
    "github.gitAuthentication": True,
    "githubPullRequests.queries": [
        {
            "label": "Waiting For My Review",
            "query": "is:open is:pr review-requested:@me"
        },
        {
            "label": "Assigned To Me",
            "query": "is:open is:pr assignee:@me"
        },
        {
            "label": "Created By Me",
            "query": "is:open is:pr author:@me"
        }
    ],
    "githubActions.workflows.pinned.workflows": [".github/workflows/ci-cd.yml"],
    "githubActions.workflows.pinned.refresh.enabled": True,
    "githubActions.workflows.pinned.refresh.interval": 30,
    "git.enableStatusBarSync": True,
    "git.autofetch": True,
    "git.showProgress": True
}

# Merge settings
settings.update(github_settings)

# Write back to file
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("VS Code settings updated successfully")
EOF
    
    if command -v python3 >/dev/null 2>&1; then
        python3 /tmp/update_vscode_settings.py "$settings_file"
        rm /tmp/update_vscode_settings.py
        echo -e "${GREEN}✅ VS Code settings configured${NC}"
    else
        echo -e "${YELLOW}⚠️  Python not available, skipping automatic settings configuration${NC}"
        echo "Manually add these settings to your VS Code settings.json:"
        echo ""
        echo '{'
        echo '  "github.gitAuthentication": true,'
        echo '  "githubActions.workflows.pinned.workflows": [".github/workflows/ci-cd.yml"],'
        echo '  "githubActions.workflows.pinned.refresh.enabled": true,'
        echo '  "git.autofetch": true'
        echo '}'
    fi
}

# Function to open project in VS Code with GitHub integration
open_project() {
    echo -e "${BLUE}Opening project in VS Code...${NC}"
    
    cd "$PROJECT_ROOT"
    
    if code .; then
        echo -e "${GREEN}✅ Project opened in VS Code${NC}"
        echo ""
        echo -e "${YELLOW}Next steps in VS Code:${NC}"
        echo "1. Look for GitHub authentication prompts"
        echo "2. Check the GitHub tab in the sidebar"
        echo "3. View GitHub Actions in the status bar"
        echo "4. Access Pull Requests from the sidebar"
        echo ""
    else
        echo -e "${RED}❌ Failed to open project in VS Code${NC}"
    fi
}

# Main execution
main() {
    echo "This script will set up GitHub integration in VS Code for monitoring"
    echo "GitHub Actions, managing Pull Requests, and repository integration."
    echo ""
    
    # Check prerequisites
    if ! check_vscode; then
        exit 1
    fi
    
    echo ""
    
    # Install required extensions
    echo -e "${BLUE}📦 Installing GitHub Extensions${NC}"
    echo "--------------------------------"
    
    # GitHub Pull Requests extension
    if check_extension "github.vscode-pull-request-github"; then
        echo -e "${GREEN}✅ GitHub Pull Requests extension already installed${NC}"
    else
        install_extension "github.vscode-pull-request-github" "GitHub Pull Requests"
    fi
    
    # GitHub Actions extension
    if check_extension "github.vscode-github-actions"; then
        echo -e "${GREEN}✅ GitHub Actions extension already installed${NC}"
    else
        install_extension "github.vscode-github-actions" "GitHub Actions"
    fi
    
    # Optional but recommended extensions
    echo ""
    echo -e "${BLUE}📦 Installing Recommended Extensions${NC}"
    echo "-----------------------------------"
    
    # Git Graph
    if ! check_extension "mhutchie.git-graph"; then
        install_extension "mhutchie.git-graph" "Git Graph (Visual Git History)"
    else
        echo -e "${GREEN}✅ Git Graph already installed${NC}"
    fi
    
    # GitHub Repositories (for remote editing)
    if ! check_extension "github.remotehub"; then
        install_extension "github.remotehub" "GitHub Repositories"
    else
        echo -e "${GREEN}✅ GitHub Repositories already installed${NC}"
    fi
    
    echo ""
    
    # Configure VS Code settings
    configure_vscode_settings
    
    echo ""
    
    # Setup authentication
    setup_github_auth
    
    echo ""
    
    # Open project
    read -p "Open project in VS Code now? (y/n): " open_now
    if [[ "$open_now" =~ ^[Yy]$ ]]; then
        open_project
    fi
    
    echo ""
    echo -e "${GREEN}🎉 GitHub Integration Setup Complete!${NC}"
    echo ""
    echo -e "${YELLOW}What you can now do in VS Code:${NC}"
    echo ""
    echo "📊 ${BLUE}GitHub Actions:${NC}"
    echo "   • View workflow status in status bar"
    echo "   • Monitor CI/CD pipeline runs"
    echo "   • See build failures and logs"
    echo ""
    echo "🔀 ${BLUE}Pull Requests:${NC}"
    echo "   • Create and review PRs directly in VS Code"
    echo "   • View PR comments and suggestions"
    echo "   • Merge PRs from the editor"
    echo ""
    echo "📈 ${BLUE}Repository Management:${NC}"
    echo "   • Browse repository files remotely"
    echo "   • View commit history and branches"
    echo "   • Manage issues and discussions"
    echo ""
    echo -e "${PURPLE}Access these features from:${NC}"
    echo "• GitHub tab in the sidebar"
    echo "• Status bar GitHub Actions indicator"
    echo "• Command Palette (Ctrl+Shift+P): 'GitHub:'"
    echo ""
    echo -e "${BLUE}Repository URL:${NC} https://github.com/rfair404/WordPress-QuickStart"
    echo ""
}

# Run main function
main "$@"