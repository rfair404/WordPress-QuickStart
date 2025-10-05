// Jest configuration for potential JavaScript unit tests
// Currently using Playwright for E2E testing
module.exports = {
  testEnvironment: "node",
  testMatch: [
    "<rootDir>/src/**/__tests__/**/*.js",
    "<rootDir>/src/**/?(*.)+(spec|test).js",
    "<rootDir>/tests/unit/**/?(*.)+(spec|test).js",
  ],
  testPathIgnorePatterns: [
    "/node_modules/",
    "/vendor/",
    "/wp/",
    "/custom/",
    "/tests/e2e/",
    "/tests/integration/",
    "/tests/validation/",
    "\\.min\\.js$",
  ],
  collectCoverageFrom: [
    "src/**/*.js",
    "!src/**/*.min.js",
    "!**/node_modules/**",
  ],
};
