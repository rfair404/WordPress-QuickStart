#!/bin/bash

# WordPress E-commerce Starter - Dependency Validator
# Validates all required dependencies and their versions

echo "🔍 WordPress Quickstart - Dependency Validator"
echo "======================================================"

# Configuration
MIN_DOCKER_VERSION="20.10.0"
MIN_LANDO_VERSION="3.20.0"
MIN_PHP_VERSION="8.1.0"
MIN_NODE_VERSION="16.0.0"
MIN_COMPOSER_VERSION="2.0.0"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Version comparison function
version_compare() {
    local version1="$1"
    local version2="$2"

    # Remove any non-numeric characters except dots
    version1=$(echo "$version1" | sed 's/[^0-9.]//g')
    version2=$(echo "$version2" | sed 's/[^0-9.]//g')

    if [ "$(printf '%s\n' "$version1" "$version2" | sort -V | head -n1)" = "$version2" ]; then
        return 0  # version1 >= version2
    else
        return 1  # version1 < version2
    fi
}

# Validate Docker
validate_docker() {
    echo -e "\n${BLUE}🐳 Validating Docker${NC}"
    echo "-------------------"

    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker not found${NC}"
        echo "   Install: Run ./scripts/setup/install-lando-docker.sh"
        return 1
    fi

    local docker_version
    docker_version=$(docker --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

    if [ -z "$docker_version" ]; then
        echo -e "${YELLOW}⚠️  Could not determine Docker version${NC}"
        return 1
    fi

    if version_compare "$docker_version" "$MIN_DOCKER_VERSION"; then
        echo -e "${GREEN}✅ Docker $docker_version (>= $MIN_DOCKER_VERSION)${NC}"

        # Check if Docker is running
        if docker ps >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Docker daemon is running${NC}"
        else
            echo -e "${YELLOW}⚠️  Docker daemon not running${NC}"
            echo "   Fix: Start Docker Desktop or run 'sudo systemctl start docker'"
            return 1
        fi

        return 0
    else
        echo -e "${RED}❌ Docker $docker_version (< $MIN_DOCKER_VERSION required)${NC}"
        echo "   Update: Run ./scripts/setup/install-lando-docker.sh"
        return 1
    fi
}

# Validate Lando
validate_lando() {
    echo -e "\n${BLUE}🚀 Validating Lando${NC}"
    echo "------------------"

    if ! command -v lando >/dev/null 2>&1; then
        echo -e "${RED}❌ Lando not found${NC}"
        echo "   Install: Run ./scripts/setup/install-lando-docker.sh"
        return 1
    fi

    local lando_version
    lando_version=$(lando version --component cli 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

    if [ -z "$lando_version" ]; then
        echo -e "${YELLOW}⚠️  Could not determine Lando version${NC}"
        return 1
    fi

    if version_compare "$lando_version" "$MIN_LANDO_VERSION"; then
        echo -e "${GREEN}✅ Lando $lando_version (>= $MIN_LANDO_VERSION)${NC}"
        return 0
    else
        echo -e "${RED}❌ Lando $lando_version (< $MIN_LANDO_VERSION required)${NC}"
        echo "   Update: Run ./scripts/setup/install-lando-docker.sh"
        return 1
    fi
}

# Validate project dependencies
validate_project_deps() {
    echo -e "\n${BLUE}📦 Validating Project Dependencies${NC}"
    echo "----------------------------------"

    local issues=0

    # Check PHP (via Lando)
    if command -v lando >/dev/null 2>&1 && lando info >/dev/null 2>&1; then
        local php_version
        php_version=$(lando php -v 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

        if [ -n "$php_version" ] && version_compare "$php_version" "$MIN_PHP_VERSION"; then
            echo -e "${GREEN}✅ PHP $php_version (>= $MIN_PHP_VERSION)${NC}"
        else
            echo -e "${YELLOW}⚠️  PHP version check failed or < $MIN_PHP_VERSION${NC}"
            ((issues++))
        fi
    else
        echo -e "${YELLOW}⚠️  Cannot check PHP version (Lando not running)${NC}"
        ((issues++))
    fi

    # Check Composer
    if command -v lando >/dev/null 2>&1 && lando info >/dev/null 2>&1; then
        local composer_version
        composer_version=$(lando composer --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

        if [ -n "$composer_version" ] && version_compare "$composer_version" "$MIN_COMPOSER_VERSION"; then
            echo -e "${GREEN}✅ Composer $composer_version (>= $MIN_COMPOSER_VERSION)${NC}"
        else
            echo -e "${YELLOW}⚠️  Composer version check failed or < $MIN_COMPOSER_VERSION${NC}"
            ((issues++))
        fi
    else
        echo -e "${YELLOW}⚠️  Cannot check Composer version (Lando not running)${NC}"
        ((issues++))
    fi

    # Check Node.js
    if command -v lando >/dev/null 2>&1 && lando info >/dev/null 2>&1; then
        local node_version
        node_version=$(lando node --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

        if [ -n "$node_version" ] && version_compare "$node_version" "$MIN_NODE_VERSION"; then
            echo -e "${GREEN}✅ Node.js $node_version (>= $MIN_NODE_VERSION)${NC}"
        else
            echo -e "${YELLOW}⚠️  Node.js version check failed or < $MIN_NODE_VERSION${NC}"
            ((issues++))
        fi
    else
        echo -e "${YELLOW}⚠️  Cannot check Node.js version (Lando not running)${NC}"
        ((issues++))
    fi

    return $issues
}

# Validate project structure
validate_project_structure() {
    echo -e "\n${BLUE}📁 Validating Project Structure${NC}"
    echo "-------------------------------"

    local issues=0
    local required_files=(
        ".lando.yml"
        "composer.json"
        "package.json"
        "README.md"
        "scripts/setup/env-setup.sh"
        "scripts/setup/install-lando-docker.sh"
    )

    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            echo -e "${GREEN}✅ $file${NC}"
        else
            echo -e "${RED}❌ $file (missing)${NC}"
            ((issues++))
        fi
    done

    return $issues
}

# Main validation
main() {
    local total_issues=0

    validate_docker || ((total_issues++))
    validate_lando || ((total_issues++))
    validate_project_deps && : || ((total_issues++))
    validate_project_structure && : || ((total_issues++))

    echo -e "\n${BLUE}📋 Validation Summary${NC}"
    echo "===================="

    if [ $total_issues -eq 0 ]; then
        echo -e "${GREEN}🎉 All dependencies are valid and ready!${NC}"
        echo ""
        echo "You can now run:"
        echo "  lando start    # Start the development environment"
        echo "  lando info     # View service information"
        return 0
    else
        echo -e "${YELLOW}⚠️  Found $total_issues validation issue(s)${NC}"
        echo ""
        echo "To fix issues, run:"
        echo "  ./scripts/setup/install-lando-docker.sh  # Install/update Docker & Lando"
        echo "  ./scripts/setup/env-setup.sh            # Setup project environment"
        return 1
    fi
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
