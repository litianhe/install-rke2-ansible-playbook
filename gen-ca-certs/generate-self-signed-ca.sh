#!/bin/bash

# Get the current directory of the script
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Current Directory: $CURRENT_DIR"

# Generate a timestamp for logging or unique naming
TIMESTAMP=$(date +%s)
echo "Timestamp: $TIMESTAMP"

# Set the product name, default to 'k3s' if not specified
PRODUCT="${PRODUCT:-k3s}"
echo "Product: $PRODUCT"

# Set the data directory path, default to '/var/lib/rancher/{PRODUCT}' if not specified
DATA_DIR="${DATA_DIR:-/var/lib/rancher/${PRODUCT}}"
echo "Data Directory: $DATA_DIR"

# Create the necessary directory structure for TLS certificates
mkdir -p "${DATA_DIR}/server/tls"
echo "Created Directory: ${DATA_DIR}/server/tls"

# Copy the root CA and intermediate CA configuration files to the TLS directory
cp ${CURRENT_DIR}/root-ca.conf    "${DATA_DIR}/server/tls/"
echo "Copied root-ca.conf to ${DATA_DIR}/server/tls/"
cp ${CURRENT_DIR}/intermediate-ca.conf   "${DATA_DIR}/server/tls/"
echo "Copied intermediate-ca.conf to ${DATA_DIR}/server/tls/"

# Change to the TLS directory to perform subsequent operations
cd "${DATA_DIR}/server/tls"
echo "Changed to Directory: ${DATA_DIR}/server/tls"

# ROOT CA Operations
## Generate Root CA Key
# Generate a 4096-bit RSA key for the root CA
openssl genrsa -out root-ca.key 4096 2>/dev/null
echo "Generated Root CA Key: root-ca.key"

## Generate Root CA Certificate
# Generate a self-signed certificate for the root CA, valid for 3650 days
openssl req -x509 -new -nodes -sha512 -days 3650 -key root-ca.key -out root-ca.pem -config root-ca.conf -extensions v3_ca
echo "Generated Root CA Certificate: root-ca.pem"

## Generate Root CA Serial Number
# Generate a random serial number for the root CA
# mkdir -p ".ca/certs"
# touch .ca/index
# openssl rand -hex 8 > .ca/serial
# echo "Generated Root CA Serial Number: $(cat .ca/serial)"

# Intermediate CA Operations
## Generate intermediate CA Key
# Generate a 4096-bit RSA key for the intermediate CA
openssl genrsa -out intermediate-ca.key 4096 2>/dev/null
echo "Generated Intermediate CA Key: intermediate-ca.key"

# Generate intermediate CA Certificate signed by Root CA
openssl req -new -key intermediate-ca.key -out intermediate-ca.csr -config intermediate-ca.conf -extensions v3_ca
openssl x509 -req -in intermediate-ca.csr -CA root-ca.pem -CAkey root-ca.key -CAcreateserial -out intermediate-ca.pem -days 3700 -extfile intermediate-ca.conf -extensions v3_ca
echo "Generated Intermediate CA Certificate signed by root CA: intermediate-ca.pem"

# Verify the intermediate CA certificate
openssl verify -CAfile root-ca.pem intermediate-ca.pem
echo "Verified Intermediate CA Certificate signed by root CA: PASS"

rm -f  "${DATA_DIR}/server/tls/root-ca.conf"
rm -f  "${DATA_DIR}/server/tls/intermediate-ca.conf"

echo "Done!"