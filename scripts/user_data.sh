#!/usr/bin/env bash
set -euo pipefail

#-----Log everything to a file for debugging-----
exec > >(tee /var/log/user_data.log | logger -t user_data) 2>&1
echo "==> user_data.sh started: $(date)"

#-----1. System update and base packages-----
echo "==> Updating system packages"
apt-get update -y
apt-get upgrade -y
apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    nginx \
    default-mysql-client \
    git \
    curl \
    unzip

#-----2. Create app user and directory-----
echo "==> Creating app user and directory"
useradd -m -s /bin/bash appuser || true
mkdir -p /opt/app
chown appuser:appuser /opt/app

#-----3. Clone the application code-----
echo "==> Cloning application code"
git clone https://github.com/Zubair-624/aws-dynamic-website-ec2-rds-cloudfront.git /opt/app/repo
chown -R appuser:appuser /opt/app/repo

#-----4. Set up Python virtual environment-----
echo "==> Setting up Python virtual environment"
python3 -m venv /opt/app/venv
/opt/app/venv/bin/pip install --upgrade pip
/opt/app/venv/bin/pip install -r /opt/app/repo/website/requirements.txt

#-----5. Create systemd service for Flask-----
echo "==> Creating Flask systemd service"
cat > /etc/systemd/system/flask-app.service << 'EOF'
[Unit]
Description=Flask Web Application
After=network.target

[Service]
User=appuser
WorkingDirectory=/opt/app/repo/website
Environment="FLASK_APP=server.py"
Environment="FLASK_ENV=production"
ExecStart=/opt/app/venv/bin/python server.py
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

#-----6. Configure Nginx-----
echo "==> Configuring Nginx"
cat > /etc/nginx/sites-available/flask-app << 'EOF'
server {
    listen 80;
    server_name _;

    # Forward all requests to Flask on port 5000
    location / {
        proxy_pass         http://127.0.0.1:5000;
        proxy_set_header   Host $host;
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_read_timeout 60s;
        proxy_connect_timeout 10s;
    }
}
EOF

# Enable the site and remove default
ln -sf /etc/nginx/sites-available/flask-app /etc/nginx/sites-enabled/flask-app
rm -f /etc/nginx/sites-enabled/default

# Test Nginx config
nginx -t

#-----7. Enable and start services-----
echo "==> Starting services"
systemctl daemon-reload
systemctl enable flask-app
systemctl start flask-app
systemctl enable nginx
systemctl restart nginx

#-----8. Done-----
echo "==> user_data.sh completed successfully: $(date)"
echo "==> Flask running on port 5000"
echo "==> Nginx forwarding port 80 → 5000"
