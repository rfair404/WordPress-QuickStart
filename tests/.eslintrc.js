module.exports = {
	extends: [ '../.config/linting/.eslintrc.js' ],
	env: {
		browser: true,
		node: true,
		jest: true,
	},
	globals: {
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
		navigator: 'readonly',
	},
	rules: {
		'no-console': 'off',
		'no-unused-vars': 'warn',
		'max-lines-per-function': 'off',
		'no-nested-ternary': 'warn',
		'no-shadow': 'warn',
	},
};
