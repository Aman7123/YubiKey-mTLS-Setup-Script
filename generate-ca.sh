#!/bin/bash

# Set variables
key_file="ca.key"
cert_file="ca.crt"

# Generate private key
openssl genpkey -algorithm RSA -out "$key_file"

# Generate CA certificate
openssl req -new -x509 -key "$key_file" -out "$cert_file" -sha256 -days 1825

# Output success message
echo "Generated CA key and certificate successfully."
