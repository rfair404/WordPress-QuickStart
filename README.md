# WordPress Quickstart

[![GitHub Issues](https://img.shields.io/github/issues/rfair404/WordPress-QuickStart)](https://github.com/rfair404/WordPress-QuickStart/issues)
[![GitHub Stars](https://img.shields.io/github/stars/rfair404/WordPress-QuickStart)](https://github.com/rfair404/WordPress-QuickStart)
[![GitHub Forks](https://img.shields.io/github/forks/rfair404/WordPress-QuickStart)](https://github.com/rfair404/WordPress-QuickStart/fork)

A WordPress quickstart application with features for modern WordPress development and deployment.

**Repository:**
[https://github.com/rfair404/WordPress-QuickStart](https://github.com/rfair404/WordPress-QuickStart)

## Features

- WordPress user authentication system
- Content management and customization
- Custom themes and plugins support
- **GitHub CLI integration** (Actions monitoring, PR management)
- **Cross-platform Lando wrapper** (Windows, Mac, Linux compatibility)
- **Testing setup** (Unit + E2E with Playwright)
- **CI/CD pipeline** (3 workflows, quality gates)
- **Docker development environment** with Lando
- **VS Code development tools** integration
- **WordPress VIP coding standards** compliance
- **Frontend tooling** (ESLint, Prettier, Stylelint)
- **Performance monitoring** and health checks
- **Automated dependency management** (Dependabot for Composer, npm, and GitHub Actions)
- **Setup** and environment management
- **Environment-aware configuration** (local vs CI optimization)

## Quick Start

### Prerequisites

**Important: This project requires Lando and Docker to be installed before you can run the
development environment.**

#### Automated Installation (Recommended)

We provide automated installation scripts that download and install both Docker Desktop and Lando
for you:

```bash
# For Windows (Git Bash/PowerShell)
.\scripts\setup\install-lando-docker.bat

# For Mac/Linux/WSL
./scripts/setup/install-lando-docker.sh
```

**What the installer does:**

- Downloads latest versions of Docker Desktop and Lando
- Runs official installers with proper configurations
- Verifies installations and provides next steps
- Handles different operating systems automatically

**Automated Mode (No Prompts)**

For CI/CD or automated setups, you can run the installation scripts without interactive prompts:

```bash
# Install both Docker and Lando automatically
WQS_AUTO=1 ./scripts/setup/install-lando-docker.sh

# Silent installation with minimal output
WQS_AUTO=1 WQS_QUIET=1 ./scripts/setup/install-lando-docker.sh

# Skip Docker, install only Lando
WQS_AUTO=1 WQS_INSTALL_DOCKER=0 ./scripts/setup/install-lando-docker.sh

# Force reinstall of Lando even if already installed
WQS_AUTO=1 WQS_FORCE_LANDO=1 ./scripts/setup/install-lando-docker.sh

# Environment setup without prompts
WQS_AUTO=1 ./scripts/setup/env-setup.sh

# Silent environment setup
WQS_AUTO=1 WQS_QUIET=1 ./scripts/setup/env-setup.sh
```

#### Manual Installation

If you prefer to install manually:

1. **Docker Desktop** - Container platform (required by Lando)
   - **Windows/Mac**: [Download Docker Desktop](https://www.docker.com/products/docker-desktop/)
   - **Linux**: [Install Docker Engine](https://docs.docker.com/engine/install/)
   - Ensure Docker Desktop is running before starting Lando

2. **Lando** - Local development environment
   - [Download Lando](https://github.com/lando/lando/releases/latest)
   - Choose the appropriate installer for your operating system
   - Lando manages PHP, MySQL, Node.js, and all development tools

#### Optional Software

- [Composer](https://getcomposer.org/) - PHP dependency management (included in Lando)
- [Node.js](https://nodejs.org/) (v18+) - JavaScript runtime (included in Lando)
- [Git](https://git-scm.com/) - Version control
- [GitHub CLI](https://cli.github.com/) - GitHub Actions monitoring and repository management

### Installation

1. **Verify Prerequisites**

   Make sure Docker Desktop is installed and running:

   ```bash
   docker --version
   docker compose version    # Modern Docker includes compose
   ```

   Make sure Lando is installed:

   ```bash
   lando version
   ```

2. **Clone the repository**

   **Prerequisites**: Make sure you have SSH keys set up for GitHub. If not, follow
   [GitHub's SSH key setup guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).

   ```bash
   git clone git@github.com:rfair404/WordPress-QuickStart.git
   cd WordPress-QuickStart
   ```

   **Tip**: If you forked this repository, use your fork's SSH URL instead:
   `git@github.com:yourusername/WordPress-QuickStart.git`

3. **Start the development environment**

   ```bash
   lando start
   ```

   **⏱ First-time setup**: The initial `lando start` will take 5-10 minutes as it:
   - Downloads WordPress, PHP, MySQL, and Node.js Docker images
   - Builds custom containers with your project configuration
   - Sets up the database and installs WordPress
   - Configures SSL certificates for HTTPS development

4. **Install dependencies**

   ```bash
   # Install PHP dependencies and configure coding standards
   lando composer dev:setup

   # Install Node.js dependencies
   lando npm install
   ```

5. **Set up development environment** (Optional but Recommended)

   Configure your terminal and VS Code with project-specific shortcuts and settings:

   ```bash
   # Windows (PowerShell/Command Prompt)
   .\scripts\setup\env-setup.bat

   # Mac/Linux/Git Bash/WSL
   ./scripts/setup/env-setup.sh
   ```

   **What this does**:
   - Adds helpful aliases (`goto-src`, `wqs-start`, `wqs-stop`, etc.)
   - Configures VS Code settings for Git Bash integration
   - Sets up custom terminal prompt with git branch info
   - Creates project navigation shortcuts

6. **Test the setup**

   Run the setup test to verify everything is working:

   ```bash
   # On Windows
   .\scripts\setup\test-setup.bat

   # On Mac/Linux/Git Bash
   ./scripts/setup/test-setup.sh
   ```

7. **Set up VS Code GitHub Integration** (Recommended for Development)

   Enable GitHub Actions monitoring, Pull Request management, and repository integration directly in
   VS Code:

   ```bash
   # Windows (Command Prompt/PowerShell)
   scripts\setup\github-integration.bat

   # Mac/Linux/Git Bash/WSL
   bash scripts/setup/github-integration.sh
   ```

   **What this sets up**:
   - **Extensions**: GitHub Pull Requests, GitHub Actions, Git Graph, GitHub Repositories
   - **CI/CD Monitoring**: Real-time GitHub Actions status in VS Code status bar
   - **PR Management**: Create, review, and merge Pull Requests from VS Code
   - **Repository Tools**: Visual git history, branch management, issue tracking

   **GitHub Authentication** (Required after running the script):
   1. **Create Personal Access Token**:
      - Go to:
        [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)
      - Click "Generate new token (classic)"
      - **Required scopes**:
        - `repo` - Full control of private repositories
        - `workflow` - Update GitHub Action workflows
        - `read:org` - Read org and team membership
        - `user:email` - Access user email addresses
      - Copy the generated token

   2. **Configure in VS Code**:
      - Press `Ctrl+Shift+P` (Command Palette)
      - Type: `GitHub: Sign In`
      - Select "Use Personal Access Token"
      - Paste your token

   **After authentication, you can**:
   - Monitor your CI/CD pipeline status in VS Code status bar
   - View GitHub Actions logs directly in the editor
   - Create and review Pull Requests without leaving VS Code
   - Get notifications when builds fail/succeed
   - Browse repository files and commit history visually

8. **Access your development site**

   Once `lando start` completes, your site will be available at these URLs:

   | Service             | URL                                             | Notes                                |
   | ------------------- | ----------------------------------------------- | ------------------------------------ |
   | **Main Site**       | https://wordpress-quickstart.lndo.site          | Your WordPress front-end             |
   | **Admin Dashboard** | https://wordpress-quickstart.lndo.site/wp-admin | Username: `admin`, Password: `admin` |
   | **Email Testing**   | https://mail.wordpress-quickstart.lndo.site     | MailHog catches all emails           |
   | **Database Access** | `lando info`                                    | Get database connection details      |

   **Troubleshooting**: If URLs don't work, run `lando info` to see your actual URLs.

## Complete Setup Workflow

Here's the full workflow from a fresh system to a running development environment:

### New Developer Quick Start (5-10 minutes)

````bash
# Step 1: Install prerequisites (automated)
./scripts/setup/install-lando-docker.sh    # Mac/Linux/WSL
# OR
.\scripts\setup\install-lando-docker.bat   # Windows

# Step 2: Clone and enter project
```bash
git clone git@github.com:rfair404/WordPress-QuickStart.git
cd WordPress-QuickStart

# Step 3: Install WordPress via Composer
composer install                           # Downloads WordPress to wp/ directory

# Step 4: Start development environment (takes 5-10 minutes first time)
lando start                                 # Also generates wp-config.php automatically

# Step 5: Install development dependencies
lando composer dev:setup
lando npm install

# Step 6: Configure development environment (optional)
./scripts/setup/env-setup.sh               # Mac/Linux/WSL
# OR
.\scripts\setup\env-setup.bat              # Windows

# Step 6: Verify everything works
./scripts/setup/test-setup.sh              # Mac/Linux/WSL
# OR
.\scripts\setup\test-setup.bat             # Windows

# Step 7: Open your site
# Visit: https://wordpress-quickstart.lndo.site
````

### CI/CD and Automation

All setup scripts support automated mode for continuous integration and deployment workflows:

```bash
# Complete automated setup (no user interaction)
WQS_AUTO=1 ./scripts/setup/install-lando-docker.sh
WQS_AUTO=1 ./scripts/setup/env-setup.sh

# Test automation features
WQS_TEST_AUTOMATION=1 ./scripts/setup/test-setup.sh

# Get help for any script
./scripts/setup/install-lando-docker.sh --help
./scripts/setup/env-setup.sh --help
```

**Environment Variables for Automation:**

- `WQS_AUTO=1` - Enable automated mode (no prompts)
- `WQS_QUIET=1` - Reduce output verbosity (silent mode)
- `WQS_DEBUG=1` - Enable debug output for troubleshooting
- `WQS_ERROR_TOLERANT=1` - Continue on errors instead of exiting
- `WQS_INSTALL_DOCKER=0/1` - Control Docker installation
- `WQS_INSTALL_LANDO=0/1` - Control Lando installation
- `WQS_FORCE_LANDO=1` - Force Lando reinstall
- `WQS_SETUP_BASHRC=0/1` - Control .bashrc setup
- `WQS_SETUP_VSCODE=0/1` - Control VS Code workspace setup

**Error Tolerance & Debugging:**

````bash
# Debug mode - shows detailed execution steps
WQS_AUTO=1 WQS_DEBUG=1 ./scripts/setup/install-lando-docker.sh

# Error tolerant mode - continues on non-critical failures
WQS_AUTO=1 WQS_ERROR_TOLERANT=1 ./scripts/setup/install-lando-docker.sh

# Combined debugging and error tolerance
WQS_AUTO=1 WQS_DEBUG=1 WQS_ERROR_TOLERANT=1 ./scripts/setup/install-lando-docker.sh

# Run comprehensive test suite
./scripts/setup/test-runner.sh
```### Daily Development Workflow

```bash
# Start your day
lando start                    # Start the development environment
lando info                     # Get current URLs and status

# Development tasks
lando wp plugin list           # WordPress CLI commands
lando composer test            # Run PHP tests
lando npm run dev             # Start frontend development server
lando npm run lint:js         # Check JavaScript code quality

# End your day
lando stop                     # Stop the environment (saves resources)
````

## Development Environment

### Terminal Setup

The project includes a comprehensive `.bashrc` file with:

- **Environment variables** for all project paths
- **Aliases** for common development tasks
- **Helper functions** for project management
- **Custom prompt** showing git branch and Lando status
- **Auto-completion** for git and npm commands

#### Git Bash / WSL Setup

```bash
# Run the environment setup script
./scripts/setup/env-setup.sh

# Or manually source the .bashrc
source .bashrc

# View available commands
wqs_help
```

#### PowerShell Setup

```powershell
# Run the environment setup
.\scripts\setup\env-setup.bat

# Import PowerShell profile
. .\scripts\setup\powershell-profile.ps1
```

### VS Code Integration

The environment setup configures VS Code with:

- **Git Bash** as the default terminal
- **Automatic .bashrc sourcing** in terminals
- **Format on save** enabled
- **Custom tasks** for Lando, testing, and linting
- **File associations** for project files
- **GitHub integration** with Actions monitoring, PR management, and repository tools

#### Enhanced GitHub Workflow

With the GitHub integration extensions installed, VS Code provides:

- **Real-time CI/CD monitoring** - GitHub Actions status in status bar
- **Pull Request management** - Create, review, and merge PRs in editor
- **Visual git history** - Interactive commit history and branch visualization
- **Build notifications** - Immediate feedback on test failures/successes
- **Repository browser** - Browse remote files without cloning
- **Issue integration** - Link commits and PRs to GitHub issues

Run the GitHub integration setup script to enable these features (see Quick Start step 7).

### Available Commands

After sourcing `.bashrc`, you'll have access to:

```bash
# Project functions
wqs_info          # Show project information
wqs_setup         # Complete development setup
wqs_test          # Run all tests
wqs_clean         # Clean development environment
wqs_help          # Show all available commands

# Development shortcuts
dev-setup         # Install dependencies
dev-test          # Run all tests
dev-lint          # Run all linters
dev-fix           # Fix linting issues
dev-format        # Format all files
dev-build         # Build assets
dev-watch         # Start dev server

# Navigation shortcuts
goto-src          # cd to src/
goto-tests        # cd to tests/
goto-scripts      # cd to scripts/
goto-config       # cd to .config/
goto-docs         # cd to docs/
goto-root         # cd to project root
```

## WordPress Management

This project uses **Composer to manage WordPress** as a dependency, keeping it separate from your
custom code in the `wp/` directory.

### Why Composer-managed WordPress?

- **Clean separation** between WordPress core and your custom code
- **Version control** - WordPress updates are managed through Composer
- **Security** - Easy to update WordPress core and plugins
- **Professional workflow** - Standard in enterprise WordPress development

### Directory Structure

```
project-root/
├── wp/                          # WordPress installation (managed by Composer)
│   ├── wp-admin/               # WordPress admin (auto-installed)
│   ├── wp-includes/            # WordPress core (auto-installed)
│   └── wp-config.php           # Auto-generated configuration
├── custom/                     # YOUR CUSTOM CONTENT DIRECTORY
│   ├── plugins/                # Plugins (installed via Composer)
│   ├── themes/                 # Themes (installed via Composer)
│   ├── uploads/                # Media uploads (gitignored)
│   └── mu-plugins/             # Must-use plugins
├── src/                        # Your custom PHP code
├── tests/                      # Your tests
└── composer.json               # WordPress and plugin dependencies
```

### WordPress Installation Methods

**Option 1: Full Installation (Recommended)**

```bash
lando start                                        # Start development environment
./scripts/wp-manager.sh install:full              # Complete installation with sample content
```

**Option 2: Basic Installation**

```bash
./scripts/wp-manager.sh install                   # Install WordPress files only
# Then visit your site to complete setup manually
```

**What's included in Full Installation:**

- WordPress core installation and configuration
- Database setup and admin user creation
- Sample pages (Home, About, Contact, Shop, Blog)
- Sample blog posts
- Navigation menu creation
- Pretty permalinks (`/%postname%/`)
- Optional storefront configuration (configure storefront plugins separately)
- Professional WordPress settings

### WordPress Management Commands

Use the provided WordPress manager script:

```bash
# WordPress Core Management
./scripts/wp-manager.sh install                    # Basic WordPress installation
./scripts/wp-manager.sh install:full               # Full installation with sample content
./scripts/wp-manager.sh update                     # Update WordPress core
./scripts/wp-manager.sh version                    # Show WordPress version
./scripts/wp-manager.sh status                     # Show installation status

# Plugin Management
./scripts/wp-manager.sh plugin:install yoast        # Install Yoast SEO
./scripts/wp-manager.sh plugin:install contact-form-7 # Install Contact Form 7
./scripts/wp-manager.sh plugin:remove pluginname    # Remove a plugin
./scripts/wp-manager.sh plugin:list                 # List installed plugins

# Theme Management
./scripts/wp-manager.sh theme:install twentytwentyfour  # Install default theme
./scripts/wp-manager.sh theme:remove themename          # Remove a theme
./scripts/wp-manager.sh theme:list                      # List installed themes

# Utility Commands
./scripts/wp-manager.sh config:generate             # Regenerate wp-config.php
./scripts/wp-manager.sh cleanup                     # Clean cache and temp files
```

### Alternative: Direct Composer Commands

You can also use Composer directly:

```bash
# WordPress Core
composer install                                    # Install WordPress
composer update johnpbloch/wordpress-core           # Update WordPress
composer show johnpbloch/wordpress-core             # Show version

# Plugins (from WordPress.org)
composer require wpackagist-plugin/yoast            # Install Yoast SEO
composer require wpackagist-plugin/contact-form-7   # Install Contact Form 7
composer remove wpackagist-plugin/pluginname        # Remove a plugin

# Themes (from WordPress.org)
composer require wpackagist-theme/twentytwentyfour  # Install default theme
composer require wpackagist-theme/astra             # Install Astra
composer remove wpackagist-theme/themename          # Remove theme

# Development plugins
composer require wpackagist-plugin/query-monitor --dev  # Dev-only plugin
composer require wpackagist-plugin/debug-bar --dev      # Debug tools
```

### Quick Start Commands

```bash
# Complete WordPress setup with sample content
lando start                                         # Start development server
./scripts/wp-manager.sh install:full               # Full WordPress installation with sample content

# OR Basic setup (manual WordPress setup required)
composer install                                    # Install WordPress core only
./scripts/wp-manager.sh plugin:install yoast        # Add Yoast SEO (optional)
./scripts/wp-manager.sh theme:install twentytwentyfour  # Add default theme

# Validate installation
composer test:wordpress                             # Run WordPress validation tests

# Your site is ready!
open https://wordpress-ecommerce-starter.lndo.site
```

### Configuration

- **WordPress config** is auto-generated at `wp/wp-config.php`
- **Content directory** is custom-named `custom/` at project root (instead of `wp-content/`)
- **Database settings** are configured for Lando automatically
- **Debug mode** is enabled for development
- **File editing** is disabled for security (use Composer instead)

### Important Notes

- **Never edit files in `wp/`** - they're managed by Composer
- **Your content lives in `custom/`** at the project root, separate from WordPress core
- **Add custom themes/plugins** via Composer or put them in the `custom/` directory
- **The `wp/` directory is gitignored** - WordPress is installed via Composer
- **Uploads and cache** in `custom/` are preserved but not version controlled

### WordPress Installation Testing

Validate your WordPress installation with comprehensive tests:

```bash
# Run all WordPress validation tests
composer test:wordpress

# Run individual test suites
composer test:wp-installation              # Shell script validation
composer test:wp-unit                      # PHPUnit WordPress tests
bash tests/validate-wordpress-installation.sh  # Direct shell validation

# Run E2E tests for WordPress
npm run test:e2e:wordpress                 # Playwright browser tests
```

**What gets tested:**

- WordPress directory structure
- Core files and directories exist
- wp-config.php is properly configured
- Database connection works
- Plugin and theme directory structure
- Composer installation integrity
- File permissions and security
- WordPress version validation
- Browser accessibility tests

## Development Workflow

### GitHub CLI Integration

This project includes comprehensive GitHub CLI integration for enhanced development workflow:

#### Installation

GitHub CLI can be installed automatically during environment setup, or manually:

```bash
# Automatic installation via setup script
./scripts/setup/github-cli-setup.sh

# Windows (using winget)
winget install GitHub.cli

# macOS (using Homebrew)
brew install gh

# Manual installation: https://cli.github.com/
```

#### Available Commands

**Composer shortcuts:**

```bash
lando composer gh:check      # Check GitHub CLI installation status
lando composer gh:actions    # List recent workflow runs
lando composer gh:auth       # Check authentication status
```

**npm shortcuts:**

```bash
lando npm run gh:check           # Check GitHub CLI installation
lando npm run gh:actions:latest  # View latest workflow run details
lando npm run gh:actions:logs    # View failed workflow logs
```

**Direct GitHub CLI commands:**

```bash
gh run list                      # List recent workflow runs
gh run view --log-failed         # View failed run logs
gh run view <run-id>             # View specific run details
gh auth login                    # Authenticate with GitHub
gh repo view                     # View repository information
```

#### GitHub Actions Monitoring & Troubleshooting

This project includes a custom `gh-wrapper.sh` script that provides consistent GitHub CLI operations
with validation.

**Using the GitHub CLI Wrapper:**

```bash
# View recent workflow runs
bash scripts/gh-wrapper.sh run list --limit 5

# Check latest build status
bash scripts/gh-wrapper.sh run list --json databaseId --limit 1 --jq '.[0].databaseId'

# View detailed build information
bash scripts/gh-wrapper.sh run view <run-id>

# View failed logs for troubleshooting
bash scripts/gh-wrapper.sh run view <run-id> --log-failed

# Rerun failed workflows
bash scripts/gh-wrapper.sh run rerun <run-id>

# View repository information
bash scripts/gh-wrapper.sh repo view
```

**Legacy Composer Commands (for reference):**

```bash
# Quick diagnosis (if GitHub CLI is available)
lando npm run gh:actions:logs    # View latest failed logs

# Direct GitHub CLI usage
gh run list --status failure     # List all failed runs
gh run view <run-id> --log-failed # View specific failure logs
gh run rerun <run-id>            # Rerun failed workflow
```

#### CI/CD Behavior

**Note**: GitHub CLI tests automatically skip in CI/CD environments to avoid issues where GitHub CLI
might not be available or needed. The system detects CI/CD environments using common environment
variables (`CI`, `GITHUB_ACTIONS`, `GITLAB_CI`, etc.).

- **Local Development**: All GitHub CLI tests and functionality available
- ⏭ **CI/CD Pipelines**: GitHub CLI tests skipped automatically
- **Override**: Set `WQS_CI_MODE=0` to force GitHub CLI tests in CI/CD

### Code Quality & Linting

This project enforces strict coding standards using multiple linting tools:

```bash
# PHP Code Standards (WordPress VIP)
lando phpcs                    # Check PHP code standards
lando phpcbf                   # Fix PHP code standards automatically

# JavaScript/CSS Linting
lando npm run lint:js          # Check JavaScript with ESLint
lando npm run lint:js:fix      # Fix JavaScript issues
lando npm run lint:css         # Check CSS with Stylelint
lando npm run lint:css:fix     # Fix CSS issues

# File formatting
lando npm run format           # Format all files with Prettier
lando npm run format:check     # Check file formatting
```

### Testing

#### Unit Tests

```bash
# PHP Tests
lando test                     # Run PHPUnit tests
lando composer test:coverage   # Run tests with coverage report

# JavaScript Tests
lando npm test                 # Run JavaScript unit tests
lando npm run test:watch       # Run tests in watch mode
```

#### End-to-End Testing with Playwright

Our comprehensive E2E testing suite uses Playwright to test WordPress functionality:

```bash
# First, install Playwright browsers
npm run test:e2e:install      # Install browser dependencies

# Run E2E tests (make sure your site is running first)
lando start                   # Start WordPress site
npm run test:e2e              # Run all E2E tests

# Different test modes
npm run test:e2e:headed       # Run with browser UI visible
npm run test:e2e:debug        # Debug mode with dev tools
npm run test:e2e:ui           # Interactive test runner UI

# Specific test suites
npm run test:e2e:wordpress    # WordPress-only tests
npm run test:e2e:visual       # Visual regression tests

# Generate test code
npm run test:e2e:codegen      # Record and generate test code

# View test reports
npm run test:e2e:report       # Open HTML test report
```

#### Test Categories

- **WordPress Core Tests** (`@wordpress`): Admin login, post creation, settings, themes, plugins
- **Visual Regression Tests** (`@visual`): Screenshot comparisons across devices and themes
- **Debug Tests**: Environment inspection, health checks, performance monitoring

#### Running Tests in CI/CD

```bash
# Full test suite including E2E
lando start && WQS_RUN_E2E=1 ./scripts/setup/test-runner.sh

# Test with different configurations
WQS_AUTO=1 WQS_DEBUG=1 ./scripts/setup/test-runner.sh
```

#### Test Configuration

Configure tests via environment variables:

```bash
# Playwright configuration
PLAYWRIGHT_BASE_URL=https://your-site.lndo.site  # Override base URL
WP_ADMIN_USER=admin                               # Admin username
WP_ADMIN_PASSWORD=password                        # Admin password
# Storefront / plugin customer credentials (optional)
# Add customer credentials only if you include a storefront/plugin that requires them

# Test execution
WQS_RUN_E2E=1                                    # Enable E2E tests in test runner
PLAYWRIGHT_DEBUG=1                               # Enable Playwright debug mode
```

### Development Tools

```bash
# Code quality and formatting
lando npm run lint:js          # Check JavaScript for linting issues
lando npm run lint:js:fix      # Fix JavaScript linting issues automatically
lando npm run lint:css         # Check CSS/SCSS for style issues
lando npm run lint:css:fix     # Fix CSS/SCSS style issues automatically
lando npm run format           # Format all files with Prettier
lando npm run format:check     # Check if files are properly formatted

# Testing
lando npm run test             # Run E2E tests (default)
lando npm run test:e2e         # Run Playwright E2E tests
lando npm run test:e2e:headed  # Run E2E tests with browser UI
lando npm run test:e2e:debug   # Debug E2E tests step-by-step
```

### Useful Lando Commands

```bash
# WordPress CLI
lando wp --info               # WordPress information
lando wp plugin list          # List installed plugins
lando wp theme list           # List installed themes

# Database
lando db-import database.sql  # Import database
lando db-export               # Export database

# Logs
lando logs                    # View application logs
```

## Project Structure

```
wordpress-ecommerce-starter/
├── .config/                  # Configuration files
│   ├── linting/             # PHPCS, ESLint, Stylelint configs
│   ├── testing/             # PHPUnit configuration
│   └── formatting/          # Prettier configuration
├── .github/workflows/        # GitHub Actions CI/CD pipelines
├── .vscode/                  # VS Code workspace settings
├── docs/                     # Project documentation
│   ├── CONTRIBUTING.md      # How to contribute
│   └── CHANGELOG.md         # Version history
├── scripts/setup/            # Setup and installation scripts
│   ├── install-lando-docker.* # Automated dependency installation
│   ├── env-setup.*          # Development environment configuration
│   ├── test-setup.*         # Setup verification
│   └── git-hooks.*          # Git hook installation
├── src/                      # Custom PHP classes (PSR-4 autoloaded)
│   └── WQS_Sample_Utility.php # Example utility class
├── tests/                    # PHPUnit test suite
│   ├── bootstrap.php        # Test environment setup
│   └── unit/                # Unit tests
├── .bashrc                   # Terminal aliases and functions
├── .lando.yml                # Lando development environment config
├── composer.json             # PHP dependencies and scripts
├── package.json              # Node.js dependencies and scripts
└── README.md                 # This documentation
```

### Key Files Explained

| File/Directory   | Purpose                                  | When You'll Use It                                         |
| ---------------- | ---------------------------------------- | ---------------------------------------------------------- |
| `.lando.yml`     | Development environment configuration    | Modify for custom PHP/Node versions or add services        |
| `composer.json`  | PHP dependencies and development scripts | Add new PHP packages or custom scripts                     |
| `package.json`   | Node.js tools and frontend dependencies  | Add new JavaScript tools or frontend packages              |
| `src/`           | Your custom PHP classes                  | Add business logic, utilities, or WordPress customizations |
| `tests/`         | Automated tests                          | Ensure your code works correctly                           |
| `scripts/setup/` | Automation scripts                       | One-time setup and maintenance tasks                       |
| `.config/`       | Tool configurations                      | Customize linting rules, test settings, formatting         |

## Coding Standards

This project follows:

- **WordPress VIP Coding Standards** for PHP
- **WordPress JavaScript Coding Standards** for JS
- **WordPress CSS Coding Standards** for CSS
- **PSR-4** autoloading for custom PHP classes
- **GPL-2.0-or-later** license compliance

### Code Formatting

All code is automatically formatted using:

- **PHP_CodeSniffer** and **PHPCBF** for PHP
- **ESLint** for JavaScript
- **Stylelint** for CSS
- **Prettier** for JSON, YAML, Markdown

### Git Hooks & Pre-commit Automation

The project includes comprehensive git hooks that automatically:

- **Pre-commit**: Run Prettier on all staged files and fix linting issues
- **Pre-push**: Execute optimized test suite for fast validation (smoke tests, WordPress validation,
  linting)
- **Commit-msg**: Validate commit message format (conventional commits)

> **Note**: The pre-push hook runs only essential fast checks. The complete test suite (PHPUnit,
> full E2E tests) runs in CI/CD pipelines to ensure thorough validation without slowing down local
> development.

#### Setting Up Git Hooks

The hooks are automatically installed when you run the development setup:

```bash
# Automatically installs hooks
lando composer dev:setup
```

Or install them manually:

```bash
# Windows
.\setup-git-hooks.bat

# Mac/Linux
./setup-git-hooks.sh

# Or via npm
lando npm run hooks:setup
```

#### Bypassing Hooks (when needed)

```bash
# Skip pre-commit hooks
git commit --no-verify -m "emergency fix"

# Skip pre-push hooks
git push --no-verify
```

#### Supported Commit Message Format

The commit-msg hook enforces conventional commit format:

```
feat(scope): add new feature
fix(scope): resolve bug issue
docs: update documentation
style: formatting changes
refactor: code restructuring
test: add or update tests
chore: maintenance tasks
```

## Deployment

### Staging Deployment

Automatic deployment to staging happens on every push to the `develop` branch.

### Production Deployment

Create a pull request from `develop` to `main` for production deployment.

## Environment Variables

Create a `.env` file in the root directory for local configuration:

```env
# WordPress Configuration
WP_ENVIRONMENT_TYPE=local
WP_DEBUG=true
WP_DEBUG_LOG=true
WP_DEBUG_DISPLAY=false

# Database Configuration (handled by Lando)
DB_NAME=wordpress
DB_USER=wordpress
DB_PASSWORD=wordpress
DB_HOST=database

# Storefront configuration (optional - configure storefront plugins separately)
PAYMENT_GATEWAY_TEST_MODE=true
# Add payment gateway keys if needed when using a storefront plugin
```

## Contributing

1. [Fork the repository](https://github.com/rfair404/WordPress-QuickStart/fork)
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following the coding standards
4. Run tests and linting (`lando test && lando npm test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. [Open a Pull Request](https://github.com/rfair404/WordPress-QuickStart/compare)

### Code Review Process

All pull requests must:

- Pass all automated tests
- Meet coding standards (automated checks)
- Include appropriate documentation
- Have meaningful commit messages
- Be reviewed by at least one maintainer

## License

This project is licensed under the GPL-2.0-or-later License - see the [LICENSE](LICENSE) file for
details.

## Troubleshooting

### First-Time Setup Issues

#### Prerequisites Not Installed

**Problem**: `docker: command not found` or `lando: command not found`

```bash
# Solution: Use our automated installer
./scripts/setup/install-lando-docker.sh    # Mac/Linux/WSL
.\scripts\setup\install-lando-docker.bat   # Windows

# Or install manually from official sources
```

#### Docker Desktop Not Running

**Problem**: `Cannot connect to the Docker daemon`

```bash
# Solution: Start Docker Desktop
# Windows: Start Menu → Docker Desktop
# Mac: Applications → Docker Desktop
# Linux: sudo systemctl start docker

# Verify Docker is running
docker --version
docker ps
```

#### Lando First Start Taking Too Long

**Problem**: `lando start` seems stuck or very slow

```bash
# This is normal! First-time setup downloads several GB of Docker images
# Expected time: 5-10 minutes depending on internet speed
# Watch progress with:
lando logs -f

# If truly stuck (>15 minutes), try:
lando destroy -y
lando start
```

#### Site URLs Not Working

**Problem**: https://wordpress-ecommerce-starter.lndo.site returns connection error

```bash
# Solution: Check your actual URLs
lando info

# URLs might be different if you changed the project name
# Look for the "urls" section in the output
```

### Common Development Issues

#### Docker/Lando Issues

- **"Cannot connect to the Docker daemon"**: Make sure Docker Desktop is running
- **"lando: command not found"**: Restart terminal after installation or use our installer
- **Slow performance**: Allocate more memory to Docker Desktop (4GB+ recommended)
- **Port conflicts**: Stop other local servers or change ports in `.lando.yml`
- **"No space left on device"**: Clean up Docker with `docker system prune -a`

#### Windows-Specific Issues

- **File permission errors**: Run PowerShell as Administrator
- **Path issues**: Use forward slashes in file paths when possible
- **Line ending issues**: Configure Git to handle line endings:
  `git config --global core.autocrlf true`

#### Getting Help

```bash
# View Lando logs
lando logs

# Restart Lando environment
lando restart

# Rebuild Lando environment (if config changes)
lando rebuild

# Get detailed environment info
lando info
```

## Setup Scripts Reference

The `scripts/setup/` directory contains several automated setup scripts to streamline your
development environment:

### Installation Scripts

| Script                     | Purpose                             | Platform                         |
| -------------------------- | ----------------------------------- | -------------------------------- |
| `install-lando-docker.sh`  | Auto-install Docker Desktop + Lando | macOS, Linux, Windows (Git Bash) |
| `install-lando-docker.bat` | Auto-install Docker Desktop + Lando | Windows (PowerShell/CMD)         |

**Features:**

- Downloads latest versions automatically
- Handles different operating systems
- Verifies installations
- Provides post-install instructions
- Interactive prompts for user control

### Environment Setup Scripts

| Script          | Purpose                                  | Platform          |
| --------------- | ---------------------------------------- | ----------------- |
| `env-setup.sh`  | Configure terminal environment & VS Code | Unix-like systems |
| `env-setup.bat` | Configure terminal environment & VS Code | Windows           |

**What they do:**

- Configure `.bashrc` with project aliases and functions
- Set up VS Code workspace settings
- Configure Git Bash integration
- Add development shortcuts and navigation

### Testing Scripts

| Script           | Purpose                        | Platform          |
| ---------------- | ------------------------------ | ----------------- |
| `test-setup.sh`  | Verify development environment | Unix-like systems |
| `test-setup.bat` | Verify development environment | Windows           |

**Verification includes:**

- Docker and Lando installation
- Project configuration files
- Development dependencies
- Tool availability and versions

### Git Hook Scripts

| Script          | Purpose                     | Platform          |
| --------------- | --------------------------- | ----------------- |
| `git-hooks.sh`  | Install automated git hooks | Unix-like systems |
| `git-hooks.bat` | Install automated git hooks | Windows           |

**Hook features:**

- Pre-commit: Prettier formatting + linting
- Pre-push: Optimized test suite (smoke tests, WordPress validation, linting)
- Commit-msg: Conventional commit validation

> **Note**: Full test suite (PHPUnit, complete E2E tests) runs in CI/CD for comprehensive
> validation.

### Usage Examples

```bash
# Complete new environment setup
./scripts/setup/install-lando-docker.sh    # Install prerequisites
./scripts/setup/env-setup.sh               # Configure environment
lando start                                 # Start development server
./scripts/setup/test-setup.sh              # Verify everything works

# Windows equivalent
.\scripts\setup\install-lando-docker.bat   # Install prerequisites
.\scripts\setup\env-setup.bat              # Configure environment
lando start                                 # Start development server
.\scripts\setup\test-setup.bat             # Verify everything works
```

## Maintenance & Monitoring

### Performance Monitoring

Check system performance and health:

```bash
# Quick performance check
./scripts/setup/performance-monitor.sh

# View Docker resource usage
docker system df

# Check Lando status
lando info
```

### Dependency Validation

Validate all required dependencies and versions:

```bash
# Comprehensive dependency check
./scripts/setup/dependency-validator.sh

# Check specific versions
docker --version
lando version
```

### Health Checks

Monitor your development environment:

```bash
# Quick health check
./scripts/setup/performance-monitor.sh

# Full system test
./scripts/setup/test-runner.sh

# Docker health
docker system info
```

## Documentation

### Project Guides

- [Project Structure Guide](docs/PROJECT_STRUCTURE.md) - Comprehensive architecture overview
- [GitHub CLI Integration Guide](docs/GITHUB_CLI_GUIDE.md) - Complete GitHub workflow management
- [Lando Wrapper System Guide](docs/LANDO_WRAPPER_GUIDE.md) - Cross-platform development environment
- [CI/CD Pipeline Guide](docs/CICD_PIPELINE_GUIDE.md) - Enhanced CI/CD pipeline documentation
- [Environment Configuration Guide](docs/ENVIRONMENT_CONFIG_GUIDE.md) - Environment-aware
  configuration
- [VS Code Integration Guide](docs/VSCODE_INTEGRATION_GUIDE.md) - Professional development workflow
- [Playwright E2E Testing Guide](docs/PLAYWRIGHT_GUIDE.md) - End-to-end testing with Playwright
- [Dependabot Configuration Guide](docs/DEPENDABOT_GUIDE.md) - Automated dependency management
- [Contributing Guidelines](docs/CONTRIBUTING.md) - How to contribute to the project
- [Changelog](docs/CHANGELOG.md) - Version history and release notes

### External Resources

- [Bug Reports](https://github.com/rfair404/WordPress-QuickStart/issues)
- [Discussions](https://github.com/rfair404/WordPress-QuickStart/discussions)
- [Lando Documentation](https://docs.lando.dev/)
- [Docker Documentation](https://docs.docker.com/)

## Acknowledgments

- [Lando](https://lando.dev/) for the excellent development environment
- [Docker](https://www.docker.com/) for containerization platform
- [WordPress VIP](https://wpvip.com/) for coding standards
- All the open-source contributors who make this possible
# Test workflow execution - Sun, Oct  5, 2025  9:02:47 PM
