<?php
/**
 * WordPress Configuration Generator
 * Generates wp-config.php for Composer-managed WordPress installation
 */

// Configuration settings
$wpPath = __DIR__ . '/../wp';
$configPath = $wpPath . '/wp-config.php';
$sampleConfigPath = $wpPath . '/wp-config-sample.php';
$customContentPath = dirname($wpPath) . '/custom';

// Check if WordPress is installed
if (!is_dir($wpPath)) {
    echo "❌ WordPress not found. Run 'composer install' first.\n";
    exit(1);
}

// Check if wp-config.php already exists
if (file_exists($configPath)) {
    echo "ℹ️  wp-config.php already exists. Skipping generation.\n";
    echo "   Delete $configPath to regenerate.\n";
    exit(0);
}

// Check if sample config exists
if (!file_exists($sampleConfigPath)) {
    echo "❌ wp-config-sample.php not found in WordPress installation.\n";
    exit(1);
}

// Read the sample config
$config = file_get_contents($sampleConfigPath);

// Database configuration for Lando
$dbConfig = [
    'DB_NAME' => 'wordpress',
    'DB_USER' => 'wordpress',
    'DB_PASSWORD' => 'wordpress',
    'DB_HOST' => 'database',
    'DB_CHARSET' => 'utf8mb4',
    'DB_COLLATE' => '',
];

// Security keys (generate random ones)
$securityKeys = [
    'AUTH_KEY',
    'SECURE_AUTH_KEY',
    'LOGGED_IN_KEY',
    'NONCE_KEY',
    'AUTH_SALT',
    'SECURE_AUTH_SALT',
    'LOGGED_IN_SALT',
    'NONCE_SALT',
];

// Replace database configuration
foreach ($dbConfig as $key => $value) {
    $config = preg_replace(
        "/define\s*\(\s*['\"]" . $key . "['\"]\s*,\s*['\"][^'\"]*['\"]\s*\)/",
        "define('$key', '$value')",
        $config
    );
}

// Generate and replace security keys
foreach ($securityKeys as $key) {
    $randomKey = generateRandomKey();
    $config = preg_replace(
        "/define\s*\(\s*['\"]" . $key . "['\"]\s*,\s*['\"][^'\"]*['\"]\s*\)/",
        "define('$key', '$randomKey')",
        $config
    );
}

// Replace table prefix
$config = preg_replace(
    '/\$table_prefix\s*=\s*[\'"][^\'"]*[\'"]/',
    '$table_prefix = \'wp_\'',
    $config
);

// Add custom configuration
$customConfig = "
/* Custom Configuration for WordPress Quickstart */

// WordPress URLs (will be set by Lando)
if (!defined('WP_HOME')) {
    define('WP_HOME', 'https://' . \$_SERVER['HTTP_HOST']);
}
if (!defined('WP_SITEURL')) {
    define('WP_SITEURL', WP_HOME);
}

// Content directory configuration (custom directory at project root)
define('WP_CONTENT_DIR', dirname(__DIR__) . '/custom');
define('WP_CONTENT_URL', WP_HOME . '/custom');

// Development settings
if (!defined('WP_DEBUG')) {
    define('WP_DEBUG', true);
}
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);
define('SCRIPT_DEBUG', true);

// Security enhancements
define('DISALLOW_FILE_EDIT', true);
define('DISALLOW_FILE_MODS', false); // Allow plugin/theme installation
define('AUTOMATIC_UPDATER_DISABLED', true); // Manage updates via Composer

// Performance optimizations
define('WP_CACHE', true);
define('COMPRESS_CSS', true);
define('COMPRESS_SCRIPTS', true);
define('CONCATENATE_SCRIPTS', false);
define('ENFORCE_GZIP', true);

// Custom paths
define('WP_PLUGIN_DIR', WP_CONTENT_DIR . '/plugins');
define('WP_PLUGIN_URL', WP_CONTENT_URL . '/plugins');

// Memory limits
ini_set('memory_limit', '256M');

";

// Insert custom configuration before the "That's all" comment
$config = str_replace(
    "/* That's all, stop editing! Happy publishing. */",
    $customConfig . "\n/* That's all, stop editing! Happy publishing. */",
    $config
);

// Create custom content directory structure
if (!is_dir($customContentPath)) {
    mkdir($customContentPath, 0755, true);
    mkdir($customContentPath . '/plugins', 0755, true);
    mkdir($customContentPath . '/themes', 0755, true);
    mkdir($customContentPath . '/uploads', 0755, true);
    mkdir($customContentPath . '/mu-plugins', 0755, true);

    echo "📁 Created custom content directory structure\n";
}

// Write the configuration file
if (file_put_contents($configPath, $config)) {
    echo "✅ Generated wp-config.php successfully!\n";
    echo "📍 WordPress installed in: $wpPath\n";
    echo "📁 Content directory: $customContentPath\n";
    echo "⚙️  Configuration: $configPath\n";
    echo "\n";
    echo "🚀 Next steps:\n";
    echo "   1. Run 'lando start' to start your development environment\n";
    echo "   2. Visit your site to complete WordPress installation\n";
    echo "   3. Install WooCommerce: composer require wpackagist-plugin/woocommerce\n";
} else {
    echo "❌ Failed to write wp-config.php\n";
    exit(1);
}

/**
 * Generate a random key for WordPress security
 */
function generateRandomKey($length = 64) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_+-=[]{}|;:,.<>?';
    $key = '';
    $max = strlen($characters) - 1;

    for ($i = 0; $i < $length; $i++) {
        $key .= $characters[random_int(0, $max)];
    }

    return $key;
}
