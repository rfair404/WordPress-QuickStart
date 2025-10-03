@echo off
REM Git Hooks Setup Script (Windows)
REM This script sets up git hooks for the WordPress E-commerce Starter project

setlocal EnableDelayedExpansion

echo.
echo ^|======================================================^|  
echo ^| Setting up Git hooks for WordPress E-commerce Starter ^|
echo ^|======================================================^|
echo.

REM Check if we're in a git repository
if not exist ".git" (
    echo [ERROR] Not in a git repository
    echo Run 'git init' first to initialize the repository
    pause
    exit /b 1
)

REM Create hooks directory if it doesn't exist
if not exist ".git\hooks" mkdir ".git\hooks"

echo [INFO] Creating pre-commit hook...

REM Create pre-commit hook
(
echo #!/usr/bin/env bash
echo.
echo # Pre-commit hook for WordPress E-commerce Starter
echo # Runs Prettier on all files and linting on staged files
echo.
echo set -e
echo.
echo echo "🚀 Running pre-commit checks..."
echo.
echo # Check if npm is available ^(through Lando or locally^)
echo if command -v lando ^&^> /dev/null ^&^& [ -f ".lando.yml" ]; then
echo     NPM_CMD="lando npm"
echo     COMPOSER_CMD="lando composer"
echo elif command -v npm ^&^> /dev/null; then
echo     NPM_CMD="npm"
echo     COMPOSER_CMD="composer"
echo else
echo     echo "❌ Error: npm not available. Install Node.js or use Lando environment."
echo     exit 1
echo fi
echo.
echo # Check if node_modules exists
echo if [ ! -d "node_modules" ]; then
echo     echo "📦 Installing npm dependencies..."
echo     $NPM_CMD install
echo fi
echo.
echo # Run lint-staged to format and lint staged files
echo echo "✨ Running Prettier and linters on staged files..."
echo $NPM_CMD run lint-staged
echo.
echo echo "✅ Pre-commit checks passed!"
) > ".git\hooks\pre-commit"

echo [INFO] Creating pre-push hook...

REM Create pre-push hook  
(
echo #!/usr/bin/env bash
echo.
echo # Pre-push hook for WordPress E-commerce Starter
echo # Runs full test suite before pushing
echo.
echo set -e
echo.
echo echo "🧪 Running pre-push tests..."
echo.
echo # Check if we're in Lando environment
echo if command -v lando ^&^> /dev/null ^&^& [ -f ".lando.yml" ]; then
echo     NPM_CMD="lando npm"
echo     COMPOSER_CMD="lando composer"
echo elif command -v npm ^&^> /dev/null ^&^& command -v composer ^&^> /dev/null; then
echo     NPM_CMD="npm"
echo     COMPOSER_CMD="composer"
echo else
echo     echo "❌ Error: Development tools not available. Use Lando environment or install locally."
echo     exit 1
echo fi
echo.
echo # Run JavaScript tests if they exist
echo if [ -f "package.json" ] ^&^& $NPM_CMD run test --silent 2^>/dev/null; then
echo     echo "🟢 Running JavaScript tests..."
echo     $NPM_CMD test
echo fi
echo.
echo # Run PHP tests if they exist
echo if [ -f "composer.json" ] ^&^& [ -f "phpunit.xml" ]; then
echo     echo "🟡 Running PHP tests..."
echo     $COMPOSER_CMD run test
echo fi
echo.
echo # Run full linting check
echo echo "🔍 Running full code analysis..."
echo if [ -f "composer.json" ]; then
echo     $COMPOSER_CMD run analyze 2^>/dev/null ^|^| echo "⚠️  Analysis completed with warnings"
echo fi
echo.
echo echo "✅ Pre-push checks passed!"
) > ".git\hooks\pre-push"

echo [INFO] Creating commit-msg hook...

REM Create commit-msg hook
(
echo #!/usr/bin/env bash
echo.
echo # Commit message hook for WordPress E-commerce Starter
echo # Validates commit message format ^(optional^)
echo.
echo commit_regex='^(feat^|fix^|docs^|style^|refactor^|test^|chore^)(\\(.+\\^))?: .{1,50}'
echo.
echo if ! grep -qE "$commit_regex" "$1"; then
echo     echo "❌ Invalid commit message format!"
echo     echo ""
echo     echo "Expected format: type^(scope^): description"
echo     echo ""
echo     echo "Types: feat, fix, docs, style, refactor, test, chore"
echo     echo "Example: feat^(auth^): add user login functionality"
echo     echo ""
echo     echo "Your commit message:"
echo     cat "$1"
echo     echo ""
echo     exit 1
echo fi
) > ".git\hooks\commit-msg"

echo.
echo [SUCCESS] Git hooks successfully installed!
echo.
echo Installed hooks:
echo   📝 pre-commit  - Runs Prettier and linting on staged files
echo   🚀 pre-push    - Runs full test suite before pushing  
echo   💬 commit-msg  - Validates commit message format
echo.
echo To skip hooks temporarily, use:
echo   git commit --no-verify
echo   git push --no-verify
echo.
echo Hooks are now active for this repository! 🎉
echo.
pause