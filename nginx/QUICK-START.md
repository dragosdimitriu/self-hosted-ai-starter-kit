# Quick Start Guide: HTTPS Setup for n8n

## 🎯 Where Do I Run Commands?

**IMPORTANT:** All commands below are run on your **HOST MACHINE** (your server), NOT inside Docker containers!

- ✅ Run commands in your terminal/SSH session on the server
- ❌ Do NOT SSH into containers
- ✅ The `nginx/ssl` folder on your host is automatically shared with the nginx container

## 📋 Step-by-Step Setup

### Step 1: Verify DNS is Working

First, make sure your domain points to your server:

```bash
# On your HOST machine (not in a container)
nslookup n8n.lastchance.ro
# or
ping n8n.lastchance.ro
```

You should see your server IP (77.81.243.123).

### Step 2: Choose Your Method

#### Option A: Docker-Based Setup (EASIEST - Recommended for Beginners)

This uses certbot in a Docker container, so you don't need to install anything on your host:

```bash
# On your HOST machine
cd /path/to/self-hosted-ai-starter-kit
chmod +x nginx/setup-letsencrypt-docker.sh
./nginx/setup-letsencrypt-docker.sh your-email@example.com
```

Replace `your-email@example.com` with your actual email.

**What this does:**
1. Stops nginx temporarily
2. Runs certbot in a Docker container
3. Gets the SSL certificate
4. Copies it to `nginx/ssl/` folder (which nginx container can access)
5. Restarts nginx

#### Option B: Host-Based Setup (Requires certbot on host)

If you prefer to install certbot directly on your server:

```bash
# 1. Install certbot on your HOST machine
sudo apt-get update
sudo apt-get install certbot  # Ubuntu/Debian
# or
sudo yum install certbot      # CentOS/RHEL

# 2. Stop nginx
docker compose stop nginx

# 3. Get certificate (runs on HOST, not in container)
sudo certbot certonly --standalone -d n8n.lastchance.ro --email your-email@example.com --agree-tos

# 4. Copy certificates to nginx/ssl (accessible by nginx container)
mkdir -p nginx/ssl
sudo cp /etc/letsencrypt/live/n8n.lastchance.ro/fullchain.pem nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/n8n.lastchance.ro/privkey.pem nginx/ssl/key.pem
sudo chmod 644 nginx/ssl/cert.pem
sudo chmod 600 nginx/ssl/key.pem
sudo chown $USER:$USER nginx/ssl/cert.pem nginx/ssl/key.pem

# 5. Start nginx
docker compose start nginx
```

### Step 3: Start All Services

```bash
# On your HOST machine
docker compose up -d
```

### Step 4: Access n8n

Open your browser and go to: **https://n8n.lastchance.ro**

You should see a secure connection with a valid certificate! 🔒

## 🔄 Auto-Renewal Setup

Certificates expire every 90 days. Set up auto-renewal:

### For Docker-based setup:

```bash
# Edit crontab
crontab -e

# Add this line (runs daily at midnight)
0 0 * * * cd /path/to/self-hosted-ai-starter-kit && ./nginx/renew-cert-docker.sh >> /var/log/certbot-renew.log 2>&1
```

### For host-based setup:

```bash
# Edit crontab
crontab -e

# Add this line
0 0 * * * certbot renew --quiet && docker compose -f /path/to/self-hosted-ai-starter-kit/docker-compose.yml restart nginx
```

## 🗂️ How It Works (Simple Explanation)

```
┌─────────────────────────────────────────┐
│  Your Server (HOST MACHINE)              │
│                                          │
│  ┌──────────────┐                       │
│  │ nginx/ssl/   │ ← Certificates stored  │
│  │   cert.pem   │   here on HOST         │
│  │   key.pem    │                        │
│  └──────┬───────┘                       │
│         │ (shared via volume)            │
│         ▼                               │
│  ┌──────────────┐                       │
│  │ nginx        │ ← Container reads     │
│  │ container    │   certificates from   │
│  │              │   nginx/ssl/ folder   │
│  └──────────────┘                       │
│         │                                │
│         ▼                                │
│  Ports 80 & 443 → Internet              │
└─────────────────────────────────────────┘
```

- Certificates are stored in `nginx/ssl/` on your **HOST machine**
- Docker Compose shares this folder with the nginx container (see `volumes:` in docker-compose.yml)
- nginx container reads the certificates from the shared folder
- You run certbot commands on the **HOST**, and it writes to `nginx/ssl/`

## ❓ Common Questions

**Q: Do I SSH into the nginx container?**  
A: No! Run all commands on your host machine.

**Q: Where are certificates stored?**  
A: In `nginx/ssl/` folder on your host machine (automatically shared with nginx container).

**Q: Do I need to install certbot on my host?**  
A: Only if using Option B. Option A uses certbot in Docker, so no installation needed.

**Q: What if I get "port 80 already in use"?**  
A: Make sure nginx is stopped: `docker compose stop nginx`

## 🆘 Troubleshooting

**Certificate not found:**
```bash
# Check if files exist
ls -la nginx/ssl/
```

**nginx can't read certificate:**
```bash
# Check permissions
chmod 644 nginx/ssl/cert.pem
chmod 600 nginx/ssl/key.pem
```

**Check nginx logs:**
```bash
docker compose logs nginx
```

