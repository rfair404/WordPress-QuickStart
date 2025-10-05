# Environment-Aware Configuration Guide

This guide explains the environment detection and configuration system implemented in WordPress
QuickStart, covering local development vs CI optimization strategies, configuration management, and
troubleshooting approaches.

## Overview

WordPress QuickStart implements environment detection that optimizes configuration based on the
execution context:

### Environment Types

- **Local Development**: Full-featured development environment with debugging tools
- **CI/CD Environment**: Configured for speed, reliability, and resource efficiency
- **Production Environment**: Security-focused with performance settings
- **Testing Environment**: Isolated testing with controlled data and configurations

### Key Benefits

- **Environment Detection**: No manual configuration required for different environments
- **Resource Efficiency**: Resource usage based on environment capabilities
- **Developer Experience**: Local development with debugging capabilities
- **CI/CD Speed**: Configuration for fast pipeline execution

## Environment Detection System

### Core Detection Logic

The environment detection system uses multiple indicators to determine the current context:

#### Primary Environment Variables

```bash
# CI/CD Detection
CI=true                    # Standard CI environment indicator
GITHUB_ACTIONS=true        # GitHub Actions specific
CONTINUOUS_INTEGRATION=true # Generic CI indicator

# Development Environment Detection
NODE_ENV=development       # Node.js environment
WP_ENV=development        # WordPress environment
LANDO=ON                  # Lando container environment
```

#### System-Based Detection

```javascript
// Environment detection in JavaScript/Node.js
const isCI =
  process.env.CI === 'true' ||
  process.env.GITHUB_ACTIONS === 'true' ||
  process.env.CONTINUOUS_INTEGRATION === 'true';

const isDevelopment =
  process.env.NODE_ENV === 'development' ||
  process.env.WP_ENV === 'development' ||
  process.env.LANDO === 'ON';

const isProduction = process.env.NODE_ENV === 'production' || process.env.WP_ENV === 'production';
```

#### PHP Environment Detection

```php
// Environment detection in PHP
function detect_environment() {
    // CI Detection
    if (getenv('CI') === 'true' ||
        getenv('GITHUB_ACTIONS') === 'true') {
        return 'ci';
    }

    // Development Detection
    if (getenv('WP_ENV') === 'development' ||
        getenv('LANDO') === 'ON') {
        return 'development';
    }

    // Production Detection
    if (getenv('WP_ENV') === 'production') {
        return 'production';
    }

    return 'unknown';
}
```

## Configuration Profiles

### Local Development Configuration

#### Development Experience

```javascript
// playwright.config.js - Development Profile
const developmentConfig = {
  // Full HTML reporting with screenshots
  reporter: [
    ['html', { open: 'on-failure' }],
    ['json', { outputFile: 'test-results/results.json' }],
  ],

  // Use all available CPU cores
  workers: undefined,

  // Full browser visibility for debugging
  use: {
    headless: false,
    video: 'retain-on-failure',
    screenshot: 'only-on-failure',
    trace: 'retain-on-failure',

    // Extended timeouts for debugging
    actionTimeout: 0,
    navigationTimeout: 0,
  },

  // Local webServer integration
  webServer: {
    command: 'lando start && sleep 5',
    port: 80,
    reuseExistingServer: true,
    timeout: 120000,
  },

  // Development-specific test configuration
  projects: [
    {
      name: 'chromium-desktop',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'webkit-desktop',
      use: { ...devices['Desktop Safari'] },
    },
  ],
};
```

#### WordPress Development Configuration

```php
// wp-config-generator.php - Development Profile
if ($environment === 'development') {
    // Debug settings
    define('WP_DEBUG', true);
    define('WP_DEBUG_LOG', true);
    define('WP_DEBUG_DISPLAY', true);
    define('SCRIPT_DEBUG', true);

    // Development-friendly settings
    define('WP_CACHE', false);
    define('CONCATENATE_SCRIPTS', false);
    define('COMPRESS_SCRIPTS', false);
    define('COMPRESS_CSS', false);

    // Generous memory limits
    define('WP_MEMORY_LIMIT', '512M');
    define('WP_MAX_MEMORY_LIMIT', '1024M');

    // Development database settings
    define('DB_CHARSET', 'utf8');
    define('DB_COLLATE', '');

    // Local development URLs
    define('WP_HOME', 'http://wordpress-quickstart.lndo.site');
    define('WP_SITEURL', 'http://wordpress-quickstart.lndo.site/wp');
}
```

#### Development Tools Integration

```json
{
  "scripts": {
    "dev": "concurrently \"npm run watch:css\" \"npm run watch:js\"",
    "watch:css": "stylelint **/*.css --watch",
    "watch:js": "eslint src/ --ext .js --watch",
    "debug:e2e": "playwright test --debug",
    "debug:headed": "playwright test --headed --workers=1"
  }
}
```

### CI/CD Environment Configuration

#### CI Performance

```javascript
// playwright.config.js - CI Profile
const ciConfig = {
  // Minimal, fast reporting
  reporter: [
    ['list'],
    ['json', { outputFile: 'test-results/results.json' }],
    ['junit', { outputFile: 'test-results/results.xml' }],
  ],

  // Limited workers for resource management
  workers: 2,

  // Headless execution only
  use: {
    headless: true,
    video: 'retain-on-failure',
    screenshot: 'only-on-failure',
    trace: 'off', // Disabled for performance

    // Reduced timeouts for faster feedback
    actionTimeout: 30000,
    navigationTimeout: 30000,
  },

  // No webServer in CI (external WordPress)
  webServer: undefined,

  // CI browser configuration
  projects: [
    {
      name: 'chromium-ci',
      use: {
        ...devices['Desktop Chrome'],
        // CI-specific overrides
        launchOptions: {
          args: ['--no-sandbox', '--disable-setuid-sandbox'],
        },
      },
    },
  ],
};
```

#### WordPress CI Configuration

```php
// wp-config-generator.php - CI Profile
if ($environment === 'ci') {
    // Minimal debug output
    define('WP_DEBUG', false);
    define('WP_DEBUG_LOG', false);
    define('WP_DEBUG_DISPLAY', false);
    define('SCRIPT_DEBUG', false);

    // Performance optimizations
    define('WP_CACHE', true);
    define('CONCATENATE_SCRIPTS', true);
    define('COMPRESS_SCRIPTS', true);
    define('COMPRESS_CSS', true);

    // Resource limits for CI
    define('WP_MEMORY_LIMIT', '256M');
    define('WP_MAX_MEMORY_LIMIT', '256M');

    // Fast database settings
    define('DB_CHARSET', 'utf8mb4');
    define('DB_COLLATE', 'utf8mb4_unicode_520_ci');

    // CI-specific security settings
    define('DISALLOW_FILE_EDIT', true);
    define('DISALLOW_FILE_MODS', true);
    define('AUTOMATIC_UPDATER_DISABLED', true);
}
```

#### CI Resource Management

```yaml
# GitHub Actions CI Configuration
env:
  # Resource optimization
  NODE_OPTIONS: '--max_old_space_size=4096'
  COMPOSER_MEMORY_LIMIT: '2G'

  # CI-specific settings
  CI: 'true'
  PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD: '1'
  PLAYWRIGHT_BROWSERS_PATH: '0'
```

### Production Environment Configuration

#### Security-Hardened WordPress

```php
// wp-config-generator.php - Production Profile
if ($environment === 'production') {
    // Security settings
    define('WP_DEBUG', false);
    define('WP_DEBUG_LOG', false);
    define('WP_DEBUG_DISPLAY', false);
    define('SCRIPT_DEBUG', false);

    // Performance optimizations
    define('WP_CACHE', true);
    define('CONCATENATE_SCRIPTS', true);
    define('COMPRESS_SCRIPTS', true);
    define('COMPRESS_CSS', true);

    // Security hardening
    define('DISALLOW_FILE_EDIT', true);
    define('DISALLOW_FILE_MODS', true);
    define('FORCE_SSL_ADMIN', true);
    define('WP_AUTO_UPDATE_CORE', 'minor');

    // Production database optimization
    define('WP_MEMORY_LIMIT', '256M');
    define('DB_CHARSET', 'utf8mb4');
    define('DB_COLLATE', 'utf8mb4_unicode_520_ci');

    // Caching configuration
    define('WP_CACHE_KEY_SALT', 'production-salt-' . $_SERVER['HTTP_HOST']);

    // Error logging
    ini_set('log_errors', 1);
    ini_set('error_log', '/var/log/wordpress/error.log');
}
```

#### Production Performance Monitoring

```javascript
// Production monitoring configuration
const productionConfig = {
  // Minimal testing for production validation
  reporter: [['json', { outputFile: 'monitoring/health-check.json' }]],

  // Limited test execution
  testMatch: ['**/health-check.spec.js', '**/smoke-test.spec.js'],

  // Production-safe browser settings
  use: {
    headless: true,
    video: 'off',
    screenshot: 'off',
    trace: 'off',

    // Quick timeouts for health checks
    actionTimeout: 10000,
    navigationTimeout: 15000,
  },
};
```

## Configuration Management

### Dynamic Configuration Loading

#### Configuration Factory Pattern

```javascript
// config/environment.js
class EnvironmentConfig {
  constructor() {
    this.environment = this.detectEnvironment();
    this.config = this.loadConfig();
  }

  detectEnvironment() {
    if (process.env.CI === 'true') return 'ci';
    if (process.env.NODE_ENV === 'production') return 'production';
    if (process.env.LANDO === 'ON') return 'development';
    return 'unknown';
  }

  loadConfig() {
    const configs = {
      development: require('./development.config.js'),
      ci: require('./ci.config.js'),
      production: require('./production.config.js'),
    };

    return configs[this.environment] || configs.development;
  }

  get(key, defaultValue = null) {
    return this.config[key] || defaultValue;
  }
}

module.exports = new EnvironmentConfig();
```

#### WordPress Configuration Generator

```php
<?php
// scripts/wp-config-generator.php
class WPConfigGenerator {
    private $environment;
    private $config;

    public function __construct() {
        $this->environment = $this->detectEnvironment();
        $this->config = $this->loadEnvironmentConfig();
    }

    private function detectEnvironment() {
        if (getenv('CI') === 'true') return 'ci';
        if (getenv('WP_ENV') === 'production') return 'production';
        if (getenv('LANDO') === 'ON') return 'development';
        return 'development';
    }

    private function loadEnvironmentConfig() {
        $configFile = __DIR__ . "/config/{$this->environment}.php";
        if (file_exists($configFile)) {
            return include $configFile;
        }
        return include __DIR__ . '/config/development.php';
    }

    public function generateConfig() {
        $config = "<?php\n";
        $config .= "// Auto-generated wp-config.php for {$this->environment} environment\n";
        $config .= "// Generated on " . date('Y-m-d H:i:s') . "\n\n";

        foreach ($this->config as $key => $value) {
            if (is_bool($value)) {
                $value = $value ? 'true' : 'false';
            } elseif (is_string($value)) {
                $value = "'{$value}'";
            }
            $config .= "define('{$key}', {$value});\n";
        }

        return $config;
    }
}
```

### Environment-Specific Package Scripts

#### NPM Scripts Configuration

```json
{
  "scripts": {
    "test": "npm run test:env",
    "test:env": "node scripts/run-tests-for-env.js",
    "test:development": "playwright test --config=playwright.dev.config.js",
    "test:ci": "playwright test --config=playwright.ci.config.js",
    "test:production": "playwright test --config=playwright.prod.config.js",

    "start": "npm run start:env",
    "start:env": "node scripts/start-for-env.js",
    "start:development": "lando start && npm run watch",
    "start:ci": "echo 'CI environment - no start needed'",
    "start:production": "echo 'Production start via deployment'",

    "build": "npm run build:env",
    "build:development": "webpack --mode=development --watch",
    "build:ci": "webpack --mode=production",
    "build:production": "webpack --mode=production --optimize-minimize"
  }
}
```

#### Environment-Aware Script Runner

```javascript
// scripts/run-tests-for-env.js
const { spawn } = require('child_process');
const environment = require('../config/environment');

function runTestsForEnvironment() {
  const env = environment.environment;
  const command = `npm run test:${env}`;

  console.log(`Running tests for ${env} environment...`);

  const child = spawn('npm', ['run', `test:${env}`], {
    stdio: 'inherit',
    shell: true,
  });

  child.on('exit', code => {
    process.exit(code);
  });
}

runTestsForEnvironment();
```

## Environment-Specific Optimizations

### Development Environment Enhancements

#### Hot Reloading and Live Updates

```javascript
// webpack.dev.config.js
module.exports = {
  mode: 'development',
  devtool: 'source-map',

  devServer: {
    hot: true,
    liveReload: true,
    watchFiles: ['src/**/*', 'tests/**/*'],

    // Proxy to Lando
    proxy: {
      '/api': 'http://localhost:80',
    },
  },

  // Debugging
  optimization: {
    minimize: false,
  },

  // Development plugins
  plugins: [new webpack.HotModuleReplacementPlugin(), new webpack.SourceMapDevToolPlugin({})],
};
```

#### Development Database Configuration

```yaml
# .lando.yml - Development optimizations
services:
  database:
    type: mysql:8.0
    config:
      database: config/mysql.dev.cnf

  appserver:
    type: php:8.2
    config:
      php: config/php.dev.ini

  node:
    type: node:20
    build:
      - npm install
      - npm run build:development
```

### CI Environment Optimizations

#### Fast Dependency Installation

```yaml
# GitHub Actions - CI Optimizations
- name: Cache Dependencies
  uses: actions/cache@v3
  with:
    path: |
      ~/.npm
      ~/.composer/cache
      node_modules
      vendor
    key: deps-${{ runner.os }}-${{ hashFiles('**/package-lock.json', '**/composer.lock') }}
    restore-keys: |
      deps-${{ runner.os }}-

- name: Install Dependencies
  run: |
    # Parallel installation
    npm ci --prefer-offline --no-audit &
    composer install --no-dev --optimize-autoloader --no-progress &
    wait
```

#### Resource-Constrained Testing

```javascript
// playwright.ci.config.js - Resource management
module.exports = {
  // Limit concurrent tests
  workers: process.env.GITHUB_ACTIONS ? 2 : undefined,

  // Fast test execution
  use: {
    // Disable resource-intensive features
    video: 'off',
    trace: 'off',
    screenshot: 'only-on-failure',

    // Browser launch
    launchOptions: {
      args: [
        '--no-sandbox',
        '--disable-setuid-sandbox',
        '--disable-dev-shm-usage',
        '--disable-accelerated-2d-canvas',
        '--disable-gpu',
      ],
    },
  },

  // Skip slow tests in CI
  grep: /^(?!.*@slow).*/,
};
```

### Production Environment Optimizations

#### Security and Performance Hardening

```nginx
# nginx.prod.conf - Production web server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

    # Performance optimizations
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

    # Caching
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # WordPress-specific optimizations
    location ~ \.php$ {
        fastcgi_cache_valid 200 60m;
        fastcgi_cache_use_stale error timeout updating http_500 http_503;
    }
}
```

#### Production Monitoring Integration

```javascript
// monitoring/health-check.js
const { chromium } = require('playwright');

async function healthCheck() {
  const browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  try {
    const page = await browser.newPage();

    // Basic connectivity test
    const response = await page.goto(process.env.SITE_URL);
    if (!response.ok()) {
      throw new Error(`Site returned ${response.status()}`);
    }

    // WordPress-specific checks
    await page.waitForSelector('body.wordpress', { timeout: 10000 });

    // Performance metrics
    const metrics = await page.evaluate(() => ({
      loadTime: performance.timing.loadEventEnd - performance.timing.navigationStart,
      domContentLoaded:
        performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart,
    }));

    console.log('Health check passed:', metrics);
    return true;
  } catch (error) {
    console.error('Health check failed:', error);
    return false;
  } finally {
    await browser.close();
  }
}

if (require.main === module) {
  healthCheck().then(success => {
    process.exit(success ? 0 : 1);
  });
}
```

## Troubleshooting Environment Issues

### Common Environment Detection Problems

#### Mixed Environment Signals

```bash
# Diagnose environment detection
echo "=== Environment Variables ==="
printenv | grep -E "(CI|NODE_ENV|WP_ENV|LANDO|GITHUB)"

echo "=== Current Detection ==="
node -e "console.log('Environment:', require('./config/environment').environment)"

echo "=== Configuration ==="
node -e "console.log(JSON.stringify(require('./config/environment').config, null, 2))"
```

#### Configuration Loading Issues

```javascript
// debug/config-debug.js
const fs = require('fs');
const path = require('path');

function debugConfiguration() {
  console.log('=== Configuration Debug ===');

  // Check environment detection
  const env = process.env;
  console.log('Environment Variables:', {
    CI: env.CI,
    NODE_ENV: env.NODE_ENV,
    WP_ENV: env.WP_ENV,
    LANDO: env.LANDO,
    GITHUB_ACTIONS: env.GITHUB_ACTIONS,
  });

  // Check config files
  const configDir = path.join(__dirname, '../config');
  const configFiles = fs.readdirSync(configDir);
  console.log('Available Config Files:', configFiles);

  // Load and validate configuration
  try {
    const config = require('../config/environment');
    console.log('Loaded Configuration:', config);
  } catch (error) {
    console.error('Configuration Error:', error);
  }
}

debugConfiguration();
```

### Performance Troubleshooting

#### Resource Usage Analysis

```bash
#!/bin/bash
# scripts/analyze-performance.sh

echo "=== System Resources ==="
free -h
df -h
docker system df

echo "=== Process Analysis ==="
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10

echo "=== Network Analysis ==="
netstat -tulpn | grep -E "(80|443|3306)"

echo "=== Test Performance ==="
time npm run test:e2e 2>&1 | tee performance.log

echo "=== Resource Usage During Tests ==="
grep -E "(memory|cpu|disk)" performance.log
```

#### Database Performance Analysis

```sql
-- database-performance.sql
-- Check database performance in different environments

SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
SHOW VARIABLES LIKE 'max_connections';
SHOW VARIABLES LIKE 'query_cache_size';

-- Development environment checks
SELECT
    SCHEMA_NAME as 'Database',
    ROUND(SUM(DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) as 'Size (MB)'
FROM
    information_schema.SCHEMATA s
    LEFT JOIN information_schema.TABLES t ON s.SCHEMA_NAME = t.TABLE_SCHEMA
GROUP BY
    SCHEMA_NAME;

-- Performance analysis
SHOW PROCESSLIST;
SHOW ENGINE INNODB STATUS\G
```

### Environment Synchronization

#### Configuration Validation

```javascript
// scripts/validate-environments.js
const configs = {
  development: require('../config/development.config.js'),
  ci: require('../config/ci.config.js'),
  production: require('../config/production.config.js'),
};

function validateEnvironments() {
  console.log('=== Environment Configuration Validation ===');

  const requiredKeys = ['reporter', 'workers', 'use'];

  Object.entries(configs).forEach(([env, config]) => {
    console.log(`\n--- ${env.toUpperCase()} Environment ---`);

    requiredKeys.forEach(key => {
      if (config[key] === undefined) {
        console.error(`Missing required key: ${key}`);
      } else {
        console.log(`✓ ${key}: configured`);
      }
    });

    // Environment-specific validation
    if (env === 'ci' && config.webServer) {
      console.warn('Warning: webServer configured in CI environment');
    }

    if (env === 'development' && config.use.headless !== false) {
      console.warn('Warning: headless mode enabled in development');
    }
  });
}

validateEnvironments();
```

#### Cross-Environment Testing

```bash
#!/bin/bash
# scripts/test-all-environments.sh

environments=("development" "ci" "production")

for env in "${environments[@]}"; do
    echo "=== Testing $env Environment ==="

    # Set environment
    export NODE_ENV=$env
    if [ "$env" = "ci" ]; then
        export CI=true
    else
        unset CI
    fi

    # Run environment-specific tests
    npm run test:$env || echo "Tests failed for $env"

    echo "=== Completed $env Environment ==="
    echo
done

echo "=== Environment Testing Complete ==="
```

## Best Practices

### Environment Management Principles

1. **Explicit Configuration**: Always explicitly define environment-specific settings
2. **Fail-Safe Defaults**: Provide sensible defaults when environment detection fails
3. **Validation**: Validate configuration at startup to catch issues early
4. **Documentation**: Document all environment-specific behaviors
5. **Testing**: Test configuration changes across all environments

### Security Considerations

1. **Secrets Management**: Never expose secrets in configuration files
2. **Environment Isolation**: Maintain strict separation between environments
3. **Access Control**: Limit environment access based on roles
4. **Audit Logging**: Log all configuration changes and access
5. **Regular Reviews**: Periodically review and update environment configurations

### Performance Optimization

1. **Resource Monitoring**: Continuously monitor resource usage across environments
2. **Lazy Loading**: Load configuration only when needed
3. **Caching**: Cache expensive configuration calculations
4. **Profiling**: Profile configuration loading and application startup
5. **Optimization**: Regularly optimize based on performance metrics

This environment-aware configuration system provides scalable, and maintainable environment
management that automatically optimizes for each execution context while maintaining consistency and
reliability across all environments.
