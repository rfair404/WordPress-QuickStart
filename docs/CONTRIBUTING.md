# Contributing to WordPress Quickstart

We love your input! We want to make contributing to this project as easy and transparent as possible.

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are
expected to uphold this code.

## Getting Started

1. **Fork the repository** and clone it locally
2. **Set up the development environment**:
   ```bash
   ./scripts/setup/env-setup.sh  # Unix/Mac/Git Bash
   # or
   .\scripts\setup\env-setup.bat  # Windows PowerShell
   ```
3. **Start the development environment**:
   ```bash
   lando start
   lando composer install
   lando npm install
   ```
4. **Run tests** to ensure everything works:
   ```bash
   ./scripts/setup/test-setup.sh  # Unix/Mac/Git Bash
   # or
   .\scripts\setup\test-setup.bat  # Windows
   ```

## Development Workflow

1. **Create a branch** for your feature or fix:

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following our coding standards:
   - Follow WordPress VIP coding standards for PHP
   - Use WordPress JavaScript coding standards for JS
   - All code must pass linting and tests

3. **Test your changes**:

   ```bash
   # Run PHP tests
   lando composer test

   # Run JavaScript/E2E tests (Playwright)
   lando npm run test:e2e

   # Check code formatting and linters (configs live under .config/)
   lando npm run format:check
   lando npm run lint:js
   ```

4. **Commit your changes** using conventional commit format:

   ```bash
   git commit -m "feat(auth): add user login functionality"
   ```

5. **Push to your fork** and submit a pull request

## Coding Standards

### PHP

- Follow [WordPress VIP Coding Standards](https://docs.wpvip.com/technical-references/code-quality-and-best-practices/code-review/)
- Use PHPDoc comments for all functions and classes
- Write unit tests for new functionality
- Run `lando composer lint` before committing

### JavaScript

- Follow [WordPress JavaScript Coding Standards](https://developer.wordpress.org/coding-standards/wordpress-coding-standards-for-javascript/)
- Use JSDoc comments for functions
- Write tests for new functionality
- Run `lando npm run lint:js` before committing (ESLint config is under `.config/linting/`)

### CSS

- Follow [WordPress CSS Coding Standards](https://developer.wordpress.org/coding-standards/wordpress-coding-standards-for-css/)
- Use meaningful class names
- Run `lando npm run lint:css` before committing (Stylelint config is under `.config/linting/`)

## Commit Message Format

We use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types:

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools

### Examples:

```
feat(auth): add user registration functionality
fix(cart): resolve quantity update issue
docs: update installation instructions
style: format code according to standards
refactor(payment): simplify gateway integration
test: add unit tests for user model
chore: update development dependencies
```

## Pull Request Process

1. **Update documentation** if you're changing functionality
2. **Add tests** for new features
3. **Ensure all tests pass** and code meets standards
4. **Update the README.md** if needed
5. **Fill out the pull request template** completely
6. **Request review** from maintainers

## Pull Request Guidelines

- **One feature per PR** - keep changes focused
- **Write clear descriptions** of what your PR does
- **Include screenshots** for UI changes
- **Reference issues** that your PR addresses
- **Be responsive** to feedback and requests for changes

## Testing

### Running Tests

```bash
# Run all PHP tests
lando composer test

# Run PHP tests with coverage
lando composer test:coverage

# Run JavaScript/E2E tests (Playwright)
lando npm run test:e2e

# Run linters and format checks
lando npm run format:check
lando npm run lint:js
```

### Writing Tests

- **PHP tests** go in `tests/unit/` or `tests/integration/`
- **JavaScript tests** should be co-located with components
- Follow existing test patterns and naming conventions
- Aim for good test coverage of new functionality

## Code Review

All submissions require review. We use GitHub pull requests for this purpose.

### What We Look For:

- **Code quality** and adherence to standards
- **Test coverage** for new functionality
- **Documentation** updates where needed
- **Performance** considerations
- **Security** best practices
- **Accessibility** compliance

## Bug Reports

Great bug reports tend to have:

- A quick summary and/or background
- Steps to reproduce (be specific!)
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening)

## Feature Requests

We love feature requests! Please provide:

- **Clear description** of the feature
- **Use case** - why would this be useful?
- **Implementation ideas** if you have them
- **Examples** from other projects if applicable

## Questions?

Feel free to open an issue with the "question" label, or reach out to the maintainers directly.

## License

By contributing, you agree that your contributions will be licensed under the GPL-2.0-or-later License.
