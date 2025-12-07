#!/bin/bash

################################################################################
# Podman Rootless Diagnostics Script
# 
# This script runs comprehensive diagnostics for Podman in rootless mode and
# interprets the results to help identify configuration issues.
#
# Usage: ./podman-diagnostics.sh
################################################################################

set -o pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNING=0

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((TESTS_FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠ WARN${NC}: $1"
    ((TESTS_WARNING++))
}

print_info() {
    echo -e "${BLUE}ℹ INFO${NC}: $1"
}

################################################################################
# System Information
################################################################################

check_system_info() {
    print_header "System Information"
    
    # OS Information
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        print_info "OS: $PRETTY_NAME"
        print_info "Kernel: $(uname -r)"
    else
        print_warning "Could not determine OS information"
    fi
    
    # Architecture
    print_info "Architecture: $(uname -m)"
    print_info "Hostname: $(hostname)"
    print_info "Current User: $(whoami) (UID: $(id -u), GID: $(id -g))"
}

################################################################################
# Podman Installation Check
################################################################################

check_podman_installation() {
    print_header "Podman Installation"
    
    if command -v podman &> /dev/null; then
        local version=$(podman version --format '{{.Client.Version}}')
        print_pass "Podman is installed (v$version)"
        
        # Check podman-remote
        if command -v podman-remote &> /dev/null; then
            print_pass "podman-remote is available"
        else
            print_warning "podman-remote is not available"
        fi
    else
        print_fail "Podman is not installed or not in PATH"
        return 1
    fi
}

################################################################################
# User Namespace Check
################################################################################

check_user_namespace() {
    print_header "User Namespace Support"
    
    # Check if user namespaces are enabled in the kernel
    if [ -f /proc/sys/kernel/unprivileged_userns_clone ]; then
        local userns_clone=$(cat /proc/sys/kernel/unprivileged_userns_clone)
        if [ "$userns_clone" -eq 1 ]; then
            print_pass "Unprivileged user namespaces are enabled"
        else
            print_fail "Unprivileged user namespaces are disabled (kernel.unprivileged_userns_clone=0)"
            print_info "To enable: sudo sysctl kernel.unprivileged_userns_clone=1"
        fi
    else
        print_warning "Cannot determine unprivileged_userns_clone status"
    fi
    
    # Check cgroup version
    if [ -f /proc/cgroups ]; then
        if grep -q "cgroup2" /proc/filesystems; then
            print_pass "cgroup v2 is available"
        else
            print_warning "cgroup v2 is not available (cgroup v1 mode)"
        fi
    fi
}

################################################################################
# User ID Range Check (subuid/subgid)
################################################################################

check_subid_ranges() {
    print_header "Subuid/Subgid Configuration"
    
    local current_user=$(whoami)
    local uid=$(id -u)
    
    # Check subuid
    if grep -q "^$current_user:" /etc/subuid 2>/dev/null; then
        local subuid=$(grep "^$current_user:" /etc/subuid)
        print_pass "subuid entry exists: $subuid"
    else
        print_fail "No subuid entry found for user $current_user"
        print_info "To add: sudo usermod --add-subuids 100000-165535 $current_user"
    fi
    
    # Check subgid
    if grep -q "^$current_user:" /etc/subgid 2>/dev/null; then
        local subgid=$(grep "^$current_user:" /etc/subgid)
        print_pass "subgid entry exists: $subgid"
    else
        print_fail "No subgid entry found for user $current_user"
        print_info "To add: sudo usermod --add-subgids 100000-165535 $current_user"
    fi
}

################################################################################
# systemd User Session
################################################################################

check_systemd_user_session() {
    print_header "systemd User Session"
    
    # Check if systemd is running for the user
    if systemctl --user is-active --quiet; then
        print_pass "systemd user session is active"
    else
        print_warning "systemd user session is not active"
        print_info "To start: systemctl --user start"
    fi
    
    # Check XDG_RUNTIME_DIR
    if [ -n "$XDG_RUNTIME_DIR" ]; then
        print_pass "XDG_RUNTIME_DIR is set: $XDG_RUNTIME_DIR"
        if [ -d "$XDG_RUNTIME_DIR" ]; then
            print_pass "XDG_RUNTIME_DIR exists and is accessible"
        else
            print_fail "XDG_RUNTIME_DIR does not exist or is not accessible"
        fi
    else
        print_fail "XDG_RUNTIME_DIR is not set"
        print_info "This should be set by systemd or login manager"
    fi
    
    # Check DBUS_SESSION_BUS_ADDRESS
    if [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
        print_pass "DBUS_SESSION_BUS_ADDRESS is set"
    else
        print_warning "DBUS_SESSION_BUS_ADDRESS is not set"
    fi
}

################################################################################
# Storage Configuration
################################################################################

check_storage_configuration() {
    print_header "Storage Configuration"
    
    local storage_conf="$HOME/.config/containers/storage.conf"
    
    if [ -f "$storage_conf" ]; then
        print_pass "storage.conf exists at $storage_conf"
        print_info "Storage configuration:"
        sed 's/^/  /' "$storage_conf"
    else
        print_warning "storage.conf not found at $storage_conf"
        print_info "Using default storage configuration"
    fi
    
    # Check storage directory
    local storage_root="$HOME/.local/share/containers/storage"
    if [ -d "$storage_root" ]; then
        print_pass "Storage root directory exists: $storage_root"
        local storage_size=$(du -sh "$storage_root" 2>/dev/null | cut -f1)
        print_info "Storage size: $storage_size"
    else
        print_info "Storage root directory not yet created (will be created on first use)"
    fi
}

################################################################################
# Podman Configuration
################################################################################

check_podman_configuration() {
    print_header "Podman Configuration"
    
    local podman_conf="$HOME/.config/containers/podman/podman.conf"
    
    if [ -f "$podman_conf" ]; then
        print_pass "podman.conf exists at $podman_conf"
    else
        print_info "podman.conf not found (using defaults)"
    fi
    
    # Check registries configuration
    local registries_conf="$HOME/.config/containers/registries.conf"
    if [ -f "$registries_conf" ]; then
        print_pass "registries.conf exists at $registries_conf"
    else
        print_warning "registries.conf not found (system-wide config may be in use)"
    fi
}

################################################################################
# Network Configuration
################################################################################

check_network_configuration() {
    print_header "Network Configuration"
    
    # Check slirp4netns
    if command -v slirp4netns &> /dev/null; then
        local slirp_version=$(slirp4netns --version 2>&1 | head -n1)
        print_pass "slirp4netns is installed: $slirp_version"
    else
        print_warning "slirp4netns is not installed (required for network in rootless mode)"
        print_info "To install: sudo apt-get install slirp4netns (Debian/Ubuntu)"
    fi
    
    # Check netavark
    if command -v netavark &> /dev/null; then
        print_pass "netavark is available (newer network stack)"
    else
        print_warning "netavark is not available"
    fi
    
    # Check cni plugins
    local cni_plugin_dirs=("$HOME/.config/cni/net.d" "/etc/cni/net.d" "/usr/lib/cni" "/usr/libexec/cni")
    local cni_found=0
    for dir in "${cni_plugin_dirs[@]}"; do
        if [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
            print_pass "CNI plugins found in $dir"
            cni_found=1
        fi
    done
    
    if [ $cni_found -eq 0 ]; then
        print_warning "No CNI plugins found in standard locations"
    fi
}

################################################################################
# Podman Rootless Mode
################################################################################

check_rootless_mode() {
    print_header "Rootless Mode Check"
    
    if podman info --format '{{.Host.Security.Rootless}}' 2>/dev/null | grep -q true; then
        print_pass "Podman is running in rootless mode"
    else
        print_fail "Podman is not running in rootless mode"
    fi
}

################################################################################
# Podman Service/Socket
################################################################################

check_podman_service() {
    print_header "Podman Service/Socket"
    
    # Check if user podman socket exists
    local socket_path="$XDG_RUNTIME_DIR/podman/podman.sock"
    if [ -S "$socket_path" ] 2>/dev/null; then
        print_pass "Podman socket exists at $socket_path"
    else
        print_info "Podman socket does not yet exist (will be created when podman is run)"
    fi
    
    # Check systemd service
    if systemctl --user list-unit-files | grep -q podman-rootless-setup; then
        print_info "podman-rootless-setup service is available"
    fi
}

################################################################################
# Container Runtime
################################################################################

check_runtime() {
    print_header "Container Runtime"
    
    # Check for runc
    if command -v runc &> /dev/null; then
        local runc_version=$(runc --version 2>&1 | head -n1)
        print_pass "runc is installed: $runc_version"
    else
        print_warning "runc is not found (may use crun instead)"
    fi
    
    # Check for crun
    if command -v crun &> /dev/null; then
        local crun_version=$(crun --version 2>&1 | head -n1)
        print_pass "crun is installed: $crun_version"
    else
        print_info "crun is not installed"
    fi
}

################################################################################
# Functional Tests
################################################################################

check_functional_tests() {
    print_header "Functional Tests"
    
    # Test 1: Check if podman can run a simple command
    print_info "Testing basic podman functionality..."
    if podman run --rm alpine echo "Hello from Podman" &>/dev/null; then
        print_pass "Podman can successfully run containers"
    else
        print_fail "Podman cannot run containers"
        print_info "Error output: $(podman run --rm alpine echo 'test' 2>&1)"
    fi
    
    # Test 2: Check podman info
    print_info "Testing podman info..."
    if podman info &>/dev/null; then
        print_pass "podman info command works"
    else
        print_fail "podman info command failed"
    fi
    
    # Test 3: Check image operations
    print_info "Testing image operations..."
    if podman image list &>/dev/null; then
        print_pass "Image listing works"
    else
        print_fail "Image listing failed"
    fi
}

################################################################################
# Security Configuration
################################################################################

check_security_configuration() {
    print_header "Security Configuration"
    
    # Check seccomp support
    if podman info --format '{{.Host.Security.Seccomp}}' 2>/dev/null | grep -q true; then
        print_pass "Seccomp support is enabled"
    else
        print_warning "Seccomp support may be disabled"
    fi
    
    # Check SELinux
    if command -v getenforce &> /dev/null; then
        local selinux_status=$(getenforce 2>/dev/null || echo "Disabled")
        if [ "$selinux_status" != "Disabled" ]; then
            print_info "SELinux is $selinux_status"
        else
            print_info "SELinux is not enabled"
        fi
    fi
    
    # Check AppArmor
    if [ -d /sys/kernel/security/apparmor ]; then
        print_info "AppArmor is available"
    fi
}

################################################################################
# Permissions Check
################################################################################

check_permissions() {
    print_header "Permissions and File Access"
    
    # Check home directory permissions
    local home_perms=$(stat -c %a "$HOME" 2>/dev/null || stat -f %OLp "$HOME" 2>/dev/null)
    print_info "Home directory permissions: $home_perms"
    
    # Check .config directory
    local config_dir="$HOME/.config"
    if [ -d "$config_dir" ]; then
        local config_perms=$(stat -c %a "$config_dir" 2>/dev/null || stat -f %OLp "$config_dir" 2>/dev/null)
        print_info ".config directory permissions: $config_perms"
    fi
    
    # Check .local directory
    local local_dir="$HOME/.local"
    if [ -d "$local_dir" ]; then
        local local_perms=$(stat -c %a "$local_dir" 2>/dev/null || stat -f %OLp "$local_dir" 2>/dev/null)
        print_info ".local directory permissions: $local_perms"
    fi
}

################################################################################
# Environment Variables
################################################################################

check_environment_variables() {
    print_header "Environment Variables"
    
    print_info "Key environment variables:"
    echo "  PODMAN_USERNS=host: $PODMAN_USERNS"
    echo "  PODMAN_IGNORE_CGROUPSV2_WARNING: $PODMAN_IGNORE_CGROUPSV2_WARNING"
    echo "  TMPDIR: $TMPDIR"
    echo "  TEMP: $TEMP"
    echo "  TMP: $TMP"
    echo "  XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
    echo "  XDG_CONFIG_HOME: ${XDG_CONFIG_HOME:-not set (defaults to ~/.config)}"
    echo "  XDG_DATA_HOME: ${XDG_DATA_HOME:-not set (defaults to ~/.local/share)}"
}

################################################################################
# Summary Report
################################################################################

print_summary() {
    print_header "Diagnostic Summary"
    
    local total=$((TESTS_PASSED + TESTS_FAILED + TESTS_WARNING))
    
    echo -e "Total Checks: $total"
    echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
    echo -e "  ${YELLOW}Warnings: $TESTS_WARNING${NC}"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "\n${GREEN}✓ All critical tests passed!${NC}"
        if [ $TESTS_WARNING -gt 0 ]; then
            echo -e "${YELLOW}⚠ Review warnings above for optimal configuration${NC}"
        fi
    else
        echo -e "\n${RED}✗ Some tests failed. Please review the issues above.${NC}"
    fi
    
    echo -e "\n${BLUE}Additional Resources:${NC}"
    echo "  - https://podman.io/docs"
    echo "  - https://podman.io/docs/installation/linux/rootless"
    echo "  - https://wiki.archlinux.org/title/Podman"
}

################################################################################
# Main Execution
################################################################################

main() {
    echo -e "${BLUE}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════╗
║     Podman Rootless Diagnostics Tool                  ║
║     Generated: 2025-12-07 06:37:38 UTC                ║
╚═══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    # Run all checks
    check_system_info
    check_podman_installation || exit 1
    check_user_namespace
    check_subid_ranges
    check_systemd_user_session
    check_storage_configuration
    check_podman_configuration
    check_network_configuration
    check_rootless_mode
    check_podman_service
    check_runtime
    check_security_configuration
    check_permissions
    check_environment_variables
    check_functional_tests
    
    # Print summary
    print_summary
}

# Run main function
main "$@"
