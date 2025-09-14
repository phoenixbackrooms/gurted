#!/bin/bash

# Gurted Server Setup Script
# Run this on a fresh Ubuntu 24.04 server

set -Eeuo pipefail
IFS=$'\n\t'

echo "Setting up your Gurted server..."

# Basic security and updates
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl ufw wget tar

# Create gurted user and directories
sudo useradd --system --create-home --shell /bin/bash gurted || true
sudo mkdir -p /home/gurted/{bin,mysite,config}
sudo chown -R gurted:gurted /home/gurted

# Setup basic firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 4878/tcp
sudo ufw allow 4878/udp
sudo ufw --force enable

echo "📦 Downloading Gurty and GurtCA..."
cd /tmp
LATEST_RELEASE=$(curl -s https://api.github.com/repos/phoenixbackrooms/gurted-unofficial/releases/latest | grep "tag_name" | cut -d '"' -f 4)
DOWNLOAD_URL="https://github.com/phoenixbackrooms/gurted-unofficial/releases/download/${LATEST_RELEASE}/gurted-tools-linux.tar.gz"
echo "Downloading from: $DOWNLOAD_URL"
wget -O gurted-tools-linux.tar.gz "$DOWNLOAD_URL"
tar -xzf gurted-tools-linux.tar.gz
sudo mv gurty gurtca /home/gurted/bin/
sudo chmod +x /home/gurted/bin/*
sudo chown -R gurted:gurted /home/gurted/bin
sudo mkdir -p /var/log/gurty
sudo touch /var/log/gurty/{access.log,error.log}
sudo chown -R gurted:gurted /var/log/gurty


# Create systemd service
sudo tee /etc/systemd/system/gurted.service > /dev/null <<EOF
[Unit]
Description=Gurted Server
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=gurted
Group=gurted
WorkingDirectory=/home/gurted
ExecStart=/home/gurted/bin/gurty serve --dir /home/gurted/mysite --config /home/gurted/config/gurty.toml
Restart=always
RestartSec=5
StartLimitIntervalSec=300
StartLimitBurst=10
UMask=0027

NoNewPrivileges=true
PrivateTmp=true
PrivateDevices=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=/home/gurted /var/log/gurty
ProtectClock=true
ProtectHostname=true
ProtectKernelLogs=true
ProtectKernelModules=true
ProtectKernelTunables=true
LockPersonality=true
RestrictRealtime=true
RestrictSUIDSGID=true
RestrictNamespaces=true
SystemCallArchitectures=native
SystemCallFilter=@system-service
RestrictAddressFamilies=AF_UNIX AF_INET AF_INET6
ProcSubset=pid
ProtectProc=invisible
CapabilityBoundingSet=
AmbientCapabilities=

[Install]
WantedBy=multi-user.target
EOF

# Basic config file
sudo -u gurted tee /home/gurted/config/gurty.toml > /dev/null <<EOF
[server]
host = "0.0.0.0"
port = 4878
protocol_version = "1.0.0"
alpn_identifier = "GURT/1.0"
max_connections = 10
max_message_size = "10MB"

[server.timeouts]
handshake = 5
request = 30
connection = 10
pool_idle = 300

[tls]
certificate = "/home/gurted/config/localhost+2.pem"
private_key = "/home/gurted/config/localhost+2-key.pem"

[logging]
level = "info"
access_log = "/var/log/gurty/access.log"
error_log = "/var/log/gurty/error.log"
log_requests = true
log_responses = false

[security]
deny_files = [
    "*.env",
    "*.config", 
    ".git/*",
    "node_modules/*",
    "*.key",
    "*.pem",
    "*.crt"
]

allowed_methods = ["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS", "PATCH"]
rate_limit_requests = 100  # requests per minute
rate_limit_connections = 1000  # concurrent connections per IP

# Error pages configuration
[error_pages]
# Specific error pages (uncomment and set paths to custom files)
# "400" = "/errors/400.html"
# "401" = "/errors/401.html"
# "403" = "/errors/403.html"
# "404" = "/errors/404.html"
# "405" = "/errors/405.html"
# "429" = "/errors/429.html"
# "500" = "/errors/500.html"
# "503" = "/errors/503.html"

[error_pages.default]
"400" = '''<!DOCTYPE html>
<html><head><title>400 Bad Request</title></head>
<body><h1>400 - Bad Request</h1><p>The request could not be understood by the server.</p><a href="/">Back to home</a></body></html>'''

[headers]
server = "GURT/1.0.0"
"x-frame-options" = "SAMEORIGIN"
"x-content-type-options" = "nosniff"
EOF

# basic starter page

sudo -u gurted tee /home/gurted/mysite/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Gurted tutorial</title>
    <meta name="description" content="This is the example page for the tutorial from gurt://is-a-clank.er">
    <style>
        body {
            bg-indigo-950
            text-sky-500
            font-sans
        }
        .outbox {
            p-8
        }
        h1 {
            text-sky-500
            font-sans
            text-center
        }
    </style>
</head>
<body>
    <div style="outbox">
        <h1>Hello world</h1>
        <p>This is my first page on gurted!</p>
    </div>
</body>
</html>
EOF

echo "✅ Basic setup complete!"
echo ""
echo "Next steps:"
echo "Continue following the guide at gurt://is-a-clank.er/docs/server-setup.html"
