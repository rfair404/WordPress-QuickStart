// Playwright Debugging and Development Utilities
/* eslint-disable no-console */
const { test } = require( '@playwright/test' );
const { WooCommerceShop } = require( '../utils/woocommerce-shop' );
const { TestUtils } = require( '../utils/test-utils' );

test.describe( 'Debugging Utilities', () => {
	test( 'environment inspection', async ( { page } ) => {
		// This test helps debug the testing environment
		console.log( '🔍 Environment Inspection' );
		console.log( '========================' );

		const baseURL = page.context()._options.baseURL;
		console.log( `Base URL: ${ baseURL }` );

		// Check WordPress status
		await page.goto( '/' );
		const title = await page.title();
		console.log( `Page Title: ${ title }` );

		// Check for WordPress
		const isWordPress =
			( await page
				.locator( 'meta[name="generator"][content*="WordPress"]' )
				.isVisible() ) ||
			( await page.locator( 'body[class*="wp-"]' ).isVisible() );
		console.log( `WordPress Detected: ${ isWordPress }` );

		// Check for WooCommerce
		const isWooCommerce =
			( await page.locator( 'body.woocommerce' ).isVisible() ) ||
			( await page.locator( '.woocommerce' ).first().isVisible() );
		console.log( `WooCommerce Detected: ${ isWooCommerce }` );

		// Check Lando environment
		const isLando = process.env.LANDO === 'ON';
		console.log( `Lando Environment: ${ isLando }` );

		// Network conditions
		// eslint-disable-next-line no-undef
		const userAgent = await page.evaluate( () => navigator.userAgent );
		console.log( `User Agent: ${ userAgent }` );

		const viewport = await page.viewportSize();
		console.log( `Viewport: ${ viewport.width }x${ viewport.height }` );

		console.log( '✅ Environment inspection complete' );
	} );

	test( 'WordPress health check', async ( { page } ) => {
		console.log( '🏥 WordPress Health Check' );
		console.log( '========================' );

		const testUtils = new TestUtils( page );

		await page.goto( '/' );
		await testUtils.waitForWordPress();

		// Check critical WordPress elements
		const healthChecks = [
			{
				name: 'Homepage loads',
				check: () => page.locator( 'body' ).isVisible(),
			},
			{
				name: 'WordPress meta tag',
				check: () =>
					page
						.locator(
							'meta[name="generator"][content*="WordPress"]'
						)
						.isVisible(),
			},
			{
				name: 'WordPress body class',
				check: () => page.locator( 'body[class*="wp-"]' ).isVisible(),
			},
			{
				name: 'Admin login accessible',
				check: async () => {
					await page.goto( '/wp-login.php' );
					return page.locator( '#loginform' ).isVisible();
				},
			},
			{
				name: 'REST API endpoint',
				check: async () => {
					const response = await page.request.get( '/wp-json/' );
					return response.status() === 200;
				},
			},
			{
				name: 'RSS feed accessible',
				check: async () => {
					const response = await page.request.get( '/feed/' );
					return response.status() === 200;
				},
			},
		];

		for ( const healthCheck of healthChecks ) {
			try {
				const result = await healthCheck.check();
				console.log(
					`${ result ? '✅' : '❌' } ${ healthCheck.name }`
				);
			} catch ( error ) {
				console.log(
					`❌ ${ healthCheck.name } - Error: ${ error.message }`
				);
			}
		}

		console.log( '✅ WordPress health check complete' );
	} );

	test( 'WooCommerce health check', async ( { page } ) => {
		console.log( '🛒 WooCommerce Health Check' );
		console.log( '===========================' );

		const shop = new WooCommerceShop( page );
		const testUtils = new TestUtils( page );

		const wcHealthChecks = [
			{
				name: 'Shop page accessible',
				check: async () => {
					await shop.goToShop();
					return testUtils.elementExists( '.woocommerce' );
				},
			},
			{
				name: 'Cart page accessible',
				check: async () => {
					await page.goto( '/cart' );
					return (
						testUtils.elementExists( '.woocommerce-cart-form' ) ||
						testUtils.elementExists( '.cart-empty' )
					);
				},
			},
			{
				name: 'Checkout page accessible',
				check: async () => {
					await page.goto( '/checkout' );
					return (
						testUtils.elementExists( '.woocommerce-checkout' ) ||
						page.url().includes( 'checkout' )
					);
				},
			},
			{
				name: 'My Account page accessible',
				check: async () => {
					await page.goto( '/my-account' );
					return (
						testUtils.elementExists( '.woocommerce-form-login' ) ||
						testUtils.elementExists(
							'.woocommerce-MyAccount-navigation'
						)
					);
				},
			},
			{
				name: 'WooCommerce REST API',
				check: async () => {
					const response =
						await page.request.get( '/wp-json/wc/v3/' );
					return response.status() === 401; // 401 is expected without auth
				},
			},
		];

		for ( const healthCheck of wcHealthChecks ) {
			try {
				const result = await healthCheck.check();
				console.log(
					`${ result ? '✅' : '❌' } ${ healthCheck.name }`
				);
			} catch ( error ) {
				console.log(
					`❌ ${ healthCheck.name } - Error: ${ error.message }`
				);
			}
		}

		console.log( '✅ WooCommerce health check complete' );
	} );

	test( 'performance baseline measurement', async ( { page } ) => {
		console.log( '📊 Performance Baseline Measurement' );
		console.log( '===================================' );

		// Measure homepage performance
		const startTime = Date.now();
		await page.goto( '/' );
		await page.waitForLoadState( 'networkidle' );
		const loadTime = Date.now() - startTime;

		console.log( `Homepage Load Time: ${ loadTime }ms` );

		// Measure Core Web Vitals if available
		try {
			const metrics = await page.evaluate( () => {
				return new Promise( ( resolve ) => {
					if ( typeof PerformanceObserver !== 'undefined' ) {
						const observer = new PerformanceObserver( ( list ) => {
							const entries = list.getEntries();
							resolve(
								entries.map( ( entry ) => ( {
									name: entry.name,
									value: entry.value || entry.duration,
									entryType: entry.entryType,
								} ) )
							);
						} );
						observer.observe( {
							entryTypes: [
								'navigation',
								'paint',
								'largest-contentful-paint',
							],
						} );

						setTimeout( () => resolve( [] ), 5000 ); // Timeout after 5 seconds
					} else {
						resolve( [] );
					}
				} );
			} );

			console.log(
				'Performance Metrics:',
				JSON.stringify( metrics, null, 2 )
			);
		} catch ( error ) {
			console.log( 'Performance metrics unavailable:', error.message );
		}

		// Resource loading analysis
		const resources = await page.evaluate( () => {
			const entries = performance.getEntriesByType( 'resource' );
			return entries
				.map( ( entry ) => ( {
					name: entry.name.split( '/' ).pop(),
					type: entry.initiatorType,
					size: entry.transferSize,
					duration: entry.duration,
				} ) )
				.slice( 0, 10 ); // Top 10 resources
		} );

		console.log( 'Top Resources:', JSON.stringify( resources, null, 2 ) );

		console.log( '✅ Performance baseline measurement complete' );
	} );

	test( 'console error monitoring', async ( { page } ) => {
		console.log( '🐛 Console Error Monitoring' );
		console.log( '===========================' );

		const consoleMessages = [];
		const jsErrors = [];
		const networkErrors = [];

		// Listen for console messages
		page.on( 'console', ( message ) => {
			consoleMessages.push( {
				type: message.type(),
				text: message.text(),
				location: message.location(),
			} );
		} );

		// Listen for JavaScript errors
		page.on( 'pageerror', ( error ) => {
			jsErrors.push( {
				message: error.message,
				stack: error.stack,
			} );
		} );

		// Listen for network failures
		page.on( 'response', ( response ) => {
			if ( response.status() >= 400 ) {
				networkErrors.push( {
					url: response.url(),
					status: response.status(),
					statusText: response.statusText(),
				} );
			}
		} );

		// Navigate through key pages
		const testPages = [
			'/',
			'/wp-login.php',
			'/wp-admin/',
			'/shop',
			'/cart',
		];

		for ( const testPage of testPages ) {
			try {
				console.log( `Testing page: ${ testPage }` );
				await page.goto( testPage );
				await page.waitForLoadState( 'networkidle' );
				await page.waitForTimeout( 2000 ); // Wait for any delayed scripts
			} catch ( error ) {
				console.log(
					`Error navigating to ${ testPage }: ${ error.message }`
				);
			}
		}

		// Report findings
		console.log( `Console Messages: ${ consoleMessages.length }` );
		if ( consoleMessages.length > 0 ) {
			console.log(
				'Recent Console Messages:',
				JSON.stringify( consoleMessages.slice( -5 ), null, 2 )
			);
		}

		console.log( `JavaScript Errors: ${ jsErrors.length }` );
		if ( jsErrors.length > 0 ) {
			console.log(
				'JavaScript Errors:',
				JSON.stringify( jsErrors, null, 2 )
			);
		}

		console.log( `Network Errors: ${ networkErrors.length }` );
		if ( networkErrors.length > 0 ) {
			console.log(
				'Network Errors:',
				JSON.stringify( networkErrors, null, 2 )
			);
		}

		console.log( '✅ Console error monitoring complete' );
	} );

	test( 'trace generation for debugging', async ( { page } ) => {
		console.log( '📹 Trace Generation for Debugging' );
		console.log( '=================================' );

		// Start tracing
		await page.context().tracing.start( {
			screenshots: true,
			snapshots: true,
			sources: true,
		} );

		try {
			// Simulate user journey for trace
			await page.goto( '/' );
			await page.waitForLoadState( 'networkidle' );

			// Try to interact with common elements
			const searchForm = page.locator( 'input[name="s"]' ).first();
			if ( await searchForm.isVisible() ) {
				await searchForm.fill( 'test search' );
			}

			// Visit admin login
			await page.goto( '/wp-login.php' );
			await page.waitForSelector( '#loginform' );

			// Visit shop if available
			await page.goto( '/shop' );
			await page.waitForLoadState( 'networkidle' );
		} catch ( error ) {
			console.log( `Error during trace generation: ${ error.message }` );
		} finally {
			// Stop tracing and save
			await page.context().tracing.stop( {
				path: 'test-results/debugging-trace.zip',
			} );

			console.log( '✅ Trace saved to test-results/debugging-trace.zip' );
			console.log(
				'   View with: npx playwright show-trace test-results/debugging-trace.zip'
			);
		}
	} );
} );

// Helper test for creating test data
test.describe( 'Test Data Generation', () => {
	test( 'generate test data samples', async ( { page } ) => {
		console.log( '🎲 Test Data Generation' );
		console.log( '=======================' );

		const testUtils = new TestUtils( page );

		// Generate multiple sets of test data
		for ( let i = 0; i < 3; i++ ) {
			const testData = testUtils.generateTestData();
			console.log(
				`Test Data Set ${ i + 1 }:`,
				JSON.stringify( testData, null, 2 )
			);
		}

		console.log( '✅ Test data generation complete' );
	} );
} );
