import os
import json

# Directory to search
current_dir = os.getcwd()

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

# Extract the IP addresses
outputs = data.get("outputs", {})
public_ip = outputs.get("vm_public_ip", {}).get("value")
private_ip = outputs.get("vm_private_ip", {}).get("value")

if public_ip:
    print(f"VM Public IP: {public_ip}")
else:
    print("vm_public_ip not found.")

if private_ip:
    print(f"VM Private IP: {private_ip}")
else:
    print("vm_private_ip not found.")
