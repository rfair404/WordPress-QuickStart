module.exports = {
    extends: [
        '@wordpress/eslint-plugin/recommended'
    ],
    env: {
        browser: true,
        es6: true,
        node: true,
        jquery: true
    },
    globals: {
        wp: 'readonly',
        ajaxurl: 'readonly',
        jQuery: 'readonly',
        $: 'readonly'
    },
    rules: {
        // WordPress specific overrides
        'no-console': 'warn',
        'no-debugger': 'error',
        
        // Prefer const/let over var
        'no-var': 'error',
        'prefer-const': 'error',
        
        // Code quality
        'complexity': ['warn', 10],
        'max-depth': ['warn', 4],
        'max-lines-per-function': ['warn', 50],
        
        // WordPress jQuery compatibility
        'no-global-assign': ['error', { exceptions: ['jQuery', '$'] }],
        
        // Import/export rules
        'import/no-unresolved': 'off', // WordPress handles this differently
        
        // JSDoc requirements for public functions
        'jsdoc/require-jsdoc': ['warn', {
            require: {
                FunctionDeclaration: true,
                MethodDefinition: true,
                ClassDeclaration: true
            }
        }]
    },
    overrides: [
        {
            files: ['**/*.test.js', '**/*.spec.js'],
            env: {
                jest: true
            },
            rules: {
                'no-console': 'off'
            }
        },
        {
            files: ['webpack.config.js', 'gulpfile.js', '*.config.js'],
            env: {
                node: true
            },
            rules: {
                'no-console': 'off'
            }
        }
    ],
    settings: {
        'import/resolver': {
            'webpack': {
                'config': './webpack.config.js'
            }
        }
    }
};