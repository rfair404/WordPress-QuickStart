@echo off
REM GitHub Integration Setup Script for VS Code (Windows)
REM Enables GitHub Actions monitoring, Pull Requests, and repository integration

setlocal enabledelayedexpansion

echo.
echo 🔗 GitHub Integration Setup for VS Code
echo ========================================
echo.

REM Check if VS Code is installed
where code >nul 2>&1
if errorlevel 1 (
    echo ❌ VS Code is not installed or 'code' command is not in PATH
    echo.
    echo Please install VS Code and ensure the 'code' command is available:
    echo 1. Download VS Code from https://code.visualstudio.com/
    echo 2. During installation, check 'Add to PATH' option
    echo 3. Restart your command prompt/terminal
    echo.
    pause
    exit /b 1
)

echo ✅ VS Code is installed

echo.
echo 📦 Installing GitHub Extensions
echo --------------------------------

REM Install GitHub Pull Requests extension
echo Installing GitHub Pull Requests...
code --install-extension github.vscode-pull-request-github --force
if errorlevel 1 (
    echo ❌ Failed to install GitHub Pull Requests extension
) else (
    echo ✅ GitHub Pull Requests extension installed
)

REM Install GitHub Actions extension
echo Installing GitHub Actions...
code --install-extension github.vscode-github-actions --force
if errorlevel 1 (
    echo ❌ Failed to install GitHub Actions extension
) else (
    echo ✅ GitHub Actions extension installed
)

echo.
echo 📦 Installing Recommended Extensions
echo -----------------------------------

REM Install Git Graph
echo Installing Git Graph...
code --install-extension mhutchie.git-graph --force
if errorlevel 1 (
    echo ❌ Failed to install Git Graph extension
) else (
    echo ✅ Git Graph extension installed
)

REM Install GitHub Repositories
echo Installing GitHub Repositories...
code --install-extension github.remotehub --force
if errorlevel 1 (
    echo ❌ Failed to install GitHub Repositories extension
) else (
    echo ✅ GitHub Repositories extension installed
)

echo.
echo 🔧 Configuring VS Code Settings
echo -------------------------------

REM Create VS Code settings directory if it doesn't exist
if not exist "%APPDATA%\Code\User" mkdir "%APPDATA%\Code\User"

REM Create basic settings.json if it doesn't exist
if not exist "%APPDATA%\Code\User\settings.json" (
    echo {} > "%APPDATA%\Code\User\settings.json"
)

echo ✅ VS Code settings directory ready

echo.
echo 🔐 GitHub Authentication Setup
echo ==============================
echo.
echo You'll need to authenticate with GitHub to access:
echo • Repository information
echo • GitHub Actions status
echo • Pull Request management
echo • Issue tracking
echo.
echo Authentication Instructions:
echo.
echo 1. Go to GitHub Settings ^> Developer settings ^> Personal access tokens
echo    URL: https://github.com/settings/tokens
echo.
echo 2. Click 'Generate new token (classic)'
echo.
echo 3. Select these scopes:
echo    ☑️  repo (Full control of private repositories)
echo    ☑️  workflow (Update GitHub Action workflows)
echo    ☑️  read:org (Read org and team membership)
echo    ☑️  user:email (Access user email addresses)
echo.
echo 4. Copy the generated token
echo.
echo 5. In VS Code:
echo    • Press Ctrl+Shift+P
echo    • Type 'GitHub: Sign In'
echo    • Select 'Use Personal Access Token'
echo    • Paste your token
echo.

REM Check if GitHub CLI is available
where gh >nul 2>&1
if not errorlevel 1 (
    echo ✅ GitHub CLI (gh) is available
    echo.
    set /p use_gh="Use GitHub CLI for authentication? (y/n): "
    if /i "!use_gh!"=="y" (
        echo.
        echo Checking GitHub CLI authentication...
        gh auth status >nul 2>&1
        if not errorlevel 1 (
            echo ✅ Already authenticated with GitHub CLI
        ) else (
            echo ⚠️  Not authenticated with GitHub CLI
            echo.
            set /p run_auth="Run 'gh auth login' now? (y/n): "
            if /i "!run_auth!"=="y" (
                gh auth login
            )
        )
    )
)

echo.
set /p open_project="Open project in VS Code now? (y/n): "
if /i "!open_project!"=="y" (
    echo.
    echo 🚀 Opening project in VS Code...
    cd /d "%~dp0..\.."
    code .
    if errorlevel 1 (
        echo ❌ Failed to open project in VS Code
    ) else (
        echo ✅ Project opened in VS Code
    )
)

echo.
echo 🎉 GitHub Integration Setup Complete!
echo.
echo What you can now do in VS Code:
echo.
echo 📊 GitHub Actions:
echo    • View workflow status in status bar
echo    • Monitor CI/CD pipeline runs
echo    • See build failures and logs
echo.
echo 🔀 Pull Requests:
echo    • Create and review PRs directly in VS Code
echo    • View PR comments and suggestions
echo    • Merge PRs from the editor
echo.
echo 📈 Repository Management:
echo    • Browse repository files remotely
echo    • View commit history and branches
echo    • Manage issues and discussions
echo.
echo Access these features from:
echo • GitHub tab in the sidebar
echo • Status bar GitHub Actions indicator
echo • Command Palette (Ctrl+Shift+P): 'GitHub:'
echo.
echo Repository URL: https://github.com/rfair404/WordPress-QuickStart
echo.

pause
