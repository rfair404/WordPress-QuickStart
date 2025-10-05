# WordPress Scripts Removal Plan

## Phase 1: Dependencies

### Remove

```bash
npm uninstall @wordpress/scripts
npm uninstall @wordpress/browserslist-config
npm uninstall @wordpress/stylelint-config
npm uninstall @wordpress/blocks
npm uninstall @wordpress/components
npm uninstall @wordpress/element
npm uninstall @wordpress/i18n
```

### Add

```bash
npm install --save-dev prettier
```

### Keep

- `eslint` (already installed)
- `stylelint` (already installed)
- `@playwright/test`
- `husky`
- `lint-staged`

## Phase 2: package.json Scripts

### Remove

- `"build": "wp-scripts build"`
- `"build:production": "wp-scripts build --mode=production"`
- `"start": "wp-scripts start"`
- `"dev": "wp-scripts start"`
- `"format": "wp-scripts format"`
- `"test": "wp-scripts test-unit-js --passWithNoTests"`
- `"test:watch": "wp-scripts test-unit-js --watch"`

### Replace

```json
{
  "dev": "lando start",
  "lint:js": "eslint custom/ src/ --ext .js",
  "lint:js:fix": "eslint custom/ src/ --ext .js --fix",
  "lint:css": "stylelint 'custom/**/*.css'",
  "lint:css:fix": "stylelint 'custom/**/*.css' --fix",
  "format": "prettier --write .",
  "format:check": "prettier --check .",
  "test": "lando composer test",
  "test:e2e": "playwright test --config=tests/playwright.config.js"
}
```

### Keep

- All `gh:*` commands
- `test:e2e:*` commands
- `lint-staged` command

## Phase 3: Configuration Files

### Remove Files

- `jest.config.js`
- `.config/linting/.eslintrc.js`
- `.config/linting/.stylelintrc.js`
- `.config/formatting/.prettierrc`

### Create Simple Configs

- `.eslintrc.js` (root level)
- `.prettierrc` (root level)
- `.stylelintrc.js` (root level)

### Update

- `package.json` browserslist section
- `lint-staged` configuration

## Phase 4: CI/CD Workflows

### Update `.github/workflows/pr-validation.yml`

- Remove `npm run build`
- Update `npm run format:check`
- Keep linting and testing steps

### Update Other Workflows

- Remove wp-scripts references
- Simplify npm commands

## Expected Outcomes

### Dependencies Reduced

- From: 15+ WordPress-specific packages
- To: 6 essential packages

### Scripts Simplified

- From: 20+ complex commands
- To: 8 core commands

### Config Complexity

- From: Multiple nested config directories
- To: 3 simple root-level configs

### Build Time

- Remove: webpack build step entirely
- Focus: Direct file serving via WordPress
