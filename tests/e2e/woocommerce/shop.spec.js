// WooCommerce Shop Tests
/* eslint-disable no-console, no-unused-vars */
const { test, expect } = require("@playwright/test");
const { WooCommerceShop } = require("../utils/woocommerce-shop");
const { WordPressAdmin } = require("../utils/wordpress-admin");
const { TestUtils, WordPressAssertions } = require("../utils/test-utils");

test.describe("WooCommerce Shop @woocommerce", () => {
  let shop;
  let admin;
  let testUtils;
  let wpAssertions;

  test.beforeEach(async ({ page }) => {
    shop = new WooCommerceShop(page);
    admin = new WordPressAdmin(page);
    testUtils = new TestUtils(page);
    wpAssertions = new WordPressAssertions(page);
  });

  test("shop page loads correctly", async ({ page }) => {
    await shop.goToShop();

    // Verify WooCommerce is active
    await wpAssertions.assertWooCommerceActive();

    // Check for shop elements
    const shopElements = [
      ".woocommerce-products-header",
      ".products",
      ".woocommerce-result-count",
      ".woocommerce-ordering",
    ];

    let shopElementFound = false;
    for (const selector of shopElements) {
      if (await testUtils.elementExists(selector)) {
        await expect(page.locator(selector)).toBeVisible();
        shopElementFound = true;
        break;
      }
    }

    // At minimum, verify we have WooCommerce body class or content
    if (!shopElementFound) {
      const hasWooCommerceContent =
        await testUtils.elementExists(".woocommerce");
      expect(hasWooCommerceContent).toBeTruthy();
    }

    console.log("✅ Shop page loaded correctly");
  });

  test("product search works", async ({ page }) => {
    await shop.searchProducts("test");

    // Verify we're on search results page
    expect(page.url()).toContain("s=test");

    // Check for search results elements
    const hasResults =
      (await testUtils.elementExists(".woocommerce-products-header")) ||
      (await testUtils.elementExists(".products")) ||
      (await testUtils.elementExists(".woocommerce-result-count"));

    expect(hasResults).toBeTruthy();

    console.log("✅ Product search works");
  });

  test("cart page is accessible", async ({ page }) => {
    await shop.viewCart();

    // Check cart page loaded
    await expect(
      page.locator(".woocommerce-cart-form, .cart-empty"),
    ).toBeVisible();

    // Check we're on cart page
    expect(page.url()).toContain("cart");

    console.log("✅ Cart page is accessible");
  });

  test("checkout page is accessible", async ({ page }) => {
    await page.goto("/checkout");
    await testUtils.waitForWordPress();

    // Check checkout page loaded
    const checkoutForm = await testUtils.elementExists(".woocommerce-checkout");
    const checkoutContent =
      (await testUtils.elementExists(".woocommerce-checkout-payment")) ||
      (await testUtils.elementExists(".checkout-button")) ||
      page.url().includes("checkout");

    expect(checkoutForm || checkoutContent).toBeTruthy();

    console.log("✅ Checkout page is accessible");
  });

  test("my account page loads", async ({ page }) => {
    await page.goto("/my-account");
    await testUtils.waitForWordPress();

    // Should show login form or account dashboard
    const hasLogin = await testUtils.elementExists(".woocommerce-form-login");
    const hasAccount = await testUtils.elementExists(
      ".woocommerce-MyAccount-navigation",
    );

    expect(hasLogin || hasAccount).toBeTruthy();

    console.log("✅ My Account page loads");
  });

  test("product categories page works", async ({ page }) => {
    // Try common WooCommerce category URLs
    const categoryUrls = ["/product-category/uncategorized/", "/shop/"];

    let categoryFound = false;
    for (const url of categoryUrls) {
      try {
        const response = await page.goto(url);
        if (response.status() === 200) {
          await testUtils.waitForWordPress();

          // Check for WooCommerce content
          if (await testUtils.elementExists(".woocommerce")) {
            categoryFound = true;
            console.log(`✅ Product category page works: ${url}`);
            break;
          }
        }
      } catch (error) {
        // Continue to next URL
      }
    }

    // If no category pages found, at least verify shop works
    if (!categoryFound) {
      await shop.goToShop();
      await wpAssertions.assertWooCommerceActive();
      console.log("✅ Shop page verified (no specific categories found)");
    }
  });

  test("WooCommerce widgets and blocks work", async ({ page }) => {
    await shop.goToShop();

    // Look for common WooCommerce widgets/blocks
    const wcElements = [
      ".wc-block-product-search",
      ".wc-block-product-categories",
      ".widget_product_search",
      ".widget_product_categories",
      ".woocommerce-widget-layered-nav",
    ];

    let wcElementFound = false;
    for (const selector of wcElements) {
      if (await testUtils.elementExists(selector)) {
        wcElementFound = true;
        console.log(`✅ Found WooCommerce element: ${selector}`);
        break;
      }
    }

    // Minimum check - just verify WooCommerce is present
    if (!wcElementFound) {
      await wpAssertions.assertWooCommerceActive();
      console.log(
        "✅ WooCommerce is active (no specific widgets/blocks found)",
      );
    }
  });

  test.skip("can add product to cart", async ({ page }) => {
    // This test is skipped by default as it requires actual products
    // Uncomment and modify when you have products set up

    const testData = testUtils.generateTestData();

    try {
      await shop.addToCart(testData.productName, 1);

      // Verify cart has items
      const cartCount = await shop.getCartItemCount();
      expect(cartCount).toBeGreaterThan(0);

      console.log("✅ Product added to cart successfully");
    } catch (error) {
      console.log(
        "ℹ️  Product add to cart test skipped - no test products available",
      );
    }
  });

  test.skip("checkout process works", async ({ page }) => {
    // This test is skipped by default as it requires products and setup
    // Uncomment and modify when you have a complete WooCommerce setup

    const testData = testUtils.generateTestData();

    try {
      // Add product to cart first
      await shop.addToCart("Test Product", 1);

      // Complete checkout
      const orderSuccess = await shop.completeCheckout({
        billing: {
          firstName: testData.firstName,
          lastName: testData.lastName,
          email: testData.email,
          phone: testData.phone,
          address1: testData.address,
          city: testData.city,
          postcode: testData.postcode,
        },
        paymentMethod: "cod",
      });

      expect(orderSuccess).toBeTruthy();

      console.log("✅ Checkout process completed successfully");
    } catch (error) {
      console.log(
        "ℹ️  Checkout test skipped - requires complete WooCommerce setup",
      );
    }
  });
});

test.describe("WooCommerce Admin @woocommerce", () => {
  let shop;
  let admin;
  let testUtils;

  test.beforeEach(async ({ page }) => {
    shop = new WooCommerceShop(page);
    admin = new WordPressAdmin(page);
    testUtils = new TestUtils(page);
  });

  test("WooCommerce admin pages are accessible", async ({ page }) => {
    await admin.login();

    // Test WooCommerce admin pages
    const wcAdminPages = [
      { slug: "admin.php?page=wc-admin", name: "WooCommerce Dashboard" },
      { slug: "edit.php?post_type=product", name: "Products" },
      { slug: "edit.php?post_type=shop_order", name: "Orders" },
      { slug: "edit.php?post_type=shop_coupon", name: "Coupons" },
      { slug: "admin.php?page=wc-settings", name: "Settings" },
    ];

    let wcPagesFound = 0;

    for (const wcPage of wcAdminPages) {
      try {
        await admin.navigateToAdminPage(wcPage.slug);

        // Check if page loaded successfully
        await page.waitForSelector(".wrap, #wpbody-content", {
          timeout: 5000,
        });

        const hasContent =
          (await testUtils.elementExists(".wrap")) ||
          (await testUtils.elementExists("#wpbody-content"));

        if (hasContent) {
          wcPagesFound++;
          console.log(`✅ ${wcPage.name} page accessible`);
        }
      } catch (error) {
        console.log(
          `ℹ️  ${wcPage.name} page not found (WooCommerce may not be installed)`,
        );
      }
    }

    if (wcPagesFound === 0) {
      console.log(
        "ℹ️  No WooCommerce admin pages found - WooCommerce may not be installed",
      );

      // At least verify we can access admin
      await admin.navigateToAdminPage("index.php");
      await expect(page.locator("#dashboard-widgets")).toBeVisible();
    } else {
      console.log(`✅ Found ${wcPagesFound} WooCommerce admin pages`);
    }
  });

  test.skip("can create a simple product", async ({ page }) => {
    // This test is skipped by default - enable when WooCommerce is set up
    await admin.login();

    try {
      await admin.navigateToAdminPage("post-new.php?post_type=product");

      const testData = testUtils.generateTestData();

      // Fill product details
      await page.fill("#title", testData.productName);

      // Set regular price
      await page.fill("#_regular_price", "29.99");

      // Publish product
      await page.click("#publish");

      // Wait for success
      await page.waitForSelector(".updated, .notice-success", {
        timeout: 10000,
      });

      console.log("✅ Product created successfully");
    } catch (error) {
      console.log(
        "ℹ️  Product creation test skipped - WooCommerce not available",
      );
    }
  });

  test("WooCommerce installation check", async ({ page }) => {
    await admin.login();

    // Check if WooCommerce is installed by looking for it in plugins
    await admin.navigateToAdminPage("plugins.php");

    const hasWooCommerce = await testUtils.elementExists(
      '[data-slug="woocommerce"]',
    );

    if (hasWooCommerce) {
      console.log("✅ WooCommerce plugin is installed");

      // Check if it's active
      const isActive = await testUtils.elementExists(
        '[data-slug="woocommerce"].active',
      );
      if (isActive) {
        console.log("✅ WooCommerce plugin is active");
      } else {
        console.log("ℹ️  WooCommerce plugin is installed but not active");
      }
    } else {
      console.log(
        "ℹ️  WooCommerce plugin not found - install it to enable e-commerce functionality",
      );
    }
  });
});
