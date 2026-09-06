#!/bin/bash

###############################################
# AUTO-LOCALISATION DU SCRIPT
###############################################
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
EPARVIER_DIR="$BASE_DIR/eparvier"
KING_DIR="$BASE_DIR/kingdomaine"

###############################################
# EPARVIER – Stack Applicative
###############################################

start_eparvier() {
    echo "🚀 Démarrage de la stack EPARVIER..."
    docker compose -f "$EPARVIER_DIR/docker-compose.yml" up -d
}

stop_eparvier() {
    echo "🛑 Arrêt de la stack EPARVIER..."
    docker compose -f "$EPARVIER_DIR/docker-compose.yml" down
}

logs_eparvier() {
    echo "📜 Logs EPARVIER..."
    docker compose -f "$EPARVIER_DIR/docker-compose.yml" logs -f
}

rebuild_api() {
    echo "🔧 Rebuild de l'API .NET..."
    docker compose -f "$EPARVIER_DIR/docker-compose.yml" build solaizeapi
    docker compose -f "$EPARVIER_DIR/docker-compose.yml" up -d solaizeapi
}

rebuild_blazor() {
    echo "🔧 Rebuild de Blazor..."
    docker compose -f "$EPARVIER_DIR/docker-compose.yml" build blazor
    docker compose -f "$EPARVIER_DIR/docker-compose.yml" up -d blazor
}

backup_mongo() {
    echo "💾 Backup MongoDB..."
    TIMESTAMP=$(date +"%Y%m%d_%H%M")
    docker exec mongo mongodump --out "/data/db/backup_$TIMESTAMP"
    echo "✔️ Backup créé : backup_$TIMESTAMP"
}

###############################################
# KINGDOMAINE – Monitoring complet
###############################################

start_monitoring() {
    echo "🚀 Démarrage du monitoring..."
    docker compose -f "$KING_DIR/docker-compose.yml" up -d
}

stop_monitoring() {
    echo "🛑 Arrêt du monitoring..."
    docker compose -f "$KING_DIR/docker-compose.yml" down
}

logs_monitoring() {
    echo "📜 Logs du monitoring..."
    docker compose -f "$KING_DIR/docker-compose.yml" logs -f
}

status_monitoring() {
    echo "📊 État des services de monitoring :"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" \
        | grep -E "prometheus|grafana|exporter|cadvisor|node"
}

test_monitoring() {
    echo "🔍 Tests rapides du monitoring :"

    echo "➡️  Prometheus :"
    curl -s http://localhost:9090/-/ready >/dev/null && echo "   ✔️ OK" || echo "   ❌ KO"

    echo "➡️  Grafana :"
    curl -s http://localhost:3000/login | grep -q "Grafana" && echo "   ✔️ OK" || echo "   ❌ KO"

    echo "➡️  Node Exporter :"
    curl -s http://localhost:9100/metrics >/dev/null && echo "   ✔️ OK" || echo "   ❌ KO"

    echo "➡️  cAdvisor :"
    curl -s http://localhost:8080/metrics >/dev/null && echo "   ✔️ OK" || echo "   ❌ KO"

    echo "➡️  MongoDB Exporter :"
    curl -s http://localhost:9216/metrics >/dev/null && echo "   ✔️ OK" || echo "   ❌ KO"

    echo "➡️  Blackbox Exporter :"
    curl -s http://localhost:9115/probe >/dev/null && echo "   ✔️ OK" || echo "   ❌ KO"
}

###############################################
# HEALTHCHECK GLOBAL
###############################################

healthcheck() {
    echo "🩺 Healthcheck global :"

    echo "➡️ API .NET :"
    curl -s http://localhost:5010/health >/dev/null && echo "   ✔️ OK" || echo "   ❌ KO"

    echo "➡️ Blazor :"
    curl -s http://localhost:5110 >/dev/null && echo "   ✔️ OK" || echo "   ❌ KO"

    echo "➡️ MongoDB :"
    nc -z localhost 27017 && echo "   ✔️ OK" || echo "   ❌ KO"

    echo "➡️ Loki :"
    curl -s http://localhost:3100/ready >/dev/null && echo "   ✔️ OK" || echo "   ❌ KO"
}

###############################################
# DOCKER UTILITAIRES
###############################################

status() {
    echo "📊 Conteneurs actifs :"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

clean() {
    echo "🧹 Nettoyage Docker..."
    docker container prune -f
    docker image prune -f
}

update_images() {
    echo "⬆️ Mise à jour des images Docker..."
    docker pull $(docker images --format "{{.Repository}}:{{.Tag}}")
}

###############################################
# MENU INTERACTIF
###############################################

menu() {
    clear
    echo "========================================"
    echo "        🚀 INFRASTRUCTURE MANAGER       "
    echo "========================================"
    echo "1) Start EPARVIER"
    echo "2) Stop EPARVIER"
    echo "3) Logs EPARVIER"
    echo "4) Rebuild API"
    echo "5) Rebuild Blazor"
    echo "6) Backup Mongo"
    echo "----------------------------------------"
    echo "7) Start Monitoring"
    echo "8) Stop Monitoring"
    echo "9) Logs Monitoring"
    echo "10) Status Monitoring"
    echo "11) Test Monitoring"
    echo "----------------------------------------"
    echo "12) Healthcheck Global"
    echo "13) Docker Status"
    echo "14) Docker Clean"
    echo "15) Update Docker Images"
    echo "----------------------------------------"
    echo "0) Quitter"
    echo "========================================"
    read -p "👉 Choix : " choice

    case $choice in
        1) start_eparvier ;;
        2) stop_eparvier ;;
        3) logs_eparvier ;;
        4) rebuild_api ;;
        5) rebuild_blazor ;;
        6) backup_mongo ;;
        7) start_monitoring ;;
        8) stop_monitoring ;;
        9) logs_monitoring ;;
        10) status_monitoring ;;
        11) test_monitoring ;;
        12) healthcheck ;;
        13) status ;;
        14) clean ;;
        15) update_images ;;
        0) exit 0 ;;
        *) echo "❌ Choix invalide" ;;
    esac

    read -p "Appuie sur Entrée pour continuer..."
    menu
}

###############################################
# LANCEMENT DU MENU PAR DÉFAUT
###############################################

menu
