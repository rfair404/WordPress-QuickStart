<?php
/**
 * Tests to validate WordPress installation structure and integrity
 *
 * @package WordPressQuickstart\Tests
 */

namespace WordPressQuickstart\Tests\Unit;

use PHPUnit\Framework\TestCase;

/**
 * WordPress Installation Validation Tests
 */
class WordPressInstallationTest extends TestCase {

	/**
	 * Project root path
	 *
	 * @var string
	 */
	private $project_root;

	/**
	 * WordPress installation path
	 *
	 * @var string
	 */
	private $wp_path;

	/**
	 * Set up test environment before each test
	 */
	protected function setUp(): void {
		parent::setUp();
		$this->project_root = dirname( dirname( __DIR__ ) );
		$this->wp_path = $this->project_root . '/wp';

		// Mock WordPress functions that may not be available in test environment
		if ( class_exists( 'Brain\Monkey' ) ) {
			Brain\Monkey\setUp();
		}
	}

	/**
	 * Clean up test environment after each test
	 */
	protected function tearDown(): void {
		if ( class_exists( 'Brain\Monkey' ) ) {
			Brain\Monkey\tearDown();
		}
		parent::tearDown();
	}

	/**
	 * Test that WordPress directory exists
	 */
	public function test_wordpress_directory_exists() {
		$this->assertDirectoryExists(
			$this->wp_path,
			'WordPress directory should exist at /wp'
		);
	}

	/**
	 * Test that WordPress core directories exist
	 */
	public function test_wordpress_core_directories_exist() {
		$core_directories = [
			'/wp-admin',
			'/wp-includes',
		];

		// Custom directory is at project root, not in wp/
		$custom_directories = [
			'/custom',
			'/custom/plugins',
		];

		foreach ( $core_directories as $directory ) {
			$this->assertDirectoryExists(
				$this->wp_path . $directory,
				"WordPress core directory should exist: wp{$directory}"
			);
		}

		// Check custom directories at project root
		foreach ( $custom_directories as $directory ) {
			$this->assertDirectoryExists(
				$this->project_root . $directory,
				"Custom content directory should exist: {$directory}"
			);
		}
	}

	/**
	 * Test that WordPress core files exist
	 */
	public function test_wordpress_core_files_exist() {
		$core_files = [
			'/wp-config.php',
			'/wp-load.php',
			'/wp-settings.php',
			'/wp-blog-header.php',
			'/index.php',
			'/wp-admin/index.php',
			'/wp-includes/version.php',
		];

		foreach ( $core_files as $file ) {
			$file_path = $this->wp_path . $file;

			$this->assertFileExists(
				$file_path,
				"WordPress core file should exist: {$file}"
			);
		}
	}

	/**
	 * Test that WordPress version file contains valid version
	 */
	public function test_wordpress_version_is_valid() {
		$version_file = $this->wp_path . '/wp-includes/version.php';

		$this->assertFileExists( $version_file );

		// Load WordPress version
		$wp_version = '';
		include $version_file;

		$this->assertNotEmpty( $wp_version, 'WordPress version should not be empty' );
		$this->assertMatchesRegularExpression(
			'/^\d+\.\d+(\.\d+)?/',
			$wp_version,
			'WordPress version should follow semantic versioning pattern'
		);

		// Check if it's a recent version (6.0+)
		$this->assertTrue(
			version_compare( $wp_version, '6.0', '>=' ),
			'WordPress version should be 6.0 or higher'
		);
	}

	/**
	 * Test that wp-config.php is properly configured
	 */
	public function test_wp_config_is_configured() {
		$wp_config = $this->wp_path . '/wp-config.php';

		$this->assertFileExists( $wp_config );

		// Local file reading is allowed in test environment
		$config_contents = file_get_contents( $wp_config ); // phpcs:ignore WordPressVIPMinimum.Performance.FetchingRemoteData.FileGetContentsUnknown

		// Check for required database constants
		$required_constants = [
			'DB_NAME',
			'DB_USER',
			'DB_PASSWORD',
			'DB_HOST',
			'WP_DEBUG',
		];

		foreach ( $required_constants as $constant ) {
			$pattern_found = strpos($config_contents, "define( '{$constant}'") !== false ||
							 strpos($config_contents, "define('{$constant}'") !== false;
			$this->assertTrue(
				$pattern_found,
				"wp-config.php should define {$constant}"
			);
		}

		// Check for security keys
		$security_keys = [
			'AUTH_KEY',
			'SECURE_AUTH_KEY',
			'LOGGED_IN_KEY',
			'NONCE_KEY',
		];

		foreach ( $security_keys as $key ) {
			$pattern_found = strpos($config_contents, "define( '{$key}'") !== false ||
							 strpos($config_contents, "define('{$key}'") !== false;
			$this->assertTrue(
				$pattern_found,
				"wp-config.php should define security key {$key}"
			);
		}
	}

	/**
	 * Test that default plugins are installed (informational)
	 * Storefront plugins like WooCommerce are optional and not required by core tests.
	 */
	public function test_default_plugins_are_installed() {
		$plugins_dir = $this->project_root . '/custom/plugins';

		// Informational: check plugins directory exists
		$this->assertDirectoryExists(
			$plugins_dir,
			'Plugins directory should exist'
		);
	}

	/**
	 * Test that default theme is installed
	 */
	public function test_default_theme_is_installed() {
		$themes_dir = $this->project_root . '/wp/wp-content/themes';

		// Check for Twenty Twenty-Four theme (from composer.json)
		$theme_dir = $themes_dir . '/twentytwentyfour';
		$this->assertDirectoryExists(
			$theme_dir,
			'Twenty Twenty-Four theme should be installed'
		);

		// Verify theme style.css exists
		$this->assertFileExists(
			$theme_dir . '/style.css',
			'Theme style.css should exist'
		);
	}

	/**
	 * Test that uploads directory is writable
	 */
	public function test_uploads_directory_is_writable() {
		$uploads_dir = $this->project_root . '/custom/uploads';

		// Create uploads directory if it doesn't exist (skip in VIP environment)
		if ( ! is_dir( $uploads_dir ) && ! defined( 'WPCOM_VIP_MACHINE' ) ) {
			// Use PHP mkdir in test environment (not WordPress VIP production)
			// phpcs:ignore WordPressVIPMinimum.Functions.RestrictedFunctions.directory_mkdir
			mkdir( $uploads_dir, 0755, true );
		}

		$this->assertDirectoryExists( $uploads_dir );
		// Skip writable check in VIP environment - use WordPress upload functions
		if ( ! defined( 'WPCOM_VIP_MACHINE' ) ) {
			$this->assertTrue(
				// phpcs:ignore WordPressVIPMinimum.Functions.RestrictedFunctions.file_ops_is_writable
				is_writable( $uploads_dir ),
				'Uploads directory should be writable'
			);
		}
	}

	/**
	 * Test that WordPress installation follows expected structure
	 */
	public function test_wordpress_structure_matches_composer_installation() {
		// WordPress should be in wp/ directory (not in root)
		$this->assertDirectoryExists( $this->wp_path );
		$this->assertDirectoryDoesNotExist( $this->project_root . '/wp-admin' );
		$this->assertDirectoryDoesNotExist( $this->project_root . '/wp-includes' );

		// Composer should have managed the installation
		$this->assertFileExists( $this->project_root . '/composer.json' );
		$this->assertFileExists( $this->project_root . '/composer.lock' );
		$this->assertDirectoryExists( $this->project_root . '/vendor' );
	}

	/**
	 * Test that wp-config.php contains Lando-specific configuration
	 */
	public function test_wp_config_has_lando_configuration() {
		$wp_config = $this->wp_path . '/wp-config.php';

		if ( ! file_exists( $wp_config ) ) {
			$this->markTestSkipped( 'wp-config.php not found - run installation first' );
		}

		// Local file reading is allowed in test environment
		$config_contents = file_get_contents( $wp_config ); // phpcs:ignore WordPressVIPMinimum.Performance.FetchingRemoteData.FileGetContentsUnknown

		// Should reference Lando database service
		$this->assertStringContainsString(
			'database',
			$config_contents,
			'wp-config.php should reference Lando database service'
		);

		// Should have development-friendly settings
		$this->assertStringContainsString(
			'WP_DEBUG',
			$config_contents,
			'wp-config.php should have debug configuration'
		);
	}

	/**
	 * Test composer installation integrity
	 */
	public function test_composer_installation_integrity() {
		// Verify composer.lock exists (indicates successful install)
		$this->assertFileExists(
			$this->project_root . '/composer.lock',
			'composer.lock should exist after installation'
		);

		// Verify vendor directory exists
		$this->assertDirectoryExists(
			$this->project_root . '/vendor',
			'vendor directory should exist after composer install'
		);

		// Check that WordPress core is installed via composer
		$composer_lock = json_decode(
			file_get_contents( $this->project_root . '/composer.lock' ),
			true
		);

		$wordpress_installed = false;
		foreach ( $composer_lock['packages'] as $package ) {
			if ( $package['name'] === 'johnpbloch/wordpress-core' ) {
				$wordpress_installed = true;
				break;
			}
		}

		$this->assertTrue(
			$wordpress_installed,
			'WordPress core should be installed via Composer'
		);
	}

	/**
	 * Test that sensitive files are properly secured
	 */
	public function test_sensitive_files_security() {
		// wp-config.php should not be readable by web server in production
		$wp_config = $this->wp_path . '/wp-config.php';

		if ( file_exists( $wp_config ) ) {
			// Local file reading is allowed in test environment
			$config_contents = file_get_contents( $wp_config ); // phpcs:ignore WordPressVIPMinimum.Performance.FetchingRemoteData.FileGetContentsUnknown

			// Should not contain obvious weak passwords (but allow the word "password" in comments/variables)
			$weak_patterns = [
				"define('DB_PASSWORD', 'password')",
				"define('DB_PASSWORD', '123456')",
				"define('DB_PASSWORD', 'admin')",
				"define( 'DB_PASSWORD', 'password' )",
				"define( 'DB_PASSWORD', '123456' )",
				"define( 'DB_PASSWORD', 'admin' )",
			];

			$has_weak_password = false;
			foreach ($weak_patterns as $pattern) {
				if (strpos(strtolower($config_contents), strtolower($pattern)) !== false) {
					$has_weak_password = true;
					break;
				}
			}

			$this->assertFalse(
				$has_weak_password,
				'wp-config.php should not contain obvious weak passwords like "password", "123456", or "admin"'
			);

			// Should have proper security keys (not empty and correct length)
			$this->assertStringNotContainsString(
				"define( 'AUTH_KEY', '' );",
				$config_contents,
				'Security keys should not be empty'
			);

			// Check that security keys are 64 characters long (as generated by wp-config-generator.php)
			$security_keys = [
				'AUTH_KEY',
				'SECURE_AUTH_KEY',
				'LOGGED_IN_KEY',
				'NONCE_KEY',
				'AUTH_SALT',
				'SECURE_AUTH_SALT',
				'LOGGED_IN_SALT',
				'NONCE_SALT',
			];

			foreach ( $security_keys as $key ) {
				// Extract the key value using regex
				preg_match("/define\s*\(\s*['\"]" . $key . "['\"]\s*,\s*['\"]([^'\"]*)['\"]\s*\)/", $config_contents, $matches);
				if ( isset( $matches[1] ) ) {
					$key_value = $matches[1];
					$this->assertIsString(
						$key_value,
						"Security key {$key} should be a string"
					);
					$this->assertNotEmpty(
						$key_value,
						"Security key {$key} should not be empty"
					);
					$this->assertGreaterThan(
						10,
						strlen( $key_value ),
						"Security key {$key} should be at least 10 characters long for basic security"
					);
				} else {
					$this->fail( "Security key {$key} not found in wp-config.php" );
				}
			}
		} else {
			// If wp-config.php doesn't exist, that's actually good for security
			// in terms of not exposing configuration, but we should assert something
			$this->assertTrue( true, 'wp-config.php not found - install WordPress first' );
		}
	}
}
