#!/data/data/com.termux/files/usr/bin/bash
# Installation script for Codex Hosting Node on Android (Termux)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Codex Hosting Node - Android Installation${NC}"
echo "=========================================="
echo ""

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}Error: This script must be run in Termux${NC}"
    exit 1
fi

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    aarch64)
        BINARY="codex-hosting-aarch64-linux-android.tar.gz"
        ;;
    armv7l|armv8l)
        BINARY="codex-hosting-armv7-linux-android.tar.gz"
        ;;
    *)
        echo -e "${RED}Error: Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

echo "Detected architecture: $ARCH"
echo "Binary to download: $BINARY"
echo ""

# Check for required dependencies
echo "Checking dependencies..."
MISSING_DEPS=""

for cmd in wget tar; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_DEPS="$MISSING_DEPS $cmd"
    fi
done

if [ -n "$MISSING_DEPS" ]; then
    echo -e "${YELLOW}Missing dependencies:$MISSING_DEPS${NC}"
    echo "Installing dependencies..."
    pkg install -y $MISSING_DEPS
fi

echo -e "${GREEN}✓${NC} All dependencies satisfied"
echo ""

# Download the binary
echo "Downloading Codex Hosting Node..."
echo -e "${YELLOW}Note: For enhanced security, verify checksums from the release page${NC}"
DOWNLOAD_URL="https://github.com/openai/codex/releases/latest/download/$BINARY"
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

if ! wget -q --show-progress "$DOWNLOAD_URL"; then
    echo -e "${RED}Error: Failed to download binary${NC}"
    echo "URL: $DOWNLOAD_URL"
    rm -rf "$TMP_DIR"
    exit 1
fi

echo -e "${GREEN}✓${NC} Download complete"
echo ""

# Extract the archive
echo "Extracting archive..."
tar -xzf "$BINARY"

# Find the extracted binary
EXTRACTED_BINARY=$(find . -name "codex-hosting*" -type f ! -name "*.tar.gz" | head -1)

if [ -z "$EXTRACTED_BINARY" ]; then
    echo -e "${RED}Error: Could not find extracted binary${NC}"
    rm -rf "$TMP_DIR"
    exit 1
fi

# Make executable and move to bin directory
chmod +x "$EXTRACTED_BINARY"
mv "$EXTRACTED_BINARY" "$PREFIX/bin/codex-hosting"

echo -e "${GREEN}✓${NC} Installation complete"
echo ""

# Clean up
cd - > /dev/null
rm -rf "$TMP_DIR"

# Create default configuration
CONFIG_DIR="$HOME/.codex"
CONFIG_FILE="$CONFIG_DIR/hosting-config.json"
STORAGE_DIR="$CONFIG_DIR/storage"

mkdir -p "$CONFIG_DIR"
mkdir -p "$CONFIG_DIR/log"
mkdir -p "$STORAGE_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating default configuration..."
    cat > "$CONFIG_FILE" << EOF
{
  "port": 8081,
  "storageDir": "$STORAGE_DIR",
  "maxFileSize": 104857600,
  "allowedOrigins": ["*"],
  "logLevel": "info",
  "logFile": "$CONFIG_DIR/log/hosting.log"
}
EOF
    echo -e "${GREEN}✓${NC} Configuration created at $CONFIG_FILE"
    echo -e "${YELLOW}Security Note: allowedOrigins is set to '*' for development.${NC}"
    echo -e "${YELLOW}For production, restrict to trusted origins in $CONFIG_FILE${NC}"
else
    echo -e "${YELLOW}Configuration already exists at $CONFIG_FILE${NC}"
fi

echo ""
echo -e "${GREEN}Installation successful!${NC}"
echo ""
echo "To verify installation, run:"
echo "  codex-hosting --version"
echo ""
echo "To start the hosting node, run:"
echo "  codex-hosting start"
echo ""
echo "Configuration file: $CONFIG_FILE"
echo "Storage directory: $STORAGE_DIR"
echo "Log file: $CONFIG_DIR/log/hosting.log"
