#!/bin/bash

echo "=== Installation DuckDNS pour KINGDOMAINE ==="

read -p "Nom de domaine DuckDNS (ex: kingepar) : " DOMAIN
read -p "Token DuckDNS : " TOKEN

# Dossier
sudo mkdir -p /opt/duckdns
sudo chmod 755 /opt/duckdns

# Script de mise à jour
cat <<EOF | sudo tee /opt/duckdns/duck.sh >/dev/null
#!/bin/bash
echo "\$(date) - Mise à jour DuckDNS" >> /opt/duckdns/duck.log
curl -s "https://www.duckdns.org/update?domains=${DOMAIN}&token=${TOKEN}&ip=" >> /opt/duckdns/duck.log
echo "" >> /opt/duckdns/duck.log
EOF

sudo chmod +x /opt/duckdns/duck.sh

# Service systemd
cat <<EOF | sudo tee /etc/systemd/system/duckdns.service >/dev/null
[Unit]
Description=DuckDNS updater
After=network-online.target

[Service]
Type=oneshot
ExecStart=/opt/duckdns/duck.sh
EOF

# Timer systemd
cat <<EOF | sudo tee /etc/systemd/system/duckdns.timer >/dev/null
[Unit]
Description=Run DuckDNS updater every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=duckdns.service

[Install]
WantedBy=timers.target
EOF

# Activation
sudo systemctl daemon-reload
sudo systemctl enable --now duckdns.timer

echo "=== Installation terminée ==="
echo "Vérification : tail -f /opt/duckdns/duck.log"