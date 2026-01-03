#!/bin/bash

# Script to set up Let's Encrypt SSL certificate for n8n.lastchance.ro
# This script should be run on the host machine (not inside Docker)

DOMAIN="n8n.lastchance.ro"
EMAIL="${1:-your-email@example.com}"  # Pass your email as first argument

echo "Setting up Let's Encrypt SSL certificate for $DOMAIN"
echo "Email: $EMAIL"
echo ""

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Certbot is not installed. Installing..."
    
    # Detect OS and install certbot
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y certbot
        elif command -v yum &> /dev/null; then
            sudo yum install -y certbot
        else
            echo "Please install certbot manually for your distribution"
            exit 1
        fi
    else
        echo "Please install certbot manually for your OS"
        exit 1
    fi
fi

# Make sure nginx is stopped temporarily for standalone mode
echo "Stopping nginx container temporarily..."
docker compose stop nginx

# Obtain certificate using standalone mode
echo "Obtaining SSL certificate from Let's Encrypt..."
sudo certbot certonly --standalone \
    -d "$DOMAIN" \
    --email "$EMAIL" \
    --agree-tos \
    --non-interactive \
    --preferred-challenges http

if [ $? -eq 0 ]; then
    echo ""
    echo "Certificate obtained successfully!"
    
    # Create ssl directory if it doesn't exist
    mkdir -p nginx/ssl
    
    # Copy certificates
    echo "Copying certificates to nginx/ssl directory..."
    sudo cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem nginx/ssl/cert.pem
    sudo cp /etc/letsencrypt/live/$DOMAIN/privkey.pem nginx/ssl/key.pem
    
    # Set proper permissions
    sudo chmod 644 nginx/ssl/cert.pem
    sudo chmod 600 nginx/ssl/key.pem
    sudo chown $USER:$USER nginx/ssl/cert.pem nginx/ssl/key.pem
    
    echo ""
    echo "Certificates copied successfully!"
    echo ""
    echo "You can now start the services with:"
    echo "  docker compose up -d"
    echo ""
    echo "To set up auto-renewal, add this to your crontab (crontab -e):"
    echo "  0 0 * * * certbot renew --quiet && docker compose restart nginx"
    
    # Start nginx again
    echo ""
    echo "Starting nginx container..."
    docker compose start nginx
else
    echo ""
    echo "Failed to obtain certificate. Please check:"
    echo "1. Domain $DOMAIN points to this server's IP"
    echo "2. Ports 80 and 443 are open in your firewall"
    echo "3. No other service is using port 80"
    exit 1
fi

