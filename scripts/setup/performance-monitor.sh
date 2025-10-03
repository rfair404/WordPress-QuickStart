#!/bin/bash

# WordPress E-commerce Starter - Performance Monitor
# This script provides performance metrics and system health checks

echo "📊 WordPress E-commerce Starter - Performance Monitor"
echo "=================================================="

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Performance metrics
check_performance() {
    echo -e "\n${BLUE}🔍 System Performance${NC}"
    echo "--------------------"

    # Docker resource usage
    if command -v docker >/dev/null 2>&1; then
        echo "Docker status: $(docker info --format '{{.ServerVersion}}' 2>/dev/null || echo 'Not running')"
        if docker ps >/dev/null 2>&1; then
            echo "Active containers: $(docker ps --format 'table {{.Names}}' | tail -n +2 | wc -l)"
            echo "Docker memory usage: $(docker system df --format 'table {{.Type}}\t{{.Size}}' 2>/dev/null | grep Images | awk '{print $2}' || echo 'Unknown')"
        fi
    fi

    # Lando status
    if command -v lando >/dev/null 2>&1; then
        echo "Lando version: $(lando version --component cli 2>/dev/null | head -1 || echo 'Not available')"
        if lando info >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Lando environment is running${NC}"
        else
            echo -e "${YELLOW}⚠️  Lando environment is stopped${NC}"
        fi
    fi

    # System resources
    echo "Available disk space: $(df -h . | tail -1 | awk '{print $4}' || echo 'Unknown')"
    echo "System memory: $(free -h 2>/dev/null | grep Mem | awk '{print $7 "/" $2}' || echo 'Unknown')"
}

# Health checks
check_health() {
    echo -e "\n${BLUE}🏥 Health Checks${NC}"
    echo "----------------"

    local issues=0

    # Check critical services
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker not found${NC}"
        ((issues++))
    elif ! docker ps >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Docker not running${NC}"
        ((issues++))
    else
        echo -e "${GREEN}✅ Docker is healthy${NC}"
    fi

    if ! command -v lando >/dev/null 2>&1; then
        echo -e "${RED}❌ Lando not found${NC}"
        ((issues++))
    else
        echo -e "${GREEN}✅ Lando is available${NC}"
    fi

    # Check project files
    if [ ! -f ".lando.yml" ]; then
        echo -e "${YELLOW}⚠️  .lando.yml not found${NC}"
        ((issues++))
    else
        echo -e "${GREEN}✅ Lando configuration found${NC}"
    fi

    if [ ! -f "composer.json" ]; then
        echo -e "${YELLOW}⚠️  composer.json not found${NC}"
        ((issues++))
    else
        echo -e "${GREEN}✅ Composer configuration found${NC}"
    fi

    echo -e "\n${BLUE}Summary: $issues issues detected${NC}"
    return $issues
}

# Quick fixes
suggest_fixes() {
    echo -e "\n${BLUE}🔧 Quick Fixes${NC}"
    echo "-------------"
    echo "If you're experiencing issues, try these commands:"
    echo ""
    echo "🐳 Restart Docker:"
    echo "   lando poweroff && lando start"
    echo ""
    echo "🔄 Rebuild containers:"
    echo "   lando rebuild -y"
    echo ""
    echo "🧹 Clean up Docker:"
    echo "   docker system prune -f"
    echo ""
    echo "📊 Run full diagnostics:"
    echo "   ./scripts/setup/test-runner.sh"
}

# Main execution
main() {
    check_performance
    if ! check_health; then
        suggest_fixes
    else
        echo -e "\n${GREEN}🎉 All systems are healthy!${NC}"
    fi
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
