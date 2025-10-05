// Global teardown for WordPress E2E tests
/* eslint-disable no-console */

async function globalTeardown() {
  console.log("🧹 Running global teardown...");

  // Clean up any test artifacts
  const fs = require("fs");

  try {
    // Clean up temporary auth files if they exist
    const authFile = "./test-results/auth-setup.json";
    if (fs.existsSync(authFile)) {
      fs.unlinkSync(authFile);
      console.log("✅ Cleaned up auth setup file");
    }

    // Log test completion
    console.log("✅ Global teardown completed successfully!");
  } catch (error) {
    console.warn("⚠️  Warning during teardown:", error.message);
  }
}

module.exports = globalTeardown;
