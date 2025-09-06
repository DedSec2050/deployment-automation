#!/bin/bash

# Check if filename argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <key_name>"
    exit 1
fi

KEY_NAME="$1"
KEY_DIR="./${KEY_NAME}"

# Create directory if it doesn't exist
mkdir -p "$KEY_DIR"

# Full path for the private key
KEY_PATH="${KEY_DIR}/${KEY_NAME}"

# Generate SSH key pair without passphrase
ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -q

echo "SSH key pair generated in folder: $KEY_DIR"
echo "Private key: ${KEY_PATH}"
echo "Public key: ${KEY_PATH}.pub"
