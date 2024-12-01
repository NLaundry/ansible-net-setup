#!/usr/bin/bash

# SMB Testing Script
SHARE_NAME="Shared"
SHARE_PATH="/srv/smb_shared"
SMB_CONF="/etc/samba/smb.conf"
HOST="localhost"

# Colors for output
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
NC="\033[0m" # No color

# Function to display status messages
status() {
    echo -e "${BLUE}$1${NC}"
}

success() {
    echo -e "${GREEN}✔ $1${NC}"
}

error() {
    echo -e "${RED}✘ $1${NC}"
}

# 1. Check if the Samba configuration block exists
status "Checking Samba configuration..."
if grep -q "\[${SHARE_NAME}\]" "$SMB_CONF"; then
    success "Samba configuration block for '${SHARE_NAME}' exists."
else
    error "Samba configuration block for '${SHARE_NAME}' not found in $SMB_CONF."
    exit 1
fi

# 2. Check if the shared directory exists
status "Checking shared directory..."
if [[ -d "$SHARE_PATH" ]]; then
    success "Shared directory '${SHARE_PATH}' exists."
else
    error "Shared directory '${SHARE_PATH}' does not exist."
    exit 1
fi

# 3. Check if the Samba service is running
status "Checking Samba service..."
if systemctl is-active --quiet smbd; then
    success "Samba service is running."
else
    error "Samba service is not running."
    exit 1
fi

# 4. Test listing available SMB shares
status "Testing SMB shares..."
if smbclient -L "$HOST" -N >/dev/null 2>&1; then
    success "SMB shares are accessible on ${HOST}."
else
    error "Failed to list SMB shares on ${HOST}."
    exit 1
fi

# 5. Test connecting to the shared directory
status "Checking SHARED dir is created"
if smbclient -L "//${HOST}" -N | grep -q "${SHARE_NAME}"; then
    success "Successfully found the '${SHARE_NAME}' share on ${HOST}."
else
    error "Failed to find the '${SHARE_NAME}' share on ${HOST}."
    exit 1
fi

# Final success message
success "SMB setup is working correctly!"

