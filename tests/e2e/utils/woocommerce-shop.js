// WooCommerce E2E Test Utilities
const { expect } = require('@playwright/test');

/**
 * WooCommerce utilities for E2E testing
 */
class WooCommerceShop {
  constructor(page) {
    this.page = page;
    this.baseURL = page.context()._options.baseURL || 'http://localhost:8080';
  }

  /**
   * Navigate to shop page
   */
  async goToShop() {
    await this.page.goto('/shop');
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Search for products
   * @param {string} query - Search query
   */
  async searchProducts(query) {
    await this.goToShop();

    // Use WooCommerce product search
    await this.page.fill('.woocommerce-product-search input[name="s"]', query);
    await this.page.click('.woocommerce-product-search button[type="submit"]');

    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Add product to cart
   * @param {string} productName - Name of product to add to cart
   * @param {number} quantity - Quantity to add
   */
  async addToCart(productName, quantity = 1) {
    // Search for the product
    await this.searchProducts(productName);

    // Find product and click add to cart
    const productElement = this.page.locator('.product').filter({ hasText: productName }).first();

    if (await productElement.isVisible()) {
      // Set quantity if different from 1
      if (quantity > 1) {
        const quantityInput = productElement.locator('input.qty');
        if (await quantityInput.isVisible()) {
          await quantityInput.fill(quantity.toString());
        }
      }

      // Click add to cart button
      await productElement.locator('.add_to_cart_button, button[name="add-to-cart"]').first().click();

      // Wait for cart update
      await this.page.waitForSelector('.woocommerce-message, .added_to_cart', { timeout: 10000 });

      console.log(`✅ Added ${quantity}x ${productName} to cart`);
    } else {
      throw new Error(`Product "${productName}" not found`);
    }
  }

  /**
   * View cart
   */
  async viewCart() {
    await this.page.goto('/cart');
    await this.page.waitForSelector('.woocommerce-cart-form', { timeout: 10000 });
  }

  /**
   * Update cart quantities
   * @param {Object} updates - Product updates { productName: newQuantity }
   */
  async updateCartQuantities(updates) {
    await this.viewCart();

    for (const [productName, quantity] of Object.entries(updates)) {
      const cartRow = this.page.locator('.cart_item').filter({ hasText: productName });

      if (await cartRow.isVisible()) {
        const quantityInput = cartRow.locator('input.qty');
        await quantityInput.fill(quantity.toString());
      }
    }

    // Update cart
    await this.page.click('button[name="update_cart"]');
    await this.page.waitForSelector('.woocommerce-message', { timeout: 10000 });

    console.log('✅ Updated cart quantities');
  }

  /**
   * Remove item from cart
   * @param {string} productName - Name of product to remove
   */
  async removeFromCart(productName) {
    await this.viewCart();

    const cartRow = this.page.locator('.cart_item').filter({ hasText: productName });

    if (await cartRow.isVisible()) {
      await cartRow.locator('.remove').click();

      // Wait for removal confirmation
      await this.page.waitForSelector('.woocommerce-message', { timeout: 10000 });

      console.log(`✅ Removed ${productName} from cart`);
    }
  }

  /**
   * Proceed to checkout
   */
  async proceedToCheckout() {
    await this.viewCart();

    await this.page.click('.checkout-button');
    await this.page.waitForSelector('.woocommerce-checkout', { timeout: 10000 });
  }

  /**
   * Fill billing information
   * @param {Object} billingInfo - Billing details
   */
  async fillBillingInfo(billingInfo) {
    const {
      firstName = 'John',
      lastName = 'Doe',
      email = 'john.doe@example.com',
      phone = '1234567890',
      address1 = '123 Main St',
      city = 'Anytown',
      postcode = '12345',
      country = 'US',
      state = 'CA'
    } = billingInfo;

    await this.page.fill('#billing_first_name', firstName);
    await this.page.fill('#billing_last_name', lastName);
    await this.page.fill('#billing_email', email);
    await this.page.fill('#billing_phone', phone);
    await this.page.fill('#billing_address_1', address1);
    await this.page.fill('#billing_city', city);
    await this.page.fill('#billing_postcode', postcode);

    // Select country
    await this.page.selectOption('#billing_country', country);

    // Select state (if dropdown is visible)
    const stateSelect = this.page.locator('#billing_state');
    if (await stateSelect.isVisible()) {
      await stateSelect.selectOption(state);
    }

    console.log('✅ Filled billing information');
  }

  /**
   * Select payment method
   * @param {string} method - Payment method (cod, bacs, etc.)
   */
  async selectPaymentMethod(method = 'cod') {
    const paymentOption = this.page.locator(`#payment_method_${method}`);

    if (await paymentOption.isVisible()) {
      await paymentOption.check();
      console.log(`✅ Selected payment method: ${method}`);
    } else {
      console.warn(`⚠️  Payment method ${method} not available`);
    }
  }

  /**
   * Place order
   */
  async placeOrder() {
    await this.page.click('#place_order');

    // Wait for order confirmation or error
    await this.page.waitForSelector('.woocommerce-order-received, .woocommerce-error', { timeout: 30000 });

    // Check if order was successful
    const orderReceived = await this.page.locator('.woocommerce-order-received').isVisible();

    if (orderReceived) {
      console.log('✅ Order placed successfully');
      return true;
    } else {
      const errors = await this.page.locator('.woocommerce-error').allTextContents();
      console.error('❌ Order failed:', errors);
      return false;
    }
  }

  /**
   * Complete checkout process
   * @param {Object} checkoutData - Checkout information
   */
  async completeCheckout(checkoutData = {}) {
    await this.proceedToCheckout();
    await this.fillBillingInfo(checkoutData.billing || {});
    await this.selectPaymentMethod(checkoutData.paymentMethod || 'cod');

    // Accept terms if required
    const termsCheckbox = this.page.locator('#terms');
    if (await termsCheckbox.isVisible()) {
      await termsCheckbox.check();
    }

    return await this.placeOrder();
  }

  /**
   * Get cart totals
   * @returns {Object} Cart totals information
   */
  async getCartTotals() {
    await this.viewCart();

    const subtotal = await this.page.locator('.cart-subtotal .amount').textContent();
    const total = await this.page.locator('.order-total .amount').textContent();

    return {
      subtotal: subtotal?.trim(),
      total: total?.trim()
    };
  }

  /**
   * Get product count in cart
   * @returns {number} Number of items in cart
   */
  async getCartItemCount() {
    const cartCount = await this.page.locator('.cart-contents-count, .cartcontents').textContent();
    return parseInt(cartCount?.trim() || '0');
  }

  /**
   * Clear cart
   */
  async clearCart() {
    await this.viewCart();

    // Remove all items
    const removeButtons = await this.page.locator('.cart_item .remove').all();

    for (const button of removeButtons) {
      await button.click();
      await this.page.waitForTimeout(1000); // Small delay between removals
    }

    console.log('✅ Cleared cart');
  }

  /**
   * Apply coupon code
   * @param {string} couponCode - Coupon code to apply
   */
  async applyCoupon(couponCode) {
    await this.viewCart();

    await this.page.fill('#coupon_code', couponCode);
    await this.page.click('button[name="apply_coupon"]');

    await this.page.waitForSelector('.woocommerce-message, .woocommerce-error', { timeout: 10000 });

    const success = await this.page.locator('.woocommerce-message').isVisible();

    if (success) {
      console.log(`✅ Applied coupon: ${couponCode}`);
      return true;
    } else {
      console.log(`❌ Failed to apply coupon: ${couponCode}`);
      return false;
    }
  }

  /**
   * Login customer
   * @param {string} username - Customer username
   * @param {string} password - Customer password
   */
  async loginCustomer(username, password) {
    await this.page.goto('/my-account');

    await this.page.fill('#username', username);
    await this.page.fill('#password', password);
    await this.page.click('button[name="login"]');

    // Wait for dashboard or error
    await this.page.waitForSelector('.woocommerce-MyAccount-navigation, .woocommerce-error', { timeout: 10000 });

    const loggedIn = await this.page.locator('.woocommerce-MyAccount-navigation').isVisible();

    if (loggedIn) {
      console.log(`✅ Logged in customer: ${username}`);
      return true;
    } else {
      console.log(`❌ Failed to login customer: ${username}`);
      return false;
    }
  }
}

module.exports = { WooCommerceShop };
