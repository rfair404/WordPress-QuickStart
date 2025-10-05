// Visual Regression Tests for WordPress Quickstart
/* eslint-disable no-console */
const { test, expect } = require("@playwright/test");
const { WordPressAdmin } = require("../utils/wordpress-admin");
const { WooCommerceShop } = require("../utils/woocommerce-shop");
const { TestUtils } = require("../utils/test-utils");

test.describe("Visual Regression Tests @visual", () => {
  let admin;
  let shop;
  let testUtils;

  test.beforeEach(async ({ page }) => {
    admin = new WordPressAdmin(page);
    shop = new WooCommerceShop(page);
    testUtils = new TestUtils(page);
  });

  test("homepage visual snapshot", async ({ page }) => {
    await page.goto("/");
    await testUtils.waitForWordPress();

    // Hide any dynamic elements that might cause flaky tests
    await page.addStyleTag({
      content: `
        /* Hide dynamic elements for consistent screenshots */
        .wp-admin-bar { display: none !important; }
        .widget_calendar { display: none !important; }
        .current-time { display: none !important; }
        [data-timestamp] { display: none !important; }
      `,
    });

    // Wait for images to load
    await page.waitForLoadState("networkidle");

    // Take full page screenshot
    await expect(page).toHaveScreenshot("homepage-full.png", {
      fullPage: true,
      animations: "disabled",
    });

    console.log("✅ Homepage visual snapshot captured");
  });

  test("shop page visual snapshot", async ({ page }) => {
    await shop.goToShop();

    // Hide dynamic elements
    await page.addStyleTag({
      content: `
        .wp-admin-bar { display: none !important; }
        .woocommerce-ordering { display: none !important; }
        .price-filter-widget { display: none !important; }
      `,
    });

    await page.waitForLoadState("networkidle");

    // Take screenshot of shop page
    await expect(page).toHaveScreenshot("shop-page.png", {
      fullPage: true,
      animations: "disabled",
    });

    console.log("✅ Shop page visual snapshot captured");
  });

  test("cart page visual snapshot", async ({ page }) => {
    await shop.viewCart();

    // Hide dynamic elements
    await page.addStyleTag({
      content: `
        .wp-admin-bar { display: none !important; }
        .cart-collaterals .shipping-calculator-form { display: none !important; }
      `,
    });

    await page.waitForLoadState("networkidle");

    // Take screenshot
    await expect(page).toHaveScreenshot("cart-page.png", {
      fullPage: true,
      animations: "disabled",
    });

    console.log("✅ Cart page visual snapshot captured");
  });

  test("checkout page visual snapshot", async ({ page }) => {
    await page.goto("/checkout");
    await testUtils.waitForWordPress();

    // Hide dynamic elements
    await page.addStyleTag({
      content: `
        .wp-admin-bar { display: none !important; }
        .woocommerce-checkout-review-order { opacity: 0.5; }
        .payment_methods { opacity: 0.5; }
      `,
    });

    await page.waitForLoadState("networkidle");

    // Take screenshot
    await expect(page).toHaveScreenshot("checkout-page.png", {
      fullPage: true,
      animations: "disabled",
    });

    console.log("✅ Checkout page visual snapshot captured");
  });

  test("admin login page visual snapshot", async ({ page }) => {
    await page.goto("/wp-login.php");
    await page.waitForSelector("#loginform");

    // Hide dynamic elements
    await page.addStyleTag({
      content: `
        .forgetmenot { display: none !important; }
      `,
    });

    // Take screenshot
    await expect(page).toHaveScreenshot("admin-login.png", {
      animations: "disabled",
    });

    console.log("✅ Admin login visual snapshot captured");
  });

  test("admin dashboard visual snapshot", async ({ page }) => {
    await admin.login();
    await admin.navigateToAdminPage("index.php");

    // Hide dynamic elements
    await page.addStyleTag({
      content: `
        .wp-admin-bar { display: none !important; }
        #dashboard_right_now .inside { opacity: 0.5; }
        #dashboard_activity .inside { opacity: 0.5; }
        .welcome-panel-last { display: none !important; }
      `,
    });

    await page.waitForLoadState("networkidle");

    // Take screenshot
    await expect(page).toHaveScreenshot("admin-dashboard.png", {
      fullPage: true,
      animations: "disabled",
    });

    console.log("✅ Admin dashboard visual snapshot captured");
  });

  test("mobile homepage visual snapshot", async ({ page }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });

    await page.goto("/");
    await testUtils.waitForWordPress();

    // Hide dynamic elements
    await page.addStyleTag({
      content: `
        .wp-admin-bar { display: none !important; }
      `,
    });

    await page.waitForLoadState("networkidle");

    // Take mobile screenshot
    await expect(page).toHaveScreenshot("homepage-mobile.png", {
      fullPage: true,
      animations: "disabled",
    });

    console.log("✅ Mobile homepage visual snapshot captured");
  });

  test("tablet shop page visual snapshot", async ({ page }) => {
    // Set tablet viewport
    await page.setViewportSize({ width: 768, height: 1024 });

    await shop.goToShop();

    // Hide dynamic elements
    await page.addStyleTag({
      content: `
        .wp-admin-bar { display: none !important; }
      `,
    });

    await page.waitForLoadState("networkidle");

    // Take tablet screenshot
    await expect(page).toHaveScreenshot("shop-page-tablet.png", {
      fullPage: true,
      animations: "disabled",
    });

    console.log("✅ Tablet shop page visual snapshot captured");
  });

  test("theme compatibility visual check", async ({ page }) => {
    await page.goto("/");
    await testUtils.waitForWordPress();

    // Hide admin bar and dynamic content
    await testUtils.hideAdminBar();
    await page.addStyleTag({
      content: `
        /* Normalize dynamic content for visual testing */
        .widget_calendar,
        .widget_recent_comments,
        .widget_recent_entries,
        [data-timestamp],
        .current-time {
          display: none !important;
        }

        /* Ensure consistent font rendering */
        * {
          -webkit-font-smoothing: antialiased;
          -moz-osx-font-smoothing: grayscale;
        }
      `,
    });

    await page.waitForLoadState("networkidle");

    // Test different viewport sizes
    const viewports = [
      { name: "desktop", width: 1200, height: 800 },
      { name: "tablet", width: 768, height: 1024 },
      { name: "mobile", width: 375, height: 667 },
    ];

    for (const viewport of viewports) {
      await page.setViewportSize({
        width: viewport.width,
        height: viewport.height,
      });
      await page.waitForTimeout(1000); // Allow layout to stabilize

      await expect(page).toHaveScreenshot(`theme-${viewport.name}.png`, {
        fullPage: true,
        animations: "disabled",
      });

      console.log(`✅ Theme compatibility ${viewport.name} snapshot captured`);
    }
  });

  test("WooCommerce product grid visual snapshot", async ({ page }) => {
    await shop.goToShop();

    // Focus on product grid area if it exists
    const productGrid = page
      .locator(".products, .woocommerce-products-wrapper")
      .first();

    if (await productGrid.isVisible()) {
      await expect(productGrid).toHaveScreenshot("product-grid.png", {
        animations: "disabled",
      });
      console.log("✅ Product grid visual snapshot captured");
    } else {
      // Fallback to full shop page
      await expect(page).toHaveScreenshot("shop-content.png", {
        fullPage: true,
        animations: "disabled",
      });
      console.log(
        "✅ Shop content visual snapshot captured (no product grid found)",
      );
    }
  });
});

test.describe("Visual Regression - Error States @visual", () => {
  let testUtils;

  test.beforeEach(async ({ page }) => {
    testUtils = new TestUtils(page);
  });

  test("404 page visual snapshot", async ({ page }) => {
    await page.goto("/non-existent-page-" + Date.now());
    await testUtils.waitForWordPress();

    // Hide dynamic elements
    await page.addStyleTag({
      content: `
        .wp-admin-bar { display: none !important; }
      `,
    });

    await page.waitForLoadState("networkidle");

    // Take screenshot
    await expect(page).toHaveScreenshot("404-page.png", {
      fullPage: true,
      animations: "disabled",
    });

    console.log("✅ 404 page visual snapshot captured");
  });

  test("search no results visual snapshot", async ({ page }) => {
    await page.goto("/?s=nonexistenttermdefinitelynotfound12345");
    await testUtils.waitForWordPress();

    // Hide dynamic elements
    await page.addStyleTag({
      content: `
        .wp-admin-bar { display: none !important; }
      `,
    });

    await page.waitForLoadState("networkidle");

    // Take screenshot
    await expect(page).toHaveScreenshot("search-no-results.png", {
      fullPage: true,
      animations: "disabled",
    });

    console.log("✅ Search no results visual snapshot captured");
  });
});
