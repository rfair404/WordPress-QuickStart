# Project Structure Guide

This document provides an overview of the WordPress QuickStart project architecture, capabilities,
and development workflow.

## Overview

WordPress QuickStart is a WordPress development framework featuring:

- **Composer-managed WordPress core** for secure, version-controlled updates
- **CI/CD pipeline** with testing and quality gates
- **Cross-platform development environment** using Lando containerization
- **GitHub CLI integration** for workflow management
- **Environment-aware configuration** for local development and CI/CD

## Core Architecture

### WordPress Integration

- **Core WordPress**: Latest WordPress core files managed via Composer in `wp/` directory
- **Custom Content**: User uploads, themes, and plugins organized in `custom/` directory
- **Configuration**: Environment-specific wp-config.php generation with security hardening
- **Database**: MySQL integration through Lando containers with setup
- **Installation Validation**: WordPress installation testing and health checks
- **Environment-aware Setup**: Different configurations for local vs CI environments

### Development Environment

The project uses Lando for containerized development with the following services:

- **Web Server**: Apache with PHP 8.3/8.4 support
- **Database**: MySQL 8.0 with automatic WordPress schema setup
- **Node.js**: For frontend tooling and E2E testing with Playwright
- **Composer**: PHP dependency management and WordPress core updates
- **GitHub CLI**: Integrated workflow management and CI/CD monitoring

### Testing Infrastructure

#### Unit Testing (PHPUnit)

- **Location**: `tests/unit/`
- **Framework**: PHPUnit with WordPress test framework integration
- **Coverage**: WordPress functionality, custom plugins, and theme components
- **CI Integration**: Execution across PHP 8.3/8.4 matrix

#### End-to-End Testing (Playwright)

- **Location**: `tests/e2e/`
- **Framework**: Playwright with cross-browser testing support
- **Coverage**: WordPress admin functionality, frontend user interactions
- **Environment Detection**: Configuration for local development vs CI execution
- **Reporters**: HTML reports for local development, list reporter for CI efficiency

### GitHub CLI Integration

GitHub workflow management capabilities:

- **GitHub Actions Monitoring**: Real-time workflow status and job monitoring from VS Code
- **Pull Request Management**: PR creation, review workflows, and merge operations
- **Repository Management**: Repository operations and maintenance tasks
- **Cross-platform Compatibility**: Consistent GitHub CLI access on Windows, Mac, and Linux
- **Wrapper System**: GitHub CLI detection and installation automation

### Lando Wrapper System

Cross-platform development environment management:

- **Universal Lando Access**: Automatic detection and installation across operating systems
- **PATH Management**: PATH resolution for development tools and executables
- **Windows Compatibility**: Special handling for Windows .cmd extensions and PowerShell
- **Auto-installation**: Lando setup when not detected in system PATH
- **Environment Detection**: Platform-specific optimizations for Docker and container management

## Directory Structure

```
├── .github/                  # GitHub Actions workflows and templates
│   ├── workflows/            # CI/CD pipeline definitions
│   └── PULL_REQUEST_TEMPLATE.md
├── custom/                   # Custom WordPress content
│   ├── plugins/              # Custom WordPress plugins
│   ├── themes/               # Custom WordPress themes
│   └── uploads/              # Media uploads and user content
├── docs/                     # Project documentation
│   ├── CHANGELOG.md          # Version history and release notes
│   ├── CONTRIBUTING.md       # Contribution guidelines and standards
│   ├── PLAYWRIGHT_GUIDE.md   # E2E testing guide and best practices
│   └── PROJECT_STRUCTURE.md  # This architecture guide
├── scripts/                  # Automation and utility scripts
│   ├── gh-wrapper.sh         # GitHub CLI wrapper with cross-platform support
│   ├── wp-config-generator-wpcli.sh # WordPress configuration generator
│   ├── wp-core-install-wpcli.sh     # WordPress installation automation
│   └── setup/                # Environment setup and configuration
│       ├── dependency-validator.sh
│       ├── env-setup.sh      # Environment setup for Unix systems
│       ├── env-setup.bat     # Environment setup for Windows
│       ├── github-cli-setup.sh
│       ├── install-lando-docker.sh
│       ├── lando-wrapper.sh  # Cross-platform Lando wrapper
│       ├── playwright-setup.sh
│       └── test-setup.sh
├── tests/                    # Test suites
│   ├── e2e/                  # Playwright end-to-end tests
│   │   ├── placeholder.spec.js # WordPress core functionality tests
│   │   └── utils/            # E2E testing utilities and helpers
│   ├── unit/                 # PHPUnit unit tests
│   │   ├── SampleTest.php    # Example unit test structure
│   │   └── WordPressInstallationTest.php
│   ├── validation/           # Installation and environment validation
│   ├── playwright.config.js  # Environment-aware Playwright configuration
│   └── bootstrap.php         # PHP test bootstrap and WordPress integration
├── wp/                       # WordPress core files (Composer managed)
│   ├── wp-admin/             # WordPress administration interface
│   ├── wp-content/           # WordPress core content (symlinked to custom/)
│   ├── wp-includes/          # WordPress core functionality
│   └── wp-config.php         # WordPress configuration (generated)
├── .lando.yml                # Lando development environment configuration
├── composer.json             # PHP dependencies and WordPress core management
├── package.json              # Node.js dependencies and npm scripts
└── README.md                 # Project overview and quick start guide
```

## Environment Detection

The project includes environment detection for configuration:

### CI/CD Environment

- **Configuration**: Minimal resource usage and faster execution
- **Playwright Setup**: List reporter for clean CI logs, webServer disabled
- **GitHub Actions Matrix**: Parallel execution across PHP 8.3/8.4 and Node 20
- **Validation Focus**: Essential functionality testing with optional components disabled

### Local Development

- **Full Feature Set**: Complete development tools with hot reloading
- **Playwright Setup**: HTML reporter with interactive debugging capabilities
- **VS Code Integration**: GitHub CLI monitoring and PR management tools
- **Development Tools**: ESLint, Prettier, Stylelint with watch modes

### Production Environment

- **Security**: wp-config.php with security constants
- **Performance Optimization**: Caching, compression, and resource optimization
- **Monitoring Integration**: Health checks and performance monitoring capabilities

## CI/CD Pipeline

### Workflow Architecture

The project implements a three-tier CI/CD pipeline:

#### 1. WordPress Quickstart CI/CD

- **Trigger**: Push to main branch, Pull Requests targeting main
- **Matrix Strategy**: PHP 8.3/8.4 × Node.js 20 combinations
- **Test Coverage**:
  - Unit tests with PHPUnit
  - E2E tests with Playwright
  - Code quality validation (ESLint, Prettier, PHPCS)
  - WordPress VIP coding standards compliance

#### 2. Pull Request Validation

- **Trigger**: PR creation and updates
- **Focus**: Fast validation and formatting checks
- **Features**: Rapid feedback and early error detection
- **Quality Gates**: Code formatting, basic syntax validation, dependency checks

#### 3. Pull Request Tests

- **Trigger**: PR events and status changes
- **Scope**: Test suite execution
- **Quality Gates**: All unit tests, E2E tests, and code quality checks must pass
- **Integration**: WordPress installation validation and environment testing

### Quality Assurance

#### Code Standards

- **PHP**: WordPress VIP Coding Standards with PHPCS
- **JavaScript**: ESLint with WordPress-specific rules
- **CSS**: Stylelint with WordPress theme development standards
- **Formatting**: Prettier for consistent code formatting across all file types

#### Testing Strategy

- **Unit Tests**: PHPUnit with WordPress test framework integration
- **Integration Tests**: WordPress installation and configuration validation
- **E2E Tests**: Playwright with WordPress admin and frontend user workflow testing
- **Visual Regression**: Screenshot comparison for UI consistency

## Development Workflow

### Getting Started

1. **Environment Setup**: Via setup scripts for Windows, Mac, and Linux
2. **Dependency Installation**: Composer and npm dependency resolution
3. **Container Startup**: Lando environment with WordPress, MySQL, and development tools
4. **GitHub Integration**: Automatic GitHub CLI setup and VS Code extension configuration

### Daily Development

1. **Feature Development**: Branch-based development with testing feedback
2. **Code Quality**: Real-time linting and formatting with VS Code integration
3. **Testing**: Continuous test execution during development with watch modes
4. **CI/CD Monitoring**: Real-time GitHub Actions status in VS Code status bar

### Deployment Process

1. **Pull Request Creation**: PR template and validation workflow
2. **Review Process**: Test execution and code quality validation
3. **Merge Strategy**: Protected main branch with required status checks
4. **Release Management**: Changelog generation and version management

## Best Practices

### Code Organization

- **Separation of Concerns**: Clear distinction between WordPress core, custom content, and project
  infrastructure
- **Version Control**: Composer-managed WordPress core with semantic versioning
- **Custom Content**: Organized in `custom/` directory with proper WordPress directory structure
- **Documentation**: Inline documentation and architectural decision records

### Testing Approach

- **Test-Driven Development**: Unit tests for custom functionality before implementation
- **E2E Coverage**: Critical user workflows and WordPress administrative functions
- **Environment Parity**: Consistent testing environments between local development and CI/CD
- **Performance Testing**: Performance validation and regression detection

### Security Considerations

- **WordPress Security**: Regular WordPress core updates via Composer
- **Environment Isolation**: Containerized development with secure configuration management
- **Access Control**: GitHub CLI integration with proper authentication and authorization
- **Configuration Management**: Environment-specific configuration with secure defaults

This architecture provides a scalable foundation for WordPress development with modern tooling,
testing, and professional workflow management.
