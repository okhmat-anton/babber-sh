#!/bin/bash

# === SETUP FOR SOCKET BABBER ===

echo "[1/11] Installing system packages..."
sudo yum update -y
sudo yum install -y git make docker

echo "[2/11] Cloning the repository with SSH..."
read -p "Enter full SSH repo URL (e.g. git@github.com:user/repo.git): " REPO_URL
cd /home/ec2-user
git clone "$REPO_URL"
REPO_NAME=$(basename "$REPO_URL" .git)
cd "$REPO_NAME"

echo "[3/11] Installing docker-compose..."
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose version

echo "[4/11] Adding user to docker group..."
sudo usermod -aG docker ec2-user

echo "[5/11] 🐳 Запуск Docker"
sudo systemctl enable docker
sudo systemctl start docker

echo "[6/11] Activating docker group for this session..."
newgrp docker <<EONG

echo "[7/11] Copying make-start systemd service..."
sudo cp /home/ec2-user/$REPO_NAME/make-start.service /etc/systemd/system/make-start.service
sudo systemctl daemon-reload
sudo systemctl enable make-start
sudo systemctl start make-start

echo "[8/11] Starting project with make..."
make install

echo "✅ Готово! API развернут и инициализирована."
echo "[10/11] NOTE: Ensure outbound port 80 433 8000 is open in AWS security group."
echo "[11/11]ℹ️ Перезайди в SSH для полной активации docker-группы"
EONG