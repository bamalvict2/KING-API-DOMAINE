#!/bin/bash

echo -e "\e[33m============================================\e[0m"
echo -e "\e[33m      🚀 CHECK & START — KING‑AO SYSTEM      \e[0m"
echo -e "\e[33m============================================\e[0m"
echo ""

ACTIONS="/opt/KING-AO/KING-AO/actions"
MODULES="/opt/KING-AO/modules"

# -------------------------------
# CHECK METIER (module SHELL)
# -------------------------------
echo -e "\e[36m🔍 Vérification module METIER...\e[0m"

for f in start.sh stop.sh status.sh logs.sh sync.sh rebuild.sh; do
    if [ -f "$ACTIONS/metier/$f" ]; then
        echo -e "  ✔ $f trouvé"
    else
        echo -e "  ✖ $f manquant"
    fi
done

echo ""

# -------------------------------
# CHECK KINGDOMAINE (module LOCAL)
# -------------------------------
echo -e "\e[36m🔍 Vérification module KINGDOMAINE...\e[0m"

for f in start.sh stop.sh status.sh logs.sh; do
    if [ -f "$ACTIONS/kingdomaine/$f" ]; then
        echo -e "  ✔ $f trouvé"
    else
        echo -e "  ✖ $f manquant"
    fi
done

echo ""

# -------------------------------
# CHECK PORTAL (Docker)
# -------------------------------
echo -e "\e[36m🔍 Vérification module PORTAL (Docker)...\e[0m"

if [ -f "$MODULES/portal/docker-compose.yml" ]; then
    echo -e "  ✔ docker-compose.yml trouvé"
else
    echo -e "  ✖ docker-compose.yml manquant"
fi

echo ""

# -------------------------------
# CHECK MONITORING (Docker)
# -------------------------------
echo -e "\e[36m🔍 Vérification module MONITORING...\e[0m"

if [ -f "$MODULES/monitoring/docker-compose.yml" ]; then
    echo -e "  ✔ docker-compose.yml trouvé"
else
    echo -e "  ✖ docker-compose.yml manquant"
fi

echo ""

# -------------------------------
# CHECK DOCKER CONTAINERS
# -------------------------------
echo -e "\e[36m🔍 Vérification conteneurs Docker...\e[0m"

docker ps | grep portal >/dev/null && \
    echo -e "  ✔ portal actif" || \
    echo -e "  ✖ portal non trouvé"

docker ps | grep metier >/dev/null && \
    echo -e "  ✔ metier actif" || \
    echo -e "  ✖ metier non trouvé"

docker ps | egrep 'grafana|prometheus|cadvisor|loki' >/dev/null && \
    echo -e "  ✔ monitoring actif" || \
    echo -e "  ✖ monitoring non trouvé"

echo ""

# -------------------------------
# CHECK NGINX SYSTEM
# -------------------------------
echo -e "\e[36m🔍 Vérification NGINX KING‑AO...\e[0m"

NGINX_CONF="/etc/nginx/sites-enabled/kingao.conf"

if [ -f "$NGINX_CONF" ]; then
    echo -e "  ✔ Configuration NGINX trouvée"
else
    echo -e "  ✖ Configuration NGINX manquante"
fi

echo ""

# -------------------------------
# CHECK ORCHESTRATOR
# -------------------------------
echo -e "\e[36m🔍 Vérification orchestrateur KING‑AO...\e[0m"

if [ -f "/opt/KING-AO/KING-AO/orchestrator.sh" ]; then
    echo -e "  ✔ orchestrator.sh OK"
else
    echo -e "  ✖ orchestrator.sh manquant"
fi

echo ""

# -------------------------------
# LANCEMENT DU CHEF D’ORCHESTRE
# -------------------------------
echo -e "\e[32m🚀 Lancement du chef d’orchestre KING‑AO...\e[0m"
echo ""

/opt/KING-AO/KING-AO/STYLE-ORCH-KING-AO.sh

echo ""
echo -e "\e[32m🎉 KING‑AO est lancé et opérationnel.\e[0m"
echo -e "\e[33m============================================\e[0m"
