// Common test utilities and helpers
/* eslint-disable no-console */
const { expect } = require( '@playwright/test' );

/**
 * General test utilities
 */
class TestUtils {
	constructor( page ) {
		this.page = page;
	}

	/**
	 * Wait for WordPress to load completely
	 */
	async waitForWordPress() {
		// Wait for body to be visible
		await this.page.waitForSelector( 'body', { timeout: 30000 } );

		// Wait for network to be idle
		await this.page.waitForLoadState( 'networkidle', { timeout: 30000 } );

		// Additional wait for WordPress-specific elements
		try {
			await this.page.waitForSelector(
				'.wp-site-blocks, #main, .site-main',
				{
					timeout: 5000,
				}
			);
		} catch ( error ) {
			// Continue if WordPress-specific elements aren't found
			console.warn(
				'WordPress-specific elements not found, continuing...'
			);
		}
	}

	/**
	 * Check if element exists without throwing
	 * @param {string} selector - CSS selector
	 * @return {boolean} True if element exists
	 */
	async elementExists( selector ) {
		try {
			const element = await this.page.locator( selector ).first();
			return await element.isVisible();
		} catch {
			return false;
		}
	}

	/**
	 * Wait for text to appear on page
	 * @param {string} text    - Text to wait for
	 * @param {number} timeout - Timeout in milliseconds
	 */
	async waitForText( text, timeout = 10000 ) {
		await this.page.waitForSelector( `text=${ text }`, { timeout } );
	}

	/**
	 * Scroll element into view
	 * @param {string} selector - CSS selector
	 */
	async scrollIntoView( selector ) {
		await this.page.locator( selector ).scrollIntoViewIfNeeded();
	}

	/**
	 * Take full page screenshot
	 * @param {string} name - Screenshot name
	 */
	async fullPageScreenshot( name ) {
		await this.page.screenshot( {
			path: `test-results/screenshots/${ name }-${ Date.now() }.png`,
			fullPage: true,
		} );
	}

	/**
	 * Check console errors
	 * @return {Array} Array of console error messages
	 */
	async getConsoleErrors() {
		const errors = [];

		this.page.on( 'console', ( message ) => {
			if ( message.type() === 'error' ) {
				errors.push( message.text() );
			}
		} );

		return errors;
	}

	/**
	 * Check for 404 errors
	 */
	async check404() {
		const response = await this.page.waitForResponse( '**' );
		if ( response.status() === 404 ) {
			throw new Error( `404 error detected on ${ response.url() }` );
		}
	}

	/**
	 * Handle WordPress admin bar interference
	 */
	async hideAdminBar() {
		try {
			await this.page.evaluate( () => {
				const adminBar = document.getElementById( 'wpadminbar' );
				if ( adminBar ) {
					adminBar.style.display = 'none';
				}
			} );
		} catch ( error ) {
			// Ignore if admin bar doesn't exist
		}
	}

	/**
	 * Generate random test data
	 */
	generateTestData() {
		const timestamp = Date.now();
		const random = Math.floor( Math.random() * 1000 );

		return {
			email: `test${ timestamp }@example.com`,
			username: `testuser${ random }`,
			productName: `Test Product ${ random }`,
			postTitle: `Test Post ${ timestamp }`,
			firstName: 'Test',
			lastName: `User${ random }`,
			company: `Test Company ${ random }`,
			phone: `555-${ random.toString().padStart( 4, '0' ) }`,
			address: `${ random } Test Street`,
			city: 'Test City',
			postcode: `${ random.toString().padStart( 5, '0' ) }`,
		};
	}

	/**
	 * Wait for AJAX requests to complete
	 */
	async waitForAjax() {
		await this.page.waitForFunction(
			() => {
				// jQuery AJAX
				if ( typeof window.jQuery !== 'undefined' ) {
					return window.jQuery.active === 0;
				}

				// Modern fetch/XMLHttpRequest
				return ! window.fetch || window.fetch.length === 0;
			},
			{ timeout: 30000 }
		);
	}

	/**
	 * Retry an action with exponential backoff
	 * @param {Function} action     - Action to retry
	 * @param {number}   maxRetries - Maximum number of retries
	 * @param {number}   baseDelay  - Base delay in milliseconds
	 */
	async retryAction( action, maxRetries = 3, baseDelay = 1000 ) {
		let lastError;

		for ( let attempt = 1; attempt <= maxRetries; attempt++ ) {
			try {
				return await action();
			} catch ( error ) {
				lastError = error;

				if ( attempt === maxRetries ) {
					throw error;
				}

				const delay = baseDelay * Math.pow( 2, attempt - 1 );
				console.log(
					`Attempt ${ attempt } failed, retrying in ${ delay }ms...`
				);
				await this.page.waitForTimeout( delay );
			}
		}

		throw lastError;
	}

	/**
	 * Mock WordPress REST API responses
	 * @param {Object} mockData - Mock response data
	 */
	async mockRestAPI( mockData ) {
		await this.page.route( '**/wp-json/**', async ( route ) => {
			const url = route.request().url();

			// Check if we have mock data for this endpoint
			const endpoint = url.split( '/wp-json/' )[ 1 ];

			if ( mockData[ endpoint ] ) {
				await route.fulfill( {
					status: 200,
					contentType: 'application/json',
					body: JSON.stringify( mockData[ endpoint ] ),
				} );
			} else {
				await route.continue();
			}
		} );
	}

	/**
	 * Wait for WordPress nonce to be available
	 */
	async waitForNonce() {
		await this.page.waitForFunction(
			() => {
				return (
					typeof window.wpApiSettings !== 'undefined' ||
					typeof window._wpUtilSettings !== 'undefined'
				);
			},
			{ timeout: 10000 }
		);
	}

	/**
	 * Handle WordPress login redirects
	 */
	async handleLoginRedirects() {
		// Wait for potential redirects after login
		await this.page.waitForLoadState( 'networkidle' );

		// Handle WordPress admin redirects
		const currentUrl = this.page.url();
		if (
			currentUrl.includes( 'wp-login.php' ) &&
			! currentUrl.includes( 'loggedout=true' )
		) {
			// Still on login page, might need to wait longer
			await this.page.waitForTimeout( 2000 );
		}
	}
}

/**
 * WordPress-specific assertions
 */
class WordPressAssertions {
	constructor( page ) {
		this.page = page;
	}

	/**
	 * Assert WordPress is loaded
	 */
	async assertWordPressLoaded() {
		// Check for WordPress-specific elements
		const wpElements = [
			'body.wordpress',
			'body[class*="wp-"]',
			'.wp-site-blocks',
			'#main',
			'.site-main',
		];

		let found = false;
		for ( const selector of wpElements ) {
			if ( await this.page.locator( selector ).isVisible() ) {
				found = true;
				break;
			}
		}

		if ( ! found ) {
			// Check for WordPress generator meta tag
			const generator = await this.page
				.locator( 'meta[name="generator"][content*="WordPress"]' )
				.isVisible();
			if ( generator ) {
				found = true;
			}
		}

		expect( found ).toBeTruthy();
	}

	/**
	 * Assert admin bar is visible (user is logged in)
	 */
	async assertAdminBarVisible() {
		await expect( this.page.locator( '#wpadminbar' ) ).toBeVisible();
	}

	/**
	 * Assert no PHP errors on page
	 */
	async assertNoPhpErrors() {
		const phpErrors = [
			'Fatal error',
			'Parse error',
			'Warning:',
			'Notice:',
			'Deprecated:',
		];

		const pageContent = await this.page.textContent( 'body' );

		for ( const error of phpErrors ) {
			expect( pageContent ).not.toContain( error );
		}
	}

	/**
	 * Assert WooCommerce is active
	 */
	async assertWooCommerceActive() {
		// Check for WooCommerce body classes or elements
		const wcElements = [
			'body.woocommerce',
			'.woocommerce',
			'.wc-block-components-button',
		];

		let found = false;
		for ( const selector of wcElements ) {
			if ( await this.page.locator( selector ).first().isVisible() ) {
				found = true;
				break;
			}
		}

		expect( found ).toBeTruthy();
	}
}

module.exports = { TestUtils, WordPressAssertions };
