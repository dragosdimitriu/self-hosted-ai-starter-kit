# Where to Run Commands - Important!

## 🖥️ Your Setup

You're currently on a **Windows machine** (PowerShell), but your n8n server is running on a **Linux server** at IP `77.81.243.123`.

## ✅ Where Commands Should Run

**All commands must be run on your LINUX SERVER, not on your Windows machine!**

### Option 1: SSH into Your Server (Recommended)

1. **Connect to your server via SSH:**
   ```bash
   # On Windows, use PowerShell, Git Bash, or WSL
   ssh username@77.81.243.123
   # or
   ssh username@n8n.lastchance.ro
   ```

2. **Once connected to your server, navigate to the project:**
   ```bash
   cd /path/to/self-hosted-ai-starter-kit
   ```

3. **Now run the setup script:**
   ```bash
   chmod +x nginx/setup-letsencrypt-docker.sh
   ./nginx/setup-letsencrypt-docker.sh your-email@example.com
   ```

### Option 2: If You Have Direct Access to the Server

If you have physical access or remote desktop to the Linux server:
- Open a terminal on that server
- Navigate to your project directory
- Run the commands there

## 🔍 How to Check if You're on the Right Machine

**On your Linux server, run:**
```bash
# Check if Docker is installed
docker --version

# Check if docker compose is available
docker compose version

# Check if your containers are running
docker compose ps
```

If these commands work, you're on the right machine!

## 📝 Summary

- ❌ **Don't run commands on Windows** (where you're editing files)
- ✅ **Run commands on your Linux server** (where Docker is running)
- 🔐 **Use SSH** to connect to your server: `ssh user@77.81.243.123`

## 🆘 If Docker is Not on Your Server

If Docker is not installed on your Linux server, you'll need to install it first:

### Ubuntu/Debian:
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group (to run without sudo)
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt-get update
sudo apt-get install docker-compose-plugin

# Log out and back in for group changes to take effect
```

### CentOS/RHEL:
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo yum install docker-compose-plugin
```

