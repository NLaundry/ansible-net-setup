Here’s the updated README with the details about the scripts and their specific roles:

---

# Ansible NAS and SMB Setup

This repository contains Ansible playbooks and configuration files for automating the setup of a network-attached storage (NAS) system with SMB shares and ensuring devices in the network can discover and mount these shares easily. It’s a companion to the YouTube video on setting up and using Ansible for networked storage.

---

## **Overview**

The project aims to:
1. Configure a NAS (NASty) with SMB shares using Ansible.
2. Automate discovery and mounting of the shares on devices in the network (TODO).

---

### **Network Setup**

- **Servers**:
  - **Chuwi**: Outward-facing server hosting a website and a Minecraft server.
  - **NASty**: NAS and Ansible control node. Secured via Tailscale, no external access other than Tailnet.

- **Workstations**:
  - **microwin**: Windows PC.
  - **workstation**: Linux PC (dual boot with microwin).
  - **nathan-laptop**: macOS laptop.

- **Offsite**:
  - **dave-nas**: Offsite NAS to be configured identically to NASty.

---

## **What is SMB and Why Use It?**

**SMB (Server Message Block)** is a network file sharing protocol that allows devices to access files, printers, and other shared resources on a network. It is widely supported across multiple operating systems, including Windows, macOS, and Linux.

I chose SMB over NFS because it provides better cross-platform compatibility, making it easier to set up and use in a network with diverse operating systems like mine, which includes Windows, macOS, and Linux. While NFS is often preferred in Linux-only environments, SMB simplifies integration and ensures seamless access for all devices in the network.

---

## **How the Ansible Playbook Works**

The playbook automates the following tasks on the NAS:
1. **Install Samba and smbclient**: Ensures the necessary packages for the SMB server and testing tools are installed.
2. **Create Shared Directory**: Sets up the shared folder on the NAS (`/srv/smb_shared`).
3. **Configure SMB Shares**: Updates `/etc/samba/smb.conf` to add the shared folder with the necessary settings:
   - The share is browsable and writable.
   - Guest access is enabled for simplicity.
4. **Restart Samba Service**: Ensures the `smbd` service restarts to apply the new configuration.

---

## **Scripts Overview**

### **1. `setup.sh`**
This script installs Ansible on the control node (NASty) and verifies the installation:
- Installs Ansible via `apt`.
- Confirms the installation by running `ansible --version`.

Usage:
```bash
./setup.sh
```

---

### **2. `run.sh`**
This script performs the following actions:
1. Pings the hosts in the `NAS` group in the inventory file to verify connectivity.
2. Runs the playbook (`playbooks/smb-serv-setup.yml`) to configure SMB on all devices in the `NAS` group.

Usage:
```bash
./run.sh
```

---

### **3. `tests/smb_test.sh`**
Located in the `tests/` directory, this script verifies that SMB has been configured correctly after running the playbook. It checks:
1. Presence of the correct SMB configuration in `/etc/samba/smb.conf`.
2. Existence of the shared directory (`/srv/smb_shared`) with the correct permissions.
3. Status of the Samba service (`smbd`).
4. Availability of the SMB share on the NAS.

Usage:
```bash
./tests/smb_test.sh
```

---

## **Setup Instructions**

1. Clone this repository:
   ```bash
   git clone https://github.com/username/ansible-net-setup.git
   cd ansible-net-setup
   ```

2. Run the setup script to install Ansible:
   ```bash
   ./setup.sh
   ```

3. Configure the inventory file (`inventory/hosts.ini`) with your network details:
   ```ini
   [nas]
   localhost ansible_connection=local
   ```

4. Test connectivity to the nodes:
   ```bash
   ./run.sh
   ```

---

## **Testing SMB Setup**

After running the playbook, use the test script to ensure everything is configured correctly:
```bash
./tests/smb_test.sh
```

If any checks fail, the script will provide details about what went wrong and how to fix it.

---

## **Why Tailscale?**

[Tailscale](https://tailscale.com/) is a zero-config, mesh VPN that simplifies secure networking. It’s core to this setup because:
- NASty and Dave-NAS are only accessible via Tailnet, ensuring no direct exposure to the public internet.
- Tailnet creates a secure, private network linking all devices (servers, workstations, and offsite NAS).
- Facilitates seamless and secure connectivity, even for offsite devices like Dave-NAS.

---

## **Why Ansible?**

Ansible is used to streamline and automate the configuration of SMB shares and their discovery across the network. Key benefits include:

- **Efficiency**: Configurations for NASty and Dave-NAS are nearly identical, so Ansible saves time by applying the same playbooks to both.
- **Consistency**: Ensures every device in the network can discover and mount NAS shares with a single command.
- **Convenience for Tinkering**: Frequent distro-hopping or VM setups benefit from Ansible by enabling quick, automated configuration of SMB access.

---

## **TODO**
1. Write and integrate playbooks to automate:
   - Discovering SMB shares from other devices in the network.
   - Mounting shares on:
     - Windows PCs (microwin).
     - Linux workstations.
     - macOS laptops.

2. Extend the playbooks to include additional network services as needed.

