#!/bin/bash

# WordPress QuickStart - wp core install using WP-CLI
# This script uses wp-cli to install WordPress core for Composer-managed installations

set -euo pipefail

WP_PATH="wp"
SITE_URL="https://wordpress-quickstart.lndo.site"
SITE_TITLE="WordPress Quickstart"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin"
ADMIN_EMAIL="admin@example.com"

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

# Run WordPress core install
wp core install \
    --url="$SITE_URL" \
    --title="$SITE_TITLE" \
    --admin_user="$ADMIN_USER" \
    --admin_password="$ADMIN_PASSWORD" \
    --admin_email="$ADMIN_EMAIL" \
    --skip-email

echo "WordPress core installed successfully using wp-cli."
