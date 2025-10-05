# Playwright E2E Testing Guide

This guide helps you get started with end-to-end testing using Playwright in the WordPress
Quickstart project.

## Quick Start

### 1. Setup Your Environment

First, make sure your WordPress site is running:

```bash
# Start your development environment
lando start

# Install Playwright and browsers
npm install
npm run test:e2e:install
```

### 2. Run Your First Test

```bash
# Run all E2E tests
npm run test:e2e

# Run with browser visible (helpful for debugging)
npm run test:e2e:headed

# Run specific test suites
npm run test:e2e:wordpress    # WordPress functionality
npm run test:e2e:visual       # Visual regression tests
// Optional storefront tests can be run if using an e-commerce plugin
```

### 3. Debug Tests

```bash
# Interactive debugging
npm run test:e2e:debug

# Test runner UI (great for development)
npm run test:e2e:ui

# Generate test code by recording actions
npm run test:e2e:codegen
```

## Test Structure

```
tests/
├── playwright.config.js      # Playwright configuration
├── e2e/
│   ├── utils/                # Reusable test utilities
│   │   ├── wordpress-admin.js    # WordPress admin helpers
│   │   └── test-utils.js         # General test utilities
│   ├── wordpress/            # WordPress core tests
│   │   ├── admin.spec.js     # Admin functionality tests
│   │   └── frontend.spec.js  # Frontend tests
│   ├── storefront/           # Optional storefront tests (e.g., shop/cart)
│   │   └── shop.spec.js      # Storefront, cart, checkout tests
│   ├── visual/               # Visual regression tests
│   │   └── screenshots.spec.js   # Screenshot comparison tests
│   ├── debug.spec.js         # Debugging and inspection tests
│   ├── global-setup.js       # Global test setup
│   └── global-teardown.js    # Global test cleanup
├── unit/                     # PHP unit tests
└── bootstrap.php             # PHP test bootstrap
```

## Writing Tests

### Basic Test Example

```javascript
// tests/e2e/my-test.spec.js
const { test, expect } = require('@playwright/test');
const { WordPressAdmin } = require('./utils/wordpress-admin');

test('my WordPress test', async ({ page }) => {
  const admin = new WordPressAdmin(page);

  // Login to WordPress admin
  await admin.login();

  // Navigate to posts
  await admin.navigateToAdminPage('edit.php');

  // Verify posts page loaded
  await expect(page.locator('.wp-list-table')).toBeVisible();
});
```

### Using Test Utilities

````javascript
const { test, expect } = require('@playwright/test');
const { WordPressAdmin } = require('./utils/wordpress-admin');
// Optional storefront helpers can be added if using a storefront plugin
// const { Storefront } = require("./utils/storefront");
const { TestUtils } = require('./utils/test-utils');

## Test Examples

### WordPress Core Functionality Test

```javascript
test('WordPress admin access', async ({ page }) => {
  // Navigate to WordPress admin
  await page.goto('/wp-admin');

  // Check login page loads
  await expect(page).toHaveTitle(/Log In/);

  // Verify WordPress branding
  await expect(page.locator('#login')).toBeVisible();
});
````

## Configuration

// Optional storefront helpers can be added if using an e-commerce plugin // const { Storefront } =
require("./utils/storefront");

Create a `.env` file in your project root:

```bash
  // const shop = new Storefront(page);
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=password

// Storefront/customer credentials (optional)
// WC_CUSTOMER_USER=customer
// WC_CUSTOMER_PASSWORD=password
// Optional storefront tests (if a storefront plugin is installed)
// await storefront.goToShop();
// await storefront.searchProducts("test");
PLAYWRIGHT_BASE_URL=https://wordpress-quickstart.lndo.site

# Enable debug mode
    // await shop.addToCart("Test Product", 1);
```

```javascript
// await shop.completeCheckout({
```

Use tags to organize and filter tests:

```javascript
test.describe('WordPress Admin @wordpress @admin', () => {
  // Admin tests
});

// Optional storefront test group (uncomment if storefront tests are used)
// test.describe("Storefront @storefront @shop", () => {
//   // Shop tests
// });

test.describe('Visual Tests @visual @regression', () => {
  // Visual regression tests
});
```

Run specific tagged tests:

```bash
# Run only WordPress tests
npx playwright test --grep @wordpress

# Run only WooCommerce tests
// Optional storefront customer credentials can be added if using an e-commerce plugin
// WC_CUSTOMER_USER=customer
// WC_CUSTOMER_PASSWORD=password
# Run visual regression tests
npx playwright test --grep @visual
```

## Best Practices

### 1. Use Page Object Model

Organize your test code using the provided utilities:

```javascript
// Good: Using utility classes
const admin = new WordPressAdmin(page);
await admin.login();
await admin.createPost({ title: 'Test Post' });

// Avoid: Direct page interactions everywhere
// Optional storefront tests can be tagged if using an e-commerce plugin
// test.describe("Storefront @storefront @shop", () => {
//   // Storefront tests
// });
```

npm run test:e2e:wordpress # WordPress functionality npm run test:e2e:visual # Visual regression
tests // Optional storefront tests can be run if needed by a project-specific plugin // Hide dynamic
elements in visual tests await page.addStyleTag({ content:
`.wp-admin-bar { display: none !important; }     .widget_calendar { display: none !important; }`,
}); // npx playwright test --grep @woocommerce

### 3. Use Proper Waits

```javascript
// Good: Wait for specific elements
await page.waitForSelector('.woocommerce-message');

// Good: Wait for network to be idle
await page.waitForLoadState('networkidle');

// Avoid: Fixed timeouts
await page.waitForTimeout(5000);
```

### 4. Test Data Management

```javascript
// Generate unique test data
const testUtils = new TestUtils(page);
const testData = testUtils.generateTestData();

// Use the generated data
await admin.createPost({
  title: testData.postTitle,
  content: 'Test content',
});
```

## Debugging Tips

### 1. Visual Debugging

```bash
# Run with browser visible
npm run test:e2e:headed

# Slow down execution
npx playwright test --headed --slowMo=1000
```

### 2. Test Inspector

```bash
# Open test in inspector
npm run test:e2e:debug

# Or target specific test
npx playwright test debug.spec.js --debug
```

### 3. Screenshots and Videos

Screenshots and videos are automatically captured on failure. Find them in:

```
test-results/
├── screenshots/
├── videos/
└── traces/
```

### 4. Trace Viewer

```bash
# Generate trace file
npx playwright test --trace on

# View trace file
npx playwright show-trace test-results/trace.zip
```

## Continuous Integration

In your CI/CD pipeline:

```yaml
# GitHub Actions example
- name: Install dependencies
  run: npm ci

- name: Install Playwright browsers
  run: npx playwright install --with-deps

- name: Start WordPress
  run: lando start

- name: Run E2E tests
  run: npm run test:e2e
  env:
    WP_ADMIN_USER: admin
    WP_ADMIN_PASSWORD: password
```

## Troubleshooting

### Common Issues

1. **Site not accessible**: Make sure `lando start` is running
2. **Browser install failed**: Run `npm run test:e2e:install`
3. **Login failed**: Check WP_ADMIN_USER and WP_ADMIN_PASSWORD
4. **Flaky tests**: Add proper waits and hide dynamic content

### Getting Help

1. Check the debug test: `npx playwright test debug.spec.js`
2. Run health checks: Look for "WordPress health check" output
3. View test reports: `npm run test:e2e:report`
4. Enable debug mode: `PLAYWRIGHT_DEBUG=1 npm run test:e2e`

## Example Test Scenarios

### WordPress Functionality

- Admin login and navigation
- Post/page creation and editing
- Plugin and theme management
- Settings configuration
- User management

### Optional Storefront Functionality

- Product catalog browsing
- Search functionality
- Add to cart workflow
- Checkout process
- Customer account management

### Visual Regression

- Homepage appearance
- Shop page layout
- Cart and checkout pages
- Admin dashboard
- Mobile/tablet responsiveness

This testing setup ensures your WordPress e-commerce site works reliably across different browsers
and devices!
