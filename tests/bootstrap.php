<?php
/**
 * PHPUnit bootstrap file for WordPress Quickstart
 *
 * @package WordPressEcommerceStarter
 */

// Set the timezone to avoid warnings in test environment
// phpcs:ignore WordPress.DateTime.RestrictedFunctions.timezone_change_date_default_timezone_set
date_default_timezone_set( 'UTC' );

// Define testing environment (constant defined in phpunit.xml)

// Load Composer autoloader
if ( file_exists( __DIR__ . '/../vendor/autoload.php' ) ) {
	require_once __DIR__ . '/../vendor/autoload.php';
}

// Set up Brain Monkey for WordPress function mocking
if ( class_exists( 'Brain\Monkey' ) ) {
	Brain\Monkey\setUp();

	// Set up common WordPress constants and functions
	if ( ! defined( 'ABSPATH' ) ) {
		define( 'ABSPATH', __DIR__ . '/../' );
	}

	if ( ! defined( 'WP_CONTENT_DIR' ) ) {
		define( 'WP_CONTENT_DIR', dirname( ABSPATH ) . '/custom' );
	}

	if ( ! defined( 'WP_PLUGIN_DIR' ) ) {
		define( 'WP_PLUGIN_DIR', WP_CONTENT_DIR . '/plugins' );
	}

	if ( ! defined( 'WP_DEBUG' ) ) {
		define( 'WP_DEBUG', true );
	}

	// Mock common WordPress functions
	Brain\Monkey\Functions\when( '__' )->returnArg( 1 );
	Brain\Monkey\Functions\when( '_e' )->returnArg( 1 );
	Brain\Monkey\Functions\when( '_x' )->returnArg( 1 );
	Brain\Monkey\Functions\when( '_n' )->returnArg( 1 );
	Brain\Monkey\Functions\when( 'esc_html' )->returnArg( 1 );
	Brain\Monkey\Functions\when( 'esc_attr' )->returnArg( 1 );
	Brain\Monkey\Functions\when( 'esc_url' )->returnArg( 1 );
	Brain\Monkey\Functions\when( 'wp_kses_post' )->returnArg( 1 );
	Brain\Monkey\Functions\when( 'sanitize_text_field' )->returnArg( 1 );
}

// Set up global teardown for Brain Monkey
register_shutdown_function( function () {
	if ( class_exists( 'Brain\Monkey' ) ) {
		Brain\Monkey\tearDown();
	}
} );
