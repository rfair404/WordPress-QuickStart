# GitHub CLI Integration Guide

This guide covers the GitHub CLI integration implemented in WordPress QuickStart, including setup,
authentication, workflow management, and cross-platform compatibility.

## Overview

WordPress QuickStart includes a GitHub CLI integration system that provides:

- **GitHub CLI Installation**: Cross-platform detection and installation
- **Workflow Monitoring**: Real-time GitHub Actions status tracking
- **Pull Request Management**: PR lifecycle management from command line
- **Repository Operations**: Repository management and maintenance
- **VS Code Integration**: GitHub Actions monitoring directly in the editor

## Architecture

### GitHub CLI Wrapper System

The project includes a GitHub CLI wrapper located at `scripts/gh-wrapper.sh` that provides:

- **Cross-platform Compatibility**: Works on Windows, Mac, and Linux
- **Automatic Detection**: GitHub CLI detection and PATH resolution
- **Installation Automation**: Downloads and installs GitHub CLI when not found
- **Error Handling**: Error reporting and troubleshooting guidance
- **Authentication Management**: GitHub authentication workflow

### Integration Points

#### 1. CI/CD Pipeline Integration

- **Workflow Status**: Real-time monitoring of GitHub Actions workflows
- **Job Tracking**: Individual job status and completion monitoring
- **Failure Analysis**: Failure detection and reporting
- **Matrix Results**: Matrix job result aggregation

#### 2. Development Workflow Integration

- **Branch Management**: Branch creation and management
- **PR Automation**: Pull request creation with templates
- **Review Process**: Code review and approval workflow
- **Merge Management**: Merge strategies and conflict resolution

#### 3. VS Code Integration

- **Status Bar Integration**: Real-time GitHub Actions status in VS Code status bar
- **Command Palette**: GitHub CLI commands accessible through VS Code command palette
- **Problem Panel**: GitHub Actions errors displayed in VS Code problems panel
- **Terminal Integration**: GitHub CLI commands available in integrated terminal

## Setup and Installation

### Setup

The project provides GitHub CLI setup through multiple installation methods:

#### Windows Setup

```bash
# PowerShell or Command Prompt
.\scripts\setup\github-cli-setup.bat

# Git Bash
```

#### Mac/Linux Setup

```bash
# Unix systems

# Using the main setup script
```

#### Manual Installation Verification

```bash
# Test GitHub CLI installation
./scripts/gh-wrapper.sh --version

# Test authentication status
./scripts/gh-wrapper.sh auth status

# Test repository access
./scripts/gh-wrapper.sh repo view
```

### Authentication Setup

#### Initial Authentication

```bash
# Interactive authentication (recommended)
./scripts/gh-wrapper.sh auth login

# Web-based authentication
./scripts/gh-wrapper.sh auth login --web

# Token-based authentication
./scripts/gh-wrapper.sh auth login --with-token < token.txt
```

#### Authentication Verification

```bash
# Check authentication status
./scripts/gh-wrapper.sh auth status

# List authenticated accounts
./scripts/gh-wrapper.sh auth status --show-token

# Test API access
./scripts/gh-wrapper.sh api user
```

#### SSH Key Configuration

```bash
# List SSH keys
./scripts/gh-wrapper.sh ssh-key list

# Add SSH key
./scripts/gh-wrapper.sh ssh-key add ~/.ssh/id_rsa.pub

# Test SSH connection
ssh -T git@github.com
```

## Workflow Management

### GitHub Actions Monitoring

#### Real-time Workflow Status

```bash
# List recent workflow runs
./scripts/gh-wrapper.sh run list

# Monitor specific workflow
./scripts/gh-wrapper.sh run list --workflow="WordPress Quickstart CI/CD"

# Watch workflow in real-time
./scripts/gh-wrapper.sh run watch 12345
```

#### Workflow Analysis

```bash
# Get workflow run details
./scripts/gh-wrapper.sh run view 12345

# Download workflow logs
./scripts/gh-wrapper.sh run download 12345

# View specific job logs
./scripts/gh-wrapper.sh run view 12345 --log --job="test-php-8-1"
```

#### Matrix Job Monitoring

```bash
# List all matrix jobs
./scripts/gh-wrapper.sh run list --json status,conclusion,databaseId

# Filter by job status
./scripts/gh-wrapper.sh run list --status=failure

# Monitor specific matrix combinations
./scripts/gh-wrapper.sh run list --workflow="Pull Request Tests" --branch=feature/branch
```

### Pull Request Management

#### PR Creation and Management

```bash
# Create pull request with template
./scripts/gh-wrapper.sh pr create --template

# Create draft pull request
./scripts/gh-wrapper.sh pr create --draft --title "WIP: Feature implementation"

# List pull requests
./scripts/gh-wrapper.sh pr list --state=open
```

#### PR Review Process

```bash
# View pull request details
./scripts/gh-wrapper.sh pr view 123

# Check pull request status
./scripts/gh-wrapper.sh pr status

# Review pull request
./scripts/gh-wrapper.sh pr review 123 --approve --body "LGTM!"
```

#### PR Merge Management

```bash
# Merge pull request (squash)
./scripts/gh-wrapper.sh pr merge 123 --squash

# Merge with merge commit
./scripts/gh-wrapper.sh pr merge 123 --merge

# Rebase and merge
./scripts/gh-wrapper.sh pr merge 123 --rebase
```

### Repository Operations

#### Repository Information

```bash
# View repository details
./scripts/gh-wrapper.sh repo view

# List repository collaborators
./scripts/gh-wrapper.sh api repos/:owner/:repo/collaborators

# Repository statistics
./scripts/gh-wrapper.sh api repos/:owner/:repo --jq '.size, .forks_count, .stargazers_count'
```

#### Issue Management

```bash
# List issues
./scripts/gh-wrapper.sh issue list

# Create issue
./scripts/gh-wrapper.sh issue create --title "Bug report" --body "Description"

# Close issue
./scripts/gh-wrapper.sh issue close 456
```

#### Release Management

```bash
# List releases
./scripts/gh-wrapper.sh release list

# Create release
./scripts/gh-wrapper.sh release create v1.0.0 --title "Version 1.0.0" --notes "Release notes"

# Download release assets
./scripts/gh-wrapper.sh release download v1.0.0
```

## VS Code Integration

### GitHub Actions Extension Setup

The project automatically configures VS Code with GitHub-specific extensions:

#### Required Extensions

```json
{
  "recommendations": [
    "GitHub.vscode-pull-request-github",
    "GitHub.github-vscode-theme",
    "GitHub.copilot",
    "ms-vscode.vscode-github-actions"
  ]
}
```

#### VS Code Settings Configuration

```json
{
  "github-actions.workflows.pinned.workflows": [
    ".github/workflows/wordpress-quickstart-ci-cd.yml",
    ".github/workflows/pull-request-validation.yml",
    ".github/workflows/pull-request-tests.yml"
  ],
  "github-actions.workflows.pinned.refresh.enabled": true,
  "github-actions.workflows.pinned.refresh.interval": 30
}
```

### Real-time Monitoring Features

#### Status Bar Integration

- **Workflow Status**: Current workflow run status displayed in status bar
- **Job Progress**: Individual job progress and completion indicators
- **Failure Alerts**: Immediate notification of workflow failures
- **Success Confirmation**: Visual confirmation of successful runs

#### Command Palette Integration

```
GitHub Actions: View Workflow Runs
GitHub Actions: Trigger Workflow
GitHub Actions: Cancel Workflow Run
GitHub Actions: Download Workflow Logs
```

#### Problems Panel Integration

- **Workflow Errors**: GitHub Actions errors displayed in Problems panel
- **Job Failures**: Individual job failures with clickable links to logs
- **Matrix Results**: Matrix job failure reporting
- **Quick Fixes**: Suggested fixes for common CI/CD issues

## Cross-Platform Compatibility

### Windows-Specific Features

#### PowerShell Integration

```powershell
# PowerShell profile integration
Set-Alias gh ./scripts/gh-wrapper.sh

# Windows-specific GitHub CLI commands
./scripts/gh-wrapper.sh auth setup-git --hostname github.com
```

#### Windows Subsystem for Linux (WSL)

```bash
# WSL compatibility check
./scripts/gh-wrapper.sh --version

# WSL SSH key sharing
./scripts/gh-wrapper.sh ssh-key list
```

### Mac-Specific Features

#### Homebrew Integration

```bash
# Homebrew installation verification
brew list gh

# macOS keychain integration
./scripts/gh-wrapper.sh auth login --hostname github.com
```

#### macOS Security

```bash
# Keychain access verification
security find-generic-password -s github.com

# SSH agent integration
ssh-add -l
```

### Linux-Specific Features

#### Package Manager Integration

```bash
# APT-based systems
sudo apt update && sudo apt install gh

# RPM-based systems
sudo dnf install gh

# Arch-based systems
sudo pacman -S github-cli
```

#### System Service Integration

```bash
# systemd service for GitHub CLI authentication
systemctl --user status gh-auth

# Environment variable management
export GITHUB_TOKEN="your_token_here"
```

## Troubleshooting

### Common Issues

#### Authentication Problems

```bash
# Re-authenticate
./scripts/gh-wrapper.sh auth logout
./scripts/gh-wrapper.sh auth login

# Check token permissions
./scripts/gh-wrapper.sh auth status --show-token

# Verify repository access
./scripts/gh-wrapper.sh repo view
```

#### Installation Issues

```bash
# Verify installation
./scripts/gh-wrapper.sh --version

# Check PATH configuration
echo $PATH | grep -i github

# Manual installation check
which gh || where gh
```

#### Network and Proxy Issues

```bash
# Configure proxy
git config --global http.proxy http://proxy.company.com:8080

# Test network connectivity
./scripts/gh-wrapper.sh api user

# Check SSL certificates
git config --global http.sslVerify false  # Only for testing
```

### Performance Optimization

#### Rate Limit Management

```bash
# Check rate limit status
./scripts/gh-wrapper.sh api rate_limit

# Use authenticated requests
export GITHUB_TOKEN="your_token"

# Implement request caching
./scripts/gh-wrapper.sh --cache-duration 300
```

#### Batch Operations

```bash
# Batch workflow monitoring
./scripts/gh-wrapper.sh run list --limit 50 --json

# Bulk PR operations
./scripts/gh-wrapper.sh pr list --state all --json

# Repository batch queries
./scripts/gh-wrapper.sh api graphql --paginate
```

## Configuration

### Custom Workflow Templates

#### PR Template Integration

```markdown
<!-- .github/pull_request_template.md -->

## Changes Made

- [ ] Feature implementation
- [ ] Tests added/updated
- [ ] Documentation updated

## GitHub CLI Commands Used

- `gh pr create --template`
- `gh pr review --approve`
- `gh pr merge --squash`
```

#### Issue Templates

```yaml
# .github/ISSUE_TEMPLATE/bug_report.yml
name: Bug Report
description: File a bug report using GitHub CLI
title: '[Bug]: '
body:
  - type: textarea
    attributes:
      label: GitHub CLI Version
      description: Output of `gh --version`
```

### Automation Scripts

#### Workflow Monitoring Automation

```bash
#!/bin/bash
# Monitor workflow and send notifications
WORKFLOW_ID=$(./scripts/gh-wrapper.sh run list --limit 1 --json databaseId --jq '.[0].databaseId')
STATUS=$(./scripts/gh-wrapper.sh run view $WORKFLOW_ID --json status --jq '.status')

if [ "$STATUS" = "completed" ]; then
  echo "Workflow completed successfully"
  # Send notification
fi
```

#### PR Management

```bash
#!/bin/bash
# PR creation and management
BRANCH=$(git branch --show-current)
./scripts/gh-wrapper.sh pr create --title "feat: $BRANCH" --body "PR for $BRANCH"
./scripts/gh-wrapper.sh pr merge --auto --squash
```

## Integration with Project Workflow

### Development Lifecycle Integration

1. **Feature Development**: Use GitHub CLI for branch management and PR creation
2. **Code Review**: Leverage GitHub CLI for review process
3. **CI/CD Monitoring**: Real-time workflow monitoring during development
4. **Release Management**: Release creation and asset management

### Quality Assurance Integration

1. **Pre-commit Hooks**: GitHub CLI integration for commit validation
2. **PR Validation**: PR checks using GitHub CLI
3. **Workflow Validation**: Continuous workflow monitoring and validation
4. **Release Validation**: Release testing and validation

This GitHub CLI integration provides a professional, efficient workflow management system that
scales with your development needs while maintaining cross-platform compatibility and error
handling.
