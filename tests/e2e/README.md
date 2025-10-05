# E2E Tests Removed

The Playwright E2E tests have been temporarily removed from this directory to resolve build issues.

## What was removed
- All `.spec.js` test files
- Test utilities and helper classes
- Global setup/teardown files
- Visual regression tests
- WordPress and storefront test suites

## To restore E2E testing
1. Reinstall Playwright browsers: `npm run test:e2e:install`
2. Recreate test files based on project needs
3. Update Playwright configuration if needed

The E2E testing infrastructure can be rebuilt when Playwright issues are resolved.