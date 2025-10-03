#!/bin/bash

# WordPress E-commerce Starter - Docker Desktop & Lando Installation Script
# This script installs Docker Desktop and Lando for local WordPress development

# Automated mode: Set WES_AUTO=1 to skip interactive prompts
# Additional options:
#   WES_INSTALL_DOCKER=1/0 (default: 1)
#   WES_INSTALL_LANDO=1/0 (default: 1)
#   WES_FORCE_LANDO=1/0 (default: 0) - Force Lando reinstall

# Error handling and debugging options
DEBUG_MODE="${WES_DEBUG:-0}"
ERROR_TOLERANT="${WES_ERROR_TOLERANT:-0}"

# Set appropriate error handling based on mode
if [[ "$ERROR_TOLERANT" == "1" ]]; then
    set -uo pipefail  # Don't exit on errors
else
    set -euo pipefail  # Exit on errors (default)
fi

# Debug function
debug() {
    if [[ "$DEBUG_MODE" == "1" ]]; then
        echo -e "\033[0;36m[DEBUG]\033[0m $1" >&2
    fi
}

# Error handler
handle_error() {
    local exit_code=$?
    local line_number=$1
    echo -e "\033[0;31m[ERROR]\033[0m Script failed at line $line_number with exit code $exit_code" >&2
    if [[ "$DEBUG_MODE" == "1" ]]; then
        echo -e "\033[0;36m[DEBUG]\033[0m Call stack:" >&2
        local frame=0
        while caller $frame >&2; do
            ((frame++))
        done
    fi
    if [[ "$ERROR_TOLERANT" != "1" ]]; then
        exit $exit_code
    fi
}

# Set up error trap
trap 'handle_error $LINENO' ERR

# Usage function
show_usage() {
    echo "🐳 WordPress E-commerce Starter - Lando & Docker Desktop Installer"
    echo "================================================================="
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Interactive Mode (default):"
    echo "  ./scripts/setup/install-lando-docker.sh"
    echo ""
    echo "Automated Mode (no prompts):"
    echo "  WES_AUTO=1 ./scripts/setup/install-lando-docker.sh"
    echo ""
    echo "Environment Variables:"
    echo "  WES_AUTO=1            Enable automated mode (no interactive prompts)"
    echo "  WES_QUIET=1           Reduce output verbosity"
    echo "  WES_DEBUG=1           Enable debug output for troubleshooting"
    echo "  WES_ERROR_TOLERANT=1  Continue on errors instead of exiting"
    echo "  WES_INSTALL_DOCKER=1  Install Docker Desktop (default: 1)"
    echo "  WES_INSTALL_LANDO=1   Install Lando (default: 1)"
    echo "  WES_FORCE_LANDO=1     Force Lando reinstall if already installed (default: 0)"
    echo ""
    echo "Examples:"
    echo "  WES_AUTO=1 $0                                    # Install both with defaults"
    echo "  WES_AUTO=1 WES_INSTALL_DOCKER=0 $0              # Install only Lando"
    echo "  WES_AUTO=1 WES_FORCE_LANDO=1 $0                # Force Lando reinstall"
    echo ""
    exit 0
}

# Check for help flag
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    show_usage
fi

# Check for quiet mode
QUIET_MODE="${WES_QUIET:-0}"

if [[ "$QUIET_MODE" != "1" ]]; then
    echo "🐳 WordPress E-commerce Starter - Lando & Docker Desktop Installer"
    echo "=================================================================="
    echo ""
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions with error tolerance
log_info() {
    debug "log_info called with: $1"
    if [[ "$QUIET_MODE" != "1" ]]; then
        echo -e "${BLUE}[INFO]${NC} $1" || true
    fi
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" || true
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" || true
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2 || true
}

# Safe command execution with error handling
safe_execute() {
    local cmd="$1"
    local description="$2"
    debug "Executing: $cmd"
    if [[ "$ERROR_TOLERANT" == "1" ]]; then
        if ! eval "$cmd"; then
            log_warning "Command failed but continuing: $description"
            return 1
        fi
    else
        eval "$cmd" || {
            log_error "Command failed: $description"
            return 1
        }
    fi
    return 0
}

# Check if running on supported OS with error tolerance
check_os() {
    debug "Checking OS type: $OSTYPE"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        OS="windows"
    else
        log_error "Unsupported operating system: $OSTYPE"
        if [[ "$ERROR_TOLERANT" != "1" ]]; then
            exit 1
        else
            log_warning "Continuing with unknown OS, assuming Linux-like behavior"
            OS="linux"
        fi
    fi
    log_info "Detected $OS system"
    debug "OS detection completed: $OS"
}

# Check if command exists with error tolerance
command_exists() {
    local cmd="$1"
    debug "Checking if command exists: $cmd"
    if command -v "$cmd" >/dev/null 2>&1; then
        debug "Command found: $cmd"
        return 0
    else
        debug "Command not found: $cmd"
        return 1
    fi
}

# Check prerequisites
check_prerequisites() {
    if ! command_exists curl && ! command_exists wget; then
        log_error "Either curl or wget is required for downloads"
        exit 1
    fi
    log_info "Prerequisites check passed"
}

# Download file with progress
download_file() {
    local url="$1"
    local output="$2"

    log_info "Downloading: $(basename "$output")"

    if command_exists curl; then
        curl -L --progress-bar "$url" -o "$output"
    elif command_exists wget; then
        wget --progress=bar:force:noscroll "$url" -O "$output"
    else
        log_error "Neither curl nor wget is available"
        return 1
    fi
}

# Install Docker Desktop
install_docker_desktop() {
    log_info "Installing Docker Desktop..."

    case "$OS" in
        "linux")
            log_info "For Linux, please install Docker Engine manually:"
            log_info "https://docs.docker.com/engine/install/"
            log_warning "Skipping Docker Desktop installation on Linux"
            ;;
        "macos")
            local docker_url="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
            local docker_file="/tmp/Docker.dmg"

            if command_exists docker; then
                log_warning "Docker already installed, skipping..."
                return 0
            fi

            log_info "Downloading Docker Desktop for macOS..."
            download_file "$docker_url" "$docker_file"

            log_info "Mounting Docker.dmg..."
            hdiutil attach "$docker_file" -nobrowse -quiet

            log_info "Installing Docker Desktop..."
            cp -R "/Volumes/Docker/Docker.app" "/Applications/"

            log_info "Unmounting Docker.dmg..."
            hdiutil detach "/Volumes/Docker" -quiet
            rm -f "$docker_file"

            log_success "Docker Desktop installed successfully"
            log_info "Please start Docker Desktop from Applications folder"
            ;;
        "windows")
            local docker_url="https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
            local docker_file="/tmp/DockerDesktopInstaller.exe"

            if command_exists docker; then
                log_warning "Docker already installed, skipping..."
                return 0
            fi

            log_info "Downloading Docker Desktop for Windows..."
            download_file "$docker_url" "$docker_file"

            log_info "Running Docker Desktop installer..."
            log_warning "Please follow the installation wizard that will open"
            powershell.exe -Command "Start-Process '$docker_file' -Wait"

            rm -f "$docker_file"
            log_success "Docker Desktop installer completed"
            log_info "Please restart your computer if prompted"
            ;;
    esac
}

# Install Lando
install_lando() {
    log_info "Installing Lando..."

    if command_exists lando; then
        local current_version=$(lando version --component cli 2>/dev/null | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' || echo "unknown")
        log_warning "Lando already installed (version: $current_version)"

        if [[ "${WES_AUTO:-0}" == "1" ]]; then
            if [[ "${WES_FORCE_LANDO:-0}" == "1" ]]; then
                log_info "Automated mode: Reinstalling Lando (WES_FORCE_LANDO=1)"
            else
                log_info "Skipping Lando installation (already installed, use WES_FORCE_LANDO=1 to force)"
                return 0
            fi
        else
            read -p "Do you want to reinstall/update Lando? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "Skipping Lando installation (already installed)"
                return 0
            fi
        fi
    fi

    # Get latest Lando version
    local latest_version
    if command_exists curl; then
        latest_version=$(curl -s https://api.github.com/repos/lando/lando/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' 2>/dev/null)
    elif command_exists wget; then
        latest_version=$(wget -qO- https://api.github.com/repos/lando/lando/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' 2>/dev/null)
    fi

    if [ -z "$latest_version" ]; then
        latest_version="v3.21.0"  # Fallback version
        log_warning "Using fallback version: $latest_version"
    fi

    log_info "Installing Lando $latest_version..."

    case "$OS" in
        "linux")
            local lando_url="https://github.com/lando/lando/releases/download/${latest_version}/lando-linux-x64-${latest_version}.tgz"
            local lando_file="/tmp/lando-linux.tgz"
            local install_dir="$HOME/.local/bin"

            download_file "$lando_url" "$lando_file"

            mkdir -p "$install_dir"
            tar -xzf "$lando_file" -C "$install_dir"
            chmod +x "$install_dir/lando"

            rm -f "$lando_file"

            # Add to PATH if not already there
            if [[ ":$PATH:" != *":$install_dir:"* ]]; then
                echo "export PATH=\"$install_dir:\$PATH\"" >> ~/.bashrc
                export PATH="$install_dir:$PATH"
            fi

            log_success "Lando installed to $install_dir/lando"
            ;;
        "macos")
            local lando_url="https://github.com/lando/lando/releases/download/${latest_version}/lando-macos-x64-${latest_version}.dmg"
            local lando_file="/tmp/lando-macos.dmg"

            download_file "$lando_url" "$lando_file"

            log_info "Mounting Lando.dmg..."
            hdiutil attach "$lando_file" -nobrowse -quiet

            log_info "Installing Lando..."
            cp -R "/Volumes/Lando/Lando.pkg" "/tmp/"
            installer -pkg "/tmp/Lando.pkg" -target /

            log_info "Unmounting Lando.dmg..."
            hdiutil detach "/Volumes/Lando" -quiet
            rm -f "$lando_file" "/tmp/Lando.pkg"

            log_success "Lando installed successfully"
            ;;
        "windows")
            local lando_url="https://github.com/lando/lando/releases/download/${latest_version}/lando-win-x64-${latest_version}.exe"
            local lando_file="/tmp/lando-installer.exe"

            download_file "$lando_url" "$lando_file"

            log_info "Running Lando installer..."
            log_warning "Please follow the installation wizard that will open"
            powershell.exe -Command "Start-Process '$lando_file' -Wait"

            rm -f "$lando_file"
            log_success "Lando installer completed"
            ;;
    esac
}

# Configure PATH for current session and future sessions
configure_paths() {
    log_info "Configuring PATH for Docker and Lando..."

    local bashrc_file="$HOME/.bashrc"
    local needs_update=false

    # Check if Docker needs to be added to PATH
    if ! command_exists docker; then
        case "$OS" in
            "windows")
                if [ -f "/c/Program Files/Docker/Docker/resources/bin/docker.exe" ]; then
                    export PATH="$PATH:/c/Program Files/Docker/Docker/resources/bin"
                    echo 'export PATH="$PATH:/c/Program Files/Docker/Docker/resources/bin"' >> "$bashrc_file"
                    log_success "Added Docker to PATH"
                    needs_update=true
                fi
                ;;
        esac
    fi

    # Check if Lando needs to be added to PATH
    if ! command_exists lando; then
        if [ -f "$HOME/.local/bin/lando.exe" ]; then
            export PATH="$PATH:$HOME/.local/bin"
            if ! grep -q "$HOME/.local/bin" "$bashrc_file" 2>/dev/null; then
                echo 'export PATH="$PATH:$HOME/.local/bin"' >> "$bashrc_file"
                log_success "Added Lando to PATH"
                needs_update=true
            fi
        fi
    fi

    if $needs_update; then
        log_info "PATH has been updated for future terminal sessions"
        log_info "For current session, run: source ~/.bashrc"
    fi
}

# Verify installations with comprehensive error handling
verify_installations() {
    log_info "Verifying installations..."
    debug "Starting installation verification"

    local verification_errors=0

    # Check Docker with multiple methods
    debug "Checking Docker installation"
    if command_exists docker; then
        local docker_version
        if docker_version=$(docker --version 2>/dev/null); then
            log_success "Docker installed: $docker_version"
            debug "Docker version check successful"
        else
            log_warning "Docker command found but version check failed"
            ((verification_errors++))
        fi
    else
        # Try alternative Docker paths
        local docker_paths=(
            "/c/Program Files/Docker/Docker/resources/bin/docker"
            "/usr/bin/docker"
            "/usr/local/bin/docker"
        )

        local docker_found=false
        for docker_path in "${docker_paths[@]}"; do
            if [[ -f "$docker_path" ]]; then
                log_success "Docker found at: $docker_path"
                docker_found=true
                break
            fi
        done

        if [[ "$docker_found" == "false" ]]; then
            log_warning "Docker not found - restart may be needed"
            ((verification_errors++))
        fi
    fi

    # Check Lando with multiple methods
    debug "Checking Lando installation"
    if command_exists lando; then
        local lando_version
        if lando_version=$(lando version --component cli 2>/dev/null); then
            log_success "Lando installed: $lando_version"
            debug "Lando version check successful"
        else
            log_warning "Lando command found but version check failed"
            ((verification_errors++))
        fi
    else
        # Try alternative Lando paths
        local lando_paths=(
            "$HOME/.local/bin/lando"
            "$HOME/.local/bin/lando.exe"
            "/usr/local/bin/lando"
        )

        local lando_found=false
        for lando_path in "${lando_paths[@]}"; do
            if [[ -f "$lando_path" ]]; then
                log_success "Lando found at: $lando_path"
                lando_found=true
                break
            fi
        done

        if [[ "$lando_found" == "false" ]]; then
            log_warning "Lando not found - restart may be needed"
            ((verification_errors++))
        fi
    fi

    if [[ $verification_errors -eq 0 ]]; then
        log_success "Installation verification complete!"
    else
        log_warning "Installation verification completed with $verification_errors warnings"
        if [[ "$ERROR_TOLERANT" != "1" && $verification_errors -gt 1 ]]; then
            log_error "Multiple verification failures detected"
            return 1
        fi
    fi
    debug "Verification process completed"
}

# Show post-installation instructions
show_post_install_instructions() {
    echo ""
    echo "=================================================================="
    log_info "Post-installation instructions:"
    echo ""

    case "$OS" in
        "windows")
            echo "1. 🔄 Restart your computer if prompted by Docker Desktop"
            echo "2. 🐳 Start Docker Desktop from the Start Menu"
            echo "3. 🔧 Open a new Git Bash terminal"
            echo "4. ✅ Run 'docker --version' and 'lando version' to verify"
            ;;
        "macos")
            echo "1. 🐳 Start Docker Desktop from Applications folder"
            echo "2. 🔧 Open a new terminal"
            echo "3. ✅ Run 'docker --version' and 'lando version' to verify"
            ;;
        "linux")
            echo "1. 🔧 Install Docker Engine manually if not already installed"
            echo "2. 🔄 Start a new terminal session or run 'source ~/.bashrc'"
            echo "3. ✅ Run 'docker --version' and 'lando version' to verify"
            ;;
    esac

    echo ""
    echo "📖 Next steps:"
    echo "   • Navigate to your project directory"
    echo "   • Run 'lando start' to start your development environment"
    echo "   • Visit the Lando documentation: https://docs.lando.dev"
    echo ""
        log_success "Installation complete! 🎉"
}

# Configure PATH variables
configure_paths() {
    if [[ "$QUIET_MODE" != "1" ]]; then
        log_info "Configuring PATH for Docker and Lando..."
    fi

    # This function adds Docker and Lando to PATH if they're not already there
    # The actual PATH configuration is handled by .bashrc

    # Add Docker Desktop to PATH if it exists but isn't in PATH
    if [ -f "/c/Program Files/Docker/Docker/resources/bin/docker.exe" ] && ! command -v docker >/dev/null 2>&1; then
        export PATH="$PATH:/c/Program Files/Docker/Docker/resources/bin"
    fi

    # Add Lando to PATH if it exists but isn't in PATH
    if [ -f "$HOME/.local/bin/lando.exe" ] && ! command -v lando >/dev/null 2>&1; then
        export PATH="$PATH:$HOME/.local/bin"
    fi
}

# Show post-installation instructions
show_post_install_instructions() {
    if [[ "$QUIET_MODE" != "1" ]]; then
        echo ""
        echo "================================================================="
        echo ""
        log_info "Post-installation instructions:"
        echo ""
        echo "1. 🔄 Restart your computer if prompted by Docker Desktop"
        echo "2. 🐳 Start Docker Desktop from the Start Menu"
        echo "3. 🔧 Open a new Git Bash terminal"
        echo "4. ✅ Run 'docker --version' and 'lando version' to verify"
        echo ""
        echo "📖 Next steps:"
        echo "   • Navigate to your project directory"
        echo "   • Run 'lando start' to start your development environment"
        echo "   • Visit the Lando documentation: https://docs.lando.dev"
    fi

    log_success "Installation complete! 🎉"
}

# Main installation flow
main() {
    if [[ "$QUIET_MODE" != "1" ]]; then
        echo ""
        log_info "Starting installation process..."
        echo ""
    fi

    check_os
    check_prerequisites

    if [[ "$QUIET_MODE" != "1" ]]; then
        echo ""
    fi

    if [[ "${WES_AUTO:-0}" == "1" ]]; then
        if [[ "${WES_INSTALL_DOCKER:-1}" == "1" ]]; then
            log_info "Automated mode: Installing Docker Desktop (WES_INSTALL_DOCKER=1)"
            install_docker_desktop
        else
            log_info "Automated mode: Skipping Docker Desktop installation (WES_INSTALL_DOCKER=0)"
        fi
    else
        read -p "Install Docker Desktop? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            install_docker_desktop
        fi
    fi

    if [[ "$QUIET_MODE" != "1" ]]; then
        echo ""
    fi

    if [[ "${WES_AUTO:-0}" == "1" ]]; then
        if [[ "${WES_INSTALL_LANDO:-1}" == "1" ]]; then
            log_info "Automated mode: Installing Lando (WES_INSTALL_LANDO=1)"
            install_lando
        else
            log_info "Automated mode: Skipping Lando installation (WES_INSTALL_LANDO=0)"
        fi
    else
        read -p "Install Lando? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            install_lando
        fi
    fi

    if [[ "$QUIET_MODE" != "1" ]]; then
        echo ""
    fi

    verify_installations
    configure_paths
    show_post_install_instructions
}

# Run main function
main "$@"
