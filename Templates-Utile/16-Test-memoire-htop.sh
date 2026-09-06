#!/bin/bash

echo -e "\n🧠 BernardOps — Diagnostic mémoire et charge système"
echo "────────────────────────────────────────────────────"

# 1. Vérifier la mémoire disponible
echo -e "\n🧠 Mémoire disponible :"
free -h

# 2. Top 10 processus les plus gourmands
echo -e "\n🔍 Top 10 processus par consommation mémoire :"
ps aux --sort=-%mem | head -n 11

# 3. Lancer htop si dispo, sinon fallback vers top
echo -e "\n📊 Lancement de la surveillance système (htop ou top)..."
if command -v htop &> /dev/null; then
  htop
else
  echo "ℹ️ htop non installé — fallback vers top (mode lecture seule)"
  top -b -n 1 | head -n 40
fi