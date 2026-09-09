#!/bin/bash

# ============================================
#   EPARVIER COCKPIT ULTRA - BernardOps
#   Détection d'erreurs + Healthchecks + Monitoring
# ============================================

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
NC="\e[0m"

ROOT="$HOME/EPARVIER"
API="$ROOT/SolaizeApi"
BLAZOR="$ROOT/SolaizeCockpit"

# ============================================
#   FONCTIONS UTILITAIRES
# ============================================

pause() {
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
}

header() {
    clear
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${GREEN}        EPARVIER COCKPIT ULTRA           ${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""
}

# ============================================
#   DETECTION D'ERREURS DOCKER
# ============================================

detect_errors() {
    echo -e "${CYAN}Analyse des erreurs Docker...${NC}"

    # Ports occupés
    for PORT in 27017 5000 8080 80 9090 3000; do
        if sudo lsof -i :$PORT >/dev/null; then
            echo -e "${RED}⚠ Port $PORT déjà utilisé${NC}"
        fi
    done

    # Restart loop
    if docker ps | grep -i "Restarting" >/dev/null; then
        echo -e "${RED}⚠ Conteneur en restart loop détecté${NC}"
        docker ps | grep Restarting
    fi

    # Images manquantes
    if docker compose config 2>&1 | grep "not found" >/dev/null; then
        echo -e "${RED}⚠ Image manquante dans docker-compose${NC}"
    fi

    echo -e "${GREEN}Analyse terminée.${NC}"
    pause
}

# ============================================
#   HEALTHCHECKS
# ============================================

healthcheck() {
    echo -e "${CYAN}Healthchecks EPARVIER...${NC}"

    check() {
        local NAME=$1
        local CMD=$2

        if eval "$CMD" >/dev/null 2>&1; then
            echo -e "${GREEN}✔ $NAME OK${NC}"
        else
            echo -e "${RED}✘ $NAME DOWN${NC}"
        fi
    }

    check "MongoDB" "mongosh --eval 'db.runCommand({ ping: 1 })'"
    check "API" "curl -sf http://localhost:5000/health"
    check "Blazor" "curl -sf http://localhost:5100"
    check "Prometheus" "curl -sf http://localhost:9090/-/healthy"
    check "Grafana" "curl -sf http://localhost:3000/login"

    pause
}

# ============================================
#   MONITORING CPU / RAM / IO
# ============================================

monitoring() {
    header
    echo -e "${CYAN}Monitoring système (Ctrl+C pour quitter)${NC}"
    echo ""

    while true; do
        echo -e "${BLUE}--- CPU / RAM / IO ---${NC}"

        # INDEX façon htop
        echo -e "${YELLOW}CPU[user sys iowait idle]   RAM[total used free cache avail]   IO[r/s w/s await util]${NC}"
        echo ""

        echo -e "${GREEN}CPU:${NC}"
        mpstat 1 1 | tail -n 1

        echo -e "${GREEN}RAM:${NC}"
        free -h | grep Mem

        echo -e "${GREEN}IO:${NC}"
        iostat -xz 1 1 | sed -n '4p'

        echo ""
        sleep 2
        clear
    done
}

# ============================================
#   DOCKER OPS
# ============================================

docker_up() {
    cd "$ROOT" && docker compose up -d
    pause
}

docker_down() {
    cd "$ROOT" && docker compose down
    pause
}

docker_rebuild() {
    cd "$ROOT" && docker compose down -v && docker compose build --no-cache && docker compose up -d
    pause
}

docker_status() {
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    pause
}

docker_logs() {
    docker compose logs -f
}

docker_clean() {
    docker system prune -a --volumes -f
    pause
}

# ============================================
#   MODE EXPERT
# ============================================

mode_expert() {
    header
    echo -e "${CYAN}Mode Expert : commandes directes${NC}"
    echo ""
    echo -e "${YELLOW}u${NC} → UP"
    echo -e "${YELLOW}d${NC} → DOWN"
    echo -e "${YELLOW}r${NC} → REBUILD"
    echo -e "${YELLOW}s${NC} → STATUS"
    echo -e "${YELLOW}l${NC} → LOGS"
    echo -e "${YELLOW}c${NC} → CLEAN"
    echo -e "${YELLOW}h${NC} → HEALTHCHECK"
    echo -e "${YELLOW}e${NC} → Erreurs Docker"
    echo -e "${YELLOW}m${NC} → Monitoring"
    echo -e "${YELLOW}q${NC} → Quitter"
    echo ""

    while true; do
        read -n1 -p "Commande : " CMD
        echo ""

        case $CMD in
            u) docker_up ;;
            d) docker_down ;;
            r) docker_rebuild ;;
            s) docker_status ;;
            l) docker_logs ;;
            c) docker_clean ;;
            h) healthcheck ;;
            e) detect_errors ;;
            m) monitoring ;;
            q) break ;;
            *) echo -e "${RED}Commande inconnue${NC}" ;;
        esac
    done
}

# ============================================
#   MENU PRINCIPAL
# ============================================

while true; do
    header
    echo -e "${YELLOW}1) Détection d'erreurs Docker${NC}"
    echo -e "${YELLOW}2) Healthchecks EPARVIER${NC}"
    echo -e "${YELLOW}3) Monitoring CPU/RAM/IO${NC}"
    echo -e "${YELLOW}4) Mode Expert${NC}"
    echo -e "${YELLOW}5) Quitter${NC}"
    echo ""

    read -p "Votre choix : " MAIN

    case $MAIN in
        1) detect_errors ;;
        2) healthcheck ;;
        3) monitoring ;;
        4) mode_expert ;;
        5) exit ;;
        *) echo -e "${RED}Choix invalide${NC}" ; pause ;;
    esac
done
