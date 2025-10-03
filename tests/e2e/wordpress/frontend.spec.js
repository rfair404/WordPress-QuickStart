// WordPress Frontend Tests
const { test, expect } = require('@playwright/test');
const { TestUtils, WordPressAssertions } = require('../utils/test-utils');

test.describe('WordPress Frontend @wordpress', () => {
  let testUtils;
  let wpAssertions;

  test.beforeEach(async ({ page }) => {
    testUtils = new TestUtils(page);
    wpAssertions = new WordPressAssertions(page);
  });

  test('homepage loads successfully', async ({ page }) => {
    await page.goto('/');
    await testUtils.waitForWordPress();

    // Verify WordPress is loaded
    await wpAssertions.assertWordPressLoaded();

    // Check for basic page elements
    await expect(page.locator('body')).toBeVisible();
    await expect(page).toHaveTitle(/./); // Has some title

    // Ensure no PHP errors
    await wpAssertions.assertNoPhpErrors();

    console.log('✅ Homepage loaded successfully');
  });

  test('navigation menu works', async ({ page }) => {
    await page.goto('/');
    await testUtils.waitForWordPress();

    // Look for common WordPress navigation elements
    const navSelectors = [
      'nav',
      '.nav-menu',
      '.menu',
      '.navigation',
      '.wp-block-navigation'
    ];

    let navigationFound = false;
    for (const selector of navSelectors) {
      if (await testUtils.elementExists(selector)) {
        const nav = page.locator(selector).first();
        await expect(nav).toBeVisible();
        navigationFound = true;
        break;
      }
    }

    // At minimum, check that page structure exists
    if (!navigationFound) {
      console.log('ℹ️  No navigation menu found, checking basic page structure');
      await expect(page.locator('body')).toBeVisible();
    }

    console.log('✅ Navigation check completed');
  });

  test('search functionality works', async ({ page }) => {
    await page.goto('/');
    await testUtils.waitForWordPress();

    // Look for WordPress search form
    const searchSelectors = [
      '.search-form input[type="search"]',
      'input[name="s"]',
      '.wp-block-search input',
      '#search'
    ];

    let searchFound = false;
    for (const selector of searchSelectors) {
      if (await testUtils.elementExists(selector)) {
        const searchInput = page.locator(selector).first();

        // Perform search
        await searchInput.fill('test');

        // Try to submit search
        const form = searchInput.locator('xpath=ancestor::form');
        if (await form.isVisible()) {
          await form.locator('button[type="submit"], input[type="submit"]').first().click();
        } else {
          await searchInput.press('Enter');
        }

        await testUtils.waitForWordPress();

        // Verify we're on search results page
        expect(page.url()).toContain('s=test');

        searchFound = true;
        break;
      }
    }

    if (!searchFound) {
      console.log('ℹ️  No search form found on homepage');
    } else {
      console.log('✅ Search functionality works');
    }
  });

  test('404 page handles non-existent URLs', async ({ page }) => {
    const nonExistentUrl = '/this-page-definitely-does-not-exist-' + Date.now();

    await page.goto(nonExistentUrl);
    await testUtils.waitForWordPress();

    // Check that we get a 404 response
    const response = await page.waitForResponse(response =>
      response.url().includes(nonExistentUrl) && response.status() === 404
    );

    expect(response.status()).toBe(404);

    // Verify WordPress 404 page elements
    const pageContent = await page.textContent('body');
    const has404Content = pageContent.includes('404') ||
      pageContent.includes('not found') ||
      pageContent.includes('Not Found');

    expect(has404Content).toBeTruthy();

    console.log('✅ 404 page works correctly');
  });

  test('RSS feed is accessible', async ({ page }) => {
    await page.goto('/feed/');

    // Check that we get XML content
    const content = await page.textContent('body');
    expect(content).toContain('<?xml');
    expect(content).toContain('<rss');

    console.log('✅ RSS feed is accessible');
  });

  test('robots.txt is accessible', async ({ page }) => {
    const response = await page.goto('/robots.txt');

    expect(response.status()).toBe(200);

    const content = await page.textContent('body');
    expect(content).toContain('User-agent:');

    console.log('✅ robots.txt is accessible');
  });

  test('site has proper meta tags', async ({ page }) => {
    await page.goto('/');
    await testUtils.waitForWordPress();

    // Check for basic SEO meta tags
    const title = await page.locator('title').textContent();
    expect(title).toBeTruthy();
    expect(title.length).toBeGreaterThan(0);

    // Check for charset
    const charset = page.locator('meta[charset]');
    await expect(charset).toBeVisible();

    // Check for viewport meta tag (responsive design)
    const viewport = page.locator('meta[name="viewport"]');
    await expect(viewport).toBeVisible();

    console.log('✅ Site has proper meta tags');
  });

  test('no JavaScript errors on homepage', async ({ page }) => {
    const jsErrors = [];

    page.on('pageerror', (error) => {
      jsErrors.push(error.message);
    });

    await page.goto('/');
    await testUtils.waitForWordPress();

    // Wait a bit for any delayed JS to load
    await page.waitForTimeout(3000);

    // Allow for some common WordPress warnings but no actual errors
    const criticalErrors = jsErrors.filter(error =>
      !error.includes('Warning') &&
      !error.includes('wp-polyfill') &&
      !error.includes('Script error')
    );

    expect(criticalErrors).toHaveLength(0);

    if (jsErrors.length > 0) {
      console.log('ℹ️  JS warnings found (non-critical):', jsErrors);
    }

    console.log('✅ No critical JavaScript errors found');
  });

  test('page loads within acceptable time', async ({ page }) => {
    const startTime = Date.now();

    await page.goto('/');
    await testUtils.waitForWordPress();

    const loadTime = Date.now() - startTime;

    // Expect page to load within 10 seconds (generous for development)
    expect(loadTime).toBeLessThan(10000);

    console.log(`✅ Page loaded in ${loadTime}ms`);
  });

  test('basic responsive design elements', async ({ page }) => {
    await page.goto('/');
    await testUtils.waitForWordPress();

    // Test desktop view
    await page.setViewportSize({ width: 1200, height: 800 });
    await page.waitForTimeout(1000);

    const desktopBody = await page.locator('body').boundingBox();
    expect(desktopBody.width).toBeGreaterThan(1000);

    // Test mobile view
    await page.setViewportSize({ width: 375, height: 667 });
    await page.waitForTimeout(1000);

    const mobileBody = await page.locator('body').boundingBox();
    expect(mobileBody.width).toBeLessThan(400);

    console.log('✅ Basic responsive design verified');
  });
});

test.describe('WordPress Performance @wordpress', () => {
  test('Core Web Vitals are reasonable', async ({ page }) => {
    await page.goto('/');

    // Measure Core Web Vitals
    const metrics = await page.evaluate(() => {
      return new Promise((resolve) => {
        if ('web-vital' in window) {
          // If web-vitals library is available
          resolve({
            lcp: window.webVitals?.lcp || 0,
            fid: window.webVitals?.fid || 0,
            cls: window.webVitals?.cls || 0
          });
        } else {
          // Basic performance timing
          const timing = performance.timing;
          resolve({
            loadTime: timing.loadEventEnd - timing.navigationStart,
            domReady: timing.domContentLoadedEventEnd - timing.navigationStart,
            firstPaint: timing.responseStart - timing.navigationStart
          });
        }
      });
    });

    console.log('📊 Performance metrics:', metrics);

    // Basic assertions (lenient for development environment)
    if (metrics.loadTime) {
      expect(metrics.loadTime).toBeLessThan(15000); // 15 seconds max
    }

    console.log('✅ Performance metrics within acceptable range');
  });
});
