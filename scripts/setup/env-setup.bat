@echo off
REM WordPress E-commerce Starter - Environment Setup Script (Windows)
REM This script sets up the development environment for Git Bash/WSL users on Windows

setlocal EnableDelayedExpansion

echo.
echo ^|======================================================^|
echo ^| WordPress E-commerce Starter - Environment Setup    ^|
echo ^|======================================================^|
echo.

REM Get project root directory
set "PROJECT_ROOT=%~dp0..\.."
cd /d "%PROJECT_ROOT%"

echo [INFO] Project root: %PROJECT_ROOT%
echo.

REM Create VS Code workspace settings
echo [INFO] Setting up VS Code workspace configuration...

if not exist ".vscode" mkdir ".vscode"

REM Create VS Code settings.json
(
echo {
echo     "terminal.integrated.defaultProfile.windows": "Git Bash",
echo     "terminal.integrated.profiles.windows": {
echo         "Git Bash": {
echo             "path": "C:\\Program Files\\Git\\bin\\bash.exe",
echo             "args": ["--login"],
echo             "env": {
echo                 "BASH_ENV": "${workspaceFolder}/.bashrc"
echo             }
echo         }
echo     },
echo     "terminal.integrated.env.windows": {
echo         "BASH_ENV": "${workspaceFolder}/.bashrc"
echo     },
echo     "files.associations": {
echo         ".bashrc": "shellscript",
echo         ".lando.yml": "yaml",
echo         "composer.json": "json",
echo         ".config/linting/phpcs.xml": "xml"
echo     },
echo     "editor.formatOnSave": true,
echo     "editor.codeActionsOnSave": {
echo         "source.fixAll.eslint": true,
echo         "source.fixAll.stylelint": true
echo     },
echo     "php.validate.executablePath": "lando php",
echo     "eslint.workingDirectories": ["${workspaceFolder}"],
echo     "prettier.configPath": "${workspaceFolder}/.config/formatting/.prettierrc",
echo     "eslint.options": {
echo         "configFile": "${workspaceFolder}/.config/linting/.eslintrc.js"
echo     }
echo }
) > ".vscode\settings.json"

REM Create VS Code tasks.json
(
echo {
echo     "version": "2.0.0",
echo     "tasks": [
echo         {
echo             "label": "Start Lando",
echo             "type": "shell",
echo             "command": "lando start",
echo             "group": "build",
echo             "presentation": {
echo                 "echo": true,
echo                 "reveal": "always",
echo                 "focus": false,
echo                 "panel": "shared"
echo             },
echo             "problemMatcher": []
echo         },
echo         {
echo             "label": "Stop Lando",
echo             "type": "shell",
echo             "command": "lando stop",
echo             "group": "build",
echo             "presentation": {
echo                 "echo": true,
echo                 "reveal": "always",
echo                 "focus": false,
echo                 "panel": "shared"
echo             },
echo             "problemMatcher": []
echo         },
echo         {
echo             "label": "Run PHP Tests",
echo             "type": "shell",
echo             "command": "lando composer test",
echo             "group": "test",
echo             "presentation": {
echo                 "echo": true,
echo                 "reveal": "always",
echo                 "focus": false,
echo                 "panel": "shared"
echo             },
echo             "problemMatcher": []
echo         },
echo         {
echo             "label": "Run JavaScript Tests",
echo             "type": "shell",
echo             "command": "lando npm test",
echo             "group": "test",
echo             "presentation": {
echo                 "echo": true,
echo                 "reveal": "always",
echo                 "focus": false,
echo                 "panel": "shared"
echo             },
echo             "problemMatcher": []
echo         },
echo         {
echo             "label": "Lint PHP Code",
echo             "type": "shell",
echo             "command": "lando composer lint",
echo             "group": "build",
echo             "presentation": {
echo                 "echo": true,
echo                 "reveal": "always",
echo                 "focus": false,
echo                 "panel": "shared"
echo             },
echo             "problemMatcher": []
echo         },
echo         {
echo             "label": "Format All Files",
echo             "type": "shell",
echo             "command": "lando npm run format:all",
echo             "group": "build",
echo             "presentation": {
echo                 "echo": true,
echo                 "reveal": "always",
echo                 "focus": false,
echo                 "panel": "shared"
echo             },
echo             "problemMatcher": []
echo         }
echo     ]
echo }
) > ".vscode\tasks.json"

echo [SUCCESS] VS Code workspace configuration created
echo.

REM Create a PowerShell profile setup script
echo [INFO] Creating PowerShell profile setup...

(
echo # WordPress E-commerce Starter - PowerShell Profile
echo # Add this to your PowerShell profile for enhanced development experience
echo.
echo # Project paths
echo $env:WQS_PROJECT_ROOT = "%PROJECT_ROOT%"
echo $env:PATH += ";%PROJECT_ROOT%\scripts;%PROJECT_ROOT%\scripts\setup"
echo.
echo # Development aliases
echo function lando-start { lando start }
echo function lando-stop { lando stop }
echo function lando-restart { lando restart }
echo function lando-info { lando info }
echo function dev-setup { lando composer dev:setup; lando npm install }
echo function dev-test { lando composer test; lando npm test }
echo function dev-lint { lando composer lint; lando npm run lint:js }
echo function dev-format { lando npm run format:all }
echo.
echo # Navigation functions
echo function goto-src { Set-Location "$env:WQS_PROJECT_ROOT\src" }
echo function goto-tests { Set-Location "$env:WQS_PROJECT_ROOT\tests" }
echo function goto-scripts { Set-Location "$env:WQS_PROJECT_ROOT\scripts" }
echo function goto-root { Set-Location "$env:WQS_PROJECT_ROOT" }
echo.
echo Write-Host "🚀 WordPress E-commerce Starter environment loaded!" -ForegroundColor Green
) > "scripts\setup\powershell-profile.ps1"

echo [SUCCESS] PowerShell profile template created
echo.

echo ^|======================================================^|
echo ^| Environment setup complete!                          ^|
echo ^|======================================================^|
echo.
echo [INFO] Next steps:
echo   1. Open this project in VS Code
echo   2. VS Code will automatically use Git Bash terminal with .bashrc
echo   3. In the terminal, run: source .bashrc
echo   4. Run: wqs_help (to see available commands)
echo   5. Run: wqs_setup (to set up the development environment)
echo.
echo [INFO] For PowerShell users:
echo   • Import the profile: . .\scripts\setup\powershell-profile.ps1
echo   • Or add it to your PowerShell profile permanently
echo.
echo [INFO] VS Code Features Configured:
echo   • Git Bash as default terminal
echo   • Automatic .bashrc sourcing
echo   • Format on save enabled
echo   • Linting and formatting tasks
echo   • Custom file associations
echo.
pause
