# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Complete development environment setup with Lando
- Comprehensive linting and code quality tools
- Git hooks for automated code formatting and testing
- VS Code workspace configuration
- Custom .bashrc with development aliases and functions
- Organized project directory structure
- GitHub Actions CI/CD pipeline
- PHPUnit testing framework with Brain Monkey
- WordPress VIP coding standards compliance
- Prettier formatting for all file types
- ESLint and Stylelint for JavaScript/CSS quality
- Security scanning and dependency auditing
- Documentation and contributing guidelines

### Changed
- Reorganized configuration files into `.config/` directory
- Moved setup scripts to `scripts/setup/` directory
- Moved documentation to `docs/` directory

### Deprecated
- None

### Removed
- None

### Fixed
- None

### Security
- Added automated security scanning with Composer audit
- Added npm audit for JavaScript dependencies

## [1.0.0] - 2025-10-02

### Added
- Initial project structure
- Basic WordPress quickstart foundation
- Development environment configuration
- Comprehensive tooling setup

---

## Release Notes Format

### Version Numbering
We follow [Semantic Versioning](https://semver.org/):
- **MAJOR** version when you make incompatible API changes
- **MINOR** version when you add functionality in a backwards compatible manner
- **PATCH** version when you make backwards compatible bug fixes

### Categories
- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes

### Links Format
- [Unreleased]: https://github.com/rfair404/WordPress-QuickStart/compare/v1.0.0...HEAD
- [1.0.0]: https://github.com/rfair404/WordPress-QuickStart/releases/tag/v1.0.0
