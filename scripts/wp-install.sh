#!/bin/bash

# WordPress Installation Script using Lando WP-CLI
# This script provides complete WordPress setup with sample content and configuration

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
SITE_URL="https://wordpress-quickstart.lndo.site"
SITE_TITLE="WordPress Quickstart"
ADMIN_USER="admin"
ADMIN_PASSWORD="admin"
ADMIN_EMAIL="admin@example.com"

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

log_step() {
    echo -e "${PURPLE}🔄 $1${NC}"
}

# Check if Lando is running
check_lando() {
    if ! lando info > /dev/null 2>&1; then
        log_error "Lando is not running. Please run 'lando start' first."
        exit 1
    fi
}

# Check if WordPress is already installed
check_wordpress_installation() {
    if lando wp --path=wp --path=wp core is-installed --allow-root > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Install WordPress core
install_wordpress_core() {
    log_step "Installing WordPress core..."

    # Install WordPress
    lando wp --path=wp --path=wp core install \
        --url="$SITE_URL" \
        --title="$SITE_TITLE" \
        --admin_user="$ADMIN_USER" \
        --admin_password="$ADMIN_PASSWORD" \
        --admin_email="$ADMIN_EMAIL" \
        --allow-root

    log_success "WordPress core installed successfully!"
}

# Configure WordPress settings
configure_wordpress() {
    log_step "Configuring WordPress settings..."

    # Set timezone
    lando wp --path=wp option update timezone_string 'America/New_York' --allow-root

    # Set date format
    lando wp --path=wp option update date_format 'F j, Y' --allow-root
    lando wp --path=wp option update time_format 'g:i a' --allow-root

    # Enable automatic updates for minor releases only
    lando wp --path=wp option update auto_update_core_minor 1 --allow-root
    lando wp --path=wp option update auto_update_core_major 0 --allow-root

    # Set default comment status to closed for new posts
    lando wp --path=wp option update default_comment_status 'closed' --allow-root

    # Set default ping status to closed
    lando wp --path=wp option update default_ping_status 'closed' --allow-root

    # Configure media settings
    lando wp --path=wp option update thumbnail_size_w 300 --allow-root
    lando wp --path=wp option update thumbnail_size_h 300 --allow-root
    lando wp --path=wp option update medium_size_w 768 --allow-root
    lando wp --path=wp option update medium_size_h 768 --allow-root
    lando wp --path=wp option update large_size_w 1024 --allow-root
    lando wp --path=wp option update large_size_h 1024 --allow-root

    log_success "WordPress settings configured!"
}

# Set up permalink structure
setup_permalinks() {
    log_step "Setting up permalink structure..."

    # Set pretty permalinks
    lando wp --path=wp rewrite structure '/%postname%/' --allow-root

    # Flush rewrite rules
    lando wp --path=wp rewrite flush --allow-root

    log_success "Permalink structure configured!"
}

# Create sample pages
create_sample_pages() {
    log_step "Creating sample pages..."

    # Delete default pages
    lando wp --path=wp post delete 1 --force --allow-root  # Hello World post
    lando wp --path=wp post delete 2 --force --allow-root  # Sample Page

    # Create Home page
    local home_content="<h1>Welcome to WordPress Quickstart</h1>
<p>This is a sample WordPress site created for development and testing.</p>

<h2>Features</h2>
<ul>
<li>WordPress managed via Composer</li>
<li>Custom content directory structure</li>
<li>Lando development environment</li>
<li>Comprehensive testing suite</li>
</ul>

<h2>Getting Started</h2>
<p>Visit the <a href=\"/about/\">About page</a> to learn more about this project.</p>
<p>Check out our <a href=\"/shop/\">Shop</a> to view sample content.</p>
<p>Read our <a href=\"/blog/\">Blog</a> for the latest updates.</p>"

    local home_page_id=$(lando wp --path=wp post create --post_type=page --post_status=publish --post_title="Home" --post_content="$home_content" --allow-root --porcelain)

    # Create About page
    local about_content="<h1>About WordPress Quickstart</h1>
<p>WordPress Quickstart is a development scaffold designed to bootstrap WordPress projects with modern tooling and testing.</p>

<h2>Technology Stack</h2>
<ul>
<li><strong>WordPress:</strong> Latest version managed via Composer</li>
<li><strong>Lando:</strong> Local development environment</li>
<li><strong>PHP 8.1+:</strong> Modern PHP with strict typing</li>
<li><strong>Node.js:</strong> JavaScript tooling and build processes</li>
<li><strong>Playwright:</strong> End-to-end testing framework</li>
</ul>

<h2>Development Features</h2>
<ul>
<li>Automated testing with PHPUnit and Playwright</li>
<li>Code quality enforcement with PHPCS and ESLint</li>
<li>Custom content directory structure</li>
<li>Professional deployment workflows</li>
<li>Comprehensive documentation</li>
</ul>

<p><a href=\"/contact/\">Contact us</a> for more information.</p>"

    lando wp --path=wp post create --post_type=page --post_status=publish --post_title="About" --post_content="$about_content" --allow-root

    # Create Contact page
    local contact_content="<h1>Contact Us</h1>
<p>Get in touch with the WordPress E-commerce Starter team.</p>

<h2>Development Support</h2>
<p>For development questions and technical support:</p>
<ul>
<li><strong>Email:</strong> dev@example.com</li>
<li><strong>GitHub:</strong> <a href=\"https://github.com/rfair404/WordPress-QuickStart\">Project Repository</a></li>
</ul>

<h2>Business Inquiries</h2>
<p>For business partnerships and collaboration:</p>
<ul>
<li><strong>Email:</strong> business@example.com</li>
<li><strong>Phone:</strong> (555) 123-4567</li>
</ul>

<div style=\"background: #f9f9f9; padding: 20px; border-left: 4px solid #0073aa; margin: 20px 0;\">
<p><strong>Note:</strong> This is a development environment. Replace these contact details with your actual information before going live.</p>
</div>"

    lando wp --path=wp post create --post_type=page --post_status=publish --post_title="Contact" --post_content="$contact_content" --allow-root

    # Create Blog page for posts
    lando wp --path=wp post create --post_type=page --post_status=publish --post_title="Blog" --post_content="<h1>Latest Updates</h1><p>Stay updated with the latest news and developments.</p>" --allow-root

    # Create Shop page (for storefronts/plugins)
    local shop_page_id=$(lando wp --path=wp post create --post_type=page --post_status=publish --post_title="Shop" --post_content="<h1>Our Products</h1><p>Browse our collection of sample products.</p>" --allow-root --porcelain)

    # Set Home page as front page
    lando wp --path=wp option update show_on_front 'page' --allow-root
    lando wp --path=wp option update page_on_front "$home_page_id" --allow-root

    # Set Blog page for posts
    local blog_page_id=$(lando wp --path=wp post list --post_type=page --name=blog --field=ID --allow-root)
    lando wp --path=wp option update page_for_posts "$blog_page_id" --allow-root

    log_success "Sample pages created successfully!"
}

# Create sample posts
create_sample_posts() {
    log_step "Creating sample blog posts..."

    # Create first blog post
    local post1_content="Welcome to your new WordPress site! This post demonstrates the blogging capabilities of your site.

<h2>What's Included</h2>
Your development environment includes:
<ul>
<li>WordPress latest version</li>
<li>Modern development tools</li>
<li>Automated testing suite</li>
</ul>

<h2>Next Steps</h2>
<ol>
<li>Customize your theme</li>
<li>Add your content to the site</li>
<li>Configure any storefront plugins or extensions as needed</li>
<li>Launch your site!</li>
</ol>

<p>Happy blogging!</p>"

    lando wp --path=wp post create --post_status=publish --post_title="Welcome to WordPress E-commerce Starter" --post_content="$post1_content" --post_category="1" --allow-root

    # Create second blog post
    local post2_content="Setting up a website has never been easier with this WordPress starter kit.

<h2>Development Features</h2>
This starter includes professional development tools:
<ul>
<li><strong>Lando:</strong> Consistent local development environment</li>
<li><strong>Composer:</strong> PHP dependency management</li>
<li><strong>WP-CLI:</strong> Command-line WordPress management</li>
<li><strong>Testing:</strong> Automated PHPUnit and E2E tests</li>
</ul>

<p>Start building your site today!</p>"

    lando wp --path=wp post create --post_status=publish --post_title="E-commerce Development Made Easy" --post_content="$post2_content" --post_category="1" --allow-root

    log_success "Sample blog posts created!"
}

# Create navigation menus
create_navigation_menus() {
    log_step "Creating navigation menus..."

    # Create main navigation menu
    lando wp --path=wp menu create "Main Navigation" --allow-root

    # Add pages to menu
    lando wp --path=wp menu item add-post main-navigation $(lando wp --path=wp post list --post_type=page --name=home --field=ID --allow-root) --allow-root
    lando wp --path=wp menu item add-post main-navigation $(lando wp --path=wp post list --post_type=page --name=about --field=ID --allow-root) --allow-root
    lando wp --path=wp menu item add-post main-navigation $(lando wp --path=wp post list --post_type=page --name=shop --field=ID --allow-root) --allow-root
    lando wp --path=wp menu item add-post main-navigation $(lando wp --path=wp post list --post_type=page --name=blog --field=ID --allow-root) --allow-root
    lando wp --path=wp menu item add-post main-navigation $(lando wp --path=wp post list --post_type=page --name=contact --field=ID --allow-root) --allow-root

    # Assign menu to primary location (theme dependent)
    lando wp --path=wp menu location assign main-navigation primary --allow-root 2>/dev/null || true

    log_success "Navigation menus created!"
}

# Storefront configuration is intentionally out of scope for this script.
# Keep a small informational function so callers remain stable.
configure_storefront() {
    log_step "Storefront configuration skipped (out of project scope)."
    log_info "If you require storefront functionality, install and configure a storefront plugin (for example, via Composer) separately."
}

# Main installation function
main() {
    echo -e "${BLUE}"
    echo "🚀 WordPress Quickstart Installation"
    echo "============================================="
    echo -e "${NC}"

    # Check prerequisites
    check_lando

    # Check if WordPress is already installed
    if check_wordpress_installation; then
        log_warning "WordPress is already installed!"
        read -p "Do you want to reset and reinstall? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_step "Resetting WordPress installation..."
            lando wp --path=wp db reset --yes --allow-root
        else
            log_info "Installation cancelled."
            exit 0
        fi
    fi

    # Run installation steps
    install_wordpress_core
    configure_wordpress
    setup_permalinks
    create_sample_pages
    create_sample_posts
    create_navigation_menus
    configure_storefront

    echo ""
    echo -e "${GREEN}🎉 WordPress installation completed successfully!${NC}"
    echo ""
    echo "Your WordPress site is now ready:"
    echo "👉 Site URL: $SITE_URL"
    echo "👉 Admin URL: $SITE_URL/wp-admin/"
    echo "👉 Username: $ADMIN_USER"
    echo "👉 Password: $ADMIN_PASSWORD"
    echo ""
    echo "Sample content created:"
    echo "• Home page (set as front page)"
    echo "• About page"
    echo "• Contact page"
    echo "• Blog page (for posts)"
    echo "• Shop page (for storefronts/plugins)"
    echo "• Sample blog posts"
    echo "• Navigation menu"
    echo ""
    echo "Next steps:"
    echo "1. Visit your site: $SITE_URL"
    echo "2. Login to admin: $SITE_URL/wp-admin/"
    echo "3. Install and configure any storefront plugins or integrations as needed"
    echo "4. Customize your theme and content"
    echo ""
}

# Run main function
main "$@"
