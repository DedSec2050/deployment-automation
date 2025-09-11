#!/bin/bash

# Colors
GREEN="\033[0;32m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

# Check if filename argument is provided
if [ -z "$1" ]; then
    echo -e "${RED}❌ Usage:${RESET} $0 <key_name>"
    exit 1
fi

KEY_NAME="$1"
KEY_DIR="./${KEY_NAME}.key"

# Create directory if it doesn't exist
mkdir -p "$KEY_DIR"

# Full path for the private key
KEY_PATH="${KEY_DIR}/${KEY_NAME}.key"

# Generate SSH key pair without passphrase
ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -q

echo -e "${GREEN}✅ SSH key pair generated successfully!${RESET}"
echo -e "${CYAN}📂 Folder: ${RESET}${KEY_DIR}"
echo -e "${YELLOW}🔑 Private key: ${RESET}${KEY_PATH}"
echo -e "${YELLOW}🪪  Public key:  ${RESET}${KEY_PATH}.pub"
