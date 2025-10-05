# Phase 2: package.json Script Changes

## Current Scripts (Remove)

```json
{
  "build": "wp-scripts build",
  "build:production": "wp-scripts build --mode=production",
  "start": "wp-scripts start",
  "dev": "wp-scripts start",
  "lint:js": "eslint . --ext .js,.jsx,.ts,.tsx --config .config/linting/.eslintrc.js",
  "lint:js:fix": "eslint . --ext .js,.jsx,.ts,.tsx --config .config/linting/.eslintrc.js --fix",
  "lint:css": "find . -name '*.css' -o -name '*.scss' -o -name '*.pcss' | head -1 | grep -q . && wp-scripts lint-style || echo 'No CSS files found to lint'",
  "lint:css:fix": "find . -name '*.css' -o -name '*.scss' -o -name '*.pcss' | head -1 | grep -q . && wp-scripts lint-style --fix || echo 'No CSS files found to lint'",
  "format": "wp-scripts format",
  "format:check": "npm run lint:js && npm run lint:css",
  "format:all": "npm run lint:js:fix && npm run lint:css:fix",
  "test": "wp-scripts test-unit-js --passWithNoTests",
  "test:watch": "wp-scripts test-unit-js --watch"
}
```

## New Scripts (Replace With)

```json
{
  "dev": "lando start",
  "stop": "lando stop",
  "restart": "lando restart",

  "lint": "npm run lint:js && npm run lint:css && npm run lint:php",
  "lint:js": "eslint custom/ src/ --ext .js",
  "lint:js:fix": "eslint custom/ src/ --ext .js --fix",
  "lint:css": "stylelint 'custom/**/*.css' 'custom/**/*.scss'",
  "lint:css:fix": "stylelint 'custom/**/*.css' 'custom/**/*.scss' --fix",
  "lint:php": "lando composer lint",

  "format": "prettier --write .",
  "format:check": "prettier --check .",

  "test": "npm run test:php && npm run test:e2e",
  "test:php": "lando composer test",
  "test:unit": "lando composer test",

  "wp": "lando wp",
  "composer": "lando composer",
  "plugin:activate": "lando wp plugin activate",
  "plugin:deactivate": "lando wp plugin deactivate",
  "theme:activate": "lando wp theme activate"
}
```

## Scripts to Keep (No Changes)

```json
{
  "test:e2e": "playwright test --config=tests/playwright.config.js",
  "test:e2e:headed": "playwright test --config=tests/playwright.config.js --headed",
  "test:e2e:debug": "playwright test --config=tests/playwright.config.js --debug",
  "test:e2e:ui": "playwright test --config=tests/playwright.config.js --ui",
  "test:e2e:install": "playwright install",
  "test:e2e:codegen": "playwright codegen https://wordpress-quickstart.lndo.site",
  "test:e2e:report": "playwright show-report",

  "gh:check": "bash scripts/gh-wrapper.sh --version || echo 'GitHub CLI not installed. Run: npm run gh:install'",
  "gh:install": "node -e \"console.log('Install GitHub CLI from: https://cli.github.com/ or run: winget install GitHub.cli')\"",
  "gh:auth": "bash scripts/gh-wrapper.sh auth status || bash scripts/gh-wrapper.sh auth login",
  "gh:actions": "bash scripts/gh-wrapper.sh run list --limit 10",
  "gh:actions:latest": "bash scripts/gh-wrapper.sh run view $(bash scripts/gh-wrapper.sh run list --json databaseId --jq '.[0].databaseId')",
  "gh:actions:logs": "bash scripts/gh-wrapper.sh run view --log-failed $(bash scripts/gh-wrapper.sh run list --json databaseId,conclusion --jq '.[] | select(.conclusion==\"failure\") | .databaseId' | head -1)",

  "lint-staged": "lint-staged"
}
```

## lint-staged Configuration Changes

### Current (Complex)

```json
"lint-staged": {
  "*.{js,jsx,ts,tsx}": [
    "wp-scripts format",
    "wp-scripts lint-js --fix"
  ],
  "*.{css,scss,sass}": [
    "wp-scripts format",
    "wp-scripts lint-style --fix"
  ],
  "*.{json,yml,yaml,md,html}": [
    "wp-scripts format"
  ],
  "*.php": [
    "composer run lint:fix"
  ]
}
```

### New (Simple)

```json
"lint-staged": {
  "*.js": [
    "eslint --fix",
    "prettier --write"
  ],
  "*.{css,scss}": [
    "stylelint --fix",
    "prettier --write"
  ],
  "*.{json,yml,yaml,md}": [
    "prettier --write"
  ],
  "*.php": [
    "lando composer lint:fix"
  ]
}
```

## browserslist Section Changes

### Current

```json
"browserslist": [
  "extends @wordpress/browserslist-config"
]
```

### New

```json
"browserslist": [
  "defaults",
  "not ie 11"
]
```

## Summary

- **Removed**: 13 wp-scripts dependent commands
- **Added**: 8 WordPress development focused commands
- **Simplified**: lint-staged from wp-scripts to direct tools
- **Enhanced**: Added useful wp-cli shortcuts for plugin/theme development
