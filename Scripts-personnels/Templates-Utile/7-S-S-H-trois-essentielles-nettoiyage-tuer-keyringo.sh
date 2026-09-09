#!/bin/bash

# ============================
#  SSH-CORE : Anti-Keyring GNOME
# ============================

# --- Couleurs ---
ROUGE="\e[31m"
VERT="\e[32m"
JAUNE="\e[33m"
BLEU="\e[34m"
RESET="\e[0m"

# ============================
#  Détection agents parasites
# ============================
detecter_agent_parasite() {
    echo -e "${BLEU}Analyse de l'environnement SSH...${RESET}"

    if [[ "$SSH_AUTH_SOCK" == *"keyring"* ]] || [[ "$SSH_AUTH_SOCK" == *"gpg-agent"* ]]; then
        echo -e "${ROUGE}[!] SSH_AUTH_SOCK pointe vers GNOME Keyring ou GPG-Agent${RESET}"
        return 1
    fi

    if pgrep -f "gnome-keyring-daemon" >/dev/null; then
        echo -e "${ROUGE}[!] gnome-keyring-daemon actif${RESET}"
        return 1
    fi

    if pgrep -f "gpg-agent" >/dev/null; then
        echo -e "${ROUGE}[!] gpg-agent actif${RESET}"
        return 1
    fi

    echo -e "${VERT}[✓] Aucun agent parasite détecté${RESET}"
    return 0
}

# ============================
#  Forcer un vrai ssh-agent
# ============================
forcer_vrai_agent() {
    echo -e "${JAUNE}Arrêt des agents parasites...${RESET}"

    pkill -f gnome-keyring-daemon 2>/dev/null
    pkill -f gpg-agent 2>/dev/null
    pkill -f "gpg-agent --ssh" 2>/dev/null
    pkill -f seahorse 2>/dev/null
    pkill ssh-agent 2>/dev/null

    echo -e "${BLEU}Lancement d'un vrai ssh-agent...${RESET}"
    eval "$(ssh-agent -s)"

    echo -e "${BLEU}Chargement de la clé SSH...${RESET}"
    ssh-add ~/.ssh/id_ed25519 2>/dev/null || ssh-add ~/.ssh/KING-AO 2>/dev/null

    echo -e "${VERT}[✓] ssh-agent opérationnel${RESET}"
}

# ============================
#  Vérification intelligente
# ============================
verifier_agent() {
    detecter_agent_parasite
    if [ $? -eq 1 ]; then
        echo -e "${JAUNE}Correction automatique...${RESET}"
        forcer_vrai_agent
        return
    fi

    if ! pgrep -u "$USER" ssh-agent >/dev/null; then
        echo -e "${JAUNE}ssh-agent non lancé, démarrage...${RESET}"
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519 2>/dev/null || ssh-add ~/.ssh/KING-AO 2>/dev/null
    fi

    echo -e "${VERT}[✓] ssh-agent OK${RESET}"
}

# ============================
#  Affichage état complet
# ============================
etat_complet() {
    echo -e "${BLEU}===== État SSH =====${RESET}"
    echo -e "SSH_AUTH_SOCK : $SSH_AUTH_SOCK"
    echo -e "Processus ssh-agent :"
    pgrep -fl ssh-agent || echo "Aucun"
    echo
    echo -e "Processus parasites :"
    pgrep -fl gnome-keyring-daemon || echo "Aucun"
    pgrep -fl gpg-agent || echo "Aucun"
    echo
}

# ============================
#  MENU INTERACTIF
# ============================
while true; do
    clear
    echo -e "${BLEU}===== Gestion SSH-Agent / Anti-Keyring =====${RESET}"
    echo "1) Vérifier l'agent SSH"
    echo "2) Forcer un vrai ssh-agent"
    echo "3) Afficher l'état complet"
    echo "4) Redémarrer proprement ssh-agent"
    echo "5) Quitter"
    echo -n "Choix : "
    read choix

    case "$choix" in
        1)
            verifier_agent
            read -p "Appuyer sur Entrée..."
            ;;
        2)
            forcer_vrai_agent
            read -p "Appuyer sur Entrée..."
            ;;
        3)
            etat_complet
            read -p "Appuyer sur Entrée..."
            ;;
        4)
            pkill ssh-agent 2>/dev/null
            eval "$(ssh-agent -s)"
            ssh-add ~/.ssh/id_ed25519 2>/dev/null || ssh-add ~/.ssh/KING-AO 2>/dev/null
            echo -e "${VERT}[✓] Redémarrage complet effectué${RESET}"
            read -p "Appuyer sur Entrée..."
            ;;
        5)
            exit 0
            ;;
        *)
            echo "Choix invalide"
            sleep 1
            ;;
    esac
done
