@echo off
REM WordPress E-commerce Starter - Lando & Docker Desktop Installation Script (Windows)
REM This script downloads and installs Lando and Docker Desktop for development

setlocal EnableDelayedExpansion

echo.
echo ^|==================================================================^|
echo ^| WordPress E-commerce Starter - Lando ^& Docker Desktop Installer ^|
echo ^|==================================================================^|
echo.

REM Set up colors (if supported)
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)

REM Logging functions using labels
:log_info
echo [INFO] %~1
goto :eof

:log_success
echo [SUCCESS] %~1
goto :eof

:log_warning
echo [WARNING] %~1
goto :eof

:log_error
echo [ERROR] %~1
goto :eof

REM Check if running as administrator
:check_admin
call :log_info "Checking administrator privileges..."
net session >nul 2>&1
if %errorLevel% == 0 (
    call :log_success "Running with administrator privileges"
) else (
    call :log_warning "Not running as administrator - some installations may require elevation"
)
goto :eof

REM Check prerequisites
:check_prerequisites
call :log_info "Checking prerequisites..."

where curl >nul 2>&1
if %errorLevel% neq 0 (
    where powershell >nul 2>&1
    if %errorLevel% neq 0 (
        call :log_error "Neither curl nor PowerShell found - cannot download files"
        exit /b 1
    )
)

call :log_success "Prerequisites check passed"
goto :eof

REM Download file function
:download_file
set "url=%~1"
set "output=%~2"

call :log_info "Downloading: %~nx2"

REM Try curl first, then PowerShell
where curl >nul 2>&1
if %errorLevel% == 0 (
    curl -L --progress-bar "%url%" -o "%output%"
) else (
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%url%' -OutFile '%output%' -UseBasicParsing}"
)

if %errorLevel% neq 0 (
    call :log_error "Failed to download %~nx2"
    exit /b 1
)
goto :eof

REM Check if Docker is installed
:check_docker
where docker >nul 2>&1
if %errorLevel% == 0 (
    set "DOCKER_INSTALLED=1"
    for /f "tokens=*" %%i in ('docker --version 2^>nul') do set "DOCKER_VERSION=%%i"
) else (
    set "DOCKER_INSTALLED=0"
    set "DOCKER_VERSION=Not installed"
)
goto :eof

REM Check if Lando is installed
:check_lando
where lando >nul 2>&1
if %errorLevel% == 0 (
    set "LANDO_INSTALLED=1"
    for /f "tokens=*" %%i in ('lando version --component cli 2^>nul ^| findstr /r "v[0-9]*\.[0-9]*\.[0-9]*"') do set "LANDO_VERSION=%%i"
    if "!LANDO_VERSION!"=="" set "LANDO_VERSION=Unknown version"
) else (
    set "LANDO_INSTALLED=0"
    set "LANDO_VERSION=Not installed"
)
goto :eof

REM Install Docker Desktop
:install_docker_desktop
call :log_info "Installing Docker Desktop for Windows..."

call :check_docker
if "%DOCKER_INSTALLED%"=="1" (
    call :log_warning "Docker already installed: %DOCKER_VERSION%"
    choice /C YN /M "Do you want to reinstall Docker Desktop"
    if errorlevel 2 (
        call :log_info "Skipping Docker Desktop installation"
        goto :eof
    )
)

set "DOCKER_URL=https://desktop.docker.com/win/main/amd64/Docker Desktop Installer.exe"
set "DOCKER_FILE=%TEMP%\DockerDesktopInstaller.exe"

call :download_file "%DOCKER_URL%" "%DOCKER_FILE%"
if %errorLevel% neq 0 goto :eof

call :log_info "Running Docker Desktop installer..."
call :log_warning "Please follow the installation wizard that will open"

start /wait "" "%DOCKER_FILE%"

if exist "%DOCKER_FILE%" del "%DOCKER_FILE%"

call :log_success "Docker Desktop installer completed"
call :log_info "Please restart your computer if prompted"

goto :eof

REM Get latest Lando version from GitHub API
:get_latest_lando_version
call :log_info "Fetching latest Lando version from GitHub..."

set "LATEST_VERSION="
set "API_URL=https://api.github.com/repos/lando/lando/releases/latest"
set "TEMP_JSON=%TEMP%\lando_latest.json"

REM Download release info
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { Invoke-WebRequest -Uri '%API_URL%' -OutFile '%TEMP_JSON%' -UseBasicParsing } catch { exit 1 }}"

if %errorLevel% == 0 (
    REM Parse JSON for tag_name
    for /f "tokens=2 delims=:" %%a in ('findstr /r "tag_name" "%TEMP_JSON%"') do (
        set "tag=%%a"
        set "tag=!tag: =!"
        set "tag=!tag:~1,-2!"
        set "LATEST_VERSION=!tag!"
    )
    del "%TEMP_JSON%" 2>nul
)

if "%LATEST_VERSION%"=="" (
    set "LATEST_VERSION=v3.21.0"
    call :log_warning "Could not fetch latest version, using fallback: %LATEST_VERSION%"
) else (
    call :log_info "Latest Lando version: %LATEST_VERSION%"
)

goto :eof

REM Install Lando
:install_lando
call :log_info "Installing Lando..."

call :check_lando
if "%LANDO_INSTALLED%"=="1" (
    call :log_warning "Lando already installed: %LANDO_VERSION%"
    choice /C YN /M "Do you want to reinstall/update Lando"
    if errorlevel 2 (
        call :log_info "Skipping Lando installation"
        goto :eof
    )
)

call :get_latest_lando_version

set "LANDO_URL=https://github.com/lando/lando/releases/download/%LATEST_VERSION%/lando-win-x64-%LATEST_VERSION%.exe"
set "LANDO_FILE=%TEMP%\lando-installer.exe"

call :download_file "%LANDO_URL%" "%LANDO_FILE%"
if %errorLevel% neq 0 goto :eof

call :log_info "Running Lando installer..."
call :log_warning "Please follow the installation wizard that will open"

start /wait "" "%LANDO_FILE%"

if exist "%LANDO_FILE%" del "%LANDO_FILE%"

call :log_success "Lando installer completed"

goto :eof

REM Verify installations
:verify_installations
call :log_info "Verifying installations..."

set "ERRORS=0"

call :check_docker
if "%DOCKER_INSTALLED%"=="1" (
    call :log_success "Docker installed: %DOCKER_VERSION%"
) else (
    call :log_warning "Docker not found in PATH (may require restart)"
    set /a ERRORS+=1
)

call :check_lando
if "%LANDO_INSTALLED%"=="1" (
    call :log_success "Lando installed: %LANDO_VERSION%"
) else (
    call :log_warning "Lando not found in PATH (may require restart)"
    set /a ERRORS+=1
)

if %ERRORS% == 0 (
    call :log_success "All installations verified successfully!"
) else (
    call :log_warning "Some tools may require system restart or PATH updates"
)

goto :eof

REM Show post-installation instructions
:show_post_install_instructions
echo.
echo ==================================================================
call :log_info "Post-installation instructions:"
echo.
echo 1. 🔄 Restart your computer if prompted by Docker Desktop
echo 2. 🐳 Start Docker Desktop from the Start Menu
echo 3. 🔧 Open a new Git Bash terminal or Command Prompt
echo 4. ✅ Run 'docker --version' and 'lando version' to verify
echo.
echo 📖 Next steps:
echo    • Navigate to your project directory
echo    • Run 'lando start' to start your development environment
echo    • Visit the Lando documentation: https://docs.lando.dev
echo.
call :log_success "Installation complete! 🎉"
goto :eof

REM Main installation flow
:main
echo.
call :log_info "Starting installation process..."
echo.

call :check_admin
call :check_prerequisites

echo.
choice /C YN /M "Install Docker Desktop"
if not errorlevel 2 call :install_docker_desktop

echo.
choice /C YN /M "Install Lando"
if not errorlevel 2 call :install_lando

echo.
call :verify_installations
call :show_post_install_instructions

pause
goto :eof

REM Run main function
call :main
