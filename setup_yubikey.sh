#!/bin/bash

# Initialize variables
SUBJECT_NAME="Your Name"
CA_CERT_PATH="./ca.crt"
CA_KEY_PATH="./ca.key"

# Prompt for custom default values or use the known defaults
read -p "Do you have a custom default PIN? (y/n) " custom_default_pin
if [[ $custom_default_pin == "y" || $custom_default_pin == "Y" ]]; then
    read -p "Enter your custom default PIN: " DEFAULT_PIN
else
    DEFAULT_PIN="123456"
fi

read -p "Do you have a custom default PUK? (y/n) " custom_default_puk
if [[ $custom_default_puk == "y" || $custom_default_puk == "Y" ]]; then
    read -p "Enter your custom default PUK: " DEFAULT_PUK
else
    DEFAULT_PUK="12345678"
fi

read -p "Do you have a custom default Management Key? (y/n) " custom_default_mgmt_key
if [[ $custom_default_mgmt_key == "y" || $custom_default_mgmt_key == "Y" ]]; then
    read -p "Enter your custom default Management Key: " DEFAULT_MGM_KEY
else
    DEFAULT_MGM_KEY="0102030405060708010203040506070801020304050607080102030405060708"
fi

# Prompt for new values
read -p "Enter your new PIN: " NEW_PIN
read -p "Enter your new PUK: " NEW_PUK
read -p "Enter your new Management Key: " NEW_MGM_KEY

# Change the PIN
printf "$DEFAULT_PIN\n$NEW_PIN\n$NEW_PIN\n" | ykman piv access change-pin

# Change the PUK
printf "$DEFAULT_PUK\n$NEW_PUK\n$NEW_PUK\n" | ykman piv access change-puk

# Change the Management Key
if [[ $DEFAULT_MGM_KEY == "0102030405060708010203040506070801020304050607080102030405060708" ]]; then
    { echo; echo "$NEW_MGM_KEY"; echo "$NEW_MGM_KEY"; } | ykman piv access change-management-key
else
    printf "$DEFAULT_MGM_KEY\n$NEW_MGM_KEY\n$NEW_MGM_KEY\n" | ykman piv access change-management-key
fi

# Change default tries
printf "$NEW_MGM_KEY\n$NEW_PIN\ny\n" | ykman piv access set-retries 25 25

# Re-reset PIN and PUK
printf "123456\n$NEW_PIN\n$NEW_PIN\n" | ykman piv access change-pin
printf "12345678\n$NEW_PUK\n$NEW_PUK\n" | ykman piv access change-puk

# Generate a key pair on the YubiKey
printf "$NEW_MGM_KEY\n" | ykman piv keys generate --algorithm ECCP256 9a pubkey.pem

# Generate a Certificate Signing Request (CSR)
printf "$NEW_PUK\n" | ykman piv certificates request 9a pubkey.pem csr.pem -s "$SUBJECT_NAME"

# Sign the CSR with your CA
openssl x509 -req -days 365 -in csr.pem -CA "$CA_CERT_PATH" -CAkey "$CA_KEY_PATH" -CAcreateserial -out user_cert.pem

# Import the signed certificate back into the YubiKey
printf "$NEW_MGM_KEY\n" | ykman piv certificates import 9a user_cert.pem

# Optional: Clean up the temporary files
rm -f pubkey.pem csr.pem user_cert.pem

echo "YubiKey setup complete."
