#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(dirname "$(realpath "$0")")/.."
ANSIBLE_DIR="$BASE_DIR/ansible"
ENV_FILE="$BASE_DIR/.env"

echo "[*] Generating simplified Ansible project under: $ANSIBLE_DIR"

# Check for .env
if [ ! -f "$ENV_FILE" ]; then
  echo "[!] .env file not found at project root: $ENV_FILE"
  exit 1
fi

# Load variables from .env
set -a
source "$ENV_FILE"
set +a

# Clean existing ansible folder
rm -rf "$ANSIBLE_DIR"
mkdir -p "$ANSIBLE_DIR"

cd "$ANSIBLE_DIR"

# === Inventory ===
cat > hosts.yml <<EOF
---
all:
  hosts:
    vm:
      ansible_host: "$VM_SSH_HOST"
      ansible_user: "$VM_SSH_USER"
      ansible_ssh_private_key_file: "~/.ssh/id_rsa"
      ansible_port: 22
      public_ip: "$VM_PUBLIC_IP"
      private_ip: "$VM_PRIVATE_IP"
      cloudflare_token: "$CF_TUNNEL_TOKEN"
EOF

# === Main Playbook (single tasks.yml) ===
cat > tasks.yml <<'EOF'
---
- name: Configure VM (users, packages, hardening, podman, cloudflare)
  hosts: vm
  become: true
  tasks:

    - name: Update system packages
      ansible.builtin.apt:
        update_cache: yes
        upgrade: dist

    - name: Disable root SSH login
      ansible.builtin.lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^PermitRootLogin'
        line: 'PermitRootLogin no'
      notify: Restart ssh

    - name: Ensure UFW is enabled
      ansible.builtin.ufw:
        state: enabled
        default: deny

    - name: Install Podman
      ansible.builtin.package:
        name: podman
        state: present

    - name: Create admin user
      ansible.builtin.user:
        name: "admin@200630.xyz"
        shell: /bin/bash
        state: present
        create_home: yes

    - name: Create user without sudo
      ansible.builtin.user:
        name: "user@200630.xyz"
        shell: /bin/bash
        state: present
        create_home: yes

    - name: Set password for admin user
      ansible.builtin.user:
        name: "admin@200630.xyz"
        password: "{{ 'AdminPass123' | password_hash('sha512') }}"  # Adjust as needed

    - name: Set password for regular user
      ansible.builtin.user:
        name: "user@200630.xyz"
        password: "{{ 'UserPass123' | password_hash('sha512') }}"  # Adjust as needed

    - name: Add admin user to sudo group
      ansible.builtin.user:
        name: "admin@200630.xyz"
        groups: sudo
        append: yes

    - name: Download Cloudflare tunnel package
      ansible.builtin.get_url:
        url: https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
        dest: /tmp/cloudflared.deb

    - name: Install cloudflared
      ansible.builtin.apt:
        deb: /tmp/cloudflared.deb

    - name: Configure cloudflared with tunnel token
      ansible.builtin.command: >
        cloudflared service install {{ hostvars[inventory_hostname].cloudflare_token }}
      args:
        creates: /etc/systemd/system/cloudflared.service

  handlers:
    - name: Restart ssh
      ansible.builtin.service:
        name: ssh
        state: restarted
EOF

# === Config ===
cat > ansible.cfg <<'EOF'
[defaults]
inventory = hosts.yml
host_key_checking = False
retry_files_enabled = False
stdout_callback = default
result_format = yaml

[ssh_connection]
pipelining = True
EOF

echo "[*] Done! Run with: ansible-playbook tasks.yml"
