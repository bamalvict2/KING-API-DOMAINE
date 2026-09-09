#!/bin/bash

echo "======================================"
echo "   TEST NGINX - KING-AO"
echo "======================================"

echo ""
echo "🔍 Vérification syntaxe NGINX..."
sudo nginx -t
echo ""

echo "🔍 Vérification du service NGINX..."
if systemctl is-active --quiet nginx; then
    echo "✔ NGINX est actif"
else
    echo "❌ NGINX n'est pas actif"
fi
echo ""

echo "🔍 Vérification du port 80..."
sudo ss -tlnp | grep ":80"
echo ""

echo "🔍 Fichiers actifs dans sites-enabled..."
ls -l /etc/nginx/sites-enabled
echo ""

echo "🔍 Vérification que kingao.conf est chargé..."
if [ -L /etc/nginx/sites-enabled/kingao.conf ]; then
    echo "✔ kingao.conf est bien activé"
else
    echo "❌ kingao.conf n'est pas activé"
fi
echo ""

echo "🔍 Dernières erreurs NGINX..."
sudo tail -n 20 /var/log/nginx/error.log
echo ""

echo "======================================"
echo "   TEST NGINX TERMINÉ"
echo "======================================"
