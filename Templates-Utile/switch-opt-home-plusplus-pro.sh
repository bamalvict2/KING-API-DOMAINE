#!/bin/bash

# ============================================================
#  SWITCH DEV <-> PROD
#  Bernard cockpit edition INTERACTIVE
# ============================================================

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

LOG="/var/log/king-switch.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG" > /dev/null
}

echo -e "${BLUE}=== KING-AO Cockpit Switcher ===${RESET}"
echo

# ============================================================
# 1. Sélection du dossier
# ============================================================

echo -e "${YELLOW}Dossiers disponibles dans /opt :${RESET}"
ls /opt 2>/dev/null

echo
echo -e "${YELLOW}Dossiers disponibles dans /home/bamalvict :${RESET}"
ls /home/bamalvict 2>/dev/null

echo
read -p "Nom du dossier à déplacer : " DOSSIER

if [ -z "$DOSSIER" ]; then
    echo -e "${RED}Tu dois entrer un nom de dossier.${RESET}"
    exit 1
fi

# ============================================================
# 2. Choix du mode
# ============================================================

echo
echo -e "${BLUE}Choisis le mode :${RESET}"
echo -e "  1) DEV  (opt → home/bamalvict)"
echo -e "  2) PROD (home/bamalvict → opt)"
echo
read -p "Ton choix (1 ou 2) : " CHOICE

# ============================================================
# MODE DEV
# ============================================================

if [ "$CHOICE" = "1" ]; then

    if [ ! -d "/opt/$DOSSIER" ]; then
        echo -e "${RED}Le dossier /opt/$DOSSIER n'existe pas.${RESET}"
        exit 1
    fi

    if [ -d "/home/bamalvict/$DOSSIER" ]; then
        echo -e "${RED}Le dossier /home/bamalvict/$DOSSIER existe déjà.${RESET}"
        exit 1
    fi

    echo
    echo -e "${YELLOW}Passage en mode DEV pour $DOSSIER.${RESET}"
    read -p "Confirmer (o/N) : " CONFIRM

    if [[ "$CONFIRM" != "o" && "$CONFIRM" != "O" ]]; then
        echo -e "${RED}Annulé.${RESET}"
        exit 1
    fi

    sudo mv /opt/$DOSSIER /home/bamalvict/
    sudo chown -R bamalvict:bamalvict /home/bamalvict/$DOSSIER

    echo -e "${GREEN}OK Bernard, $DOSSIER est maintenant en DEV dans /home/bamalvict.${RESET}"
    log "DEV: $DOSSIER déplacé vers /home/bamalvict"
    exit 0
fi

# ============================================================
# MODE PROD
# ============================================================

if [ "$CHOICE" = "2" ]; then

    if [ ! -d "/home/bamalvict/$DOSSIER" ]; then
        echo -e "${RED}Le dossier /home/bamalvict/$DOSSIER n'existe pas.${RESET}"
        exit 1
    fi

    if [ -d "/opt/$DOSSIER" ]; then
        echo -e "${RED}Le dossier /opt/$DOSSIER existe déjà.${RESET}"
        exit 1
    fi

    echo
    echo -e "${YELLOW}Passage en mode PROD pour $DOSSIER.${RESET}"
    read -p "Confirmer (o/N) : " CONFIRM

    if [[ "$CONFIRM" != "o" && "$CONFIRM" != "O" ]]; then
        echo -e "${RED}Annulé.${RESET}"
        exit 1
    fi

    sudo mv /home/bamalvict/$DOSSIER /opt/
    sudo chown -R root:root /opt/$DOSSIER

    echo -e "${GREEN}OK Bernard, $DOSSIER est maintenant en PROD dans /opt.${RESET}"
    log "PROD: $DOSSIER déplacé vers /opt"
    exit 0
fi

echo -e "${RED}Choix invalide.${RESET}"
exit 1
