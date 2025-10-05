// Storefront/shop tests are intentionally removed from core scope.
// If storefront testing is needed, place tests under tests/e2e/storefront/ and adapt accordingly.
/* eslint-disable no-console */
const { test } = require("@playwright/test");

test.describe("Storefront placeholder", () => {
  test("placeholder - storefront tests disabled", async ({ page }) => {
    console.log("ℹ️  Storefront tests are intentionally disabled in this repository.");
  });
});
