#!/bin/bash

# ============================================================
#   DOCKER MANAGER PRO - MENU INTERACTIF
# ============================================================

EPARVIER_DIR="/home/EPARVIER/SolaizeApi"
KINGAO_DIR="/opt/KING-AO/PRJTOTO"

# --- Couleurs ---
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

# ============================================================
#   VERIFICATIONS SYSTEME
# ============================================================

check_docker_installed() {
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}Docker n'est pas installé.${RESET}"
        exit 1
    fi
}

check_docker_running() {
    if ! systemctl is-active --quiet docker; then
        echo -e "${YELLOW}Docker n'est pas démarré. Démarrage...${RESET}"
        sudo systemctl start docker
        sleep 1
    fi
}

check_docker() {
    check_docker_installed
    check_docker_running
}

docker_versions() {
    echo -e "${CYAN}Version Docker :${RESET}"
    docker --version
    echo ""
    echo -e "${CYAN}Version Docker Compose :${RESET}"
    docker compose version
}

# ============================================================
#   CONFIRMATION SECURITE
# ============================================================

confirm() {
    read -p "Confirmer (o/N) : " ans
    [[ "$ans" == "o" || "$ans" == "O" ]]
}

# ============================================================
#   FONCTIONS PROJETS
# ============================================================

soapi_up() { check_docker; cd "$EPARVIER_DIR" && docker compose up -d; }
soapi_down() { check_docker; cd "$EPARVIER_DIR" && docker compose down; }
soapi_logs() { check_docker; cd "$EPARVIER_DIR" && docker compose logs -f; }
soapi_ps() { check_docker; cd "$EPARVIER_DIR" && docker compose ps; }

kingao_up() { check_docker; cd "$KINGAO_DIR" && docker compose up -d; }
kingao_down() { check_docker; cd "$KINGAO_DIR" && docker compose down; }
kingao_logs() { check_docker; cd "$KINGAO_DIR" && docker compose logs -f; }
kingao_ps() { check_docker; cd "$KINGAO_DIR" && docker compose ps; }

# ============================================================
#   FONCTIONS DOCKER GLOBALES
# ============================================================

docker_stop_all() { check_docker; docker stop $(docker ps -q); }
docker_rm_all() { check_docker; docker rm $(docker ps -aq); }
docker_prune_dangling() { check_docker; docker image prune -f; }
docker_prune_images() { check_docker; docker image prune -a -f; }
docker_prune_networks() { check_docker; docker network prune -f; }

docker_clean_all() {
    echo -e "${RED}ATTENTION : suppression TOTALE des images, conteneurs et volumes.${RESET}"
    if confirm; then
        docker system prune -a --volumes -f
    else
        echo "Annulé."
    fi
}

docker_df() { check_docker; docker system df; }

# ============================================================
#   OUTILS AVANCES
# ============================================================

docker_shell() {
    check_docker
    read -p "Nom du conteneur : " name
    docker exec -it "$name" bash
}

docker_info() {
    check_docker
    read -p "Nom du conteneur : " name
    docker inspect "$name" | less
}

docker_ports() {
    check_docker
    docker ps --format "table {{.Names}}\t{{.Ports}}"
}

docker_logs_clean() {
    echo -e "${YELLOW}Nettoyage des logs Docker...${RESET}"
    sudo find /var/lib/docker/containers/ -name "*-json.log" -exec truncate -s 0 {} \;
}

docker_images_sorted() {
    check_docker
    docker images --format "{{.Size}}\t{{.Repository}}:{{.Tag}}" | sort -h
}

# ============================================================
#   MENUS
# ============================================================

menu_soapi() {
    clear
    echo -e "${BLUE}===== SOAPI =====${RESET}"
    echo "1) UP"
    echo "2) DOWN"
    echo "3) LOGS"
    echo "4) PS"
    echo "0) Retour"
    read -p "Choix : " c
    case $c in
        1) soapi_up ;;
        2) soapi_down ;;
        3) soapi_logs ;;
        4) soapi_ps ;;
    esac
}

menu_kingao() {
    clear
    echo -e "${BLUE}===== KINGAO =====${RESET}"
    echo "1) UP"
    echo "2) DOWN"
    echo "3) LOGS"
    echo "4) PS"
    echo "0) Retour"
    read -p "Choix : " c
    case $c in
        1) kingao_up ;;
        2) kingao_down ;;
        3) kingao_logs ;;
        4) kingao_ps ;;
    esac
}

menu_advanced() {
    clear
    echo -e "${BLUE}===== OUTILS AVANCÉS =====${RESET}"
    echo "1) Shell dans conteneur"
    echo "2) Inspecter conteneur"
    echo "3) Voir ports"
    echo "4) Nettoyer logs Docker"
    echo "5) Images triées par taille"
    echo "0) Retour"
    read -p "Choix : " c
    case $c in
        1) docker_shell ;;
        2) docker_info ;;
        3) docker_ports ;;
        4) docker_logs_clean ;;
        5) docker_images_sorted ;;
    esac
}

menu() {
    clear
    echo -e "${BLUE}=============================================="
    echo -e "           DOCKER MANAGER PRO"
    echo -e "==============================================${RESET}"

    echo "1) SOAPI"
    echo "2) KINGAO"
    echo "3) STOP ALL"
    echo "4) REMOVE ALL"
    echo "5) PRUNE DANGLING"
    echo "6) PRUNE IMAGES"
    echo "7) PRUNE NETWORKS"
    echo "8) CLEAN ALL (DANGER)"
    echo "9) DISK USAGE"
    echo "10) VERSIONS DOCKER"
    echo "11) OUTILS AVANCÉS"
    echo ""
    echo "0) QUITTER"
}

# ============================================================
#   BOUCLE PRINCIPALE
# ============================================================

while true; do
    menu
    read -p "Choix : " CH

    case $CH in
        1) menu_soapi ;;
        2) menu_kingao ;;
        3) docker_stop_all ;;
        4) docker_rm_all ;;
        5) docker_prune_dangling ;;
        6) docker_prune_images ;;
        7) docker_prune_networks ;;
        8) docker_clean_all ;;
        9) docker_df ;;
        10) docker_versions ;;
        11) menu_advanced ;;
        0) exit 0 ;;
        *) echo -e "${RED}Choix invalide${RESET}" ;;
    esac

    echo -e "${GREEN}Appuie sur Entrée pour continuer...${RESET}"
    read
done
