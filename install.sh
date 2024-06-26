#!/bin/bash

# Default paths
SCRIPT_DIR="$(dirname "$0")"
CONFIG_DIR="/etc/ssendmail"
BIN_DIR="/usr/local/bin"
INSTALL_DIR="/opt/ssendmail"

# Help function
show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help                   Show this help message and exit."
    echo "  --config-dir [path]          Set the directory for configuration files. Default: ${CONFIG_DIR}"
    echo "  --bin-dir [path]             Set the directory for symlink binary files. Default: ${BIN_DIR}"
    echo "  --install-dir [path]         Set the directory for installation files. Default: ${INSTALL_DIR}"
    echo "  --uninstall                  Uninstall scripts and optionally remove config files."
    exit 0
}

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

# Check dependency (mailsend-go)
check_dependency() {
    if ! command -v mailsend-go &> /dev/null; then
        echo "Error: mailsend-go is not installed."
        echo "Please install mailsend-go!"
        exit 1
    fi
}

# Uninstall function
uninstall() {
    echo "Uninstalling scripts..."
    rm -f "${BIN_DIR}/ssendmail.sh"
    rm -f "${INSTALL_DIR}/ssendmail.sh"

    # Removing sample config files
    echo "Removing sample config files..."
    rm -f "${CONFIG_DIR}"/*.sample

    # Option to remove other files
    read -p "Do you want to remove non-sample config files? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing non-sample config files..."
        find "${CONFIG_DIR}" -type f -delete
    fi

    # Remove directory if empty
    rmdir "${CONFIG_DIR}" 2>/dev/null

    echo "Uninstallation completed."
}

# Function to check if files exist and ask if they should be overwritten
check_and_copy_files() {
    local exist_files=()
    if [[ -f "${INSTALL_DIR}/ssendmail.sh" ]]; then
        exist_files+=("ssendmail.sh")
    fi

    if [[ ${#exist_files[@]} -ne 0 ]]; then
        echo "The following files already exist in the target directory: ${exist_files[@]}"
        read -p "Do you want to overwrite these files? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "${SCRIPT_DIR}/ssendmail.sh" "${INSTALL_DIR}/"
        fi
    else
        cp "${SCRIPT_DIR}/ssendmail.sh" "${INSTALL_DIR}/"
    fi

    ln -sf "${INSTALL_DIR}/ssendmail.sh" "${BIN_DIR}/ssendmail.sh"
}

# Process arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help) show_help ;;
        --config-dir) CONFIG_DIR="$2"; shift 2 ;;
        --bin-dir) BIN_DIR="$2"; shift 2 ;;
        --install-dir) INSTALL_DIR="$2"; shift 2 ;;
        --uninstall) uninstall; exit 0 ;;
        *) echo "Unknown option: $1"; show_help ;;
    esac
    shift
done

# Display summary and ask for confirmation
echo "Installation configuration:"
echo "  Configuration files will be copied to: ${CONFIG_DIR}"
echo "  Binary files will be installed to: ${INSTALL_DIR}"
echo "  Symlinks for binary files will be created in: ${BIN_DIR}"
echo
read -p "Do you want to continue with the installation? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 1
fi

# Check dependency
echo "Checking dependencies..."
check_dependency

# Perform installation
echo "Starting installation..."

# Create necessary directories
mkdir -p "${CONFIG_DIR}" || { echo "Failed to create config directory."; exit 1; }
mkdir -p "${INSTALL_DIR}" || { echo "Failed to create install directory."; exit 1; }

# Copy scripts
check_and_copy_files

# Copy sample configuration and secret files
cp "${SCRIPT_DIR}/config/example.config" "${CONFIG_DIR}/" || { echo "Failed to copy config files."; exit 1; }

# Set permissions
chmod 600 "${CONFIG_DIR}"/* || { echo "Failed to set permissions on config files."; exit 1; }
chmod +x "${INSTALL_DIR}/ssendmail.sh" || { echo "Failed to set execute permission on ssendmail.sh."; exit 1; }

echo "Installation completed."
