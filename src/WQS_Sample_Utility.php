<?php
/**
 * Sample utility class for testing WordPress VIP coding standards
 *
 * @package WordPressQuickstart
 * @since   1.0.0
 */

namespace WordPressQuickstart;

/**
 * Sample utility class demonstrating WordPress VIP coding standards
 *
 * This class serves as an example of proper WordPress VIP coding standards
 * and provides basic utility functions for the e-commerce starter.
 *
 * @since 1.0.0
 */
class WQS_Sample_Utility {

	/**
	 * Plugin version
	 *
	 * @since 1.0.0
	 * @var string
	 */
	const VERSION = '1.0.0';

	/**
	 * Text domain for internationalization
	 *
	 * @since 1.0.0
	 * @var string
	 */
	const TEXT_DOMAIN = 'wordpress-quickstart';

	/**
	 * Sample data array
	 *
	 * @since 1.0.0
	 * @var array
	 */
	private $sample_data = [];

	/**
	 * Initialize the utility class
	 *
	 * @since 1.0.0
	 */
	public function __construct() {
		$this->sample_data = [
			'name'    => __( 'WordPress E-commerce Starter', self::TEXT_DOMAIN ),
			'version' => self::VERSION,
			'type'    => 'utility',
		];
	}

	/**
	 * Get sample data
	 *
	 * @since 1.0.0
	 * @return array Sample data array
	 */
	public function get_sample_data(): array {
		return $this->sample_data;
	}

	/**
	 * Set a sample data value
	 *
	 * @since 1.0.0
	 * @param string $key   The data key.
	 * @param mixed  $value The data value.
	 * @return bool True on success, false on failure.
	 */
	public function set_sample_data( string $key, $value ): bool {
		if ( empty( $key ) ) {
			return false;
		}

		$this->sample_data[ sanitize_text_field( $key ) ] = $value;
		return true;
	}

	/**
	 * Sanitize and validate email address
	 *
	 * @since 1.0.0
	 * @param string $email Email address to validate.
	 * @return string|false Sanitized email address or false if invalid.
	 */
	public function sanitize_email( string $email ) {
		$sanitized_email = sanitize_email( $email );

		if ( ! is_email( $sanitized_email ) ) {
			return false;
		}

		return $sanitized_email;
	}

	/**
	 * Format price with currency symbol
	 *
	 * @since 1.0.0
	 * @param float  $price    Price amount.
	 * @param string $currency Currency code (default: USD).
	 * @return string Formatted price string.
	 */
	public function format_price( float $price, string $currency = 'USD' ): string {
		$currency_symbols = [
			'USD' => '$',
			'EUR' => '€',
			'GBP' => '£',
			'JPY' => '¥',
		];

		$symbol = $currency_symbols[ $currency ] ?? '$';

		return $symbol . number_format( $price, 2 );
	}

	/**
	 * Check if user has required capability
	 *
	 * @since 1.0.0
	 * @param string $capability Required capability.
	 * @return bool True if user has capability, false otherwise.
	 */
	public function user_can_access( string $capability = 'manage_options' ): bool {
		return current_user_can( $capability );
	}

	/**
	 * Get localized date format
	 *
	 * @since 1.0.0
	 * @param string $date_string Date string to format.
	 * @param string $format      Date format (default: WordPress setting).
	 * @return string Formatted date string.
	 */
	public function get_formatted_date( string $date_string, string $format = '' ): string {
		if ( empty( $format ) ) {
			$format = get_option( 'date_format' );
		}

		$timestamp = strtotime( $date_string );

		if ( false === $timestamp ) {
			return '';
		}

		return date_i18n( $format, $timestamp );
	}
}
