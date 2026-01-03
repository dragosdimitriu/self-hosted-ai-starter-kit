#!/bin/bash

# Script to renew Let's Encrypt certificate using Docker
# This should be run from cron for auto-renewal

DOMAIN="n8n.lastchance.ro"

# Get the project directory (assuming script is in nginx/ subdirectory)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR" || exit 1

# Run certbot in Docker to renew certificate
docker run --rm \
    -v "$PROJECT_DIR/nginx/ssl:/etc/letsencrypt" \
    -p 80:80 \
    certbot/certbot renew \
    --standalone \
    --non-interactive

if [ $? -eq 0 ]; then
    # Copy renewed certificates
    if [ -f "nginx/ssl/live/$DOMAIN/fullchain.pem" ]; then
        cp nginx/ssl/live/$DOMAIN/fullchain.pem nginx/ssl/cert.pem
        cp nginx/ssl/live/$DOMAIN/privkey.pem nginx/ssl/key.pem
        
        chmod 644 nginx/ssl/cert.pem
        chmod 600 nginx/ssl/key.pem
        
        # Restart nginx to load new certificate
        docker compose restart nginx
        
        echo "Certificate renewed successfully at $(date)"
    fi
fi

