# ansible-net-setup


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

### **What is SMB and Why Use It?**

**SMB (Server Message Block)** is a network file sharing protocol that allows devices to access files, printers, and other shared resources on a network. It is widely supported across multiple operating systems, including Windows, macOS, and Linux.

I chose SMB over NFS because it provides better cross-platform compatibility, making it easier to set up and use in a network with diverse operating systems like mine, which includes Windows, macOS, and Linux. While NFS is often preferred in Linux-only environments, SMB simplifies integration and ensures seamless access for all devices in the network.


---

## **How the Ansible Playbook Works**

The playbook automates the following tasks on the NAS:
1. **Install Samba**: Ensures the `samba` package is installed.
2. **Create Shared Directory**: Sets up the shared folder on the NAS (`/srv/smb_shared`).
3. **Configure SMB Shares**: Updates `/etc/samba/smb.conf` to add the shared folder with the necessary settings:
   - The share is browsable and writable.
   - Guest access is enabled for simplicity.
4. **Restart Samba Service**: Ensures the `smbd` service restarts to apply the new configuration.

### **Playbook Structure**

Example Playbook (`playbooks/nas_smb_setup.yml`):
```yaml
---
- name: Setup SMB on NAS
  hosts: nas
  become: true
  tasks:
    - name: Install Samba
      apt:
        name: samba
        state: present
        update_cache: yes

    - name: Create shared directory
      file:
        path: /srv/smb_shared
        state: directory
        mode: '0777'

    - name: Configure Samba share
      blockinfile:
        path: /etc/samba/smb.conf
        block: |
          [Shared]
          path = /srv/smb_shared
          browsable = yes
          read only = no
          guest ok = yes

    - name: Restart Samba service
      service:
        name: smbd
        state: restarted
```

---

## **Ansible Inventory File**

The inventory file lists all devices that Ansible manages. For now, it defines the NAS (NASty and any others) and specifies how to connect to them.

Example Inventory (`inventory/hosts`):
```ini
[nas]
dave-nas ansible_host=xxx ansible_user=user
localhost ansible_connection=local
```

- **nas1**: A remote NAS accessible via SSH.
- **localhost**: The control node (NASty) is also configured as a managed node using `ansible_connection=local`.

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

