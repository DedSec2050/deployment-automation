#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(dirname "$(realpath "$0")")/.."
ANSIBLE_DIR="$BASE_DIR/ansible"
ENV_FILE="$BASE_DIR/.env"

echo "[*] Generating Ansible project under: $ANSIBLE_DIR"

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

# === Folder structure ===
mkdir -p inventories/production/group_vars
mkdir -p inventories/staging/group_vars
mkdir -p roles/common/{tasks,handlers,templates,files,vars,defaults,meta}
mkdir -p roles/hardening/{tasks,handlers,templates,files,vars,defaults,meta}
mkdir -p roles/podman/{tasks,handlers,templates,files,vars,defaults,meta}
mkdir -p roles/cloudflare/{tasks,handlers,templates,files,vars,defaults,meta}
mkdir -p playbooks
mkdir -p library

# === Inventory files (static values from .env) ===
cat > inventories/production/hosts.yml <<EOF
---
all:
  hosts:
    vm:
      ansible_host: "$VM_PRIVATE_IP"
      ansible_user: "$VM_SSH_USER"
      ansible_ssh_private_key_file: "~/.ssh/id_rsa"
EOF

cat > inventories/staging/hosts.yml <<EOF
---
all:
  hosts:
    vm:
      ansible_host: "$VM_PRIVATE_IP"
      ansible_user: "$VM_SSH_USER"
      ansible_ssh_private_key_file: "~/.ssh/id_rsa"
EOF

# === Group vars ===
cat > inventories/production/group_vars/all.yml <<EOF
---
cloudflare:
  tunnel_token: "$CF_TUNNEL_TOKEN"

vm:
  ansible_port: 22
  podman_user: "$VM_SSH_USER"
  public_ip: "$VM_PUBLIC_IP"
  private_ip: "$VM_PRIVATE_IP"
  ssh_host: "$VM_SSH_HOST"
EOF

cat > inventories/staging/group_vars/all.yml <<EOF
---
cloudflare:
  tunnel_token: "$CF_TUNNEL_TOKEN"

vm:
  ansible_port: 22
  podman_user: "$VM_SSH_USER"
  public_ip: "$VM_PUBLIC_IP"
  private_ip: "$VM_PRIVATE_IP"
  ssh_host: "$VM_SSH_HOST"
EOF

# === Playbooks ===
cat > playbooks/site.yml <<'EOF'
---
- name: Configure VM with security hardening, Podman, and Cloudflare
  hosts: vm
  become: true
  roles:
    - role: common
    - role: hardening
    - role: podman
    - role: cloudflare
EOF

# === Requirements ===
cat > requirements.yml <<'EOF'
---
collections:
  - name: community.general
  - name: ansible.posix
roles: []
EOF

# === ansible.cfg ===
cat > ansible.cfg <<'EOF'
[defaults]
inventory = inventories/production/hosts.yml
roles_path = ./roles
collections_path = ./collections
host_key_checking = False
retry_files_enabled = False
stdout_callback = default
bin_ansible_callbacks = True
result_format = yaml

[ssh_connection]
pipelining = True

EOF

# === Role skeletons ===
cat > roles/common/tasks/main.yml <<'EOF'
---
- name: Ensure system packages are up-to-date
  ansible.builtin.apt:
    update_cache: yes
    upgrade: dist
EOF

cat > roles/hardening/tasks/main.yml <<'EOF'
---
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
EOF

cat > roles/hardening/handlers/main.yml <<'EOF'
---
- name: Restart ssh
  ansible.builtin.service:
    name: ssh
    state: restarted
EOF

cat > roles/podman/tasks/main.yml <<'EOF'
---
- name: Install Podman
  ansible.builtin.package:
    name: podman
    state: present
EOF

cat > roles/cloudflare/tasks/main.yml <<'EOF'
---
- name: Install Cloudflare tunnel
  ansible.builtin.get_url:
    url: https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    dest: /tmp/cloudflared.deb

- name: Install cloudflared package
  ansible.builtin.apt:
    deb: /tmp/cloudflared.deb

- name: Configure cloudflared with tunnel token
  ansible.builtin.command: >
    cloudflared service install {{ cloudflare.tunnel_token }}
  args:
    creates: /etc/systemd/system/cloudflared.service
EOF

echo "[*] Done! Fresh Ansible project generated at: $ANSIBLE_DIR"
