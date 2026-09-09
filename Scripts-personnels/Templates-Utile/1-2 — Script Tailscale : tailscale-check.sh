#!/bin/bash

echo "=== 🟢 TEST TAILSCALE ==="

TS_IP=$(tailscale ip -4 2>/dev/null)

if [ -z "$TS_IP" ]; then
    echo "❌ Pas d'IP Tailscale. Tailscale n'est pas connecté."
    exit 1
fi

echo "✔ IP Tailscale locale : $TS_IP"

# Test ping vers un peer
PEER="100.100.100.100"   # Exemple : à remplacer par ton Nokia G20
echo "➡ Test de ping vers $PEER..."
ping -c 2 $PEER >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✔ Connexion directe OK (NAT traversal réussi)"
else
    echo "⚠ Pas de connexion directe. Passage probable via DERP."
fi

echo "=== Fin du test Tailscale ==="
