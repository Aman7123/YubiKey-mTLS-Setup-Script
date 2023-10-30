# YubiKey Setup Script in NGINX mTLS Environment

## Introduction
This script is designed to automate the setup process of a YubiKey device for use within a mutual TLS (mTLS) environment managed by NGINX. mTLS is a secure communication protocol where both the client and server authenticate each other before establishing a connection. In this setup, the YubiKey device serves as a hardware security module (HSM) to securely store and handle cryptographic keys and certificates.

The script performs the following operations:
1. Initialize necessary variables and prompt the user for custom or default Personal Identification Number (PIN), Personal Unblocking Key (PUK), and Management Key values.
2. Change the PIN, PUK, and Management Key on the YubiKey to user-specified or default values.
3. Adjust the retry settings for the PIN and PUK.
4. Generate an elliptic curve key pair on the YubiKey.
5. Create a Certificate Signing Request (CSR) for the generated key pair.
6. Sign the CSR using a specified Certificate Authority (CA).
7. Import the signed certificate back into the YubiKey.
8. Optionally, clean up temporary files generated during the process.

The resulting setup facilitates the YubiKey's use as a client certificate in an mTLS environment, enhancing security by ensuring only authorized clients can establish connections to the server.

## Prerequisites
- YubiKey Manager (`ykman`) installed.
- OpenSSL installed.
- A Certificate Authority (CA) certificate and key.
  - The provided `generate_ca.sh` script can be used to generate a CA certificate and key.
- NGINX configured to support mTLS.

## Usage

1. Ensure you CA file locations and subject name in the script.
2. Save the script to a file, e.g., `setup_yubikey.sh`.
3. Make the script executable: `chmod +x setup_yubikey.sh`.
4. Run the script: `./setup_yubikey.sh`.
5. Follow the on-screen prompts to provide or accept default values for the PIN, PUK, and Management Key.
6. Once the script completes, your YubiKey is ready for use in the NGINX mTLS environment.

## Integration with NGINX for mTLS

For mTLS in NGINX, client certificates are verified against a trusted certificate authority. The configured YubiKey now holds a client certificate signed by a trusted CA. To set up mTLS in NGINX, follow these steps:

1. Update your NGINX configuration to require client certificates for a particular location or server:
```nginx
server {
    ...
    ssl_client_certificate /path/to/ca.crt;
    ssl_verify_client on;
    ...
}
```
2. Reload or restart NGINX to apply the changes.
3. Now, when accessing the secured endpoint, the client will need to present the certificate stored on the YubiKey.

This README provides a general understanding of the script's operation and its usage within an NGINX mTLS setup. Ensure to adjust file paths and other configurations to match your environment.