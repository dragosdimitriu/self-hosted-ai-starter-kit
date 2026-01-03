#!/bin/bash

# Docker-based Let's Encrypt setup - EASIER for beginners!
# This script runs certbot in a Docker container, so you don't need to install certbot on your host

DOMAIN="n8n.lastchance.ro"
EMAIL="${1:-your-email@example.com}"  # Pass your email as first argument

echo "=========================================="
echo "Let's Encrypt SSL Certificate Setup"
echo "Domain: $DOMAIN"
echo "Email: $EMAIL"
echo "=========================================="
echo ""
echo "This script will:"
echo "1. Stop nginx temporarily (certbot needs port 80)"
echo "2. Run certbot in a Docker container to get the certificate"
echo "3. Copy the certificate to nginx/ssl directory"
echo "4. Restart nginx"
echo ""

# Make sure we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: docker-compose.yml not found. Please run this from the project root directory."
    exit 1
fi

# Stop nginx temporarily (certbot needs port 80)
echo "Step 1: Stopping nginx container..."
docker compose stop nginx

# Create ssl directory if it doesn't exist
mkdir -p nginx/ssl

# Run certbot in a Docker container to obtain certificate
echo ""
echo "Step 2: Obtaining SSL certificate from Let's Encrypt..."
echo "This may take a minute..."
docker run --rm \
    -v "$(pwd)/nginx/ssl:/etc/letsencrypt" \
    -p 80:80 \
    certbot/certbot certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    --email "$EMAIL" \
    -d "$DOMAIN"

if [ $? -eq 0 ]; then
    echo ""
    echo "Step 3: Certificate obtained! Copying to nginx/ssl..."
    
    # Certbot stores certificates in a specific structure
    # Copy the fullchain and privkey to the expected locations
    if [ -f "nginx/ssl/live/$DOMAIN/fullchain.pem" ]; then
        cp nginx/ssl/live/$DOMAIN/fullchain.pem nginx/ssl/cert.pem
        cp nginx/ssl/live/$DOMAIN/privkey.pem nginx/ssl/key.pem
        
        # Set proper permissions
        chmod 644 nginx/ssl/cert.pem
        chmod 600 nginx/ssl/key.pem
        
        echo ""
        echo "✅ SUCCESS! Certificate is ready!"
        echo ""
        echo "Step 4: Starting nginx container..."
        docker compose start nginx
        
        echo ""
        echo "=========================================="
        echo "Setup Complete!"
        echo "=========================================="
        echo ""
        echo "You can now access n8n at: https://$DOMAIN"
        echo ""
        echo "To set up auto-renewal, add this to your crontab (crontab -e):"
        echo "  0 0 * * * cd $(pwd) && ./nginx/renew-cert-docker.sh"
        echo ""
    else
        echo "❌ Error: Certificate files not found in expected location"
        echo "Please check nginx/ssl/live/$DOMAIN/"
        exit 1
    fi
else
    echo ""
    echo "❌ Failed to obtain certificate. Please check:"
    echo "1. Domain $DOMAIN points to this server's IP"
    echo "2. Ports 80 and 443 are open in your firewall"
    echo "3. DNS has propagated (check with: nslookup $DOMAIN)"
    echo ""
    echo "Starting nginx again..."
    docker compose start nginx
    exit 1
fi

