#!/bin/bash

echo "======================================"
echo "   RELOAD NGINX + TEST TAILSCALE"
echo "======================================"

echo ""
echo "🔄 Reload NGINX..."
sudo systemctl reload nginx
if [ $? -eq 0 ]; then
    echo "✔ NGINX rechargé avec succès"
else
    echo "❌ ERREUR : NGINX n'a pas pu être rechargé"
    exit 1
fi
echo ""

echo "🔍 Vérification syntaxe NGINX..."
sudo nginx -t
echo ""

echo "🌐 Vérification Tailscale..."
if systemctl is-active --quiet tailscaled; then
    echo "✔ Tailscale est actif"
else
    echo "❌ Tailscale n'est pas actif"
fi
echo ""

echo "🔎 IP Tailscale détectée..."
TAILSCALE_IP=$(tailscale ip -4 2>/dev/null)
if [ -z "$TAILSCALE_IP" ]; then
    echo "❌ Impossible de détecter l'IP Tailscale"
else
    echo "✔ IP Tailscale : $TAILSCALE_IP"
fi
echo ""

echo "🛰️ Test de réponse HTTP via Tailscale..."
STATUS=$(curl -o /dev/null -s -w "%{http_code}" http://$TAILSCALE_IP)
echo "➡ Code HTTP : $STATUS"
echo ""

echo "======================================"
echo "   TEST TERMINÉ"
echo "======================================"
