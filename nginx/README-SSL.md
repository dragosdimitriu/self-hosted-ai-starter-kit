# SSL Certificate Setup for n8n HTTPS

This guide explains how to set up SSL certificates for n8n to enable HTTPS access.

**Domain:** `n8n.lastchance.ro`

## Option 1: Let's Encrypt (Recommended for Production)

Since you have a domain name (`n8n.lastchance.ro`), Let's Encrypt is the recommended option for free, trusted SSL certificates.

### Prerequisites:
- Domain `n8n.lastchance.ro` points to your server IP (77.81.243.123)
- Ports 80 and 443 open and accessible from the internet
- Certbot installed on your host machine

### Quick Setup (Choose One):

#### Option A: Docker-Based (EASIEST - No Installation Required)

This uses certbot in a Docker container - perfect for beginners!

```bash
chmod +x nginx/setup-letsencrypt-docker.sh
./nginx/setup-letsencrypt-docker.sh your-email@example.com
```

**Note:** All commands run on your **HOST MACHINE**, not inside containers. See `QUICK-START.md` for detailed explanation.

#### Option B: Host-Based (Requires certbot on host)

```bash
chmod +x nginx/setup-letsencrypt.sh
./nginx/setup-letsencrypt.sh your-email@example.com
```

Replace `your-email@example.com` with your actual email address.

2. **Start the services:**
   ```bash
   docker compose up -d
   ```

### Manual Setup:

1. **Install Certbot on your host machine:**
   ```bash
   # On Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install certbot
   
   # On CentOS/RHEL
   sudo yum install certbot
   ```

2. **Stop nginx temporarily:**
   ```bash
   docker compose stop nginx
   ```

3. **Obtain certificate:**
   ```bash
   sudo certbot certonly --standalone -d n8n.lastchance.ro --email your-email@example.com --agree-tos
   ```

4. **Copy certificates to nginx/ssl directory:**
   ```bash
   mkdir -p nginx/ssl
   sudo cp /etc/letsencrypt/live/n8n.lastchance.ro/fullchain.pem nginx/ssl/cert.pem
   sudo cp /etc/letsencrypt/live/n8n.lastchance.ro/privkey.pem nginx/ssl/key.pem
   sudo chmod 644 nginx/ssl/cert.pem
   sudo chmod 600 nginx/ssl/key.pem
   sudo chown $USER:$USER nginx/ssl/cert.pem nginx/ssl/key.pem
   ```

5. **Start the services:**
   ```bash
   docker compose up -d
   ```

6. **Set up auto-renewal:**
   ```bash
   # Add to crontab (crontab -e)
   0 0 * * * certbot renew --quiet && docker compose restart nginx
   ```

## Option 2: Self-Signed Certificate (Development/Testing Only)

Self-signed certificates are suitable for development and testing. Browsers will show a security warning.

### On Linux/macOS/WSL:

```bash
chmod +x nginx/generate-ssl-cert.sh
./nginx/generate-ssl-cert.sh n8n.lastchance.ro
```

### On Windows:

1. **Using Git Bash or WSL:**
   ```bash
   chmod +x nginx/generate-ssl-cert.sh
   ./nginx/generate-ssl-cert.sh n8n.lastchance.ro
   ```

2. **Using OpenSSL for Windows:**
   - Download OpenSSL for Windows from https://slproweb.com/products/Win32OpenSSL.html
   - Then run the commands manually:
   ```bash
   cd nginx/ssl
   openssl genrsa -out key.pem 2048
   openssl req -new -key key.pem -out cert.csr -subj "/CN=n8n.lastchance.ro"
   openssl x509 -req -days 365 -in cert.csr -signkey key.pem -out cert.pem -extensions v3_req -extfile <(echo "[v3_req]"; echo "subjectAltName=DNS:n8n.lastchance.ro")
   del cert.csr
   ```

## Option 3: Using Existing Certificates

If you already have SSL certificates:

1. Copy your certificate file to `nginx/ssl/cert.pem`
2. Copy your private key to `nginx/ssl/key.pem`
3. Ensure proper permissions:
   ```bash
   chmod 644 nginx/ssl/cert.pem
   chmod 600 nginx/ssl/key.pem
   ```

## After Certificate Setup

1. **Start the services:**
   ```bash
   docker compose up -d
   ```

2. **Access n8n via HTTPS:**
   - With Let's Encrypt: `https://n8n.lastchance.ro` (trusted certificate, no warnings)
   - With self-signed: `https://n8n.lastchance.ro` (accept the security warning)

3. **Verify nginx is running:**
   ```bash
   docker compose logs nginx
   ```

## Troubleshooting

### Certificate errors:
- Ensure `nginx/ssl/cert.pem` and `nginx/ssl/key.pem` exist
- Check file permissions (key should be 600, cert should be 644)
- Verify certificate is not expired

### Connection refused:
- Check if ports 80 and 443 are open in your firewall
- Verify nginx container is running: `docker compose ps`

### Browser security warning (self-signed):
- This is expected with self-signed certificates
- Click "Advanced" → "Proceed to site" (or similar)
- For production, use Let's Encrypt certificates

## Updating the Domain

If you need to change the domain name, update:
1. `docker-compose.yml` - `N8N_HOST` environment variable (or set it in `.env` file)
2. `nginx/nginx.conf` - `server_name` directive
3. Regenerate certificates with the new domain name

