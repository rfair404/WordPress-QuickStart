// WordPress E2E Test Utilities
/* eslint-disable no-console, no-nested-ternary */
const { expect } = require("@playwright/test");

/**
 * WordPress Admin utilities for E2E testing
 */
class WordPressAdmin {
  constructor(page) {
    this.page = page;
    this.baseURL = page.context()._options.baseURL || "http://localhost:8080";
  }

  /**
   * Login to WordPress admin
   * @param {string} username - Admin username
   * @param {string} password - Admin password
   */
  async login(username = "admin", password = "password") {
    await this.page.goto("/wp-login.php");

    // Wait for login form to be visible
    await this.page.waitForSelector("#loginform", { timeout: 10000 });

    // Fill login credentials
    await this.page.fill("#user_login", username);
    await this.page.fill("#user_pass", password);

    // Submit login form
    await this.page.click("#wp-submit");

    // Wait for dashboard to load
    await this.page.waitForSelector("#wpadminbar", { timeout: 15000 });

    // Verify we're logged in
    await expect(this.page.locator("#wpadminbar")).toBeVisible();

    console.log("✅ Successfully logged into WordPress admin");
  }

  /**
   * Logout from WordPress admin
   */
  async logout() {
    // Hover over admin bar user menu
    await this.page.hover("#wp-admin-bar-my-account");

    // Click logout link
    await this.page.click("#wp-admin-bar-logout a");

    // Wait for login page
    await this.page.waitForSelector("#loginform");

    console.log("✅ Successfully logged out of WordPress admin");
  }

  /**
   * Navigate to specific admin page
   * @param {string} page - Admin page slug (e.g., 'plugins.php', 'themes.php')
   */
  async navigateToAdminPage(page) {
    await this.page.goto(`/wp-admin/${page}`);
    await this.page.waitForLoadState("networkidle");
  }

  /**
   * Install and activate a plugin
   * @param {string} pluginSlug - Plugin slug to install
   */
  async installPlugin(pluginSlug) {
    await this.navigateToAdminPage("plugin-install.php");

    // Search for plugin
    await this.page.fill("#search-plugins", pluginSlug);
    await this.page.click("#search-submit");

    // Wait for search results
    await this.page.waitForSelector(".plugin-card", { timeout: 10000 });

    // Install plugin
    const installButton = this.page
      .locator(`.plugin-card-${pluginSlug} .install-now`)
      .first();
    if (await installButton.isVisible()) {
      await installButton.click();

      // Wait for installation to complete
      await this.page.waitForSelector(".activate-now", {
        timeout: 30000,
      });

      // Activate plugin
      await this.page.click(".activate-now");

      console.log(
        `✅ Successfully installed and activated plugin: ${pluginSlug}`,
      );
    } else {
      console.log(`ℹ️  Plugin ${pluginSlug} may already be installed`);
    }
  }

  /**
   * Activate a theme
   * @param {string} themeSlug - Theme slug to activate
   */
  async activateTheme(themeSlug) {
    await this.navigateToAdminPage("themes.php");

    // Find and activate theme
    const themeElement = this.page.locator(`[data-slug="${themeSlug}"]`);

    if (await themeElement.isVisible()) {
      await themeElement.hover();
      await themeElement.locator(".activate").click();

      // Wait for activation
      await this.page.waitForSelector(".current-theme", {
        timeout: 10000,
      });

      console.log(`✅ Successfully activated theme: ${themeSlug}`);
    } else {
      throw new Error(`Theme ${themeSlug} not found`);
    }
  }

  /**
   * Create a new post
   * @param {Object} postData         - Post data
   * @param {string} postData.title   - Post title
   * @param {string} postData.content - Post content
   * @param {string} postData.status  - Post status (draft, publish)
   */
  async createPost({ title, content, status = "publish" }) {
    await this.navigateToAdminPage("post-new.php");

    // Wait for editor to load
    await this.page.waitForSelector(".block-editor-writing-flow", {
      timeout: 15000,
    });

    // Add title
    await this.page.fill(".editor-post-title__input", title);

    // Add content
    await this.page.click(".block-editor-default-block-appender__content");
    await this.page.fill(
      ".block-editor-default-block-appender .wp-block-paragraph",
      content,
    );

    // Publish or save draft
    if (status === "publish") {
      await this.page.click(".editor-post-publish-panel__toggle");
      await this.page.click(".editor-post-publish-button");

      // Wait for success message
      await this.page.waitForSelector(".components-snackbar__content", {
        timeout: 10000,
      });

      console.log(`✅ Successfully published post: ${title}`);
    } else {
      await this.page.click(".editor-post-save-draft");
      console.log(`✅ Successfully saved draft: ${title}`);
    }
  }

  /**
   * Update WordPress settings
   * @param {Object} settings - Settings to update
   */
  async updateSettings(settings) {
    await this.navigateToAdminPage("options-general.php");

    for (const [key, value] of Object.entries(settings)) {
      const field = this.page.locator(`[name="${key}"]`);

      if (await field.isVisible()) {
        await field.fill(value);
      }
    }

    // Save settings
    await this.page.click("#submit");

    // Wait for save confirmation
    await this.page.waitForSelector(".updated", { timeout: 10000 });

    console.log("✅ Successfully updated WordPress settings");
  }

  /**
   * Check for admin notices
   * @return {Array} Array of notice messages
   */
  async getAdminNotices() {
    const notices = [];

    const noticeElements = await this.page.locator(".notice:visible").all();

    for (const notice of noticeElements) {
      const text = await notice.textContent();
      const type = await notice.getAttribute("class");

      notices.push({
        message: text.trim(),
        type: type.includes("error")
          ? "error"
          : type.includes("warning")
            ? "warning"
            : type.includes("success")
              ? "success"
              : "info",
      });
    }

    return notices;
  }

  /**
   * Wait for WordPress admin to be ready
   */
  async waitForAdminReady() {
    await this.page.waitForSelector("#wpadminbar", { timeout: 30000 });
    await this.page.waitForLoadState("networkidle");
  }

  /**
   * Take a screenshot with WordPress context
   * @param {string} name - Screenshot name
   */
  async screenshot(name) {
    await this.page.screenshot({
      path: `test-results/screenshots/${name}-${Date.now()}.png`,
      fullPage: true,
    });
  }
}

module.exports = { WordPressAdmin };
