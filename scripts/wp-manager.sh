#!/bin/bash

# WordPress Management Script for Composer-based Installation
# This script provides easy commands for managing WordPress via Composer

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WP_DIR="wp"
COMPOSER_FILE="composer.json"

# Helper functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if composer.json exists
check_composer() {
    if [[ ! -f "$COMPOSER_FILE" ]]; then
        log_error "composer.json not found in current directory"
        exit 1
    fi
}

# Show usage information
show_help() {
    echo "WordPress Management Script"
    echo "=========================="
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  install                  Install WordPress and generate config"
    echo "  install:full             Full WordPress installation with sample content (uses Lando WP-CLI)"
    echo "  update                   Update WordPress core to latest version"
    echo "  version                  Show current WordPress version"
    echo "  status                   Show WordPress installation status"
    echo ""
    echo "Plugin Management:"
    echo "  plugin:install <name>    Install a plugin from WordPress.org"
    echo "  plugin:remove <name>     Remove a plugin"
    echo "  plugin:list              List installed plugins"
    echo "  plugin:search <term>     Search for plugins on WordPress.org"
    echo ""
    echo "Theme Management:"
    echo "  theme:install <name>     Install a theme from WordPress.org"
    echo "  theme:remove <name>      Remove a theme"
    echo "  theme:list               List installed themes"
    echo ""
    echo "Utility Commands:"
    echo "  config:generate          Regenerate wp-config.php"
    echo "  cleanup                  Clean up WordPress installation"
    echo "  reset                    Reset WordPress installation (keeps content)"
    echo ""
    echo "Examples:"
    echo "  $0 install                    # Basic Composer installation"
    echo "  $0 install:full               # Full installation with sample content"
    echo "  $0 plugin:install <plugin-slug> # Install a plugin (e.g. contact-form-7)"
    echo "  $0 theme:install twentytwentyfour # Install default theme"
    echo "  $0 update                     # Update WordPress core"
}

# Install WordPress
install_wordpress() {
    log_info "Installing WordPress via Composer..."

    check_composer

    if [[ -d "$WP_DIR" ]]; then
        log_warning "WordPress directory already exists. Use 'update' to update existing installation."
        return 1
    fi

    # Install WordPress and dependencies
    composer install

    # Generate wp-config.php
    php scripts/wp-config-generator.php

    log_success "WordPress installation completed!"
    log_info "WordPress installed in: $WP_DIR/"
    log_info "Next steps:"
    echo "  1. Run 'lando start' to start your development environment"
    echo "  2. Visit your site to complete WordPress setup"
    echo "  3. Install any desired plugins: $0 plugin:install <plugin-slug>"
}

# Update WordPress
update_wordpress() {
    log_info "Updating WordPress to latest version..."

    check_composer

    if [[ ! -d "$WP_DIR" ]]; then
        log_error "WordPress not installed. Run '$0 install' first."
        exit 1
    fi

    composer update johnpbloch/wordpress-core

    log_success "WordPress updated successfully!"
}

# Show WordPress version
show_version() {
    check_composer

    if [[ ! -d "$WP_DIR" ]]; then
        log_error "WordPress not installed."
        exit 1
    fi

    echo "WordPress Version Information:"
    echo "============================="
    composer show johnpbloch/wordpress-core 2>/dev/null | grep -E "(name|versions|source)"

    if [[ -f "$WP_DIR/wp-includes/version.php" ]]; then
        local wp_version=$(grep "wp_version = " "$WP_DIR/wp-includes/version.php" | cut -d"'" -f2)
        echo "Installed version: $wp_version"
    fi
}

# Show installation status
show_status() {
    echo "WordPress Installation Status:"
    echo "=============================="

    if [[ -d "$WP_DIR" ]]; then
        log_success "WordPress directory exists: $WP_DIR/"

        if [[ -f "$WP_DIR/wp-config.php" ]]; then
            log_success "Configuration file exists"
        else
            log_warning "Configuration file missing"
        fi

        if [[ -d "custom" ]]; then
            log_success "Custom content directory exists at project root"

            # Count plugins and themes
            local plugin_count=$(find "custom/plugins" -maxdepth 1 -type d 2>/dev/null | wc -l || echo "0")
            local theme_count=$(find "custom/themes" -maxdepth 1 -type d 2>/dev/null | wc -l || echo "0")

            echo "  Plugins: $((plugin_count - 1))" # -1 to exclude the plugins directory itself
            echo "  Themes: $((theme_count - 1))"   # -1 to exclude the themes directory itself
        fi

        show_version
    else
        log_warning "WordPress not installed. Run '$0 install' to install."
    fi
}

# Install a plugin
install_plugin() {
    local plugin_name="$1"

    if [[ -z "$plugin_name" ]]; then
        log_error "Plugin name required. Usage: $0 plugin:install <plugin-name>"
        exit 1
    fi

    log_info "Installing plugin: $plugin_name"

    # Convert plugin name to wpackagist format
    local package_name="wpackagist-plugin/$plugin_name"

    composer require "$package_name"

    log_success "Plugin '$plugin_name' installed successfully!"
    log_info "Activate it in WordPress admin or via WP-CLI"
}

# Remove a plugin
remove_plugin() {
    local plugin_name="$1"

    if [[ -z "$plugin_name" ]]; then
        log_error "Plugin name required. Usage: $0 plugin:remove <plugin-name>"
        exit 1
    fi

    log_info "Removing plugin: $plugin_name"

    local package_name="wpackagist-plugin/$plugin_name"

    composer remove "$package_name"

    log_success "Plugin '$plugin_name' removed successfully!"
}

# List installed plugins
list_plugins() {
    log_info "Installed WordPress plugins:"
    echo ""

    composer show | grep "wpackagist-plugin/" | while read -r line; do
        local plugin_info=$(echo "$line" | awk '{print $1, $2}')
        local plugin_name=$(echo "$plugin_info" | cut -d'/' -f2)
        local plugin_version=$(echo "$plugin_info" | awk '{print $2}')
        echo "  ✓ $plugin_name ($plugin_version)"
    done
}

# Install a theme
install_theme() {
    local theme_name="$1"

    if [[ -z "$theme_name" ]]; then
        log_error "Theme name required. Usage: $0 theme:install <theme-name>"
        exit 1
    fi

    log_info "Installing theme: $theme_name"

    local package_name="wpackagist-theme/$theme_name"

    composer require "$package_name"

    log_success "Theme '$theme_name' installed successfully!"
    log_info "Activate it in WordPress admin"
}

# Remove a theme
remove_theme() {
    local theme_name="$1"

    if [[ -z "$theme_name" ]]; then
        log_error "Theme name required. Usage: $0 theme:remove <theme-name>"
        exit 1
    fi

    log_info "Removing theme: $theme_name"

    local package_name="wpackagist-theme/$theme_name"

    composer remove "$package_name"

    log_success "Theme '$theme_name' removed successfully!"
}

# List installed themes
list_themes() {
    log_info "Installed WordPress themes:"
    echo ""

    composer show | grep "wpackagist-theme/" | while read -r line; do
        local theme_info=$(echo "$line" | awk '{print $1, $2}')
        local theme_name=$(echo "$theme_info" | cut -d'/' -f2)
        local theme_version=$(echo "$theme_info" | awk '{print $2}')
        echo "  ✓ $theme_name ($theme_version)"
    done
}

# Regenerate wp-config.php
regenerate_config() {
    log_info "Regenerating wp-config.php..."

    if [[ -f "$WP_DIR/wp-config.php" ]]; then
        log_warning "Backing up existing wp-config.php"
        cp "$WP_DIR/wp-config.php" "$WP_DIR/wp-config.php.backup"
        rm "$WP_DIR/wp-config.php"
    fi

    php scripts/wp-config-generator.php

    log_success "wp-config.php regenerated!"
}

# Clean up WordPress installation
cleanup_wordpress() {
    log_info "Cleaning up WordPress installation..."

    # Remove cache files
    if [[ -d "custom/cache" ]]; then
        rm -rf "custom/cache"
        log_success "Cleared cache directory"
    fi

    # Remove upgrade directory
    if [[ -d "custom/upgrade" ]]; then
        rm -rf "custom/upgrade"
        log_success "Cleared upgrade directory"
    fi

    # Remove debug log if it exists
    if [[ -f "custom/debug.log" ]]; then
        rm "custom/debug.log"
        log_success "Cleared debug log"
    fi

    log_success "WordPress cleanup completed!"
}

# Main command handling
case "${1:-}" in
    "install")
        install_wordpress
        ;;
    "install:full")
        log_info "Running full WordPress installation with sample content..."
        ./scripts/wp-install.sh
        ;;
    "update")
        update_wordpress
        ;;
    "version")
        show_version
        ;;
    "status")
        show_status
        ;;
    "plugin:install")
        install_plugin "${2:-}"
        ;;
    "plugin:remove")
        remove_plugin "${2:-}"
        ;;
    "plugin:list")
        list_plugins
        ;;
    "theme:install")
        install_theme "${2:-}"
        ;;
    "theme:remove")
        remove_theme "${2:-}"
        ;;
    "theme:list")
        list_themes
        ;;
    "config:generate")
        regenerate_config
        ;;
    "cleanup")
        cleanup_wordpress
        ;;
    "help"|"-h"|"--help"|"")
        show_help
        ;;
    *)
        log_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
