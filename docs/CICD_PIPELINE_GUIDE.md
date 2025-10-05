# CI/CD Pipeline Guide

This guide provides documentation for the WordPress QuickStart CI/CD pipeline, covering all three
workflows, matrix strategies, quality gates, and debugging approaches.

## Pipeline Overview

WordPress QuickStart implements a three-tier CI/CD pipeline designed for reliability, speed, and
testing coverage:

### Pipeline Architecture

1. **WordPress Quickstart CI/CD**: Testing across multiple PHP and Node.js versions
2. **Pull Request Validation**: Fast feedback for PR creation and updates
3. **Pull Request Tests**: Testing for all PR changes

### Key Features

- **Matrix Testing**: PHP 8.1/8.2/8.3 × Node.js 18/20 combinations
- **Environment-Aware Configuration**: Settings for CI vs local development
- **Quality Gates**: Multiple validation layers ensuring code quality
- **Cross-Platform Support**: Consistent behavior across development environments
- **Error Recovery**: Retry mechanisms and fallback strategies

## Workflow Detailed Breakdown

### 1. WordPress Quickstart CI/CD Workflow

#### Trigger Conditions

```yaml
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:
```

#### Matrix Strategy

```yaml
strategy:
  matrix:
    php-version: ['8.1', '8.2']
    node-version: ['20']
  fail-fast: false
```

This creates **2 parallel jobs** testing all combinations:

- PHP 8.1 + Node 20
- PHP 8.2 + Node 20

#### Job Steps Breakdown

##### Environment Setup

```yaml
- name: Checkout code
  uses: actions/checkout@v4

- name: Setup PHP
  uses: shivammathur/setup-php@v2
  with:
    php-version: ${{ matrix.php-version }}
    extensions: mbstring, xml, ctype, iconv, intl

- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: ${{ matrix.node-version }}
    cache: 'npm'
```

##### Dependency Installation

```yaml
- name: Install Composer dependencies
  run: composer install --no-progress --no-suggest --prefer-dist --optimize-autoloader

- name: Install NPM dependencies
  run: npm ci

- name: Install Playwright browsers
  run: npx playwright install --with-deps
```

##### Code Quality Validation

```yaml
- name: Run PHP CodeSniffer
  run: composer run lint

- name: Run ESLint
  run: npm run lint

- name: Run Prettier check
  run: npm run format:check

- name: Run Stylelint
  run: npm run lint:css
```

##### Testing Execution

```yaml
- name: Run PHP Unit Tests
  run: composer run test

- name: Run Playwright E2E Tests
  run: npm run test:e2e
  env:
    CI: true

- name: Upload test results
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: test-results-php${{ matrix.php-version }}-node${{ matrix.node-version }}
    path: |
      test-results/
      playwright-report/
      coverage/
```

### 2. Pull Request Validation Workflow

#### Purpose and Optimization

- **Fast Feedback**: Provides immediate validation for PR changes
- **Essential Checks Only**: Focuses on critical validation without full test suite
- **Resource Efficient**: Configured for speed and minimal resource usage

#### Trigger Conditions

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
  pull_request_target:
    types: [opened, synchronize, reopened]
```

#### Validation Steps

```yaml
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup PHP 8.2 (latest stable)
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'

      - name: Setup Node.js 20 (latest LTS)
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: |
          composer install --no-dev --optimize-autoloader
          npm ci

      - name: Quick validation checks
        run: |
          composer run lint:quick
          npm run format:check
          npm run lint:quick

      - name: Syntax validation
        run: |
          find . -name "*.php" -exec php -l {} \;
          npm run build --if-present
```

### 3. Pull Request Tests Workflow

#### Testing

- **Full Test Suite**: Complete unit and E2E test execution
- **Multiple Environments**: Testing across different configurations
- **Quality Gate Enforcement**: All tests must pass for PR approval

#### Matrix Configuration

```yaml
strategy:
  matrix:
    include:
      - php: '8.1'
        node: '18'
        experimental: false
      - php: '8.2'
        node: '20'
        experimental: false
      - php: '8.3'
        node: '20'
        experimental: true # Allow experimental failures
  fail-fast: false
```

#### Testing Steps

```yaml
- name: WordPress Installation Test
  run: |
    npm run wp:install
    npm run wp:test

- name: Plugin Compatibility Test
  run: |
    composer run test:plugins
    npm run test:themes

- name: Security Scanning
  run: |
    composer audit
    npm audit

- name: Performance Testing
  run: |
    npm run test:performance
    composer run test:benchmarks
```

## Environment-Aware Configuration

### CI-Specific Optimizations

#### Playwright Configuration for CI

```javascript
// playwright.config.js
module.exports = {
  // CI settings
  reporter: process.env.CI ? 'list' : 'html',
  workers: process.env.CI ? 2 : undefined,

  // Disable webServer in CI (external WordPress instance)
  webServer: process.env.CI
    ? undefined
    : {
        command: 'npm run start:dev',
        port: 3000,
        reuseExistingServer: !process.env.CI,
      },

  use: {
    // CI-specific browser settings
    headless: true,
    video: process.env.CI ? 'retain-on-failure' : 'off',
    screenshot: process.env.CI ? 'only-on-failure' : 'off',

    // Reduce timeouts in CI
    actionTimeout: process.env.CI ? 30000 : 0,
    navigationTimeout: process.env.CI ? 30000 : 0,
  },
};
```

#### WordPress Configuration for CI

```php
// wp-config-generator.php CI detection
if (getenv('CI') === 'true') {
    // CI-specific WordPress configuration
    define('WP_DEBUG', false);
    define('WP_DEBUG_LOG', false);
    define('WP_CACHE', false);

    // Database optimization for CI
    define('WP_MEMORY_LIMIT', '256M');
    define('DB_CHARSET', 'utf8mb4');
    define('DB_COLLATE', '');
}
```

### Local Development Optimizations

#### Development Experience

```javascript
// Local development settings
module.exports = {
  reporter: 'html',
  workers: undefined, // Use all available cores

  webServer: {
    command: 'lando start',
    port: 80,
    reuseExistingServer: true,
  },

  use: {
    headless: false, // Show browser during development
    video: 'retain-on-failure',
    screenshot: 'only-on-failure',

    // Extended timeouts for debugging
    actionTimeout: 0,
    navigationTimeout: 0,
  },
};
```

## Quality Gates and Validation

### Code Quality Standards

#### PHP Quality Gates

```yaml
# composer.json scripts
'scripts':
  {
    'lint': 'phpcs --standard=WordPress-VIP-Go src/ tests/',
    'lint:fix': 'phpcbf --standard=WordPress-VIP-Go src/ tests/',
    'test': 'phpunit --configuration phpunit.xml',
    'test:coverage': 'phpunit --coverage-html coverage/',
    'audit': 'composer audit --format=json',
  }
```

#### JavaScript Quality Gates

```json
{
  "scripts": {
    "lint": "eslint src/ tests/ --ext .js,.json",
    "lint:fix": "eslint src/ tests/ --ext .js,.json --fix",
    "format": "prettier --write **/*.{js,json,md,yml}",
    "format:check": "prettier --check **/*.{js,json,md,yml}",
    "lint:css": "stylelint **/*.css **/*.scss"
  }
}
```

#### WordPress VIP Compliance

```xml
<!-- phpcs.xml -->
<ruleset>
    <description>WordPress VIP Coding Standards</description>
    <rule ref="WordPress-VIP-Go"/>
    <rule ref="WordPressVIPMinimum"/>

    <!-- Custom exclusions for CI -->
    <exclude-pattern>vendor/</exclude-pattern>
    <exclude-pattern>node_modules/</exclude-pattern>
    <exclude-pattern>wp/</exclude-pattern>
</ruleset>
```

### Security Validation

#### Dependency Security Scanning

```yaml
- name: Security Audit
  run: |
    # PHP dependency security audit
    composer audit --format=json > security-audit-php.json

    # NPM dependency security audit
    npm audit --audit-level moderate --json > security-audit-npm.json

    # Custom security checks
    ./scripts/security-scan.sh
```

#### WordPress Security Hardening

```php
// Security constants for CI
define('DISALLOW_FILE_EDIT', true);
define('DISALLOW_FILE_MODS', true);
define('FORCE_SSL_ADMIN', false); // CI doesn't use SSL
define('WP_DEBUG_DISPLAY', false);
define('SCRIPT_DEBUG', false);
```

### Performance Validation

#### Performance Testing Integration

```yaml
- name: Performance Testing
  run: |
    # Lighthouse CI
    npm run lighthouse:ci

    # WordPress performance tests
    ./scripts/performance-test.sh

    # Database query analysis
    composer run analyze:queries
```

#### Resource Usage Monitoring

```bash
#!/bin/bash
# performance-monitor.sh
echo "=== System Resources Before Tests ==="
free -h
df -h
docker system df

echo "=== Running Performance Tests ==="
time npm run test:e2e

echo "=== System Resources After Tests ==="
free -h
docker system df
```

## Error Handling and Recovery

### Retry Mechanisms

#### Flaky Test Handling

```yaml
- name: Run E2E Tests with Retry
  uses: nick-invision/retry@v2
  with:
    timeout_minutes: 10
    max_attempts: 3
    retry_on: error
    command: npm run test:e2e
```

#### Network Failure Recovery

```yaml
- name: Install Dependencies with Retry
  run: |
    for i in {1..3}; do
      npm ci && break || sleep 30
    done
```

### Error Classification

#### Error Categories

1. **Infrastructure Errors**: Network, Docker, or system issues
2. **Dependency Errors**: Package installation or compatibility issues
3. **Test Failures**: Actual code issues requiring developer attention
4. **Configuration Errors**: Environment or setup problems

#### Error Response Strategies

```yaml
- name: Classify and Handle Errors
  if: failure()
  run: |
    # Collect error information
    echo "::group::Error Classification"
    ./scripts/classify-error.sh
    echo "::endgroup::"

    # Attempt automatic recovery
    if [[ "$ERROR_TYPE" == "infrastructure" ]]; then
      echo "Attempting infrastructure recovery..."
      ./scripts/recover-infrastructure.sh
    fi
```

### Debug Information Collection

#### Debug Output

```yaml
- name: Collect Debug Information
  if: failure()
  run: |
    echo "=== Environment Information ==="
    php --version
    node --version
    npm --version
    composer --version
    docker --version

    echo "=== System Information ==="
    uname -a
    free -h
    df -h

    echo "=== Process Information ==="
    ps aux | grep -E "(php|node|npm|docker)"

    echo "=== Network Information ==="
    netstat -tulpn | head -20

    echo "=== Log Files ==="
    find . -name "*.log" -exec echo "=== {} ===" \; -exec cat {} \;
```

#### Artifact Collection Strategy

```yaml
- name: Upload Debug Artifacts
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: debug-artifacts-${{ matrix.php-version }}-${{ matrix.node-version }}
    path: |
      debug/
      logs/
      test-results/
      playwright-report/
      coverage/
      *.log
    retention-days: 7
```

## Monitoring and Observability

### Real-time Monitoring

#### GitHub Actions Status Integration

```yaml
- name: Update Status
  if: always()
  run: |
    STATUS="${{ job.status }}"
    ./scripts/gh-wrapper.sh api repos/:owner/:repo/statuses/${{ github.sha }} \
      --field state="$STATUS" \
      --field context="ci/wordpress-quickstart" \
      --field description="WordPress QuickStart CI/CD Pipeline"
```

#### External Monitoring Integration

```yaml
- name: Send Metrics
  if: always()
  run: |
    # Send metrics to monitoring system
    curl -X POST "$MONITORING_ENDPOINT" \
      -H "Content-Type: application/json" \
      -d "{
        \"pipeline\": \"wordpress-quickstart\",
        \"status\": \"${{ job.status }}\",
        \"duration\": \"${{ steps.tests.outputs.duration }}\",
        \"php_version\": \"${{ matrix.php-version }}\",
        \"node_version\": \"${{ matrix.node-version }}\"
      }"
```

### Performance Metrics

#### Pipeline Performance Tracking

```yaml
- name: Track Performance
  run: |
    echo "::group::Pipeline Metrics"
    echo "Start Time: ${{ steps.start.outputs.time }}"
    echo "End Time: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "Duration: $(($(date +%s) - ${{ steps.start.outputs.timestamp }}))"
    echo "Matrix: PHP ${{ matrix.php-version }}, Node ${{ matrix.node-version }}"
    echo "::endgroup::"
```

#### Resource Usage Tracking

```bash
#!/bin/bash
# Resource monitoring during CI
while true; do
  echo "$(date): $(free -h | grep Mem:) | $(df -h / | tail -1)"
  sleep 30
done > resource-usage.log &
MONITOR_PID=$!

# Run tests
npm run test:e2e

# Stop monitoring
kill $MONITOR_PID
```

## Troubleshooting Guide

### Common CI/CD Issues

#### Dependency Installation Failures

```bash
# Diagnosis
echo "Checking package manager status..."
npm doctor
composer diagnose

# Resolution
npm cache clean --force
composer clear-cache
rm -rf node_modules package-lock.json
npm install
```

#### Test Environment Issues

```bash
# WordPress installation problems
echo "Checking WordPress installation..."
./scripts/wp-manager.sh status
./scripts/wp-manager.sh reinstall

# Database connection issues
echo "Testing database connection..."
lando mysql -e "SELECT 1"
```

#### Browser and E2E Test Issues

```bash
# Playwright browser issues
echo "Checking Playwright installation..."
npx playwright install --with-deps
npx playwright install-deps

# Display issues in CI
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
```

### Performance Optimization

#### Speed Up CI Pipeline

```yaml
# Use caching effectively
- name: Cache Dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.npm
      ~/.composer/cache
      node_modules
      vendor
    key: deps-${{ runner.os }}-${{ hashFiles('**/package-lock.json', '**/composer.lock') }}
```

#### Optimize Test Execution

```yaml
# Parallel test execution
- name: Run Tests in Parallel
  run: |
    npm run test:unit &
    npm run test:e2e &
    composer run test &
    wait
```

#### Resource Management

```yaml
# Optimize resource usage
- name: Configure Resources
  run: |
    # Limit Docker resources
    echo '{"default-ulimits":{"nofile":{"Name":"nofile","Hard":65536,"Soft":65536}}}' | sudo tee /etc/docker/daemon.json
    sudo service docker restart

    # Configure system limits
    echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
```

## Best Practices

### Pipeline Design Principles

1. **Fail Fast**: Early detection of issues to save time and resources
2. **Parallel Execution**: Maximize concurrency for faster feedback
3. **Environment Parity**: Consistent behavior between CI and local development
4. **Coverage**: Test all critical paths and edge cases
5. **Graceful Degradation**: Handle failures with recovery mechanisms

### Security Best Practices

1. **Secret Management**: Use GitHub Secrets for sensitive information
2. **Least Privilege**: Minimal permissions for CI operations
3. **Dependency Scanning**: Regular security audits of dependencies
4. **Code Scanning**: Static analysis for security vulnerabilities
5. **Supply Chain Security**: Verify integrity of all external dependencies

### Maintenance and Updates

1. **Regular Updates**: Keep CI dependencies and actions up to date
2. **Performance Monitoring**: Track pipeline performance over time
3. **Error Analysis**: Regular review of failure patterns and improvements
4. **Documentation**: Keep CI/CD documentation current with changes
5. **Team Training**: Ensure team understands CI/CD processes and troubleshooting

This CI/CD pipeline provides scalable, and maintainable automation for WordPress QuickStart
development with professional-grade quality assurance and monitoring capabilities.
