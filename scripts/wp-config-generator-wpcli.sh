#!/bin/bash

# WordPress QuickStart - wp-config.php Generator using WP-CLI
# This script uses wp-cli to generate the wp-config.php file for Composer-managed WordPress installations

set -euo pipefail

WP_PATH="wp"
DB_NAME="wordpress"
DB_USER="wordpress"
DB_PASSWORD="wordpress"
DB_HOST="database"
DB_CHARSET="utf8mb4"
DB_COLLATE=""

# Check if wp-cli is available
if ! command -v wp &> /dev/null; then
    echo "wp-cli not found. Please install wp-cli or run inside Lando."
    exit 1
fi

# Check if WordPress directory exists
if [[ ! -d "$WP_PATH" ]]; then
    echo "WordPress directory '$WP_PATH' not found. Run 'composer install' first."
    exit 1
fi

cd "$WP_PATH"

# Generate wp-config.php using wp-cli
wp config create \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASSWORD" \
    --dbhost="$DB_HOST" \
    --dbcharset="$DB_CHARSET" \
    --dbcollate="$DB_COLLATE" \
    --skip-check \
    --force

echo "wp-config.php generated successfully using wp-cli."
