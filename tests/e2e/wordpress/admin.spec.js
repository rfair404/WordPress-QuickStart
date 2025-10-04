// WordPress Admin E2E Tests
/* eslint-disable no-console, no-unused-vars */
const { test, expect } = require( '@playwright/test' );
const { WordPressAdmin } = require( '../utils/wordpress-admin' );
const { TestUtils, WordPressAssertions } = require( '../utils/test-utils' );

test.describe( 'WordPress Admin @wordpress', () => {
	let admin;
	let testUtils;
	let wpAssertions;

	test.beforeEach( async ( { page } ) => {
		admin = new WordPressAdmin( page );
		testUtils = new TestUtils( page );
		wpAssertions = new WordPressAssertions( page );
	} );

	test( 'admin login works', async ( { page } ) => {
		await admin.login();

		// Verify we're logged in
		await wpAssertions.assertAdminBarVisible();

		// Check we're in the admin area
		expect( page.url() ).toContain( '/wp-admin' );

		console.log( '✅ Admin login successful' );
	} );

	test( 'admin dashboard loads correctly', async ( { page } ) => {
		await admin.login();
		await admin.navigateToAdminPage( 'index.php' );

		// Check for dashboard widgets
		await expect( page.locator( '#dashboard-widgets' ) ).toBeVisible();

		// Check for admin menu
		await expect( page.locator( '#adminmenu' ) ).toBeVisible();

		// Verify no PHP errors
		await wpAssertions.assertNoPhpErrors();

		console.log( '✅ Admin dashboard loaded correctly' );
	} );

	test( 'can create and publish a post', async ( { page } ) => {
		await admin.login();

		const testData = testUtils.generateTestData();

		await admin.createPost( {
			title: testData.postTitle,
			content: 'This is a test post created by Playwright E2E tests.',
			status: 'publish',
		} );

		// Verify post was created by checking posts list
		await admin.navigateToAdminPage( 'edit.php' );
		await expect(
			page.locator( `text=${ testData.postTitle }` )
		).toBeVisible();

		console.log( '✅ Post created and published successfully' );
	} );

	test( 'can save post as draft', async ( { page } ) => {
		await admin.login();

		const testData = testUtils.generateTestData();

		await admin.createPost( {
			title: `Draft ${ testData.postTitle }`,
			content: 'This is a draft post created by Playwright E2E tests.',
			status: 'draft',
		} );

		// Verify draft was saved
		await admin.navigateToAdminPage( 'edit.php?post_status=draft' );
		await expect(
			page.locator( `text=Draft ${ testData.postTitle }` )
		).toBeVisible();

		console.log( '✅ Draft post saved successfully' );
	} );

	test( 'plugins page loads and shows installed plugins', async ( {
		page,
	} ) => {
		await admin.login();
		await admin.navigateToAdminPage( 'plugins.php' );

		// Check plugins page loaded
		await expect( page.locator( '#wpbody-content' ) ).toBeVisible();
		await expect( page.locator( '.wp-list-table' ) ).toBeVisible();

		// Should have at least Hello Dolly plugin (default WordPress)
		const pluginRows = page.locator( '.wp-list-table tbody tr' );
		const pluginCount = await pluginRows.count();
		expect( pluginCount ).toBeGreaterThan( 0 );

		console.log( '✅ Plugins page loaded with plugins list' );
	} );

	test( 'themes page loads and shows available themes', async ( {
		page,
	} ) => {
		await admin.login();
		await admin.navigateToAdminPage( 'themes.php' );

		// Check themes page loaded
		await expect( page.locator( '.wp-filter' ) ).toBeVisible();

		// Should have at least one theme
		const themes = page.locator( '.theme' );
		const themeCount = await themes.count();
		expect( themeCount ).toBeGreaterThan( 0 );

		console.log( '✅ Themes page loaded with available themes' );
	} );

	test( 'can update general settings', async ( { page } ) => {
		await admin.login();

		const testData = testUtils.generateTestData();
		const originalTitle = `Test Site ${ testData.firstName }`;

		await admin.updateSettings( {
			blogname: originalTitle,
			blogdescription: 'A test WordPress site for E2E testing',
		} );

		// Verify settings were saved
		await admin.navigateToAdminPage( 'options-general.php' );
		const titleField = page.locator( '#blogname' );
		await expect( titleField ).toHaveValue( originalTitle );

		console.log( '✅ General settings updated successfully' );
	} );

	test( 'media library is accessible', async ( { page } ) => {
		await admin.login();
		await admin.navigateToAdminPage( 'upload.php' );

		// Check media library loaded
		await expect( page.locator( '.wp-header-end' ) ).toBeVisible();

		// Should have media upload interface
		await expect( page.locator( '.page-title-action' ) ).toBeVisible();

		console.log( '✅ Media library is accessible' );
	} );

	test( 'user profile can be accessed and updated', async ( { page } ) => {
		await admin.login();
		await admin.navigateToAdminPage( 'profile.php' );

		// Verify profile page loaded
		await expect( page.locator( '#your-profile' ) ).toBeVisible();

		// Update display name
		const testData = testUtils.generateTestData();
		await page.fill(
			'#display_name',
			`${ testData.firstName } ${ testData.lastName }`
		);

		// Save profile
		await page.click( '#submit' );

		// Wait for save confirmation
		await page.waitForSelector( '#message.updated', { timeout: 10000 } );

		console.log( '✅ User profile updated successfully' );
	} );

	test( 'can access WordPress settings pages', async ( { page } ) => {
		await admin.login();

		const settingsPages = [
			{ slug: 'options-general.php', name: 'General' },
			{ slug: 'options-writing.php', name: 'Writing' },
			{ slug: 'options-reading.php', name: 'Reading' },
			{ slug: 'options-discussion.php', name: 'Discussion' },
			{ slug: 'options-media.php', name: 'Media' },
			{ slug: 'options-permalink.php', name: 'Permalinks' },
		];

		for ( const settingsPage of settingsPages ) {
			await admin.navigateToAdminPage( settingsPage.slug );

			// Verify page loaded
			await expect( page.locator( '.wrap' ) ).toBeVisible();

			// Check for form elements (settings pages have forms)
			const hasForm = await testUtils.elementExists( 'form' );
			expect( hasForm ).toBeTruthy();

			console.log( `✅ ${ settingsPage.name } settings page accessible` );
		}
	} );

	test( 'admin notices are displayed properly', async ( { page } ) => {
		await admin.login();

		// Get any admin notices
		const notices = await admin.getAdminNotices();

		// Log notices for visibility
		if ( notices.length > 0 ) {
			console.log( '📢 Admin notices found:', notices );
		}

		// Check that notices are properly formatted
		for ( const notice of notices ) {
			expect( notice.message ).toBeTruthy();
			expect( [ 'error', 'warning', 'success', 'info' ] ).toContain(
				notice.type
			);
		}

		console.log( '✅ Admin notices displayed properly' );
	} );

	test( 'admin logout works', async ( { page } ) => {
		await admin.login();

		// Verify we're logged in first
		await wpAssertions.assertAdminBarVisible();

		await admin.logout();

		// Verify we're logged out
		await expect( page.locator( '#loginform' ) ).toBeVisible();
		expect( page.url() ).toContain( 'wp-login.php' );

		console.log( '✅ Admin logout successful' );
	} );

	test( 'admin area has proper security headers', async ( { page } ) => {
		await admin.login();

		// Check for WordPress nonce in admin area
		const hasNonce = await testUtils.elementExists(
			'input[name*="_wpnonce"], input[name*="_nonce"]'
		);
		expect( hasNonce ).toBeTruthy();

		// Check for proper form actions (should be admin-post.php or admin-ajax.php)
		const forms = await page.locator( 'form[action]' ).all();

		for ( const form of forms ) {
			const action = await form.getAttribute( 'action' );
			if ( action && action.length > 0 ) {
				const isValidAction =
					action.includes( 'admin-post.php' ) ||
					action.includes( 'admin-ajax.php' ) ||
					action.includes( 'wp-admin' ) ||
					action === '#';
				expect( isValidAction ).toBeTruthy();
			}
		}

		console.log( '✅ Admin area has proper security measures' );
	} );

	test( 'block editor (Gutenberg) loads correctly', async ( { page } ) => {
		await admin.login();
		await admin.navigateToAdminPage( 'post-new.php' );

		// Wait for block editor to load
		await page.waitForSelector( '.block-editor-writing-flow', {
			timeout: 15000,
		} );

		// Check for essential block editor elements
		await expect(
			page.locator( '.editor-post-title__input' )
		).toBeVisible();
		await expect(
			page.locator( '.block-editor-default-block-appender' )
		).toBeVisible();

		// Check for block inserter
		await expect(
			page.locator( '.block-editor-inserter__toggle' )
		).toBeVisible();

		console.log( '✅ Block editor loaded correctly' );
	} );
} );

test.describe( 'WordPress Admin Error Handling @wordpress', () => {
	let admin;
	let testUtils;

	test.beforeEach( async ( { page } ) => {
		admin = new WordPressAdmin( page );
		testUtils = new TestUtils( page );
	} );

	test( 'handles invalid login gracefully', async ( { page } ) => {
		await page.goto( '/wp-login.php' );

		// Try invalid login
		await page.fill( '#user_login', 'invaliduser' );
		await page.fill( '#user_pass', 'invalidpassword' );
		await page.click( '#wp-submit' );

		// Should show error message
		await expect( page.locator( '#login_error' ) ).toBeVisible();

		// Should still be on login page
		expect( page.url() ).toContain( 'wp-login.php' );

		console.log( '✅ Invalid login handled gracefully' );
	} );

	test( 'admin area blocks unauthorized access', async ( { page } ) => {
		// Try to access admin without logging in
		const response = await page.goto( '/wp-admin/' );

		// Should redirect to login page
		expect( page.url() ).toContain( 'wp-login.php' );

		console.log( '✅ Unauthorized admin access properly blocked' );
	} );
} );
