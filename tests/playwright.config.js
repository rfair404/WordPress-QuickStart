// @ts-check
const { defineConfig, devices } = require('@playwright/test');

/**
 * WordPress Quickstart - Playwright Configuration
 * Optimized for Lando development environment
 */

// Detect if running in Lando environment
const isLando = process.env.LANDO === 'ON';
const baseURL =
  process.env.PLAYWRIGHT_BASE_URL ||
  (isLando
    ? 'https://wordpress-quickstart.lndo.site'
    : 'http://localhost:8080');

module.exports = defineConfig({
  // Test directory
  testDir: './e2e',

  // Run tests in files in parallel
  fullyParallel: true,

  // Fail the build on CI if you accidentally left test.only in the source code
  forbidOnly: !!process.env.CI,

  // Retry on CI only
  retries: process.env.CI ? 2 : 0,

  // Opt out of parallel tests on CI
  workers: process.env.CI ? 1 : undefined,

  // Reporter to use
  reporter: process.env.CI
    ? [
        // CI reporters: minimal output + integrations
        [
          'html',
          {
            open: 'never',
            outputFolder: 'playwright-report',
          },
        ],
        ['json', { outputFile: 'test-results/results.json' }],
        ['junit', { outputFile: 'test-results/results.xml' }],
        ['dot'], // Minimal dots output for CI
        ['github'], // GitHub Actions integration
      ]
    : [
        // Local development reporters: detailed output
        [
          'html',
          {
            open: 'on-failure',
            outputFolder: 'playwright-report',
          },
        ],
        ['json', { outputFile: 'test-results/results.json' }],
        ['junit', { outputFile: 'test-results/results.xml' }],
        ['list'], // Detailed list output for local development
      ],

  // Shared settings for all the projects below
  use: {
    // Base URL to use in actions like `await page.goto('/')`
    baseURL,

    // Collect trace when retrying the failed test
    trace: 'on-first-retry',

    // Capture screenshot after each test failure
    screenshot: 'only-on-failure',

    // Record video on first retry
    video: 'retain-on-failure',

    // Global test timeout
    actionTimeout: 10000,

    // Maximum time each test can run
    timeout: 60000,

    // Ignore HTTPS errors (common in local development)
    ignoreHTTPSErrors: true,

    // WordPress-specific settings
    extraHTTPHeaders: {
      // Accept all languages
      'Accept-Language': 'en-US,en;q=0.9',
    },
  },

  // Configure projects for major browsers
  projects: [
    // Desktop browsers
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },

    // Mobile browsers
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'mobile-safari',
      use: { ...devices['iPhone 12'] },
    },

    // Tablet
    {
      name: 'tablet',
      use: { ...devices['iPad Pro'] },
    },

    // WordPress admin-specific (desktop only for better performance)
    {
      name: 'admin-tests',
      use: {
        ...devices['Desktop Chrome'],
        // Longer timeout for admin operations
        actionTimeout: 15000,
      },
      testMatch: '**/admin/**/*.spec.js',
    },

    // (storefront tests removed)
  ],

  // Global setup and teardown
  // globalSetup: require.resolve('./e2e/global-setup.js'),
  // globalTeardown: require.resolve('./e2e/global-teardown.js'),

  // Run your local dev server before starting the tests
  // Only run webServer for local development, not in CI or Lando
  webServer:
    process.env.CI || isLando
      ? undefined
      : {
          command: 'npm run start',
          url: baseURL,
          reuseExistingServer: !process.env.CI,
          timeout: 120 * 1000, // 2 minutes for WordPress to start
        },

  // Expect options
  expect: {
    // Maximum time expect() should wait for the condition to be met
    timeout: 5000,

    // Screenshot comparison options
    toHaveScreenshot: {
      scale: 'css',
      animations: 'disabled',
    },
    toMatchSnapshot: {
      threshold: 0.2,
    },
  },

  // Output directory for test artifacts
  outputDir: 'test-results/',

  // Test timeout
  timeout: 60000,

  // Global test setup done via 'use' and environment variables
});
