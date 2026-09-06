#!/bin/bash

echo "=== Installation Cloudflared KINGDOMAINE ==="

# 1) Mise à jour
sudo apt update -y

# 2) Installation cloudflared
echo "[1/5] Installation du paquet cloudflared..."
sudo mkdir -p /usr/local/bin
sudo curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared
sudo chmod +x /usr/local/bin/cloudflared

# 3) Création du dossier de service
echo "[2/5] Préparation du service systemd..."
sudo mkdir -p /etc/cloudflared

# 4) Token Cloudflare (à coller manuellement)
echo "COLLE TON TOKEN CI-DESSOUS :"
read -p "Token Cloudflare : " CF_TOKEN

# 5) Installation du service
echo "[3/5] Installation du service cloudflared..."
sudo cloudflared service install "$CF_TOKEN"

# 6) Rechargement systemd
echo "[4/5] Reload systemd..."
sudo systemctl daemon-reload

# 7) Démarrage du service
echo "[5/5] Démarrage du tunnel..."
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

echo "=== Vérification ==="
sudo systemctl status cloudflared --no-pager

echo "=== Installation terminée ==="