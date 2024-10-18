#!/bin/bash

# Script to generate AES symmetric key and IV (overwrite existing files)

SECRET_KEY_FILE="secret.key"
IV_FILE="iv.txt"

# Generate the AES symmetric key (32 bytes for AES-256) in hex format
echo "Generating AES symmetric key (will overwrite existing key)..."
openssl rand -hex 32 > "$SECRET_KEY_FILE"

if [[ $? -ne 0 ]]; then
    echo "Failed to generate symmetric key."
    exit 1
fi

echo "AES symmetric key saved to $SECRET_KEY_FILE."

# Generate the IV (16 bytes for AES) in hex format
echo "Generating Initialization Vector (IV) (will overwrite existing IV)..."
openssl rand -hex 16 > "$IV_FILE"

if [[ $? -ne 0 ]]; then
    echo "Failed to generate IV."
    exit 1
fi

echo "IV saved to $IV_FILE."

chmod 600 "$SECRET_KEY_FILE" "$IV_FILE"

# Copy the generated key and IV to the victim directory
cp "$SECRET_KEY_FILE" victim/ && cp "$IV_FILE" victim/
