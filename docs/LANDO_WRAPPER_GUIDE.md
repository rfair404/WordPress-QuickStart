# Lando Wrapper System Guide

This guide covers the cross-platform Lando wrapper system implemented in WordPress QuickStart,
providing universal Lando access across Windows, Mac, and Linux environments.

## Overview

The Lando wrapper system solves the common "lando: command not found" issue by providing:

- **Universal Lando Detection**: Detection across all operating systems
- **Automatic Installation**: Downloads and installs Lando when not found
- **PATH Management**: PATH resolution and environment configuration
- **Cross-platform Compatibility**: Unified interface for Windows, Mac, and Linux
- **Error Recovery**: Error handling and troubleshooting guidance

## Architecture

### Wrapper System Components

#### Primary Wrapper Script

- **Location**: `scripts/setup/lando-wrapper.sh`
- **Size**: 221 lines of cross-platform logic
- **Languages**: Bash with platform-specific adaptations
- **Features**: OS detection, installation automation, error handling

#### Integration Points

- **CI/CD Integration**: Used in GitHub Actions workflows
- **Development Scripts**: Integrated into npm scripts and composer commands
- **VS Code Integration**: Available through integrated terminal
- **Documentation**: Referenced throughout project documentation

### Cross-Platform Detection Logic

The wrapper implements OS detection:

```bash
# OS Detection
case "$(uname -s)" in
    CYGWIN*|MINGW*|MSYS*)
        OS="windows"
        ;;
    Darwin*)
        OS="macos"
        ;;
    Linux*)
        OS="linux"
        ;;
    *)
        OS="unknown"
        ;;
esac
```

#### Windows-Specific Handling

- **Cygwin Detection**: Handles Cygwin, MINGW, and MSYS environments
- **PowerShell Integration**: Works with PowerShell, Command Prompt, and Git Bash
- **Path Resolution**: Manages Windows PATH format and .cmd extensions
- **WSL Compatibility**: Full Windows Subsystem for Linux support

#### macOS-Specific Features

- **Homebrew Integration**: Detects and uses Homebrew installations
- **System Path Management**: Works with system and user PATH configurations
- **Security Handling**: Manages macOS security permissions for downloaded executables

#### Linux-Specific Features

- **Distribution Detection**: Supports major Linux distributions
- **Package Manager Integration**: Works with APT, YUM, DNF, and Pacman
- **User Permission Management**: Handles user vs system installations

## Installation and Setup

### Automatic Installation

The wrapper provides multiple installation methods:

#### Through Main Setup Script

```bash
# Unix systems (Mac/Linux/WSL)
./scripts/setup/env-setup.sh

# Windows
.\scripts\setup\env-setup.bat
```

#### Direct Lando Installation

```bash
# Unix systems
./scripts/setup/install-lando-docker.sh

# Windows
.\scripts\setup\install-lando-docker.bat
```

#### Wrapper-Only Setup

```bash
# Make wrapper executable and available
chmod +x scripts/setup/lando-wrapper.sh

# Add to PATH (optional)
export PATH="$PATH:$(pwd)/scripts/setup"
```

### Manual Installation Verification

#### Test Wrapper Functionality

```bash
# Test wrapper detection
./scripts/setup/lando-wrapper.sh --version

# Test Lando access through wrapper
./scripts/setup/lando-wrapper.sh info

# Test Docker integration
./scripts/setup/lando-wrapper.sh start
```

#### Verify PATH Configuration

```bash
# Check current PATH
echo $PATH

# Verify Lando detection
which lando

# Test direct Lando access (should work after wrapper setup)
lando version
```

## Usage Guide

### Basic Wrapper Usage

#### Command Syntax

```bash
# Basic wrapper usage
./scripts/setup/lando-wrapper.sh [lando-command] [options]

# Examples
./scripts/setup/lando-wrapper.sh start
./scripts/setup/lando-wrapper.sh stop
./scripts/setup/lando-wrapper.sh rebuild -y
```

#### Common Commands Through Wrapper

```bash
# Environment management
./scripts/setup/lando-wrapper.sh start
./scripts/setup/lando-wrapper.sh stop
./scripts/setup/lando-wrapper.sh restart

# Information and debugging
./scripts/setup/lando-wrapper.sh info
./scripts/setup/lando-wrapper.sh logs
./scripts/setup/lando-wrapper.sh ssh --service appserver

# Dependency management
./scripts/setup/lando-wrapper.sh composer install
./scripts/setup/lando-wrapper.sh npm install
./scripts/setup/lando-wrapper.sh php -v
```

### Integration with Project Commands

#### NPM Script Integration

The wrapper is integrated into package.json scripts:

```json
{
  "scripts": {
    "lando:start": "./scripts/setup/lando-wrapper.sh start",
    "lando:stop": "./scripts/setup/lando-wrapper.sh stop",
    "lando:rebuild": "./scripts/setup/lando-wrapper.sh rebuild -y",
    "lando:info": "./scripts/setup/lando-wrapper.sh info"
  }
}
```

Usage:

```bash
npm run lando:start
npm run lando:stop
npm run lando:rebuild
npm run lando:info
```

#### Composer Integration

The wrapper works seamlessly with Composer scripts:

```bash
# Through wrapper
./scripts/setup/lando-wrapper.sh composer install
./scripts/setup/lando-wrapper.sh composer update
./scripts/setup/lando-wrapper.sh composer test

# Direct integration (after PATH setup)
lando composer install
lando composer update
lando composer test
```

#### VS Code Integration

The wrapper is available in VS Code integrated terminal:

```bash
# Terminal commands
./scripts/setup/lando-wrapper.sh start

# Task integration (tasks.json)
{
  "label": "Lando Start",
  "type": "shell",
  "command": "./scripts/setup/lando-wrapper.sh start",
  "group": "build"
}
```

## Windows-Specific Features

### PowerShell Integration

#### PowerShell Profile Setup

```powershell
# Add to PowerShell profile
function lando {
    & ".\scripts\setup\lando-wrapper.sh" @args
}

# Usage
lando start
lando info
lando ssh --service appserver
```

#### Command Prompt Integration

```cmd
# Create batch file alias
echo @echo off > lando.bat
echo ".\scripts\setup\lando-wrapper.sh" %* >> lando.bat

# Usage
lando start
lando info
```

### Git Bash Integration

#### Bash Alias Setup

```bash
# Add to .bashrc or .bash_profile
alias lando='./scripts/setup/lando-wrapper.sh'

# Usage
lando start
lando stop
lando rebuild
```

### WSL (Windows Subsystem for Linux) Support

#### WSL Configuration

```bash
# WSL-specific PATH setup
export PATH="$PATH:/mnt/c/Users/Username/WordPress-QuickStart/scripts/setup"

# Docker Desktop integration
export DOCKER_HOST=tcp://localhost:2375

# Usage
./scripts/setup/lando-wrapper.sh start
```

#### WSL Performance Optimization

```bash
# Use WSL2 for better performance
wsl --set-version Ubuntu 2

# Mount with proper permissions
sudo mount -t drvfs C: /mnt/c -o metadata,uid=1000,gid=1000
```

## macOS-Specific Features

### Homebrew Integration

#### Homebrew Installation Detection

```bash
# Check Homebrew Lando installation
brew list lando

# Install via Homebrew (if not present)
brew install lando
```

#### System PATH Management

```bash
# Add to shell profile (.bashrc, .zshrc)
export PATH="/opt/homebrew/bin:$PATH"

# Verify installation
which lando
lando version
```

### macOS Security Considerations

#### Permission Management

```bash
# Allow downloaded executables
sudo spctl --master-disable  # Temporary, for installation only
sudo spctl --master-enable   # Re-enable after installation

# Trust specific executable
sudo xattr -dr com.apple.quarantine /usr/local/bin/lando
```

#### Keychain Integration

```bash
# Docker Desktop authentication
security find-generic-password -s docker-desktop

# Lando SSL certificate management
lando info --service=appserver --path=certificates
```

## Linux-Specific Features

### Package Manager Integration

#### APT-based Systems (Ubuntu, Debian)

```bash
# Repository setup
wget -qO - https://github.com/lando/lando/releases/download/v3.6.0/lando-v3.6.0.deb
sudo dpkg -i lando-v3.6.0.deb

# Install dependencies
sudo apt-get install -f
```

#### RPM-based Systems (CentOS, RHEL, Fedora)

```bash
# Download and install
wget https://github.com/lando/lando/releases/download/v3.6.0/lando-v3.6.0.rpm
sudo rpm -i lando-v3.6.0.rpm

# Or using DNF
sudo dnf install lando-v3.6.0.rpm
```

#### Arch-based Systems

```bash
# AUR installation
yay -S lando-bin

# Manual installation
wget https://github.com/lando/lando/releases/download/v3.6.0/lando-v3.6.0.tar.gz
tar -xzf lando-v3.6.0.tar.gz
sudo mv lando /usr/local/bin/
```

### System Service Integration

#### Docker Service Management

```bash
# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER

# Verify Docker access
docker --version
docker ps
```

#### Environment Configuration

```bash
# System-wide environment variables
echo 'export LANDO_PATH="/usr/local/bin"' | sudo tee -a /etc/environment

# User-specific configuration
echo 'export PATH="$PATH:/usr/local/bin"' >> ~/.bashrc
source ~/.bashrc
```

## Troubleshooting

### Common Issues and Solutions

#### "lando: command not found"

```bash
# Solution 1: Use wrapper directly
./scripts/setup/lando-wrapper.sh start

# Solution 2: Check PATH
echo $PATH | grep -i lando

# Solution 3: Reinstall Lando
./scripts/setup/install-lando-docker.sh
```

#### Docker Connection Issues

```bash
# Check Docker status
docker --version
docker ps

# Restart Docker service (Linux)
sudo systemctl restart docker

# Restart Docker Desktop (Windows/Mac)
# Use GUI or system tray
```

#### Permission Issues

```bash
# Fix file permissions
chmod +x scripts/setup/lando-wrapper.sh

# Fix Docker permissions (Linux)
sudo usermod -aG docker $USER
newgrp docker

# Fix ownership issues
sudo chown -R $USER:$USER .lando/
```

### Performance Issues

#### Slow Container Startup

```bash
# Check system resources
docker system df
docker system prune

# Optimize Lando configuration
lando rebuild -y

# Check for resource conflicts
lando logs
```

#### Network Configuration Issues

```bash
# Check network configuration
lando info --service=appserver --path=urls

# Reset network configuration
lando poweroff
lando start

# Check port conflicts
netstat -tulpn | grep :80
netstat -tulpn | grep :443
```

### Debug Mode and Logging

#### Enable Debug Mode

```bash
# Enable wrapper debug mode
export LANDO_WRAPPER_DEBUG=1
./scripts/setup/lando-wrapper.sh start

# Enable Lando debug mode
export LANDO_DEBUG=1
lando start
```

#### Log Analysis

```bash
# Check wrapper logs
./scripts/setup/lando-wrapper.sh --debug start

# Check Lando logs
lando logs --service=appserver
lando logs --service=database

# System logs (Linux)
journalctl -u docker.service
```

## Configuration

### Custom Installation Paths

#### Non-standard Installation Locations

```bash
# Custom Lando installation path
export LANDO_INSTALL_PATH="/opt/lando"
./scripts/setup/lando-wrapper.sh --install-path="/opt/lando"

# Custom wrapper configuration
export LANDO_WRAPPER_CONFIG_PATH="/etc/lando-wrapper"
```

#### Multiple Lando Versions

```bash
# Version-specific wrapper usage
./scripts/setup/lando-wrapper.sh --version=3.6.0 start

# Switch between versions
export LANDO_VERSION=3.6.0
./scripts/setup/lando-wrapper.sh start
```

### Integration with CI/CD

#### GitHub Actions Integration

```yaml
# .github/workflows example
- name: Setup Lando
  run: |
    chmod +x scripts/setup/lando-wrapper.sh
    ./scripts/setup/lando-wrapper.sh --version

- name: Start Lando
  run: ./scripts/setup/lando-wrapper.sh start
```

#### Docker Compose Integration

```yaml
# docker-compose.yml integration
version: '3.8'
services:
  lando-wrapper:
    build:
      context: .
      dockerfile: Dockerfile.lando-wrapper
    volumes:
      - ./scripts:/scripts
    command: ['./scripts/setup/lando-wrapper.sh', 'start']
```

### Performance Optimization

#### Resource Management

```bash
# Optimize Docker resources
docker system prune -a

# Configure Lando resource limits
# .lando.yml
services:
  appserver:
    limits:
      memory: 2g
      cpus: 2
```

#### Caching Strategies

```bash
# Enable BuildKit caching
export DOCKER_BUILDKIT=1

# Use Lando caching
lando rebuild --cache

# Optimize container layers
# Dockerfile best practices
```

## Integration with Project Workflow

### Development Lifecycle

1. **Environment Setup**: Wrapper automatically installs and configures Lando
2. **Daily Development**: Seamless Lando commands through wrapper
3. **Testing**: Wrapper ensures consistent environment across all platforms
4. **Deployment**: Wrapper supports CI/CD pipeline integration

### Team Collaboration

1. **Onboarding**: New developers get working environment immediately
2. **Consistency**: Same commands work across all team member machines
3. **Troubleshooting**: Centralized error handling and debugging
4. **Documentation**: Single source of truth for Lando usage

This Lando wrapper system ensures reliable, cross-platform WordPress development environment
management with minimal setup overhead and maximum compatibility.
