#!/bin/bash
# close_port.sh - Close macOS firewall for Polly server
set -e

PORT="${1:-4567}"
ANCHOR_NAME="com.apple/allow_${PORT}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[Polly Firewall]${NC} Closing port ${PORT}..."

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW}This script requires sudo privileges.${NC}"
   exec sudo "$0" "$@"
fi

# Step 1: Flush the rules from the anchor
echo "[1/2] Removing firewall rule for port ${PORT}..."
pfctl -a "${ANCHOR_NAME}" -F rules 2>/dev/null || true

# Step 2: Optionally re-block Ruby in Application Firewall
# Note: We don't re-block by default as user may want Ruby accessible for other purposes
echo "[2/2] Firewall rule removed"

echo ""
echo -e "${GREEN}✓ Port ${PORT} is now closed${NC}"
echo ""
echo "  Note: Ruby remains allowed in Application Firewall."
echo "  To also block Ruby, run:"
echo "    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --blockapp \$(rbenv which ruby)"
echo ""
