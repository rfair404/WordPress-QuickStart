module.exports = {
  extends: ["eslint:recommended"],
  ignorePatterns: [
    // Third-party plugins and themes (WooCommerce removed in Phase 2)
    "wp/**",
    "vendor/**",
    "node_modules/**",
    "*.min.js",
    "build/**",
    "dist/**",
  ],
  env: {
    browser: true,
    es6: true,
    es2020: true,
    node: true,
    jquery: true,
  },
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: "module",
  },
  globals: {
    wp: "readonly",
    ajaxurl: "readonly",
    jQuery: "readonly",
    $: "readonly",
  },
  rules: {
    // WordPress specific overrides
    "no-console": "warn",
    "no-debugger": "error",

    // Prefer const/let over var
    "no-var": "error",
    "prefer-const": "error",

    // Code quality
    complexity: ["warn", 10],
    "max-depth": ["warn", 4],
    "max-lines-per-function": ["warn", 50],

    // WordPress jQuery compatibility
    "no-global-assign": ["error", { exceptions: ["jQuery", "$"] }],
  },
  overrides: [
    {
      files: ["**/*.spec.js", "tests/**/*.js"],
      env: {
        browser: true,
        node: true,
      },
      globals: {
        // Playwright globals
        page: "readonly",
        browser: "readonly",
        context: "readonly",
        expect: "readonly",
        test: "readonly",
        describe: "readonly",
        beforeAll: "readonly",
        afterAll: "readonly",
        beforeEach: "readonly",
        afterEach: "readonly",
      },
      rules: {
        "no-console": "off",
        "no-unused-vars": "warn",
        "max-lines-per-function": "off",
      },
    },
    {
      files: ["webpack.config.js", "gulpfile.js", "*.config.js"],
      env: {
        node: true,
      },
      rules: {
        "no-console": "off",
      },
    },
  ],
};
