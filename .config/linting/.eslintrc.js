module.exports = {
	extends: ['eslint:recommended'],
	ignorePatterns: [
		'custom/plugins/woocommerce/**',
		'custom/themes/twenty*/**',
		'wp/**',
		'vendor/**',
		'node_modules/**',
		'*.min.js',
		'build/**',
		'dist/**',
	],
	env: {
		browser: true,
		es6: true,
		node: true,
		jquery: true,
	},
	globals: {
		wp: 'readonly',
		ajaxurl: 'readonly',
		jQuery: 'readonly',
		$: 'readonly',
	},
	rules: {
		// WordPress specific overrides
		'no-console': 'warn',
		'no-debugger': 'error',

		// Prefer const/let over var
		'no-var': 'error',
		'prefer-const': 'error',

		// Code quality
		complexity: ['warn', 10],
		'max-depth': ['warn', 4],
		'max-lines-per-function': ['warn', 50],

		// WordPress jQuery compatibility
		'no-global-assign': ['error', { exceptions: ['jQuery', '$'] }],

		// Import/export rules
		'import/no-unresolved': 'off', // WordPress handles this differently

		// JSDoc requirements for public functions
		'jsdoc/require-jsdoc': [
			'warn',
			{
				require: {
					FunctionDeclaration: true,
					MethodDefinition: true,
					ClassDeclaration: true,
				},
			},
		],
	},
	overrides: [
		{
			files: ['**/*.test.js', '**/*.spec.js', 'tests/**/*.js'],
			env: {
				jest: true,
				browser: true,
				node: true,
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
			},
			rules: {
				'no-console': 'off',
				'no-unused-vars': 'warn',
				'max-lines-per-function': 'off',
			},
		},
		{
			files: ['webpack.config.js', 'gulpfile.js', '*.config.js'],
			env: {
				node: true,
			},
			rules: {
				'no-console': 'off',
			},
		},
	],
	settings: {
		'import/resolver': {
			webpack: {
				config: './webpack.config.js',
			},
		},
	},
};
