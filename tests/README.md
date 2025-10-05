# Test Directory Structure

This directory contains all testing-related files and scripts for the WordPress Quickstart project,
organized contextually for better maintainability.

## Directory Structure

```
tests/
├── README.md                    # This file - test directory documentation
├── bootstrap.php                # PHPUnit bootstrap configuration
├── playwright.config.js         # Playwright E2E testing configuration
│
├── unit/                        # PHP Unit Tests
│   ├── SampleTest.php          # Basic functionality and environment tests
│   └── WordPressInstallationTest.php # WordPress installation validation tests
│
├── e2e/                         # End-to-End Tests (Playwright)
│   ├── debug.spec.js           # Debug and development tests
│   ├── global-setup.js         # Global E2E test setup
│   ├── global-teardown.js      # Global E2E test cleanup
│   └── utils/                  # E2E testing utilities
│   └── visual/                 # Visual regression tests
│   └── wordpress/             # WordPress E2E tests
│
├── analysis/                    # Test Analysis Tools
│   └── analyze-unit-tests.sh  # Analyzes unit test structure and coverage
│
├── validation/                  # Environment Validation Scripts
│   └── validate-wordpress-installation.sh # WordPress setup validation
│
├── runners/                     # Test Execution Scripts
│   ├── run-unit-tests-standalone.sh       # Standalone PHPUnit runner
│   └── run-wordpress-tests.sh             # Comprehensive WordPress test suite
│
└── integration/                 # Integration Test Scripts
    ├── test-project-setup.sh   # Complete project functionality tests
    └── test-wp-installation.sh # WordPress installation process tests
```

## Script Categories

### 📊 Analysis Scripts (`analysis/`)

Tools for analyzing test coverage, structure, and quality metrics.

- **`analyze-unit-tests.sh`** - Provides detailed analysis of PHP unit test files, including method
  counts, test patterns, dependencies, and coverage information.

### ✅ Validation Scripts (`validation/`)

Scripts that validate environment setup and configuration.

- **`validate-wordpress-installation.sh`** - Comprehensive WordPress installation validation
  including directory structure, file permissions, configuration, and composer dependencies.

### 🏃 Test Runners (`runners/`)

Scripts that execute various test suites.

- **`run-unit-tests-standalone.sh`** - Executes PHPUnit tests without requiring Docker/Lando
  environment.
- **`run-wordpress-tests.sh`** - Comprehensive test runner that executes shell scripts, PHPUnit
  tests, code quality checks, and optional E2E tests.

### 🔗 Integration Tests (`integration/`)

Scripts that test complete workflows and system integration.

- **`test-project-setup.sh`** - Tests all project functionality including file structure, script
  syntax, permissions, and WordPress manager commands.
- **`test-wp-installation.sh`** - Tests the WordPress installation process, sample content creation,
  and configuration.

## Usage Examples

### Run All Tests

```bash
# From project root
./tests/runners/run-wordpress-tests.sh
```

### Validate Environment

```bash
# Check WordPress installation
./tests/validation/validate-wordpress-installation.sh

# Environment Validation

```

### Analyze Test Coverage

```bash
# Analyze PHP unit tests
./tests/analysis/analyze-unit-tests.sh
```

### Run Specific Test Types

```bash
# Unit tests only
./tests/runners/run-unit-tests-standalone.sh

# Integration tests
./tests/integration/test-project-setup.sh

# WordPress installation tests
./tests/integration/test-wp-installation.sh
```

### Using Lando/Composer Commands

```bash
# From project root with Lando
lando composer test          # Runs PHPUnit tests
lando composer analyze      # Runs all analysis tools
lando npm test              # Runs JavaScript/E2E tests
```

## Test Configuration Files

- **`bootstrap.php`** - PHPUnit bootstrap file that sets up the testing environment
- **`playwright.config.js`** - Configuration for Playwright E2E testing framework

## Best Practices

1. **Run validation scripts first** before executing tests to ensure environment is properly
   configured
2. **Use analysis scripts** to understand test coverage and identify gaps
3. **Execute integration tests** to verify complete workflows
4. **Run the comprehensive test suite** (`run-wordpress-tests.sh`) for full project validation

## Environment Requirements

- **Lando/Docker** - Required for WordPress integration tests tests
- **PHP 8.1+** - Required for unit tests
- **Composer** - Required for dependency management and test execution
- **Node.js/npm** - Required for E2E tests and JavaScript testing

## Continuous Integration

All test scripts are designed to work in CI/CD environments. The GitHub Actions workflows in
`.github/workflows/` utilize these organized test scripts for automated testing.
