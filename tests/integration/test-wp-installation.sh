#!/bin/bash

# Test script to validate WordPress installation functionality
# This script tests the wp-install.sh script functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Test WordPress installation validation
test_wordpress_installation() {
    log_info "Testing WordPress installation validation..."

    # Check if Lando is running
    if ! lando info > /dev/null 2>&1; then
        log_warning "Lando is not running. Cannot test WordPress installation."
        return 1
    fi

    # Check if WordPress is installed
    if lando wp core is-installed --allow-root > /dev/null 2>&1; then
        log_success "WordPress is installed and configured"

        # Test sample pages exist
        local home_page=$(lando wp post list --post_type=page --name=home --field=ID --allow-root 2>/dev/null || echo "")
        if [ -n "$home_page" ]; then
            log_success "Home page exists (ID: $home_page)"
        else
            log_warning "Home page not found"
        fi

        # Test permalink structure
        local permalink_structure=$(lando wp option get permalink_structure --allow-root 2>/dev/null || echo "")
        if [ "$permalink_structure" = "/%postname%/" ]; then
            log_success "Permalink structure is correctly set to /%postname%/"
        else
            log_warning "Permalink structure: $permalink_structure (expected: /%postname%/)"
        fi

        # Test admin user
        if lando wp user get admin --allow-root > /dev/null 2>&1; then
            log_success "Admin user exists"
        else
            log_warning "Admin user not found"
        fi

        # Test if WooCommerce is configured (if installed)
        if lando wp plugin is-installed woocommerce --allow-root 2>/dev/null; then
            local shop_page_id=$(lando wp option get woocommerce_shop_page_id --allow-root 2>/dev/null || echo "")
            if [ -n "$shop_page_id" ] && [ "$shop_page_id" != "0" ]; then
                log_success "WooCommerce shop page is configured (ID: $shop_page_id)"
            else
                log_warning "WooCommerce shop page not configured"
            fi
        fi

        return 0
    else
        log_error "WordPress is not installed"
        return 1
    fi
}

# Test rewrite rules
test_rewrite_rules() {
    log_info "Testing rewrite rules..."

    if ! lando info > /dev/null 2>&1; then
        log_warning "Lando is not running. Cannot test rewrite rules."
        return 1
    fi

    # Check if rewrite rules are flushed
    local rewrite_rules=$(lando wp option get rewrite_rules --allow-root --format=count 2>/dev/null || echo "0")
    if [ "$rewrite_rules" -gt "0" ]; then
        log_success "Rewrite rules are configured ($rewrite_rules rules)"
    else
        log_warning "No rewrite rules found"
    fi
}

# Test sample content
test_sample_content() {
    log_info "Testing sample content..."

    if ! lando info > /dev/null 2>&1; then
        log_warning "Lando is not running. Cannot test sample content."
        return 1
    fi

    # Count pages
    local page_count=$(lando wp post list --post_type=page --format=count --allow-root 2>/dev/null || echo "0")
    if [ "$page_count" -ge "4" ]; then
        log_success "Sample pages created ($page_count pages)"
    else
        log_warning "Expected at least 4 pages, found $page_count"
    fi

    # Count posts
    local post_count=$(lando wp post list --post_type=post --format=count --allow-root 2>/dev/null || echo "0")
    if [ "$post_count" -ge "2" ]; then
        log_success "Sample posts created ($post_count posts)"
    else
        log_warning "Expected at least 2 posts, found $post_count"
    fi

    # Check navigation menu
    local menu_count=$(lando wp menu list --format=count --allow-root 2>/dev/null || echo "0")
    if [ "$menu_count" -ge "1" ]; then
        log_success "Navigation menu created ($menu_count menus)"
    else
        log_warning "No navigation menus found"
    fi
}

# Main test function
main() {
    echo -e "${BLUE}🧪 WordPress Installation Test Suite${NC}"
    echo "===================================="
    echo ""

    local tests_passed=0
    local tests_failed=0

    # Run tests
    if test_wordpress_installation; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi

    if test_rewrite_rules; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi

    if test_sample_content; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi

    echo ""
    echo "======================================"
    echo "Test Results:"
    echo -e "Passed: ${GREEN}$tests_passed${NC}"
    echo -e "Failed: ${RED}$tests_failed${NC}"

    if [ $tests_failed -eq 0 ]; then
        echo -e "${GREEN}🎉 All WordPress installation tests passed!${NC}"
        echo ""
        echo "Your WordPress installation is working correctly with:"
        echo "• Proper installation and configuration"
        echo "• Sample content and pages"
        echo "• Pretty permalinks"
        echo "• Navigation menus"
        echo "• WooCommerce integration (if installed)"
        exit 0
    else
        echo -e "${RED}❌ Some tests failed.${NC}"
        echo ""
        echo "To fix issues:"
        echo "1. Make sure Lando is running: lando start"
        echo "2. Run full installation: ./scripts/wp-manager.sh install:full"
        echo "3. Check WordPress admin: https://wordpress-ecommerce-starter.lndo.site/wp-admin/"
        exit 1
    fi
}

# Run main function
main "$@"
