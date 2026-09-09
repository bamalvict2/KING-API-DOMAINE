#!/bin/bash

echo "=== 🔵 MODULE NETWORKING : Vérification réseau ==="

# Vérification de l'état du service tailscale
echo "➡ Vérification du service tailscaled..."
systemctl is-active --quiet tailscaled
if [ $? -eq 0 ]; then
    echo "✔ tailscaled est actif"
else
    echo "❌ tailscaled est INACTIF"
fi

# Vérification de l'IP Tailscale
TS_IP=$(tailscale ip -4 2>/dev/null)

if [ -n "$TS_IP" ]; then
    echo "✔ IP Tailscale détectée : $TS_IP"
else
    echo "❌ Aucune IP Tailscale détectée"
fi

echo "=== Fin du module NETWORKING ==="

