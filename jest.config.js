module.exports = {
  ...require("@wordpress/scripts/config/jest-unit.config.js"),
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
};
