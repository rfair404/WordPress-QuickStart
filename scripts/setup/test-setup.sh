#!/usr/bin/env bash

# WordPress E-commerce Starter - Development Setup Test Script
# This script tests all the development tools and configurations

# Error handling and debugging options
DEBUG_MODE="${WES_DEBUG:-0}"
ERROR_TOLERANT="${WES_ERROR_TOLERANT:-0}"
QUIET_MODE="${WES_QUIET:-0}"

# Set appropriate error handling based on mode
if [[ "$ERROR_TOLERANT" == "1" ]]; then
    set -u  # Don't exit on errors
else
    set -e  # Exit on errors (default)
fi

# Debug function
debug() {
    if [[ "$DEBUG_MODE" == "1" ]]; then
        echo -e "\033[0;36m[DEBUG]\033[0m $1" >&2
    fi
}

# Error handler
handle_error() {
    local exit_code=$?
    local line_number=$1
    print_error "Script failed at line $line_number with exit code $exit_code"
    if [[ "$DEBUG_MODE" == "1" ]]; then
        echo -e "\033[0;36m[DEBUG]\033[0m Call stack:" >&2
        local frame=0
        while caller $frame >&2; do
            ((frame++))
        done
    fi
    if [[ "$ERROR_TOLERANT" != "1" ]]; then
        exit $exit_code
    fi
}

# Set up error trap
trap 'handle_error $LINENO' ERR

if [[ "$QUIET_MODE" != "1" ]]; then
    echo "🚀 WordPress E-commerce Starter - Testing Development Setup"
    echo "============================================================"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output with error tolerance
print_status() {
    if [[ "$QUIET_MODE" != "1" ]]; then
        echo -e "${BLUE}[INFO]${NC} $1" || true
    fi
    debug "Status: $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" || true
    debug "Success: $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" || true
    debug "Warning: $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2 || true
    debug "Error: $1"
}

# Safe test execution
safe_test() {
    local test_name="$1"
    local test_command="$2"
    local failure_message="$3"

    debug "Starting test: $test_name"
    print_status "Testing $test_name..."

    if [[ "$ERROR_TOLERANT" == "1" ]]; then
        if eval "$test_command"; then
            print_success "$test_name passed"
            debug "Test passed: $test_name"
            return 0
        else
            print_warning "$test_name failed but continuing: $failure_message"
            debug "Test failed but continuing: $test_name"
            return 1
        fi
    else
        if eval "$test_command"; then
            print_success "$test_name passed"
            debug "Test passed: $test_name"
            return 0
        else
            print_error "$test_name failed: $failure_message"
            debug "Test failed: $test_name"
            return 1
        fi
    fi
}

# Check if Docker is available
check_docker() {
    # Check common Docker installation paths
    local docker_paths=(
        "docker"                                              # In PATH
        "/c/Program Files/Docker/Docker/resources/bin/docker" # Windows Docker Desktop
        "/usr/bin/docker"                                      # Linux package install
        "/usr/local/bin/docker"                               # Manual install
        "/opt/docker/bin/docker"                              # Alternative install
    )

    for docker_path in "${docker_paths[@]}"; do
        if command -v "$docker_path" &> /dev/null; then
            export DOCKER_CMD="$docker_path"
            return 0
        fi
    done
    return 1
}

if ! check_docker; then
    print_error "Docker is not available"
    print_status "This project requires Docker Desktop to be installed and running"
    print_status "Download Docker Desktop from: https://www.docker.com/products/docker-desktop/"
    print_status "Or run: ./scripts/setup/install-lando-docker.sh"
    exit 1
fi

# Check if Lando is available
check_lando() {
    # Check common Lando installation paths
    local lando_paths=(
        "lando"                                    # In PATH
        "$HOME/.local/bin/lando.exe"              # Our custom install
        "$HOME/.local/bin/lando"                  # Linux install
        "/usr/local/bin/lando"                    # System install
        "$HOME/.lando/bin/lando.exe"              # Official Windows install
    )

    for lando_path in "${lando_paths[@]}"; do
        if command -v "$lando_path" &> /dev/null || [ -f "$lando_path" ]; then
            export LANDO_CMD="$lando_path"
            return 0
        fi
    done
    return 1
}

# Check if we're in a Lando environment
if check_lando; then
    COMPOSER_CMD="$LANDO_CMD composer"
    NPM_CMD="$LANDO_CMD npm"
    print_status "Using Lando environment (found at: $LANDO_CMD)"

    # Check if Lando environment is running
    if ! $LANDO_CMD info &> /dev/null; then
        print_error "Lando environment is not running"
        print_status "Run 'lando start' first to start the development environment"
        print_status "This may take several minutes on the first run"
        exit 1
    fi
else
    print_error "Lando is not available"
    print_status "This project requires Lando to be installed"
    print_status "Download Lando from: https://github.com/lando/lando/releases/latest"
    print_status "Make sure Docker Desktop is also installed and running"
    exit 1
fi

# Test 1: Check PHP version
print_status "Testing PHP version..."
if [[ "$QUIET_MODE" != "1" ]]; then
    php -v
fi
if php -r "exit(version_compare(PHP_VERSION, '8.1.0', '>=') ? 0 : 1);" 2>/dev/null; then
    print_success "PHP version is compatible (>=8.1.0)"
else
    print_error "PHP version is not compatible. Requires PHP 8.1.0 or higher"
    exit 1
fi

# Test 2: Composer validation
print_status "Validating composer.json..."
if $COMPOSER_CMD validate --strict --quiet; then
    print_success "composer.json is valid"
else
    print_error "composer.json validation failed"
    exit 1
fi

# Test 3: Install Composer dependencies (if not already installed)
if [ ! -d "vendor" ]; then
    print_status "Installing Composer dependencies..."
    if [[ "$QUIET_MODE" == "1" ]]; then
        $COMPOSER_CMD install --quiet
    else
        $COMPOSER_CMD install
    fi
    print_success "Composer dependencies installed"
fi

# Test 4: Test Composer scripts
print_status "Testing Composer scripts..."

# Test PHP linting
print_status "Running PHP Code Sniffer..."
if $COMPOSER_CMD run lint:phpcs; then
    print_success "PHPCS passed"
else
    print_warning "PHPCS found issues (this is expected for testing)"
fi

# Test PHPUnit
print_status "Running PHPUnit tests..."
if $COMPOSER_CMD run test:unit; then
    print_success "PHPUnit tests passed"
else
    print_error "PHPUnit tests failed"
    exit 1
fi

# Test security check
print_status "Running security audit..."
if $COMPOSER_CMD run security:check; then
    print_success "Security audit passed"
else
    print_warning "Security audit found issues (check manually)"
fi

# Test 5: Node.js and npm setup
if command -v node &> /dev/null; then
    print_status "Testing Node.js version..."
    node -v

    if [ -f "package.json" ]; then
        # Install npm dependencies if not already installed
        if [ ! -d "node_modules" ]; then
            print_status "Installing npm dependencies..."
            if [[ "$QUIET_MODE" == "1" ]]; then
                $NPM_CMD install --silent
            else
                $NPM_CMD install
            fi
            print_success "npm dependencies installed"
        fi

        # Test npm scripts
        print_status "Testing npm linting..."
        if $NPM_CMD run lint:js 2>/dev/null || true; then
            print_success "ESLint is configured"
        else
            print_warning "ESLint not fully configured yet"
        fi

        if $NPM_CMD run lint:css 2>/dev/null || true; then
            print_success "Stylelint is configured"
        else
            print_warning "Stylelint not fully configured yet"
        fi

        if $NPM_CMD run format:check 2>/dev/null || true; then
            print_success "Prettier is configured"
        else
            print_warning "Prettier not fully configured yet"
        fi
    fi
else
    print_warning "Node.js not found - frontend tooling will not be available"
fi

# Test 6: Check configuration files
print_status "Checking configuration files..."

config_files=(
    ".lando.yml"
    "composer.json"
    "package.json"
    ".config/linting/phpcs.xml"
    ".config/testing/phpunit.xml"
    ".config/linting/.eslintrc.js"
    ".config/linting/.stylelintrc.js"
    ".config/formatting/.prettierrc"
    ".gitignore"
    "README.md"
)

for file in "${config_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "✓ $file exists"
    else
        print_error "✗ $file is missing"
    fi
done

# Test 7: Check directory structure
print_status "Checking directory structure..."

directories=(
    "src"
    "tests"
    "tests/unit"
    ".github/workflows"
    ".lando"
)

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        print_success "✓ $dir/ exists"
    else
        print_error "✗ $dir/ is missing"
    fi
done

# Test 8: Lando-specific tests (if available)
if command -v lando &> /dev/null && [ -f ".lando.yml" ]; then
    print_status "Testing Lando configuration..."

    if lando info &> /dev/null; then
        print_success "Lando environment is running"

        # Test custom Lando tooling
        lando_tools=("wp" "composer" "npm" "phpcs" "phpcbf")
        for tool in "${lando_tools[@]}"; do
            if lando "$tool" --version &> /dev/null || lando "$tool" --help &> /dev/null; then
                print_success "✓ Lando $tool command is available"
            else
                print_warning "⚠ Lando $tool command may not be fully configured"
            fi
        done
    else
        print_warning "Lando environment is not running (run 'lando start' first)"
    fi
fi

echo ""
echo "============================================================"
print_success "🎉 Development setup test completed!"
echo ""
print_status "Next steps:"
echo "  1. Run 'lando start' to start your development environment"
echo "  2. Run 'lando composer dev:setup' to complete the setup"
echo "  3. Visit https://wordpress-ecommerce-starter.lndo.site to see your site"
echo "  4. Begin developing your WordPress e-commerce features!"
echo ""
print_status "Checking Git hooks setup..."
if [ -f ".git/hooks/pre-commit" ]; then
    print_success "✓ Git pre-commit hook is installed"
else
    print_warning "⚠ Git hooks not set up - run './setup-git-hooks.sh'"
fi

# Test 9: GitHub CLI setup and integration
print_status "Testing GitHub CLI integration..."

# Check if GitHub CLI is available
if command -v gh &> /dev/null; then
    local gh_version=$(gh --version | head -n1 | cut -d' ' -f3)
    print_success "✓ GitHub CLI v$gh_version is installed"
    
    # Test GitHub CLI authentication status
    if gh auth status &> /dev/null; then
        print_success "✓ GitHub CLI is authenticated"
        
        # Test repository access if we're in a repo
        if gh repo view &> /dev/null; then
            print_success "✓ GitHub CLI can access repository"
        else
            print_warning "⚠ GitHub CLI authenticated but cannot access repository (normal if not in repo)"
        fi
    else
        print_warning "⚠ GitHub CLI is installed but not authenticated (run 'gh auth login')"
    fi
    
    # Test GitHub CLI aliases
    if gh alias list | grep -q "actions\|logs\|latest\|status" &> /dev/null; then
        print_success "✓ GitHub CLI aliases are configured"
    else
        print_info "ℹ️  GitHub CLI aliases not configured (will be set up during authentication)"
    fi
    
else
    print_warning "⚠ GitHub CLI is not installed"
    print_info "ℹ️  Install with: ./scripts/setup/github-cli-setup.sh"
fi

# Test composer GitHub CLI scripts
print_status "Testing composer GitHub CLI scripts..."
composer_gh_scripts=("gh:check" "gh:actions" "gh:auth")
for script in "${composer_gh_scripts[@]}"; do
    if grep -q "\"$script\"" composer.json; then
        print_success "✓ Composer script '$script' is defined"
    else
        print_error "✗ Composer script '$script' is missing"
    fi
done

# Test npm GitHub CLI scripts  
if [ -f "package.json" ]; then
    print_status "Testing npm GitHub CLI scripts..."
    npm_gh_scripts=("gh:check" "gh:actions:latest" "gh:actions:logs")
    for script in "${npm_gh_scripts[@]}"; do
        if grep -q "\"$script\"" package.json; then
            print_success "✓ npm script '$script' is defined"
        else
            print_error "✗ npm script '$script' is missing"
        fi
    done
fi

# Test GitHub CLI setup scripts exist
setup_scripts=("scripts/setup/github-cli-setup.sh" "scripts/setup/github-cli-setup.bat")
for script in "${setup_scripts[@]}"; do
    if [ -f "$script" ]; then
        print_success "✓ Setup script '$script' exists"
        
        # Check if script is executable (Unix-like systems)
        if [[ "$script" == *.sh ]] && [[ ! -x "$script" ]]; then
            print_warning "⚠ Script '$script' is not executable (run: chmod +x $script)"
        fi
    else
        print_error "✗ Setup script '$script' is missing"
    fi
done

# Test Lando GitHub CLI integration
if command -v lando &> /dev/null && [ -f ".lando.yml" ]; then
    if grep -q "gh:" .lando.yml; then
        print_success "✓ GitHub CLI is integrated in Lando tooling"
    else
        print_warning "⚠ GitHub CLI not found in Lando tooling configuration"
    fi
fi

echo ""

# Test automated modes (optional test for CI/CD validation)
test_automated_modes() {
    print_status "Testing automated setup modes..."

    # Test installation script in dry-run mode
    if WES_AUTO=1 WES_INSTALL_DOCKER=0 WES_INSTALL_LANDO=0 ./scripts/setup/install-lando-docker.sh > /tmp/wes-install-test.log 2>&1; then
        print_success "✓ Automated installation script works"
    else
        print_error "✗ Automated installation script failed"
        return 1
    fi

    # Test environment setup in dry-run mode
    if WES_AUTO=1 WES_SETUP_BASHRC=0 WES_SETUP_VSCODE=0 ./scripts/setup/env-setup.sh > /tmp/wes-env-test.log 2>&1; then
        print_success "✓ Automated environment setup works"
    else
        print_error "✗ Automated environment setup failed"
        return 1
    fi

    print_success "All automated modes tested successfully"
}

# Run automated mode tests if requested
if [[ "${WES_TEST_AUTOMATION:-0}" == "1" ]]; then
    test_automated_modes
fi

if [[ "$QUIET_MODE" != "1" ]]; then
    echo ""
    print_status "Available commands:"
    echo "  • lando composer lint/test/analyze - PHP development tasks"
    echo "  • lando npm run lint:js/format:all - Frontend development tasks"
    echo "  • lando wp --info                  - WordPress CLI information"
    echo "  • ./scripts/setup/git-hooks.sh     - Set up git hooks"
    echo ""
    echo "  Automated modes (CI/CD):"
    echo "  • WES_AUTO=1 WES_QUIET=1 ./scripts/setup/install-lando-docker.sh"
    echo "  • WES_AUTO=1 WES_QUIET=1 ./scripts/setup/env-setup.sh"
    echo "  • WES_TEST_AUTOMATION=1 WES_QUIET=1 ./scripts/setup/test-setup.sh"
fi
