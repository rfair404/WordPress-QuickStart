// Storefront helpers removed — this file kept as a placeholder for future storefront integrations
module.exports.StorefrontShop = class StorefrontShop {
  constructor(page) { this.page = page; }
  async goToShop() { await this.page.goto('/shop'); }
};
