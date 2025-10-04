// Global setup for Playwright tests
/* eslint-disable no-console */
const { chromium } = require( '@playwright/test' );

async function globalSetup() {
	console.log( '🚀 Starting global setup for WordPress E2E tests...' );

	// Create a browser instance
	const browser = await chromium.launch();
	const page = await browser.newPage();

	try {
		// Get base URL from environment or config
		const baseURL =
			process.env.PLAYWRIGHT_BASE_URL ||
			( process.env.LANDO === 'ON'
				? 'https://wordpress-quickstart.lndo.site'
				: 'http://localhost:8080' );

		console.log( `📍 Testing WordPress site: ${ baseURL }` );

		// Wait for WordPress to be available
		let retries = 30; // 30 seconds max
		let isReady = false;

		while ( retries > 0 && ! isReady ) {
			try {
				await page.goto( baseURL, { timeout: 5000 } );

				// Check if WordPress is responding
				const title = await page.title();
				if ( title && ! title.includes( 'Error' ) ) {
					isReady = true;
					console.log( '✅ WordPress is ready!' );
				} else {
					throw new Error( 'WordPress not ready' );
				}
			} catch ( error ) {
				console.log(
					`⏳ Waiting for WordPress... (${ retries } attempts left)`
				);
				retries--;
				await page.waitForTimeout( 1000 );
			}
		}

		if ( ! isReady ) {
			throw new Error(
				'❌ WordPress failed to start within timeout period'
			);
		}

		// Basic WordPress health check
		try {
			// Check if wp-admin is accessible
			await page.goto( `${ baseURL }/wp-admin` );
			const hasLoginForm = await page.locator( '#loginform' ).isVisible();

			if ( hasLoginForm ) {
				console.log( '✅ WordPress admin is accessible' );
			}

			// Check if frontend is working
			await page.goto( baseURL );
			const hasContent = await page.locator( 'body' ).isVisible();

			if ( hasContent ) {
				console.log( '✅ WordPress frontend is working' );
			}
		} catch ( error ) {
			console.warn(
				'⚠️  Some WordPress components may not be fully ready:',
				error.message
			);
		}

		// Store test data in storage state for authentication tests
		await page
			.context()
			.storageState( { path: './test-results/auth-setup.json' } );
	} catch ( error ) {
		console.error( '❌ Global setup failed:', error );
		throw error;
	} finally {
		await browser.close();
	}

	console.log( '✅ Global setup completed successfully!' );
}

module.exports = globalSetup;
