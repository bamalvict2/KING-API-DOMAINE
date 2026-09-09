#!/bin/bash

ROUGE="\e[31m"
VERT="\e[32m"
JAUNE="\e[33m"
BLEU="\e[34m"
RESET="\e[0m"

pause() {
    read -p "Appuie sur ENTER pour continuer..."
}

# 1) Vérifier GNOME Keyring
check_keyring() {
    echo -e "${BLEU}--- Vérification GNOME Keyring ---${RESET}"
    if pgrep -fl gnome-keyring-daemon >/dev/null; then
        echo -e "${ROUGE}[✗] GNOME Keyring est ACTIF${RESET}"
    else
        echo -e "${VERT}[✓] GNOME Keyring est désactivé${RESET}"
    fi
    pause
}

# 2) Vérifier ssh-agent
check_agent() {
    echo -e "${BLEU}--- Vérification ssh-agent ---${RESET}"
    if pgrep -u "$USER" ssh-agent >/dev/null; then
        echo -e "${VERT}[✓] ssh-agent est actif${RESET}"
        pgrep -fl ssh-agent
    else
        echo -e "${ROUGE}[✗] Aucun ssh-agent actif${RESET}"
    fi
    pause
}

# 3) Démarrer ssh-agent
start_agent() {
    echo -e "${JAUNE}--- Démarrage d'un ssh-agent ---${RESET}"
    eval "$(ssh-agent -s)"
    echo -e "${VERT}[✓] ssh-agent démarré${RESET}"
    pause
}

# 4) Vérifier SSH_AUTH_SOCK
check_sock() {
    echo -e "${BLEU}--- Vérification SSH_AUTH_SOCK ---${RESET}"
    if [[ -S "$SSH_AUTH_SOCK" ]]; then
        echo -e "${VERT}[✓] SSH_AUTH_SOCK valide :${RESET} $SSH_AUTH_SOCK"
    else
        echo -e "${ROUGE}[✗] SSH_AUTH_SOCK invalide${RESET}"
        echo "Valeur actuelle : $SSH_AUTH_SOCK"
    fi
    pause
}

# 5) Vérifier les clés chargées
check_keys() {
    echo -e "${BLEU}--- Clés chargées dans ssh-agent ---${RESET}"
    ssh-add -l
    pause
}

# 6) Charger une clé SSH
load_key() {
    echo -e "${BLEU}--- Charger une clé SSH ---${RESET}"
    read -p "Nom de la clé (ex: KING-AO) : " key
    ssh-add ~/.ssh/"$key"
    pause
}

# 7) Vérifier permissions ~/.ssh
check_permissions() {
    echo -e "${BLEU}--- Vérification permissions ~/.ssh ---${RESET}"
    ls -ld ~/.ssh
    ls -l ~/.ssh
    pause
}

# 8) Tester GitHub
test_github() {
    echo -e "${BLEU}--- Test connexion GitHub ---${RESET}"
    ssh -T git@github.com
    pause
}

# 9) Vérifier remotes Git
check_remotes() {
    echo -e "${BLEU}--- Remotes Git ---${RESET}"
    git remote -v
    pause
}

# 10) Vérifier branche locale
check_branch() {
    echo -e "${BLEU}--- Branches locales ---${RESET}"
    git branch -vv
    pause
}

# 11) Tester un push Git
test_push() {
    echo -e "${BLEU}--- Test push Git ---${RESET}"
    read -p "Remote : " rname
    read -p "Branche : " branch
    git push "$rname" "$branch"
    pause
}

# 12) Diagnostic complet
diagnostic() {
    check_keyring
    check_agent
    check_sock
    check_keys
    test_github
    check_remotes
    check_branch
}

# 13) Réinitialiser SSH_AUTH_SOCK
reset_ssh_auth_sock() {
    echo -e "${BLEU}--- Réinitialisation SSH_AUTH_SOCK ---${RESET}"
    echo -e "${JAUNE}Ancienne valeur :${RESET} $SSH_AUTH_SOCK"
    echo -e "${JAUNE}Lancement d'un nouvel agent propre...${RESET}"

    eval "$(ssh-agent -s)"

    echo -e "${VERT}[✓] Nouvel agent lancé${RESET}"
    echo -e "${VERT}Nouveau SSH_AUTH_SOCK :${RESET} $SSH_AUTH_SOCK"

    echo -e "${JAUNE}Vous pouvez maintenant charger une clé (option 6).${RESET}"
    pause
}

# --- MENU ---
while true; do
    clear
    echo -e "${BLEU}===== MENU SÉQUENTIEL SSH / GIT =====${RESET}"
    echo "1) Vérifier GNOME Keyring  (si ACTIF → faire 13)"
    echo "2) Vérifier ssh-agent"
    echo "3) Démarrer ssh-agent"
    echo "4) Vérifier SSH_AUTH_SOCK"
    echo "5) Vérifier les clés chargées"
    echo "6) Charger une clé SSH"
    echo "7) Vérifier permissions ~/.ssh"
    echo "8) Tester la connexion GitHub"
    echo "9) Vérifier les remotes Git"
    echo "10) Vérifier la branche locale"
    echo "11) Tester un push Git"
    echo "12) Diagnostic complet (1→11)"
    echo "13) Réinitialiser SSH_AUTH_SOCK"
    echo "0) Quitter"
    echo -n "Choix : "
    read choix

    case "$choix" in
        1) check_keyring ;;
        2) check_agent ;;
        3) start_agent ;;
        4) check_sock ;;
        5) check_keys ;;
        6) load_key ;;
        7) check_permissions ;;
        8) test_github ;;
        9) check_remotes ;;
        10) check_branch ;;
        11) test_push ;;
        12) diagnostic ;;
        13) reset_ssh_auth_sock ;;
        0) exit 0 ;;
        *) echo "Choix invalide"; pause ;;
    esac
done
