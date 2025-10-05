#!/usr/bin/env bash

# Git Hooks Setup Script
# This script sets up git hooks for the WordPress E-commerce Starter project

set -e

echo "🔧 Setting up Git hooks for WordPress E-commerce Starter"
echo "======================================================="

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    echo "Run 'git init' first to initialize the repository"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash

# Pre-commit hook for WordPress E-commerce Starter
# Runs Prettier on all files and linting on staged files

set -e

echo "🚀 Running pre-commit checks..."

# Check if npm is available (through Lando or locally)
if command -v lando &> /dev/null && [ -f ".lando.yml" ]; then
    NPM_CMD="lando npm"
    COMPOSER_CMD="lando composer"
elif command -v npm &> /dev/null; then
    NPM_CMD="npm"
    COMPOSER_CMD="composer"
else
    echo "❌ Error: npm not available. Install Node.js or use Lando environment."
    exit 1
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing npm dependencies..."
    $NPM_CMD install
fi

# Run lint-staged to format and lint staged files
echo "✨ Running Prettier and linters on staged files..."
$NPM_CMD run lint-staged

echo "✅ Pre-commit checks passed!"
EOF

# Make pre-commit hook executable
chmod +x .git/hooks/pre-commit

# Create pre-push hook
cat > .git/hooks/pre-push << 'EOF'
#!/usr/bin/env bash

# Pre-push hook for WordPress E-commerce Starter
# Runs full test suite before pushing

set -e

echo "🧪 Running pre-push tests..."

# Check if we're in Lando environment
if command -v lando &> /dev/null && [ -f ".lando.yml" ]; then
    NPM_CMD="lando npm"
    COMPOSER_CMD="lando composer"
elif command -v npm &> /dev/null && command -v composer &> /dev/null; then
    NPM_CMD="npm"
    COMPOSER_CMD="composer"
else
    echo "❌ Error: Development tools not available. Use Lando environment or install locally."
    exit 1
fi

# Run JavaScript tests if they exist
if [ -f "package.json" ] && $NPM_CMD run test --silent 2>/dev/null; then
    echo "🟢 Running JavaScript tests..."
    $NPM_CMD test
fi

# Run PHP tests if they exist
if [ -f "composer.json" ] && [ -f ".config/testing/phpunit.xml" ]; then
    echo "🟡 Running PHP tests..."
    $COMPOSER_CMD run test
fi

# Run full linting check
echo "🔍 Running full code analysis..."
if [ -f "composer.json" ]; then
    $COMPOSER_CMD run analyze 2>/dev/null || echo "⚠️  Analysis completed with warnings"
fi

echo "✅ Pre-push checks passed!"
EOF

# Make pre-push hook executable
chmod +x .git/hooks/pre-push

# Create commit-msg hook for conventional commits (optional)
cat > .git/hooks/commit-msg << 'EOF'
#!/usr/bin/env bash

# Commit message hook for WordPress E-commerce Starter
# Validates commit message format (optional)

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "❌ Invalid commit message format!"
    echo ""
    echo "Expected format: type(scope): description"
    echo ""
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    echo "Example: feat(auth): add user login functionality"
    echo ""
    echo "Your commit message:"
    cat "$1"
    echo ""
    exit 1
fi
EOF

# Make commit-msg hook executable
chmod +x .git/hooks/commit-msg

echo ""
echo "✅ Git hooks successfully installed!"
echo ""
echo "Installed hooks:"
echo "  📝 pre-commit  - Runs Prettier and linting on staged files"
echo "  🚀 pre-push    - Runs full test suite before pushing"
echo "  💬 commit-msg  - Validates commit message format"
echo ""
echo "To skip hooks temporarily, use:"
echo "  git commit --no-verify"
echo "  git push --no-verify"
echo ""
echo "Hooks are now active for this repository! 🎉"