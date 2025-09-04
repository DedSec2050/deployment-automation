import os
import json

# Paths
current_dir = os.getcwd()
ansible_env_file = os.path.join(current_dir, "ansible", ".env")

# First, check if there is an "azure" folder in the current directory.
azure_dir = os.path.join(current_dir, "azure")
if os.path.isdir(azure_dir):
    directory = azure_dir
else:
    # If not, check one level up.
    parent_dir = os.path.dirname(current_dir)
    azure_dir = os.path.join(parent_dir, "azure")
    if os.path.isdir(azure_dir):
        directory = azure_dir
    else:
        # Fallback to the current directory if "azure" folder isn't found.
        directory = current_dir

print(f"Searching in directory: {directory}")

# Search for the terraform.tfstate.backup file
file_path = None
for root, dirs, files in os.walk(directory):
    if "terraform.tfstate.backup" in files:
        file_path = os.path.join(root, "terraform.tfstate.backup")
        break

if not file_path:
    print("terraform.tfstate.backup file not found.")
    exit(1)

# Read and parse the JSON file
with open(file_path, "r") as f:
    data = json.load(f)

# Extract the outputs
outputs = data.get("outputs", {})
public_ip = outputs.get("vm_public_ip", {}).get("value")
private_ip = outputs.get("vm_private_ip", {}).get("value")
ssh_conn   = outputs.get("ssh_connection_string", {}).get("value")

# Prepare environment variables
env_vars = {}

if public_ip:
    env_vars["VM_PUBLIC_IP"] = str(public_ip)
else:
    print("vm_public_ip not found.")

if private_ip:
    env_vars["VM_PRIVATE_IP"] = str(private_ip)
else:
    print("vm_private_ip not found.")

if ssh_conn:
    ssh_parts = ssh_conn.strip().split()
    if len(ssh_parts) == 2 and "@" in ssh_parts[1]:
        user = ssh_parts[1].split("@")[0]
        host = ssh_parts[1].split("@")[1]
        env_vars["VM_SSH_USER"] = user
        env_vars["VM_SSH_HOST"] = host
    else:
        print("Unexpected format in ssh_connection_string")
else:
    print("ssh_connection_string not found.")

# Write .env file inside ./ansible
os.makedirs(os.path.dirname(ansible_env_file), exist_ok=True)
with open(ansible_env_file, "w") as f:
    for key, value in env_vars.items():
        f.write(f"{key}={value}\n")

print(f".env file written to {ansible_env_file}")
