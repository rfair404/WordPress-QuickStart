<?php
/**
 * Sample test to verify PHPUnit setup
 *
 * @package WordPressQuickstart\Tests
 */

namespace WordPressQuickstart\Tests\Unit;

use PHPUnit\Framework\TestCase;
use Brain\Monkey;

/**
 * Sample test class
 */
class SampleTest extends TestCase {

	/**
	 * Set up test environment before each test
	 */
	protected function setUp(): void {
		parent::setUp();
		Monkey\setUp();
	}

	/**
	 * Clean up test environment after each test
	 */
	protected function tearDown(): void {
		Monkey\tearDown();
		parent::tearDown();
	}

	/**
	 * Test that PHPUnit is working correctly
	 */
	public function test_phpunit_setup() {
		$this->assertTrue( true );
		$this->assertEquals( 1, 1 );
		$this->assertNotEmpty( 'Hello World' );
	}

	/**
	 * Test WordPress function mocking with Brain Monkey
	 */
	public function test_wordpress_function_mocking() {
		// Mock a WordPress function
		Monkey\Functions\when( 'get_option' )
			->justReturn( 'mocked_value' );

		// Test the mocked function
		$result = get_option( 'some_option' );
		$this->assertEquals( 'mocked_value', $result );
	}

	/**
	 * Test that environment constants are defined
	 */
	public function test_environment_constants() {
		// Test basic PHP constants that should always be available
		$this->assertTrue( defined( 'PHP_VERSION' ) );
		$this->assertTrue( defined( 'PHP_EOL' ) );

		// Test that we can define and use custom constants for our tests
		if ( ! defined( 'WQS_TEST_ENVIRONMENT' ) ) {
			define( 'WQS_TEST_ENVIRONMENT', true );
		}
		$this->assertTrue( defined( 'WQS_TEST_ENVIRONMENT' ) );
		$this->assertTrue( WQS_TEST_ENVIRONMENT );
	}

	/**
	 * Test basic PHP functionality
	 */
	public function test_php_version() {
		$this->assertTrue( version_compare( PHP_VERSION, '8.1.0', '>=' ) );
	}

	/**
	 * Test array operations
	 */
	public function test_array_operations() {
		$test_array = [ 'a', 'b', 'c' ];

		$this->assertCount( 3, $test_array );
		$this->assertContains( 'b', $test_array );
		$this->assertEquals( 'a', $test_array[0] );
	}

	/**
	 * Test string operations
	 */
	public function test_string_operations() {
		$test_string = 'WordPress Quickstart';

		$this->assertStringContainsString( 'WordPress', $test_string );
		$this->assertStringStartsWith( 'WordPress', $test_string );
		$this->assertStringEndsWith( 'Starter', $test_string );
	}
}
