
#!/bin/bash

# Exit on error
set -e

# Variables
APP_NAME="Zalo"
INSTALL_DIR="$HOME/.local/share/$APP_NAME"
DESKTOP_FILE="$HOME/.local/share/applications/${APP_NAME}.desktop"
ICON_PATH="$INSTALL_DIR/assets/Zalo.png"
START_SCRIPT="$INSTALL_DIR/start.sh"
TMP_DIR="/tmp/zalo-installer"
VENV_DIR="$INSTALL_DIR/venv"

# Step 1: Install dependencies
echo "Installing Python3, pip, pystray, and Pillow..."
if command -v apt &>/dev/null; then # Debian/Ubuntu
    sudo apt update
    sudo apt install -y python3 python3-pip python3-venv unzip wget
elif command -v dnf &>/dev/null; then  # Fedora/RHEL/CentOS
    sudo dnf install -y python3 python3-pip python3-venv unzip wget
elif command -v pacman &>/dev/null; then  # Arch Linux
    sudo pacman -Sy --noconfirm python python-pip python-venv unzip wget
else
    echo "Unsupported package manager. Install Python 3, pip, python3-venv, unzip, and wget manually."
    exit 1
fi

# Step 1.1: Create virtual environment and install Python packages
echo "Creating virtual environment and installing Python packages..."
python3 -m venv "$VENV_DIR"
"$VENV_DIR/bin/pip" install pystray pillow

# Step 2: Create install directory and copy files
echo "Copying files to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp -r ./* "$INSTALL_DIR"

# Step 2.1: Download and extract Electron
echo "Downloading Electron..."
mkdir -p "$TMP_DIR"
ELECTRON_VERSION="v22.3.27"
ELECTRON_ZIP="electron-${ELECTRON_VERSION}-linux-x64.zip"
ELECTRON_URL="https://github.com/electron/electron/releases/download/${ELECTRON_VERSION}/${ELECTRON_ZIP}"

wget "$ELECTRON_URL" -P "$TMP_DIR"
unzip "$TMP_DIR/$ELECTRON_ZIP" -d "$TMP_DIR/electron"
rm "$TMP_DIR/$ELECTRON_ZIP"
cp -r "$TMP_DIR/electron" "$INSTALL_DIR/electron"
chmod +x "$INSTALL_DIR/electron/electron"

# Step 2.2: Update start.sh to use virtual environment
echo "Updating start script to use virtual environment..."
cat <<EOF > "$START_SCRIPT"
#!/bin/bash
cd "$INSTALL_DIR"
source "$VENV_DIR/bin/activate"
python3 main.py
EOF

# Step 3: Create desktop shortcut
echo "Creating desktop shortcut..."
mkdir -p "$(dirname "$DESKTOP_FILE")"
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=$APP_NAME
Comment=Launch $APP_NAME
Exec=bash $START_SCRIPT
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Utility;
EOF

# Step 4: Make scripts executable and update desktop database
chmod +x "$DESKTOP_FILE"
# chmod +x "$UNINSTALL_SCRIPT"
chmod +x "$START_SCRIPT"
update-desktop-database "$(dirname "$DESKTOP_FILE")" || true

echo "$APP_NAME installed successfully!"

echo "Virtual environment created at: $VENV_DIR"