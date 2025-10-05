// Storefront Shop Tests (optional - for WooCommerce or other storefront plugins)
/* eslint-disable no-console, no-unused-vars */
const { test, expect } = require("@playwright/test");
const { StorefrontShop } = require("../utils/storefront-shop");
const { WordPressAdmin } = require("../utils/wordpress-admin");
const { TestUtils, WordPressAssertions } = require("../utils/test-utils");

test.describe("Storefront Shop @storefront", () => {
  let shop;
  let admin;
  let testUtils;
  let wpAssertions;

  test.beforeEach(async ({ page }) => {
    shop = new StorefrontShop(page);
    admin = new WordPressAdmin(page);
    testUtils = new TestUtils(page);
    wpAssertions = new WordPressAssertions(page);
  });

  test("shop page loads correctly (optional)", async ({ page }) => {
    await shop.goToShop();

    // At minimum, verify we have storefront body class or content
    const hasStorefrontContent = await testUtils.elementExists(".storefront, .woocommerce");
    expect(hasStorefrontContent).toBeTruthy();

    console.log("✅ Shop page loaded correctly (storefront optional test)");
  });

  // Other tests can be copied from previous WooCommerce tests and adapted as optional
});
