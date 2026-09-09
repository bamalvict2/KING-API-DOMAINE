#!/bin/bash

# ============================================================
#   KINGDOMAINE.sh
#   Version fusionnée : Scripts 1 → 5 en un seul fichier
# ============================================================

GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m"

DOMAIN="solaize.duckdns.org"
LOCAL_PORT=5100
CLOUDFLARED_SERVICE="cloudflared"

# ============================================================
#   SCRIPT 1 — Diagnostic rapide
# ============================================================
script1() {
    echo -e "${YELLOW}Diagnostic rapide...${NC}"
    ping -c 2 1.1.1.1 >/dev/null && \
        echo -e "  ${GREEN}✔ Internet OK${NC}" || \
        echo -e "  ${RED}✘ Internet KO${NC}"
}

# ============================================================
#   SCRIPT 2 — Vérification réseau
# ============================================================
script2() {
    echo -e "${YELLOW}Vérification réseau...${NC}"
    ip a | grep inet
}

# ============================================================
#   SCRIPT 3 — Nettoyage KINGDOMAINE
# ============================================================
script3() {
    echo -e "${YELLOW}Nettoyage KINGDOMAINE...${NC}"
    rm -rf "$HOME/KINGDOMAINE/bin" "$HOME/KINGDOMAINE/obj"
    echo -e "${GREEN}✔ Nettoyage terminé${NC}"
}

# ============================================================
#   SCRIPT 4 — Nettoyage EPARVIER
# ============================================================
script4() {
    echo -e "${YELLOW}Nettoyage EPARVIER (bin/obj/.vs)...${NC}"

    TARGET="$HOME/EPARVIER"

    if [ ! -d "$TARGET" ]; then
        echo -e "${RED}❌ Dossier EPARVIER introuvable.${NC}"
        return
    fi

    cd "$TARGET"
    rm -rf bin obj .vs

    if [ ! -d "bin" ] && [ ! -d "obj" ] && [ ! -d ".vs" ]; then
        echo -e "${GREEN}✔ Nettoyage EPARVIER OK${NC}"
    else
        echo -e "${RED}✘ Nettoyage incomplet${NC}"
    fi
}

# ============================================================
#   SCRIPT 5 — Diagnostic complet KINGDOMAINE
# ============================================================
script5() {
    echo -e "${YELLOW}Diagnostic complet KINGDOMAINE...${NC}"

    DUCK_IP=$(dig +short $DOMAIN)
    PUBLIC_IP=$(curl -s https://api.ipify.org)

    if [[ "$DUCK_IP" == "$PUBLIC_IP" ]]; then
        echo -e "  ${GREEN}✔ DuckDNS OK${NC} — $DOMAIN → $DUCK_IP"
    else
        echo -e "  ${RED}✘ DuckDNS KO${NC}"
        echo -e "    DuckDNS : $DUCK_IP"
        echo -e "    IP Publique : $PUBLIC_IP"
    fi

    TUNNEL_STATUS=$(sudo systemctl is-active $CLOUDFLARED_SERVICE)
    [[ "$TUNNEL_STATUS" == "active" ]] \
        && echo -e "  ${GREEN}✔ Tunnel Cloudflare actif${NC}" \
        || echo -e "  ${RED}✘ Tunnel Cloudflare inactif${NC}"

    LOCAL_CHECK=$(curl -Is http://localhost:$LOCAL_PORT | head -n 1)
    echo "$LOCAL_CHECK" | grep -q "HTTP" \
        && echo -e "  ${GREEN}✔ Service interne OK${NC}" \
        || echo -e "  ${RED}✘ Service interne KO${NC}"

    EXTERNAL_CHECK=$(curl -Is https://$DOMAIN | head -n 1)
    echo "$EXTERNAL_CHECK" | grep -q "HTTP" \
        && echo -e "  ${GREEN}✔ Accès externe OK${NC}" \
        || echo -e "  ${RED}✘ Accès externe KO${NC}"
}

# ============================================================
#   MENU PRINCIPAL
# ============================================================
while true; do
    clear
    echo -e "============================================================"
    echo -e "   👑  MENU KINGDOMAINE — VERSION FUSIONNÉE"
    echo -e "============================================================"
    echo -e "  1) Diagnostic rapide"
    echo -e "  2) Vérification réseau"
    echo -e "  3) Nettoyage KINGDOMAINE"
    echo -e "  4) Nettoyage EPARVIER"
    echo -e "  5) Diagnostic complet KINGDOMAINE"
    echo -e "------------------------------------------------------------"
    echo -e "  0) Quitter"
    echo -e "============================================================"
    echo -ne "Votre choix : "
    read CHOICE

    case $CHOICE in
        1) script1; read -p "Entrée pour continuer..." ;;
        2) script2; read -p "Entrée pour continuer..." ;;
        3) script3; read -p "Entrée pour continuer..." ;;
        4) script4; read -p "Entrée pour continuer..." ;;
        5) script5; read -p "Entrée pour continuer..." ;;
        0) exit 0 ;;
        *) echo -e "${RED}Choix invalide${NC}"; sleep 1 ;;
    esac
done