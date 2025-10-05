#!/bin/bash

# GitHub CLI Wrapper Script
# This script provides a consistent interface for GitHub CLI operations

# Check if gh is available
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI not installed. Install from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "GitHub CLI not authenticated. Run: gh auth login"
    exit 1
fi

# Pass through arguments to gh
gh "$@"
