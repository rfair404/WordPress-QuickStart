# VS Code Development Integration Guide

This guide covers the VS Code integration implemented in WordPress QuickStart, including extensions,
GitHub Actions monitoring, pull request management, and development workflow setup.

## Overview

WordPress QuickStart provides a VS Code development environment that supports productivity through:

### Key Integration Features

- **GitHub Actions Monitoring**: Real-time CI/CD status directly in the editor
- **Pull Request Management**: PR workflow without leaving VS Code
- **Code Assistance**: WordPress-specific IntelliSense and debugging
- **Quality Assurance**: Real-time linting, formatting, and testing
- **Development Environment Integration**: Lando and Docker management

### Benefits

- **Unified Workflow**: All development tasks accessible from single interface
- **Real-time Feedback**: Immediate visibility into CI/CD pipeline status
- **Productivity**: Reduced context switching between tools
- **Development Environment**: Development environment setup

## Essential Extensions

### GitHub Integration Extensions

#### GitHub Pull Requests and Issues

```json
{
  "name": "GitHub Pull Requests and Issues",
  "id": "GitHub.vscode-pull-request-github",
  "description": "Complete GitHub workflow integration",
  "features": [
    "Pull request creation and management",
    "Issue tracking and management",
    "Code review directly in editor",
    "GitHub authentication integration"
  ]
}
```

**Key Features:**

- Create pull requests from VS Code
- Review and comment on PRs inline
- Manage GitHub issues and milestones
- View and respond to review comments

#### GitHub Actions

```json
{
  "name": "GitHub Actions",
  "id": "github.vscode-github-actions",
  "description": "GitHub Actions workflow monitoring",
  "features": [
    "Workflow status in status bar",
    "Real-time job monitoring",
    "Workflow logs directly in editor",
    "Trigger workflows from VS Code"
  ]
}
```

**Configuration:**

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

#### GitHub Copilot

```json
{
  "name": "GitHub Copilot",
  "id": "GitHub.copilot",
  "description": "AI-powered code assistance",
  "features": [
    "Contextual code suggestions",
    "WordPress-specific code generation",
    "Test generation assistance",
    "Documentation generation"
  ]
}
```

### Development Quality Extensions

#### ESLint Integration

```json
{
  "name": "ESLint",
  "id": "dbaeumer.vscode-eslint",
  "configuration": {
    "eslint.validate": ["javascript", "json"],
    "eslint.workingDirectories": ["./"],
    "eslint.format.enable": true,
    "eslint.codeAction.showDocumentation": {
      "enable": true
    }
  }
}
```

#### Prettier Code Formatter

```json
{
  "name": "Prettier",
  "id": "esbenp.prettier-vscode",
  "configuration": {
    "prettier.requireConfig": true,
    "prettier.configPath": ".prettierrc.json",
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  }
}
```

#### PHP Code Quality

```json
{
  "name": "PHP IntelliSense",
  "id": "felixfbecker.php-intellisense",
  "features": [
    "WordPress function completion",
    "PHPDoc generation",
    "Error detection",
    "Code navigation"
  ]
}
```

### WordPress-Specific Extensions

#### WordPress Snippets

```json
{
  "name": "WordPress Snippets",
  "id": "wordpresstoolbox.wordpress-toolbox",
  "features": [
    "WordPress hook snippets",
    "Template function snippets",
    "Plugin development snippets",
    "Theme development snippets"
  ]
}
```

#### PHP DocBlocker

```json
{
  "name": "PHP DocBlocker",
  "id": "neilbrayfield.php-docblocker",
  "configuration": {
    "php-docblocker.returnGap": true,
    "php-docblocker.gap": true,
    "php-docblocker.extra": ["@since"]
  }
}
```

## Workspace Configuration

### VS Code Settings

#### Workspace Settings (`/.vscode/settings.json`)

```json
{
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": false,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true,
    "source.fixAll.stylelint": true
  },

  "files.associations": {
    "*.php": "php",
    "*.inc": "php",
    "*.module": "php"
  },

  "php.suggest.basic": false,
  "php.validate.enable": true,
  "php.validate.executablePath": "/usr/local/bin/php",

  "emmet.includeLanguages": {
    "php": "html"
  },

  "git.autofetch": true,
  "git.confirmSync": false,
  "git.enableSmartCommit": true,

  "terminal.integrated.defaultProfile.windows": "Git Bash",
  "terminal.integrated.profiles.windows": {
    "Git Bash": {
      "path": "C:\\Program Files\\Git\\bin\\bash.exe",
      "args": ["--login"]
    }
  }
}
```

#### Extension Recommendations (`/.vscode/extensions.json`)

```json
{
  "recommendations": [
    "GitHub.vscode-pull-request-github",
    "github.vscode-github-actions",
    "GitHub.copilot",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "stylelint.vscode-stylelint",
    "felixfbecker.php-intellisense",
    "neilbrayfield.php-docblocker",
    "wordpresstoolbox.wordpress-toolbox",
    "ms-vscode.vscode-json",
    "redhat.vscode-yaml",
    "ms-vscode.vscode-docker"
  ]
}
```

### Tasks Configuration

#### VS Code Tasks (`/.vscode/tasks.json`)

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start Lando",
      "type": "shell",
      "command": "./scripts/setup/lando-wrapper.sh start",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      },
      "problemMatcher": []
    },
    {
      "label": "Stop Lando",
      "type": "shell",
      "command": "./scripts/setup/lando-wrapper.sh stop",
      "group": "build"
    },
    {
      "label": "Run PHP Tests",
      "type": "shell",
      "command": "./scripts/setup/lando-wrapper.sh composer test",
      "group": "test",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": true,
        "panel": "shared"
      },
      "problemMatcher": [
        {
          "owner": "php",
          "fileLocation": "absolute",
          "pattern": [
            {
              "regexp": "^(.*):(\\d+)$",
              "file": 1,
              "line": 2
            }
          ]
        }
      ]
    },
    {
      "label": "Run E2E Tests",
      "type": "shell",
      "command": "npm run test:e2e",
      "group": "test",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": true,
        "panel": "shared"
      },
      "problemMatcher": []
    },
    {
      "label": "Lint All Code",
      "type": "shell",
      "command": "npm run lint:all",
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      },
      "problemMatcher": [
        "$eslint-stylish",
        {
          "owner": "php",
          "fileLocation": "absolute",
          "pattern": [
            {
              "regexp": "^(.*):(\\d+):(\\d+): (error|warning|info): (.*)$",
              "file": 1,
              "line": 2,
              "column": 3,
              "severity": 4,
              "message": 5
            }
          ]
        }
      ]
    },
    {
      "label": "Format All Code",
      "type": "shell",
      "command": "npm run format:all",
      "group": "build"
    }
  ]
}
```

### Launch Configuration

#### Debug Configuration (`/.vscode/launch.json`)

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug PHP with Xdebug",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "pathMappings": {
        "/app": "${workspaceFolder}"
      },
      "ignore": ["**/vendor/**", "**/node_modules/**"]
    },
    {
      "name": "Debug Playwright Tests",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/node_modules/.bin/playwright",
      "args": ["test", "--debug"],
      "console": "integratedTerminal",
      "env": {
        "PWDEBUG": "1"
      }
    },
    {
      "name": "Debug Node.js Script",
      "type": "node",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal"
    }
  ]
}
```

## GitHub Actions Integration

### Real-time Workflow Monitoring

#### Status Bar Integration

The GitHub Actions extension provides continuous workflow monitoring:

```javascript
// Workflow status appears in status bar
// Format: "✓ CI/CD" (success) or "✗ CI/CD" (failure) or "⚡ CI/CD" (running)

// Click status bar item to:
// - View workflow details
// - Open workflow logs
// - Navigate to GitHub Actions page
```

#### Workflow Notifications

```json
{
  "github-actions.notification.showWorkflowRunStatus": true,
  "github-actions.notification.showWorkflowRunStatusInStatusBar": true,
  "github-actions.workflows.pinned.refresh.enabled": true,
  "github-actions.workflows.pinned.refresh.interval": 30
}
```

### Command Palette Integration

#### GitHub Actions Commands

```
> GitHub Actions: Open Workflow File
> GitHub Actions: Trigger Workflow
> GitHub Actions: View Workflow Runs
> GitHub Actions: Download Workflow Logs
> GitHub Actions: Cancel Workflow Run
```

#### Custom Commands via GitHub CLI

```json
{
  "commands": [
    {
      "command": "extension.ghCli.runList",
      "title": "List Workflow Runs",
      "category": "GitHub CLI"
    },
    {
      "command": "extension.ghCli.prStatus",
      "title": "Check PR Status",
      "category": "GitHub CLI"
    }
  ]
}
```

### Problems Panel Integration

#### CI/CD Error Display

VS Code Problems panel shows:

- Workflow failures with direct links to logs
- Matrix job failures with specific error details
- Code quality issues from CI linting
- Test failures with file/line references

```json
{
  "problemMatchers": [
    {
      "name": "github-actions",
      "owner": "github-actions",
      "fileLocation": "absolute",
      "pattern": [
        {
          "regexp": "^Error: (.*)\\s+at\\s+(.*):(\\d+):(\\d+)$",
          "message": 1,
          "file": 2,
          "line": 3,
          "column": 4
        }
      ]
    }
  ]
}
```

## Pull Request Management

### PR Creation Workflow

#### Create PR from VS Code

1. **Source Control Panel**: Use Git integration to commit changes
2. **Command Palette**: `> GitHub Pull Requests: Create Pull Request`
3. **PR Template**: Auto-populates with project template
4. **Review Assignment**: Assign reviewers directly from VS Code

#### PR Template Integration

```markdown
<!-- .github/pull_request_template.md -->

## Changes Made

- [ ] Feature implementation
- [ ] Tests added/updated
- [ ] Documentation updated

## VS Code Workflow

- Created via VS Code GitHub integration
- All CI/CD checks monitored in status bar
- Code review completed in editor
```

### Code Review Integration

#### In-Editor Code Review

```javascript
// Features available directly in VS Code:
// - View PR diff in editor
// - Add comments to specific lines
// - Resolve/unresolve review comments
// - Approve/request changes
// - Merge PR after approval
```

#### Review Workflow Configuration

```json
{
  "githubPullRequests.reviewMode": "review",
  "githubPullRequests.defaultMergeMethod": "squash",
  "githubPullRequests.showInSCM": true,
  "githubPullRequests.focusedMode": false
}
```

### Branch Management

#### Git Integration Enhancement

```json
{
  "git.autofetch": true,
  "git.pruneOnFetch": true,
  "git.confirmSync": false,
  "git.enableSmartCommit": true,
  "git.postCommitCommand": "sync",

  "githubPullRequests.createOnPublishBranch": "ask",
  "githubPullRequests.pushBranch": "always"
}
```

#### Branch Protection Integration

```yaml
# Branch protection rules reflected in VS Code:
# - Prevent direct pushes to main
# - Require PR review before merge
# - Require status checks to pass
# - Require branches to be up to date
```

## Development Workflow Optimization

### Live Development Features

#### Hot Reloading Integration

```json
{
  "liveServer.settings.donotShowInfoMsg": true,
  "liveServer.settings.proxy": {
    "enable": true,
    "baseUri": "/",
    "proxyUri": "http://localhost:80"
  }
}
```

#### File Watchers

```json
{
  "files.watcherExclude": {
    "**/node_modules/**": true,
    "**/vendor/**": true,
    "**/wp/**": true,
    "**/.git/**": true,
    "**/coverage/**": true,
    "**/test-results/**": true
  }
}
```

### Debugging Integration

#### PHP Debugging with Xdebug

```json
{
  "php.debug.enable": true,
  "php.debug.port": [9003],
  "php.debug.autoReload": {
    "enable": true,
    "watch": true,
    "delay": 1000
  }
}
```

#### JavaScript/Node.js Debugging

```json
{
  "debug.node.autoAttach": "on",
  "debug.terminal.clearBeforeReusing": true,
  "debug.console.fontSize": 12
}
```

#### Playwright Test Debugging

```json
{
  "playwright.showTrace": true,
  "playwright.reuseBrowser": true,
  "playwright.showBrowser": true
}
```

### Code Quality Integration

#### Real-time Linting

```json
{
  "eslint.run": "onType",
  "eslint.autoFixOnSave": true,
  "stylelint.validate": ["css", "scss", "sass"],
  "php.validate.run": "onType"
}
```

#### Format on Save Configuration

```json
{
  "editor.formatOnSave": true,
  "editor.formatOnPaste": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  }
}
```

## Terminal Integration

### Integrated Terminal Configuration

#### Multi-terminal Setup

```json
{
  "terminal.integrated.profiles.linux": {
    "Lando": {
      "path": "/bin/bash",
      "args": ["-c", "./scripts/setup/lando-wrapper.sh ssh --service appserver"]
    },
    "Node": {
      "path": "/bin/bash",
      "args": ["-c", "./scripts/setup/lando-wrapper.sh node"]
    }
  },

  "terminal.integrated.defaultProfile.linux": "bash"
}
```

#### Terminal Automation

```json
{
  "terminal.integrated.automationShell.linux": "/bin/bash",
  "terminal.integrated.cwd": "${workspaceFolder}",
  "terminal.integrated.env.linux": {
    "TERM": "xterm-256color"
  }
}
```

### Custom Terminal Commands

#### Quick Command Access

```json
{
  "terminal.integrated.profiles.linux": {
    "WordPress CLI": {
      "path": "/bin/bash",
      "args": ["-c", "./scripts/setup/lando-wrapper.sh wp --info"]
    },
    "Composer": {
      "path": "/bin/bash",
      "args": ["-c", "./scripts/setup/lando-wrapper.sh composer"]
    },
    "NPM": {
      "path": "/bin/bash",
      "args": ["-c", "./scripts/setup/lando-wrapper.sh npm"]
    }
  }
}
```

## Performance Optimization

### VS Code Performance Settings

#### Large Project Optimization

```json
{
  "search.exclude": {
    "**/node_modules": true,
    "**/vendor": true,
    "**/wp": true,
    "**/.git": true,
    "**/coverage": true,
    "**/test-results": true,
    "**/playwright-report": true
  },

  "files.exclude": {
    "**/node_modules": true,
    "**/vendor": true,
    "**/.git": true,
    "**/coverage": true
  },

  "typescript.preferences.includePackageJsonAutoImports": "off",
  "php.memoryLimit": "2G"
}
```

#### Extension Performance

```json
{
  "extensions.autoUpdate": false,
  "extensions.autoCheckUpdates": false,
  "telemetry.telemetryLevel": "off",
  "update.mode": "manual"
}
```

### Memory and CPU Optimization

#### Resource Management

```json
{
  "editor.suggest.maxVisibleSuggestions": 6,
  "editor.suggest.showSnippets": false,
  "editor.quickSuggestions": {
    "other": false,
    "comments": false,
    "strings": false
  },

  "workbench.editor.limit.enabled": true,
  "workbench.editor.limit.value": 10,
  "workbench.editor.limit.perEditorGroup": true
}
```

## Troubleshooting

### Common VS Code Issues

#### Extension Conflicts

```bash
# Disable conflicting extensions
code --disable-extensions

# Reset extension host
code --reset-extension-host

# Clear extension cache
rm -rf ~/.vscode/extensions/.obsolete
```

#### GitHub Integration Issues

```bash
# Re-authenticate GitHub
code --open-url https://github.com/login/device

# Clear GitHub credentials
git config --global --unset credential.helper
gh auth logout
gh auth login
```

#### Performance Issues

```json
{
  "workbench.settings.enableNaturalLanguageSearch": false,
  "workbench.enableExperiments": false,
  "workbench.settings.useSplitJSON": true,
  "search.followSymlinks": false
}
```

### Debug Mode and Logging

#### VS Code Debug Information

```bash
# Start VS Code with debug logging
code --log debug --verbose

# Check extension logs
code --log-extension-host-communication

# Performance profiling
code --prof-v8-extension-host
```

#### Extension Debug Mode

```json
{
  "github-actions.log": "debug",
  "eslint.debug": true,
  "php.debug.log": true,
  "prettier.traceConfig": true
}
```

## Best Practices

### Workspace Organization

1. **Consistent Structure**: Maintain consistent project structure across all WordPress projects
2. **Shared Settings**: Use workspace settings for team consistency
3. **Extension Management**: Maintain recommended extensions list for team members
4. **Git Integration**: Leverage VS Code Git features for version control
5. **Documentation**: Keep VS Code configuration documented and version controlled

### Security Considerations

1. **Credential Management**: Use VS Code secure credential storage
2. **Extension Vetting**: Only install trusted, well-maintained extensions
3. **Settings Sync**: Be careful with settings sync regarding sensitive information
4. **Remote Development**: Secure remote development connections properly
5. **Access Control**: Implement proper access controls for shared workspaces

### Team Collaboration

1. **Shared Configuration**: Version control VS Code workspace settings
2. **Extension Recommendations**: Maintain team extension recommendations
3. **Code Style**: Enforce consistent code style through VS Code settings
4. **Review Process**: Use VS Code GitHub integration for efficient code reviews
5. **Knowledge Sharing**: Document VS Code workflows and customizations

This VS Code integration provides a professional, efficient development environment that maximizes
productivity while maintaining code quality and team collaboration standards.
