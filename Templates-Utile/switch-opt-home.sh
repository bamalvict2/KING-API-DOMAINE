#!/bin/bash

# ============================================================
#  SWITCH DEV <-> PROD
#  Bernard cockpit edition PRO++
#  Usage :
#     ./switch.sh KING-AO dev
#     ./switch.sh KING-AO prod
# ============================================================

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

DOSSIER=$1
MODE=$2
LOG="/var/log/king-switch.log"

if [ -z "$DOSSIER" ] || [ -z "$MODE" ]; then
    echo -e "${RED}Usage : ./switch.sh NOM_DOSSIER dev|prod${RESET}"
    exit 1
fi

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG" > /dev/null
}

# ============================================================
# MODE DEV : /opt -> /home/bamalvict + chown bamalvict
# ============================================================
if [ "$MODE" = "dev" ]; then

    if [ ! -d "/opt/$DOSSIER" ]; then
        echo -e "${RED}Le dossier /opt/$DOSSIER n'existe pas.${RESET}"
        exit 1
    fi

    if [ -d "/home/bamalvict/$DOSSIER" ]; then
        echo -e "${RED}Le dossier /home/bamalvict/$DOSSIER existe déjà.${RESET}"
        exit 1
    fi

    echo -e "${YELLOW}Tu veux passer $DOSSIER en mode DEV ?${RESET}"
    read -p "Confirmer (o/N) : " CONFIRM

    if [[ "$CONFIRM" != "o" && "$CONFIRM" != "O" ]]; then
        echo -e "${RED}Annulé.${RESET}"
        exit 1
    fi

    echo -e "${BLUE}Déplacement vers /home/bamalvict...${RESET}"
    sudo mv /opt/$DOSSIER /home/bamalvict/
    sudo chown -R bamalvict:bamalvict /home/bamalvict/$DOSSIER

    echo -e "${GREEN}OK Bernard, $DOSSIER est maintenant en DEV dans /home/bamalvict.${RESET}"
    log "DEV: $DOSSIER déplacé vers /home/bamalvict"
    exit 0
fi

# ============================================================
# MODE PROD : /home -> /opt + chown root
# ============================================================
if [ "$MODE" = "prod" ]; then

    if [ ! -d "/home/bamalvict/$DOSSIER" ]; then
        echo -e "${RED}Le dossier /home/bamalvict/$DOSSIER n'existe pas.${RESET}"
        exit 1
    fi

    if [ -d "/opt/$DOSSIER" ]; then
        echo -e "${RED}Le dossier /opt/$DOSSIER existe déjà.${RESET}"
        exit 1
    fi

    echo -e "${YELLOW}Tu veux passer $DOSSIER en mode PROD ?${RESET}"
    read -p "Confirmer (o/N) : " CONFIRM

    if [[ "$CONFIRM" != "o" && "$CONFIRM" != "O" ]]; then
        echo -e "${RED}Annulé.${RESET}"
        exit 1
    fi

    echo -e "${BLUE}Déplacement vers /opt...${RESET}"
    sudo mv /home/bamalvict/$DOSSIER /opt/
    sudo chown -R root:root /opt/$DOSSIER

    echo -e "${GREEN}OK Bernard, $DOSSIER est maintenant en PROD dans /opt.${RESET}"
    log "PROD: $DOSSIER déplacé vers /opt"
    exit 0
fi

echo -e "${RED}Mode inconnu : utilise dev ou prod.${RESET}"
exit 1
