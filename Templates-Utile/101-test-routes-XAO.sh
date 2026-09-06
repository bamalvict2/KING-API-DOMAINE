#!/bin/bash

echo "======================================"
echo "   TEST ROUTES NGINX - KING-AO"
echo "======================================"

# IP Tailscale détectée automatiquement
TAILSCALE_IP=$(hostname -I | awk '{print $1}')

echo "🔍 IP détectée : $TAILSCALE_IP"
echo ""

# Fonction de test HTTP
test_route() {
    ROUTE=$1
    echo -n "➡ Test $ROUTE ... "
    STATUS=$(curl -o /dev/null -s -w "%{http_code}" http://$TAILSCALE_IP$ROUTE)
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "302" ]; then
        echo "✔ OK ($STATUS)"
    else
        echo "❌ ERREUR ($STATUS)"
    fi
}

echo "🔍 Tests des modules KING-AO"
test_route "/portal/"
test_route "/metier/"
test_route "/kingdomaine/"
test_route "/cockpit/"
echo ""

echo "🔍 Tests Monitoring"
test_route "/grafana/"
test_route "/prometheus/"
test_route "/cadvisor/"
test_route "/loki/"
echo ""

echo "======================================"
echo "   TEST ROUTES TERMINÉ"
echo "======================================"
