module.exports = {
  extends: ["stylelint-config-standard"],
  ignoreFiles: [
    "custom/plugins/woocommerce/**/*.css",
    "custom/themes/twenty*/**/*.css",
    "wp/**/*.css",
    "vendor/**/*.css",
    "node_modules/**/*.css",
    "*.min.css",
    "build/**/*.css",
    "dist/**/*.css",
  ],
  rules: {
    // WordPress theme specific overrides
    "max-line-length": null,
    "declaration-property-unit-allowed-list": null,

    // Allow vendor prefixes (handled by autoprefixer)
    "property-no-vendor-prefix": null,
    "value-no-vendor-prefix": null,

    // Custom property patterns for CSS variables
    "custom-property-pattern": "^([a-z][a-z0-9]*)(-[a-z0-9]+)*$",

    // Allow deep nesting for WordPress themes
    "max-nesting-depth": 6,

    // Color and font rules
    "color-named": "never",
    "font-family-name-quotes": "always-where-recommended",

    // Performance rules
    "selector-max-universal": 1,
    "selector-max-type": 3,

    // WordPress specific class naming
    "selector-class-pattern":
      "^[a-z]([a-z0-9-]+)?(__([a-z0-9]+-?)+)?(--([a-z0-9]+-?)+){0,2}$|^wp-|^has-|^is-|^js-",

    // Allow WordPress core classes
    "selector-id-pattern": null,
  },
  overrides: [
    {
      files: ["**/*.scss"],
      rules: {
        "at-rule-no-unknown": null,
        "scss/at-rule-no-unknown": true,
      },
    },
  ],
  ignoreFiles: [
    "vendor/**/*.css",
    "node_modules/**/*.css",
    "wp-content/uploads/**/*.css",
    "build/**/*.css",
    "dist/**/*.css",
    "coverage/**/*.css",
  ],
};
