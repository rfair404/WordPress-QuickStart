# Dependabot Configuration Guide

This document explains the Dependabot configuration for the WordPress QuickStart project, which automatically monitors and updates dependencies across multiple ecosystems.

## Overview

Dependabot is configured to monitor three types of dependencies:

1. **Composer packages** (PHP dependencies)
2. **npm packages** (JavaScript/Node.js dependencies) 
3. **GitHub Actions** (CI/CD workflow dependencies)

## Configuration Details

### Schedule

All dependency checks run weekly on **Mondays**:
- **09:00 PT** - Composer (PHP) packages
- **09:30 PT** - npm (JavaScript) packages  
- **10:00 PT** - GitHub Actions

### Pull Request Limits

- **Composer**: Maximum 5 open PRs
- **npm**: Maximum 5 open PRs
- **GitHub Actions**: Maximum 3 open PRs

This prevents overwhelming the maintainers with too many dependency updates at once.

## Dependency Groups

To reduce noise and make reviews easier, related dependencies are grouped together:

### Composer Groups

- **`wordpress-core`**: WordPress core packages
  - `johnpbloch/wordpress-*`

- **`coding-standards`**: PHP code quality tools
  - All phpcs, coding standards, and linting packages
  - `wp-coding-standards/*`, `automattic/vipwpcs`, `phpcompatibility/*`, etc.

- **`testing-framework`**: PHP testing tools
  - `phpunit/*`, `yoast/phpunit-*`

### npm Groups

- **`linting-tools`**: JavaScript code quality tools
  - `eslint*`, `prettier*`, `stylelint*`, `@typescript-eslint/*`

- **`testing-framework`**: JavaScript testing tools
  - `@playwright/*`, `playwright*`

- **`build-tools`**: Build and compilation tools
  - `webpack*`, `babel*`, `@babel/*`

### GitHub Actions Groups

- **`setup-actions`**: Environment setup actions
  - `actions/checkout`, `actions/setup-*`, `actions/cache`

- **`deployment-actions`**: Deployment and artifact actions
  - `actions/deploy-*`, `actions/upload-*`, `actions/download-*`

## Ignored Updates

Certain updates are ignored to prevent breaking changes:

### Composer
- **WordPress Core major versions**: Only minor and patch updates are automatically proposed
  - Major WordPress updates require manual review and testing

### npm
- **ESLint major versions**: Can introduce breaking configuration changes
- **Playwright major versions**: May require test updates and infrastructure changes

### Why These Are Ignored

These packages are ignored for major version updates because:
- They often introduce breaking changes
- They require careful testing and potential configuration updates
- They may impact the entire development workflow

## Labels and Reviewers

All Dependabot PRs are automatically:
- **Labeled** with appropriate tags (`dependencies`, `php`, `javascript`, etc.)
- **Assigned** to `rfair404` for review
- **Set as reviewer** for `rfair404`

## Commit Message Format

Commit messages follow a consistent format:
- **Composer**: `composer: update package-name to v1.2.3`
- **npm**: `npm: update package-name to v1.2.3`
- **GitHub Actions**: `github-actions: update action-name to v1.2.3`

## Workflow Integration

Dependabot PRs automatically trigger all CI/CD workflows:
- PHP linting and testing
- JavaScript linting and testing
- Security scanning
- Documentation checks

This ensures all dependency updates are properly validated before merging.

## Manual Override

If you need to update ignored dependencies or want to bypass the schedule:
1. Use `@dependabot rebase` in PR comments to update an existing PR
2. Create manual PRs for major version updates
3. Use `@dependabot ignore` to skip specific updates

## Security Updates

Dependabot automatically creates PRs for security vulnerabilities regardless of the schedule or ignore rules. These should be prioritized and reviewed immediately.

## Monitoring

Check the **Insights > Dependency graph > Dependabot** section in GitHub to:
- View the update schedule
- See failed update attempts
- Monitor security alerts
- Review configuration status

## Best Practices

1. **Review grouped PRs together** - they're related and often work together
2. **Test thoroughly** - run the full test suite before merging
3. **Update lock files** - both `composer.lock` and `package-lock.json` will be updated
4. **Check for breaking changes** - review changelogs for major updates
5. **Monitor CI/CD** - ensure all workflows pass before merging