const js = require('@eslint/js');

module.exports = [
  // Global ignores for all configurations
  {
    ignores: [
      // WordPress core files
      'wp/**/*',
      // Vendor and third-party code
      'vendor/**/*',
      'node_modules/**/*',
      'build/**/*',
      'coverage/**/*',
      'playwright-report/**/*',
      // Minified files
      '**/*.min.js',
      // Generated files
      'dist/**/*',
    ],
  },

  // Apply to all JavaScript files in our custom code
  {
    files: ['**/*.js', '**/*.mjs'],
    languageOptions: {
      ecmaVersion: 2020,
      sourceType: 'module',
      globals: {
        // WordPress globals
        wp: 'readonly',
        ajaxurl: 'readonly',
        jQuery: 'readonly',
        $: 'readonly',
        // Browser globals
        window: 'readonly',
        document: 'readonly',
        console: 'readonly',
        // Node.js globals
        process: 'readonly',
        Buffer: 'readonly',
        __dirname: 'readonly',
        __filename: 'readonly',
        module: 'readonly',
        require: 'readonly',
        exports: 'readonly',
        global: 'readonly',
      },
    },
    rules: {
      ...js.configs.recommended.rules,

      // WordPress specific overrides
      'no-console': 'warn',
      'no-debugger': 'error',

      // Prefer const/let over var
      'no-var': 'error',
      'prefer-const': 'error',

      // Code quality
      complexity: ['warn', 10],
      'max-depth': ['warn', 4],

      // WordPress jQuery compatibility
      'no-global-assign': ['error', { exceptions: ['jQuery', '$'] }],
    },
  },

  // Test files configuration
  {
    files: ['**/*.spec.js', 'tests/**/*.js'],
    languageOptions: {
      globals: {
        // Playwright globals
        page: 'readonly',
        browser: 'readonly',
        context: 'readonly',
        expect: 'readonly',
        test: 'readonly',
        describe: 'readonly',
        beforeAll: 'readonly',
        afterAll: 'readonly',
        beforeEach: 'readonly',
        afterEach: 'readonly',
      },
    },
    rules: {
      'no-console': 'off',
      'no-unused-vars': 'warn',
    },
  },

  // Config files
  {
    files: ['webpack.config.js', 'gulpfile.js', '*.config.js'],
    languageOptions: {
      sourceType: 'commonjs',
      globals: {
        module: 'readonly',
        require: 'readonly',
        exports: 'readonly',
        __dirname: 'readonly',
        __filename: 'readonly',
      },
    },
    rules: {
      'no-console': 'off',
    },
  },
];
