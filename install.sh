#!/usr/bin/env bash
# Bash Toolbox Installer

set -e

REPO_URL="https://github.com/ArtemRivnyi/bash-toolbox-linux-windows.git"
INSTALL_DIR="/usr/local/bin"
CONF_DIR="/etc/bash-toolbox"

echo "================================================"
echo "Installing Bash Toolbox..."
echo "================================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (or use sudo)"
  exit 1
fi

# Create a temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "Cloning repository..."
git clone -q "$REPO_URL" repo
cd repo

echo "Installing scripts to $INSTALL_DIR..."
# We assume the bash scripts have .sh extension and are in the root or a 'scripts' dir.
# Simply moving all .sh files found to the install dir.
find . -maxdepth 2 -name "*.sh" -not -name "install.sh" -exec install -m 755 {} "$INSTALL_DIR/" \;

echo "Creating configuration directory at $CONF_DIR..."
mkdir -p "$CONF_DIR"
chmod 750 "$CONF_DIR"

echo "================================================"
echo "Installation complete!"
echo "Scripts are now available in your PATH ($INSTALL_DIR)."
echo "================================================"

# Cleanup
rm -rf "$TMP_DIR"
