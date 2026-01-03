#!/bin/bash

# Script to generate self-signed SSL certificate for n8n
# This is for development/testing. For production, use Let's Encrypt.

SSL_DIR="./nginx/ssl"
DOMAIN_OR_IP="${1:-n8n.lastchance.ro}"

echo "Generating self-signed SSL certificate for $DOMAIN_OR_IP..."
echo "Note: This creates a self-signed certificate. Browsers will show a security warning."
echo "For production use, consider using Let's Encrypt with a domain name."

# Create SSL directory if it doesn't exist
mkdir -p "$SSL_DIR"

# Generate private key
openssl genrsa -out "$SSL_DIR/key.pem" 2048

# Detect if it's an IP address or domain name
if [[ $DOMAIN_OR_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    # It's an IP address
    SAN="IP:$DOMAIN_OR_IP"
else
    # It's a domain name
    SAN="DNS:$DOMAIN_OR_IP"
fi

# Generate certificate signing request
openssl req -new -key "$SSL_DIR/key.pem" -out "$SSL_DIR/cert.csr" \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=$DOMAIN_OR_IP"

# Generate self-signed certificate (valid for 365 days)
openssl x509 -req -days 365 -in "$SSL_DIR/cert.csr" -signkey "$SSL_DIR/key.pem" \
  -out "$SSL_DIR/cert.pem" \
  -extensions v3_req \
  -extfile <(echo "[v3_req]"; echo "subjectAltName=$SAN")

# Clean up CSR file
rm "$SSL_DIR/cert.csr"

# Set proper permissions
chmod 600 "$SSL_DIR/key.pem"
chmod 644 "$SSL_DIR/cert.pem"

echo ""
echo "SSL certificate generated successfully!"
echo "Certificate: $SSL_DIR/cert.pem"
echo "Private Key: $SSL_DIR/key.pem"
echo ""
echo "You can now start the services with: docker compose up -d"

