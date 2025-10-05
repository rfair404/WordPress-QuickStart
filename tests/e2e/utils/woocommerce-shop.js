/* eslint-disable no-console */

// Placeholder WooCommerceShop utility
class WooCommerceShop {
  constructor(page) {
    this.page = page;
  }

  async goToShop() {
    // Placeholder navigation - implement storefront-specific helpers under tests/e2e/storefront/
    await this.page.goto('/shop');
  }

  async searchProducts() {
    // No-op placeholder
    return;
  }

  async addToCart() {
    // No-op placeholder
    return;
  }

  async viewCart() {
    // No-op placeholder
    return;
  }

  async getCartItemCount() {
    return 0;
  }
}

module.exports = { WooCommerceShop };
