#!/usr/bin/env bash

# Script to manage and run Ansible playbooks with status updates
set -e  # Exit immediately on any error

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

# Step 1: Ping NAS hosts to check connectivity
status "Pinging NAS hosts to verify connectivity"
if ansible -i inventory/hosts.ini -m ping NAS; then
    success "All NAS hosts are reachable"
else
    error "One or more NAS hosts are unreachable. Check your inventory or network connection"
fi

# Step 2: Run the playbook to set up SMB
status "Running the SMB server setup playbook"
if ansible-playbook -i inventory/hosts.ini playbooks/smb-serv-setup.yml; then
    success "Playbook executed successfully"
else
    error "Playbook execution failed. Check the Ansible output for details"
fi

# Step 3: Notify user that the process is complete
success "SMB server setup is complete. You're ready to use your NAS!"


