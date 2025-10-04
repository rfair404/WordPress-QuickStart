#!/bin/bash
# GitHub CLI Wrapper Script
# This script provides a consistent way to call GitHub CLI across different environments

# Try to find GitHub CLI
if command -v gh &> /dev/null; then
    # gh is in PATH
    exec gh "$@"
elif [[ -f "/c/Program Files/GitHub CLI/gh.exe" ]]; then
    # Windows default installation path
    exec "/c/Program Files/GitHub CLI/gh.exe" "$@"
elif [[ -f "$HOME/AppData/Local/GitHubCLI/gh.exe" ]]; then
    # Windows user installation path
    exec "$HOME/AppData/Local/GitHubCLI/gh.exe" "$@"
else
    echo "Error: GitHub CLI not found. Please install it from: https://cli.github.com/" >&2
    echo "Or run: bash scripts/setup/github-cli-setup.sh" >&2
    exit 1
fi
