#!/bin/bash

# Lando Environment Wrapper
# Ensures Lando is available across different environments and platforms

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect the operating system
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        CYGWIN*|MINGW32*|MINGW64*|MSYS*)    echo "windows";;
        *)          echo "unknown";;
    esac
}

# Function to find Lando executable
find_lando() {
    local os=$(detect_os)
    local lando_path=""
    
    # Try standard locations first
    if command -v lando >/dev/null 2>&1; then
        echo "$(which lando)"
        return 0
    fi
    
    case "$os" in
        "windows")
            # Windows-specific locations
            local windows_paths=(
                "/c/Users/$USER/.lando/bin/lando.cmd"
                "/c/Users/$USER/AppData/Local/Lando/bin/lando.cmd"
                "/c/ProgramData/chocolatey/bin/lando.exe"
                "/c/Program Files/Lando/bin/lando.exe"
            )
            
            for path in "${windows_paths[@]}"; do
                if [[ -f "$path" ]]; then
                    echo "$path"
                    return 0
                fi
            done
            
            # Try lando.cmd in PATH
            if command -v lando.cmd >/dev/null 2>&1; then
                echo "$(which lando.cmd)"
                return 0
            fi
            ;;
            
        "macos")
            # macOS-specific locations
            local macos_paths=(
                "/usr/local/bin/lando"
                "/opt/homebrew/bin/lando"
                "$HOME/.lando/bin/lando"
            )
            
            for path in "${macos_paths[@]}"; do
                if [[ -f "$path" ]]; then
                    echo "$path"
                    return 0
                fi
            done
            ;;
            
        "linux")
            # Linux-specific locations
            local linux_paths=(
                "/usr/local/bin/lando"
                "/usr/bin/lando"
                "$HOME/.lando/bin/lando"
                "$HOME/.local/bin/lando"
            )
            
            for path in "${linux_paths[@]}"; do
                if [[ -f "$path" ]]; then
                    echo "$path"
                    return 0
                fi
            done
            ;;
    esac
    
    return 1
}

# Function to install or suggest Lando installation
suggest_lando_install() {
    local os=$(detect_os)
    
    log_error "Lando not found on this system!"
    echo
    log_info "To install Lando, visit: https://docs.lando.dev/getting-started/installation.html"
    echo
    
    case "$os" in
        "windows")
            log_info "For Windows, you can:"
            echo "  1. Download from: https://github.com/lando/lando/releases"
            echo "  2. Or use Chocolatey: choco install lando"
            ;;
        "macos")
            log_info "For macOS, you can:"
            echo "  1. Use Homebrew: brew install lando"
            echo "  2. Download from: https://github.com/lando/lando/releases"
            ;;
        "linux")
            log_info "For Linux, you can:"
            echo "  1. Download from: https://github.com/lando/lando/releases"
            echo "  2. Use package managers (varies by distribution)"
            ;;
    esac
    
    return 1
}

# Function to create a lando alias/symlink
setup_lando_alias() {
    local lando_path="$1"
    local os=$(detect_os)
    
    if [[ "$os" == "windows" && "$lando_path" == *.cmd ]]; then
        # Create a bash wrapper for Windows .cmd files
        local wrapper_dir="$HOME/.local/bin"
        mkdir -p "$wrapper_dir"
        
        local wrapper_script="$wrapper_dir/lando"
        cat > "$wrapper_script" << EOF
#!/bin/bash
# Auto-generated Lando wrapper for Windows
exec "$lando_path" "\$@"
EOF
        chmod +x "$wrapper_script"
        
        # Add to PATH if not already there
        if [[ ":$PATH:" != *":$wrapper_dir:"* ]]; then
            log_info "Adding $wrapper_dir to PATH in your shell profile"
            
            # Determine shell profile file
            local profile_file=""
            if [[ -f "$HOME/.bashrc" ]]; then
                profile_file="$HOME/.bashrc"
            elif [[ -f "$HOME/.bash_profile" ]]; then
                profile_file="$HOME/.bash_profile"
            elif [[ -f "$HOME/.profile" ]]; then
                profile_file="$HOME/.profile"
            fi
            
            if [[ -n "$profile_file" ]]; then
                echo "export PATH=\"$wrapper_dir:\$PATH\"" >> "$profile_file"
                log_success "Added PATH update to $profile_file"
                log_warning "Please restart your terminal or run: source $profile_file"
            fi
        fi
        
        log_success "Lando wrapper created at: $wrapper_script"
    fi
}

# Main function
main() {
    local os=$(detect_os)
    log_info "Detecting Lando installation on $os..."
    
    local lando_path
    if lando_path=$(find_lando); then
        log_success "Found Lando at: $lando_path"
        
        # Test if it works
        if "$lando_path" version >/dev/null 2>&1; then
            local version=$("$lando_path" version 2>/dev/null | head -1)
            log_success "Lando is working! Version: $version"
            
            # Setup alias if needed
            if [[ "$os" == "windows" && "$lando_path" == *.cmd ]] && ! command -v lando >/dev/null 2>&1; then
                log_info "Setting up Lando wrapper for bash compatibility..."
                setup_lando_alias "$lando_path"
            fi
            
            return 0
        else
            log_error "Lando found but not working properly"
            return 1
        fi
    else
        suggest_lando_install
        return 1
    fi
}

# If script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi