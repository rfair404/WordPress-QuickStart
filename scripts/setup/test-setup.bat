@echo off
REM WordPress E-commerce Starter - Development Setup Test Script (Windows)
REM This script tests all the development tools and configurations

setlocal EnableDelayedExpansion

echo.
echo ^|======================================================^|
echo ^| WordPress E-commerce Starter - Testing Setup        ^|
echo ^|======================================================^|
echo.

REM Check if Docker is available
set "DOCKER_CMD="
where docker >nul 2>nul
if %errorlevel% == 0 (
    set "DOCKER_CMD=docker"
) else (
    REM Check Docker Desktop installation path
    if exist "C:\Program Files\Docker\Docker\resources\bin\docker.exe" (
        set "DOCKER_CMD=C:\Program Files\Docker\Docker\resources\bin\docker.exe"
    )
)

if "%DOCKER_CMD%"=="" (
    echo [ERROR] Docker is not available
    echo [INFO] This project requires Docker Desktop to be installed and running
    echo [INFO] Download Docker Desktop from: https://www.docker.com/products/docker-desktop/
    echo [INFO] Or run: .\scripts\setup\install-lando-docker.bat
    echo.
    pause
    exit /b 1
)

REM Check if Lando is available
set "LANDO_CMD="
where lando >nul 2>nul
if %errorlevel% == 0 (
    set "LANDO_CMD=lando"
) else (
    REM Check common Lando installation paths
    if exist "%USERPROFILE%\.local\bin\lando.exe" (
        set "LANDO_CMD=%USERPROFILE%\.local\bin\lando.exe"
    ) else if exist "%USERPROFILE%\.lando\bin\lando.exe" (
        set "LANDO_CMD=%USERPROFILE%\.lando\bin\lando.exe"
    )
)

if not "%LANDO_CMD%"=="" (
    echo [INFO] Using Lando environment (found at: %LANDO_CMD%)
    set "COMPOSER_CMD=%LANDO_CMD% composer"
    set "NPM_CMD=%LANDO_CMD% npm"

    REM Check if Lando environment is running
    lando info >nul 2>nul
    if %errorlevel% neq 0 (
        echo [WARNING] Lando environment is not running
        echo [INFO] Run 'lando start' first to start the development environment
        echo [INFO] This may take several minutes on the first run
        echo.
        pause
        exit /b 1
    )
) else (
    echo [ERROR] Lando is not available
    echo [INFO] This project requires Lando to be installed
    echo [INFO] Download Lando from: https://github.com/lando/lando/releases/latest
    echo [INFO] Make sure Docker Desktop is also installed and running
    echo.
    pause
    exit /b 1
)

echo.
echo [INFO] Testing PHP version...
php -v
if %errorlevel% neq 0 (
    echo [ERROR] PHP is not available
    pause
    exit /b 1
)

echo.
echo [INFO] Validating composer.json...
%COMPOSER_CMD% validate --strict
if %errorlevel% neq 0 (
    echo [ERROR] composer.json validation failed
    pause
    exit /b 1
)
echo [SUCCESS] composer.json is valid

echo.
echo [INFO] Checking if vendor directory exists...
if not exist "vendor" (
    echo [INFO] Installing Composer dependencies...
    %COMPOSER_CMD% install
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install Composer dependencies
        pause
        exit /b 1
    )
    echo [SUCCESS] Composer dependencies installed
) else (
    echo [SUCCESS] Composer dependencies already installed
)

echo.
echo [INFO] Testing Composer scripts...

echo [INFO] Running PHP Code Sniffer...
%COMPOSER_CMD% run lint:phpcs
if %errorlevel% == 0 (
    echo [SUCCESS] PHPCS passed
) else (
    echo [WARNING] PHPCS found issues (this may be expected)
)

echo.
echo [INFO] Running PHPUnit tests...
%COMPOSER_CMD% run test:unit
if %errorlevel% neq 0 (
    echo [ERROR] PHPUnit tests failed
    pause
    exit /b 1
)
echo [SUCCESS] PHPUnit tests passed

echo.
echo [INFO] Running security audit...
%COMPOSER_CMD% run security:check
if %errorlevel% == 0 (
    echo [SUCCESS] Security audit passed
) else (
    echo [WARNING] Security audit found issues (check manually)
)

echo.
echo [INFO] Checking Node.js availability...
where node >nul 2>nul
if %errorlevel% == 0 (
    echo [SUCCESS] Node.js is available
    node -v

    if exist "package.json" (
        if not exist "node_modules" (
            echo [INFO] Installing npm dependencies...
            %NPM_CMD% install
            if %errorlevel% neq 0 (
                echo [ERROR] Failed to install npm dependencies
                pause
                exit /b 1
            )
            echo [SUCCESS] npm dependencies installed
        ) else (
            echo [SUCCESS] npm dependencies already installed
        )
    )
) else (
    echo [WARNING] Node.js not found - frontend tooling will not be available
)

echo.
echo [INFO] Checking configuration files...
set "config_files=.lando.yml composer.json package.json .config\linting\phpcs.xml .config\testing\phpunit.xml .config\linting\.eslintrc.js .config\linting\.stylelintrc.js .config\formatting\.prettierrc .gitignore README.md"

for %%f in (%config_files%) do (
    if exist "%%f" (
        echo [SUCCESS] ✓ %%f exists
    ) else (
        echo [ERROR] ✗ %%f is missing
    )
)

echo.
echo [INFO] Checking directory structure...
set "directories=src tests tests\unit .github\workflows .lando"

for %%d in (%directories%) do (
    if exist "%%d" (
        echo [SUCCESS] ✓ %%d\ exists
    ) else (
        echo [ERROR] ✗ %%d\ is missing
    )
)

echo.
echo [INFO] Testing Lando configuration (if available)...
where lando >nul 2>nul
if %errorlevel% == 0 (
    if exist ".lando.yml" (
        lando info >nul 2>nul
        if %errorlevel% == 0 (
            echo [SUCCESS] Lando environment is running
        ) else (
            echo [WARNING] Lando environment is not running (run 'lando start' first)
        )
    )
) else (
    echo [INFO] Lando not available (using local environment)
)

echo.
echo ^|======================================================^|
echo ^| [SUCCESS] Development setup test completed!         ^|
echo ^|======================================================^|
echo.
echo [INFO] Next steps:
echo   1. Run 'lando start' to start your development environment
echo   2. Run 'lando composer dev:setup' to complete the setup
echo   3. Visit https://wordpress-ecommerce-starter.lndo.site
echo   4. Begin developing your WordPress e-commerce features!
echo.
echo [INFO] Checking Git hooks setup...
if exist ".git\hooks\pre-commit" (
    echo [SUCCESS] ✓ Git pre-commit hook is installed
) else (
    echo [WARNING] ⚠ Git hooks not set up - run 'setup-git-hooks.bat'
)

echo.
echo [INFO] Available commands:
echo   • lando composer lint          - Run PHP linting
echo   • lando composer test          - Run PHP tests
echo   • lando composer analyze       - Run full analysis
echo   • lando npm run lint:js        - Run JavaScript linting
echo   • lando npm run format:all     - Format all files with Prettier
echo   • lando npm run build          - Build frontend assets
echo   • lando wp --info              - WordPress CLI information
echo   • .\scripts\setup\git-hooks.bat - Set up git hooks for automated formatting
echo.
pause
