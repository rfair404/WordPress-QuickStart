const { test, expect } = require('@playwright/test');

/**
 * WordPress Installation Validation Tests
 *
 * These tests validate that WordPress is properly installed and accessible
 * through the web interface, confirming our Composer-managed setup works.
 */

test.describe('WordPress Installation Validation', () => {

  test('WordPress installation page is accessible', async ({ page }) => {
    // Navigate to the WordPress installation URL
    await page.goto('/');

    // Should either show WordPress installation screen or a working site
    const pageContent = await page.textContent('body');

    // Check for WordPress installation indicators
    const hasWordPressInstaller = await page.locator('body').textContent().then(
      text => text.includes('WordPress') ||
        text.includes('Welcome') ||
        text.includes('Install') ||
        text.includes('Site Title')
    );

    const hasWorkingSite = await page.locator('body').textContent().then(
      text => text.includes('Just another WordPress site') ||
        text.includes('Hello world!') ||
        text.includes('Sample Page')
    );

    // Either installation screen or working site should be present
    expect(hasWordPressInstaller || hasWorkingSite).toBeTruthy();
  });

  test('WordPress admin is accessible', async ({ page }) => {
    // Navigate to WordPress admin
    await page.goto('/wp-admin/');

    // Should show WordPress login screen
    await expect(page).toHaveTitle(/WordPress/);

    // Should have login form elements
    const loginElements = [
      page.locator('#user_login'),
      page.locator('#user_pass'),
      page.locator('#wp-submit')
    ];

    for (const element of loginElements) {
      await expect(element).toBeVisible();
    }

    // Should have WordPress branding
    const bodyText = await page.textContent('body');
    expect(bodyText).toMatch(/WordPress|Log In|Username|Password/i);
  });

  test('WordPress core files are served correctly', async ({ page }) => {
    // Test that WordPress core files return appropriate responses
    const coreFiles = [
      '/wp-includes/js/jquery/jquery.min.js',
      '/wp-admin/css/login.css',
      '/wp-includes/css/admin-bar.css'
    ];

    for (const file of coreFiles) {
      const response = await page.request.get(file);
      expect(response.status()).toBe(200);

      // Should have appropriate content type
      const contentType = response.headers()['content-type'];
      if (file.endsWith('.js')) {
        expect(contentType).toMatch(/javascript|text/);
      } else if (file.endsWith('.css')) {
        expect(contentType).toMatch(/css|text/);
      }
    }
  });

  test('WooCommerce plugin is installed and detectable', async ({ page }) => {
    // Navigate to WordPress admin
    await page.goto('/wp-admin/');

    // Check if WooCommerce assets are loaded (indicates plugin is installed)
    const woocommerceAssets = [
      '/custom/plugins/woocommerce/assets/css/admin.css',
      '/custom/plugins/woocommerce/assets/js/admin/woocommerce.js'
    ]; let woocommerceDetected = false;

    for (const asset of woocommerceAssets) {
      try {
        const response = await page.request.get(asset);
        if (response.status() === 200) {
          woocommerceDetected = true;
          break;
        }
      } catch (error) {
        // Asset might not be loaded on login page, that's OK
      }
    }

    // Alternative: Check if WooCommerce directory exists by trying to access it
    if (!woocommerceDetected) {
      const response = await page.request.get('/custom/plugins/woocommerce/');
      // Should return 403 (forbidden) or 200, not 404 (not found)
      expect(response.status()).not.toBe(404);
    }
  });

  test('Default theme is installed and accessible', async ({ page }) => {
    // Check that Twenty Twenty-Four theme files are accessible
    const themeFiles = [
      '/custom/themes/twentytwentyfour/style.css',
      '/custom/themes/twentytwentyfour/theme.json'
    ]; let themeDetected = false;

    for (const file of themeFiles) {
      const response = await page.request.get(file);
      if (response.status() === 200) {
        themeDetected = true;
        const content = await response.text();
        expect(content.length).toBeGreaterThan(0);
        break;
      }
    }

    expect(themeDetected).toBeTruthy();
  });

  test('WordPress uploads directory is accessible', async ({ page }) => {
    // Try to access uploads directory
    const response = await page.request.get('/custom/uploads/');    // Should return 403 (forbidden) or 200, not 404 (directory exists)
    expect(response.status()).not.toBe(404);
  });

  test('WordPress REST API is functional', async ({ page }) => {
    // Test WordPress REST API endpoint
    const response = await page.request.get('/wp-json/wp/v2/');

    expect(response.status()).toBe(200);

    const apiData = await response.json();
    expect(apiData).toHaveProperty('namespace');
    expect(apiData.namespace).toBe('wp/v2');
  });

  test('WordPress version is correct', async ({ page }) => {
    // Check WordPress version via generator meta tag
    await page.goto('/');

    const generator = await page.locator('meta[name="generator"]').getAttribute('content');

    if (generator) {
      expect(generator).toMatch(/WordPress \d+\.\d+/);

      // Extract version number
      const versionMatch = generator.match(/WordPress (\d+\.\d+)/);
      if (versionMatch) {
        const version = versionMatch[1];
        const majorVersion = parseFloat(version);
        expect(majorVersion).toBeGreaterThanOrEqual(6.0);
      }
    }
  });

  test('WordPress database connection is working', async ({ page }) => {
    // Navigate to site - if DB connection fails, we'll see an error
    await page.goto('/');

    const bodyText = await page.textContent('body');

    // Should not show database connection errors
    expect(bodyText).not.toMatch(/Error establishing a database connection/i);
    expect(bodyText).not.toMatch(/Database connection error/i);
    expect(bodyText).not.toMatch(/Can't select database/i);
  });

  test('WordPress multisite is not accidentally enabled', async ({ page }) => {
    // Navigate to admin
    await page.goto('/wp-admin/');

    const bodyText = await page.textContent('body');

    // Should not show multisite indicators (unless intentionally configured)
    expect(bodyText).not.toMatch(/Network Admin/i);
    expect(bodyText).not.toMatch(/My Sites/i);
  });
});
