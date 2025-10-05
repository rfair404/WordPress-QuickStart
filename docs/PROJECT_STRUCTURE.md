# Project Structure

This document describes the organized file structure of the WordPress Quickstart project.

## Root Directory

```
wordpress-quickstart/
├── .config/                  # Local configuration files
├── .github/                  # GitHub Actions workflows and templates
├── .lando/                   # Lando-specific configuration
├── .vscode/                  # VS Code workspace settings
├── docs/                     # Project documentation
├── scripts/                  # Setup and automation scripts
├── src/                      # PHP source files
├── tests/                    # All test files and configurations
├── .bashrc                   # Bash environment configuration

├── .gitignore                # Git ignore rules
├── .lando.yml                # Lando configuration
├── composer.json             # PHP dependencies and scripts
├── package.json              # Node.js dependencies and scripts
└── README.md                 # Main project documentation
```

## Core Directories

### `/docs/` - Documentation

```
docs/
├── CHANGELOG.md              # Version history and changes
├── CONTRIBUTING.md           # Contribution guidelines
└── PLAYWRIGHT_GUIDE.md       # E2E testing guide
```

### `/scripts/` - Automation Scripts

```
scripts/
└── setup/                    # Environment setup scripts
    ├── dependency-validator.sh   # Validate system dependencies
    ├── env-setup.sh             # Environment configuration
    ├── env-setup.bat            # Windows environment setup
    ├── git-hooks.sh             # Git hooks installation
    ├── git-hooks.bat            # Windows git hooks
    ├── install-lando-docker.sh  # Docker/Lando installer
    ├── install-lando-docker.bat # Windows installer
    ├── performance-monitor.sh   # System performance monitoring
    ├── test-runner.sh           # Comprehensive test runner
    ├── test-setup.sh            # Test environment setup
    └── test-setup.bat           # Windows test setup
```

### `/src/` - Source Code

```
src/
└── WQS_Sample_Utility.php    # Sample WordPress utility class
```

### `/tests/` - Testing Infrastructure

```
tests/
├── playwright.config.js      # Playwright E2E test configuration
├── bootstrap.php             # PHPUnit bootstrap file
├── e2e/                      # End-to-end tests
│   ├── utils/                # Test utility classes
│   │   ├── wordpress-admin.js    # WordPress admin helpers
│   │   └── test-utils.js         # General test utilities
│   ├── wordpress/            # WordPress core tests
│   │   ├── admin.spec.js     # Admin functionality tests
│   │   └── frontend.spec.js  # Frontend functionality tests
│   ├── storefront/           # Optional storefront tests (project-specific)
│   │   └── shop.spec.js      # Storefront functionality tests (optional)
│   ├── visual/               # Visual regression tests
│   │   └── screenshots.spec.js   # Screenshot comparison tests
│   ├── debug.spec.js         # Debug and inspection tests
│   ├── global-setup.js       # Global test setup
│   └── global-teardown.js    # Global test cleanup
└── unit/                     # PHP unit tests
    └── SampleTest.php        # Sample PHPUnit test
```

## Configuration Files

### Root Level Configuration

- **`.bashrc`** - Bash environment with custom functions and aliases

- **`.gitignore`** - Files and directories to ignore in version control
- **`.lando.yml`** - Lando development environment configuration
- **`composer.json`** - PHP dependencies, autoloading, and scripts
- **`package.json`** - Node.js dependencies and npm scripts

### Directory-Specific Configuration

- **`.github/workflows/`** - CI/CD pipeline definitions
- **`.vscode/settings.json`** - VS Code workspace settings
- **`tests/playwright.config.js`** - E2E testing configuration

## File Naming Conventions

### Scripts

- **`.sh`** - Unix/Linux/Mac shell scripts
- **`.bat`** - Windows batch files
- **`.ps1`** - PowerShell scripts (if needed)

### Tests

- **`*.spec.js`** - Playwright E2E test files
- **`*.test.php`** - PHPUnit test files
- **`*Test.php`** - PHPUnit test classes

### Documentation

- **`*.md`** - Markdown documentation files
- **UPPERCASE.md** - Major documentation files (README, CHANGELOG, etc.)

## Generated Directories (Git Ignored)

These directories are created during development but not tracked in version control:

```
node_modules/                 # Node.js dependencies
vendor/                       # PHP dependencies (Composer)
test-results/                 # Test artifacts and reports
playwright-report/            # Playwright HTML reports
coverage/                     # Code coverage reports
.lando/                      # Lando runtime files
```

## Development Workflow Integration

### Setup Scripts Location

All setup and automation scripts are organized in `/scripts/setup/` for easy discovery and
maintenance.

### Test Organization

- **Unit tests** → `/tests/unit/` (PHP)
- **E2E tests** → `/tests/e2e/` (JavaScript/Playwright)
- **Test config** → `/tests/playwright.config.js`

### Documentation Structure

- **User docs** → `/docs/` (guides, API docs)
- **Code docs** → Inline comments and docblocks
- **Project docs** → Root level (README, CONTRIBUTING)

## Benefits of This Structure

1. **Clear separation of concerns** - Scripts, tests, docs, and source code are logically organized
2. **Easy navigation** - Developers can quickly find what they need
3. **Scalable** - Structure supports growth without reorganization
4. **Tool-friendly** - Follows conventions expected by development tools
5. **CI/CD ready** - Clear paths for automated testing and deployment

## Key Design Decisions

1. **Tests in `/tests/`** - All testing infrastructure in one place
2. **Scripts in `/scripts/setup/`** - All automation tools organized together
3. **Docs in `/docs/`** - Separate directory for substantial documentation
4. **Config at root** - Tool configurations where tools expect them
5. **Platform-specific scripts** - `.sh` and `.bat` versions for cross-platform support

This structure balances organization with tool compatibility and developer productivity.
