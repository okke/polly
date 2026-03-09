#!/bin/bash
# open_port.sh - Open macOS firewall for Polly server
set -e

PORT="${1:-4567}"
ANCHOR_NAME="com.apple/allow_${PORT}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[Polly Firewall]${NC} Opening port ${PORT}..."

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW}This script requires sudo privileges.${NC}"
   exec sudo "$0" "$@"
fi

# Step 1: Enable packet filter if not already enabled
echo "[1/3] Enabling packet filter..."
pfctl -E 2>/dev/null || true

# Step 2: Add rule to allow incoming TCP on the port
echo "[2/3] Adding firewall rule for port ${PORT}..."
echo "pass in proto tcp from any to any port ${PORT}" | pfctl -a "${ANCHOR_NAME}" -f -

# Step 3: Handle Application Firewall (ALF) for Ruby
echo "[3/3] Configuring Application Firewall for Ruby..."

# Find Ruby executable (supports rbenv, asdf, system ruby)
RUBY_PATH=""
if command -v rbenv &> /dev/null; then
    RUBY_PATH="$(rbenv which ruby 2>/dev/null || true)"
fi

if [[ -z "$RUBY_PATH" ]] && command -v asdf &> /dev/null; then
    RUBY_PATH="$(asdf which ruby 2>/dev/null || true)"
fi

if [[ -z "$RUBY_PATH" ]]; then
    RUBY_PATH="$(which ruby 2>/dev/null || true)"
fi

if [[ -n "$RUBY_PATH" && -f "$RUBY_PATH" ]]; then
    echo "    Found Ruby at: ${RUBY_PATH}"
    /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp "$RUBY_PATH" 2>/dev/null || true
    /usr/libexec/ApplicationFirewall/socketfilterfw --add "$RUBY_PATH" 2>/dev/null || true
    echo "    Ruby unblocked in Application Firewall"
else
    echo -e "${YELLOW}    Warning: Could not find Ruby executable${NC}"
fi

# Also handle puma if it exists as a separate binary
PUMA_PATH=""
if command -v rbenv &> /dev/null; then
    PUMA_PATH="$(rbenv which puma 2>/dev/null || true)"
fi

if [[ -n "$PUMA_PATH" && -f "$PUMA_PATH" ]]; then
    echo "    Found Puma at: ${PUMA_PATH}"
    /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp "$PUMA_PATH" 2>/dev/null || true
    /usr/libexec/ApplicationFirewall/socketfilterfw --add "$PUMA_PATH" 2>/dev/null || true
    echo "    Puma unblocked in Application Firewall"
fi

echo ""
echo -e "${GREEN}✓ Firewall opened for port ${PORT}${NC}"
echo ""
echo "  Make sure your server binds to 0.0.0.0 (not 127.0.0.1)"
echo "  Participants can connect via: http://\$(ipconfig getifaddr en0):${PORT}"
echo ""
