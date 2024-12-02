#!/bin/bash

# Function to display status messages
status() {
    echo -e "\n\033[1;34m$1...\033[0m"  # Bold blue text for status updates
}

# Function to display success messages
success() {
    echo -e "\033[1;32m✔ $1\033[0m"  # Green text for success messages
}

# Function to display error messages
error() {
    echo -e "\033[1;31m✘ $1\033[0m"  # Red text for errors
    exit 1
}

# Step 1: Display available disks
status "Fetching available disks"
DISKS_LIST=$(lsblk -dpno NAME,SIZE | grep -E '/dev/sd|/dev/nvme')

if [ -z "$DISKS_LIST" ]; then
    error "No available disks found. Ensure disks are connected and try again."
fi

echo -e "Available disks:"
echo "$DISKS_LIST"
echo

# Step 2: Select the disks for your zpool
status "Select the disks for your zpool"
echo "Enter the disk identifiers for the ZFS pool (e.g., sda sdb):"
read -p "Disks: " SHORT_DISKS

# Validate input
if [ -z "$SHORT_DISKS" ]; then
    error "No disks provided. Exiting."
fi

# Convert disk identifiers to full paths
status "Converting disk identifiers to full paths"
DISKS=""
for short_disk in $SHORT_DISKS; do
    if echo "$DISKS_LIST" | grep -q "/dev/$short_disk"; then
        DISKS="$DISKS /dev/$short_disk"
    else
        error "Invalid disk identifier: $short_disk. Please try again."
    fi
done

# Step 3: Create or overwrite the vars.yml file
status "Writing selected disks to vars/disks.yml"
VARS_FILE="./vars/disks.yml"
mkdir -p ./vars
echo "zfs_disks:" > "$VARS_FILE"
for disk in $DISKS; do
    echo "  - $disk" >> "$VARS_FILE"
done

success "Disks configuration saved to $VARS_FILE:"
cat "$VARS_FILE"
echo

# Final message
success "Setup complete! Run the Ansible playbook to configure the ZFS pool."

