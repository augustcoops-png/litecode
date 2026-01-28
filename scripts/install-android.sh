#!/data/data/com.termux/files/usr/bin/bash
# Quick installer for Codex Android nodes
# Usage: curl -fsSL https://raw.githubusercontent.com/openai/codex/main/scripts/install-android.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Codex Android Installer${NC}"
echo "========================"
echo ""

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}Error: This script must be run in Termux${NC}"
    echo "Please install Termux from F-Droid or Google Play Store"
    exit 1
fi

# Check for required dependencies
echo "Checking dependencies..."
MISSING_DEPS=""

for cmd in wget curl git; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_DEPS="$MISSING_DEPS $cmd"
    fi
done

if [ -n "$MISSING_DEPS" ]; then
    echo -e "${YELLOW}Missing dependencies:$MISSING_DEPS${NC}"
    echo "Updating package list and installing dependencies..."
    pkg update -y
    pkg install -y $MISSING_DEPS
fi

echo -e "${GREEN}✓${NC} All dependencies satisfied"
echo ""

# Prompt user for what to install
echo -e "${BLUE}What would you like to install?${NC}"
echo "1) Validator Node"
echo "2) Hosting Node"
echo "3) Both (Validator + Hosting)"
echo ""
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        INSTALL_VALIDATOR=true
        INSTALL_HOSTING=false
        ;;
    2)
        INSTALL_VALIDATOR=false
        INSTALL_HOSTING=true
        ;;
    3)
        INSTALL_VALIDATOR=true
        INSTALL_HOSTING=true
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""

# Download and run validator installer
if [ "$INSTALL_VALIDATOR" = true ]; then
    echo -e "${GREEN}Installing Validator Node...${NC}"
    SCRIPT_URL="https://raw.githubusercontent.com/openai/codex/main/scripts/install-validator-android.sh"
    TMP_SCRIPT=$(mktemp)
    
    if curl -fsSL "$SCRIPT_URL" -o "$TMP_SCRIPT"; then
        chmod +x "$TMP_SCRIPT"
        bash "$TMP_SCRIPT"
        rm "$TMP_SCRIPT"
    else
        echo -e "${RED}Failed to download validator installer${NC}"
        exit 1
    fi
    echo ""
fi

# Download and run hosting installer
if [ "$INSTALL_HOSTING" = true ]; then
    echo -e "${GREEN}Installing Hosting Node...${NC}"
    SCRIPT_URL="https://raw.githubusercontent.com/openai/codex/main/scripts/install-hosting-android.sh"
    TMP_SCRIPT=$(mktemp)
    
    if curl -fsSL "$SCRIPT_URL" -o "$TMP_SCRIPT"; then
        chmod +x "$TMP_SCRIPT"
        bash "$TMP_SCRIPT"
        rm "$TMP_SCRIPT"
    else
        echo -e "${RED}Failed to download hosting installer${NC}"
        exit 1
    fi
    echo ""
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

if [ "$INSTALL_VALIDATOR" = true ]; then
    echo "Validator Node installed. Start with:"
    echo -e "  ${YELLOW}codex-validator start${NC}"
    echo ""
fi

if [ "$INSTALL_HOSTING" = true ]; then
    echo "Hosting Node installed. Start with:"
    echo -e "  ${YELLOW}codex-hosting start${NC}"
    echo ""
fi

echo "For more information, visit:"
echo "  https://developers.openai.com/codex/android"
echo ""
echo "Need help? Check the documentation:"
echo "  https://github.com/openai/codex/blob/main/docs/android-install.md"
