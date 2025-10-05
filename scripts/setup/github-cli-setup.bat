@echo off
setlocal enabledelayedexpansion

REM WordPress Quickstart - GitHub CLI Setup Script (Windows)
REM This script installs and configures GitHub CLI for development workflow

REM Configuration
set INSTALL_GHCLI=1
set SETUP_AUTH=1
set AUTO_MODE=0
set QUIET_MODE=0

REM Parse command line arguments
:parse_args
if "%~1"=="" goto main
if "%~1"=="--help" goto show_usage
if "%~1"=="-h" goto show_usage
if "%~1"=="--no-install" set INSTALL_GHCLI=0 & shift & goto parse_args
if "%~1"=="--no-auth" set SETUP_AUTH=0 & shift & goto parse_args
if "%~1"=="--auto" set AUTO_MODE=1 & shift & goto parse_args
if "%~1"=="--quiet" set QUIET_MODE=1 & shift & goto parse_args
echo Unknown option: %~1
goto show_usage

:main
echo [INFO] Starting GitHub CLI setup for WordPress Quickstart...

REM Check if GitHub CLI is already installed
gh --version >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] GitHub CLI is already installed
    if !AUTO_MODE! neq 1 (
        set /p REINSTALL="GitHub CLI is already installed. Do you want to reinstall it? (y/N): "
        if /i "!REINSTALL!" neq "y" set INSTALL_GHCLI=0
    ) else (
        echo [INFO] GitHub CLI already installed, skipping installation
        set INSTALL_GHCLI=0
    )
) else (
    echo [INFO] GitHub CLI is not installed
)

REM Install GitHub CLI if needed
if !INSTALL_GHCLI! equ 1 (
    echo [INFO] Installing GitHub CLI using winget...

    REM Check if winget is available
    winget --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] winget not available. Please install GitHub CLI manually from: https://cli.github.com/
        exit /b 1
    )

    REM Install GitHub CLI
    winget install --id GitHub.cli --accept-package-agreements --accept-source-agreements
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install GitHub CLI
        exit /b 1
    )

    REM Verify installation
    gh --version >nul 2>&1
    if %errorlevel% equ 0 (
        echo [SUCCESS] GitHub CLI installed successfully!
    ) else (
        echo [ERROR] GitHub CLI installation failed
        exit /b 1
    )
)

REM Setup authentication if requested
if !SETUP_AUTH! equ 1 (
    echo [INFO] Setting up GitHub CLI authentication...

    REM Check if already authenticated
    gh auth status >nul 2>&1
    if %errorlevel% equ 0 (
        echo [INFO] GitHub CLI is already authenticated
        gh auth status
    ) else (
        if !AUTO_MODE! equ 1 (
            echo [WARN] Auto mode enabled but GitHub CLI authentication requires interactive setup
            echo [WARN] Run 'gh auth login' manually after this script completes
        ) else (
            echo [INFO] Starting GitHub CLI authentication process...
            echo [INFO] You'll be prompted to authenticate with GitHub
            gh auth login

            REM Verify authentication
            gh auth status >nul 2>&1
            if %errorlevel% equ 0 (
                echo [SUCCESS] GitHub CLI authentication successful!
            ) else (
                echo [ERROR] GitHub CLI authentication failed
            )
        )
    )
)

REM Setup useful aliases
echo [INFO] Setting up GitHub CLI aliases...
gh alias set actions "run list --limit 10" >nul 2>&1
gh alias set logs "run view --log-failed" >nul 2>&1
gh alias set latest "run view $(gh run list --json databaseId --jq \".[0].databaseId\")" >nul 2>&1
gh alias set status "run list --status" >nul 2>&1
echo [SUCCESS] GitHub CLI aliases configured

REM Test functionality
echo [INFO] Testing GitHub CLI functionality...
gh --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] GitHub CLI not working properly
    exit /b 1
)

gh auth status >nul 2>&1
if %errorlevel% equ 0 (
    gh repo view >nul 2>&1
    if %errorlevel% equ 0 (
        echo [INFO] GitHub CLI can access repository successfully
    ) else (
        echo [WARN] GitHub CLI installed but cannot access repository (this is normal if not in a repo directory)
    )
) else (
    echo [WARN] GitHub CLI not authenticated - some features will be limited
)

echo [SUCCESS] GitHub CLI is working correctly

REM Show helpful information
echo.
echo [INFO] GitHub CLI Setup Complete!
echo.
echo Available commands:
echo   gh --version           - Show GitHub CLI version
echo   gh auth login          - Authenticate with GitHub
echo   gh run list            - List recent workflow runs
echo   gh run view --log-failed - View failed run logs
echo   gh repo view           - View repository information
echo.
echo Composer shortcuts:
echo   lando composer gh:check   - Check GitHub CLI status
echo   lando composer gh:actions - List recent actions
echo   lando composer gh:auth    - Check authentication status
echo.
echo npm shortcuts:
echo   lando npm run gh:check        - Check GitHub CLI status
echo   lando npm run gh:actions:latest - View latest run
echo   lando npm run gh:actions:logs   - View latest run logs
echo.
echo [SUCCESS] GitHub CLI is ready for development workflow!
goto end

:show_usage
echo Usage: %0 [options]
echo.
echo Options:
echo   -h, --help              Show this help message
echo   --no-install            Skip GitHub CLI installation
echo   --no-auth               Skip authentication setup
echo   --auto                  Run in automated mode (no prompts)
echo   --quiet                 Minimize output
echo.
echo Examples:
echo   %0                      # Interactive installation
echo   %0 --auto --quiet       # Silent installation
goto end

:end
endlocal
