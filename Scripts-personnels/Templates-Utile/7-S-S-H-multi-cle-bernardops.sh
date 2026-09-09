#!/bin/bash

# ============================================================
#   COCKPIT SSH + TOKEN GITHUB – VERSION PRO BERNARDOPS V9
#   Pour avoir le nom de la cle - ls ~/.ssh/id_ed25519*
# ============================================================

# ============================================================
#   COCKPIT SSH + TOKEN GITHUB – VERSION PRO BERNARDOPS V7
# ============================================================
# Ce cockpit permet de gérer facilement :
#   - La création de clés SSH
#   - L’ajout de la clé dans ssh-agent
#   - L’affichage de la clé publique
#   - La configuration du fichier ~/.ssh/config
#   - Le rappel pour enregistrer la clé dans GitHub
#   - Le test de connexion SSH
#   - La gestion du Token GitHub (PAT)
#   - La correction des permissions
#   - La suppression d’une ou de toutes les clés SSH
#
# -------------------------
#   🔐 RÔLE DE LA CLÉ SSH
# -------------------------
# Une clé SSH permet d’authentifier votre machine auprès de GitHub
# sans mot de passe. Elle remplace HTTPS et sécurise vos opérations.
#
# La clé privée reste sur votre machine.
# La clé publique doit être enregistrée dans :
#   GitHub → Settings → SSH and GPG keys → New SSH key
#
# ------------------------------
#   🔑 RÔLE DU TOKEN GITHUB (PAT)
# ------------------------------
# Le Token GitHub remplace votre mot de passe pour :
#   - Les accès HTTPS
#   - L’API GitHub
#   - Les scripts automatisés
#   - Les dépôts privés
#
# Ne jamais partager votre token.
# Ne jamais le mettre dans un dépôt Git.
#
# ============================================================
#   FIN DU HEADER — DÉBUT DU SCRIPT
#   Pour avoir le nom de la cle - ls ~/.ssh/id_ed25519*
# ============================================================







# Couleurs
VERT="\e[32m"
ROUGE="\e[31m"
BLEU="\e[34m"
JAUNE="\e[33m"
RESET="\e[0m"

# Vérification dossier ~/.ssh
verifier_dossier_ssh() {
    if [ ! -d ~/.ssh ]; then
        echo -e "${JAUNE}Dossier ~/.ssh absent, création...${RESET}"
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
    fi
}

# Vérification agent SSH
verifier_agent() {
    if ! pgrep -u "$USER" ssh-agent >/dev/null; then
        echo -e "${JAUNE}ssh-agent non lancé, démarrage...${RESET}"
        eval "$(ssh-agent -s)"
    fi
}

# 1) Générer une clé SSH
generer_cle() {
    verifier_dossier_ssh
    echo -e "${BLEU}--- Génération d'une nouvelle clé SSH ---${RESET}"
    read -p "Nom de la clé (ex: perso, travail) : " nom
    read -p "Email GitHub : " email

    if [ -f ~/.ssh/id_ed25519_$nom ]; then
        echo -e "${ROUGE}Erreur : une clé portant ce nom existe déjà.${RESET}"
        return
    fi

    ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519_$nom
    echo -e "${VERT}Clé générée : ~/.ssh/id_ed25519_${nom}${RESET}"
}

# 2) Ajouter une clé à l’agent
ajouter_agent() {
    verifier_agent
    echo -e "${BLEU}--- Ajout d'une clé à l'agent SSH ---${RESET}"
    read -p "Nom de la clé : " nom

    if [ ! -f ~/.ssh/id_ed25519_$nom ]; then
        echo -e "${ROUGE}Erreur : clé introuvable.${RESET}"
        return
    fi

    ssh-add ~/.ssh/id_ed25519_$nom
    echo -e "${VERT}Clé ajoutée à l'agent.${RESET}"
}

# 3) Afficher une clé publique
afficher_pub() {
    echo -e "${BLEU}--- Affichage de la clé publique ---${RESET}"
    read -p "Nom de la clé : " nom

    if [ ! -f ~/.ssh/id_ed25519_${nom}.pub ]; then
        echo -e "${ROUGE}Erreur : clé publique introuvable.${RESET}"
        return
    fi

    echo -e "${JAUNE}"
    cat ~/.ssh/id_ed25519_${nom}.pub
    echo -e "${RESET}"
}

# 4) Ajouter un bloc SSH config
configurer_ssh() {
    verifier_dossier_ssh
    echo -e "${BLEU}--- Configuration automatique du fichier ~/.ssh/config ---${RESET}"

    read -p "Nom de la clé : " nom
    read -p "Alias Host (ex: github-perso) : " alias
    read -p "HostName (ex: github.com) : " host
    read -p "Port (443 pour GitHub) : " port

    if [ ! -f ~/.ssh/id_ed25519_$nom ]; then
        echo -e "${ROUGE}Erreur : clé introuvable.${RESET}"
        return
    fi

    cat >> ~/.ssh/config <<EOF

Host $alias
    HostName $host
    User git
    Port $port
    IdentityFile ~/.ssh/id_ed25519_$nom
    IdentitiesOnly yes
    AddKeysToAgent yes
EOF

    echo -e "${VERT}Bloc ajouté dans ~/.ssh/config${RESET}"
}

# 5) Tester une connexion SSH
tester_connexion() {
    echo -e "${BLEU}--- Test de connexion SSH ---${RESET}"
    read -p "Alias Host à tester : " alias
    ssh -T $alias
}

# 6) Lister les clés
liste_cles() {
    echo -e "${BLEU}--- Liste des clés SSH disponibles ---${RESET}"
    ls -1 ~/.ssh/id_ed25519_* 2>/dev/null | sed 's/.pub//g'
}

# 7) Initialiser le token GitHub
initialiser_token() {
    echo -e "${BLEU}--- Initialisation du token GitHub (HTTPS) ---${RESET}"
    read -p "Colle ton token GitHub (PAT) : " token

    git config --global credential.helper store
    echo "https://$token:x-oauth-basic@github.com" > ~/.git-credentials

    echo -e "${VERT}Token enregistré.${RESET}"
}

# 8) Corriger permissions SSH
corriger_permissions() {
    echo -e "${BLEU}--- Correction des permissions SSH ---${RESET}"
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_ed25519_* 2>/dev/null
    chmod 644 ~/.ssh/id_ed25519_*.pub 2>/dev/null
    echo -e "${VERT}Permissions corrigées.${RESET}"
}

# 9) Diagnostic automatique SSH PRO (analyse + nettoyage + réparation)
diagnostic_ssh() {
    echo -e "${BLEU}--- Diagnostic automatique SSH PRO ---${RESET}"
    verifier_dossier_ssh

    echo ""
    echo -e "${JAUNE}1) Analyse du dossier ~/.ssh${RESET}"

    if [ -d ~/.ssh ]; then
        echo -e "${VERT}[OK] Dossier ~/.ssh présent${RESET}"
    else
        echo -e "${ROUGE}[!] Dossier ~/.ssh manquant${RESET}"
        return
    fi

    echo ""
    echo -e "${JAUNE}2) Analyse des fichiers de clés${RESET}"

    cles_privees=()
    cles_publiques=()
    parasites=()

    while IFS= read -r f; do
        base=$(basename "$f")
        case "$base" in
            id_ed25519_*\.pub)
                cles_publiques+=("$base")
                ;;
            id_ed25519_*)
                cles_privees+=("$base")
                ;;
            *~|*.old|*.bak|*.save)
                parasites+=("$base")
                ;;
        esac
    done < <(ls -1 ~/.ssh 2>/dev/null)

    echo -e "${BLEU}Clés privées détectées :${RESET}"
    if [ ${#cles_privees[@]} -eq 0 ]; then
        echo -e "${ROUGE}  Aucune clé privée id_ed25519_* trouvée${RESET}"
    else
        for c in "${cles_privees[@]}"; do echo "  - $c"; done
    fi

    echo -e "${BLEU}Clés publiques détectées :${RESET}"
    if [ ${#cles_publiques[@]} -eq 0 ]; then
        echo -e "${JAUNE}  Aucune clé publique .pub trouvée${RESET}"
    else
        for c in "${cles_publiques[@]}"; do echo "  - $c"; done
    fi

    echo ""
    echo -e "${JAUNE}3) Vérification permissions + intégrité des clés privées${RESET}"

    cles_hs=()
    for c in "${cles_privees[@]}"; do
        chemin="$HOME/.ssh/$c"
        perms=$(stat -c "%a" "$chemin" 2>/dev/null)
        header=$(head -n 1 "$chemin" 2>/dev/null)

        ok=true

        if [ "$perms" != "600" ]; then
            echo -e "${JAUNE}[!] $c : permissions = $perms (recommandé : 600)${RESET}"
            ok=false
        fi

        if [[ "$header" != "-----BEGIN OPENSSH PRIVATE KEY-----" ]]; then
            echo -e "${ROUGE}[!] $c : format inattendu (clé HS ou corrompue)${RESET}"
            ok=false
        fi

        if [ "$ok" = false ]; then
            cles_hs+=("$c")
        else
            echo -e "${VERT}[OK] $c : permissions + format corrects${RESET}"
        fi
    done

    echo ""
    echo -e "${JAUNE}4) Analyse du fichier ~/.ssh/config${RESET}"

    cles_config=()
    if [ -f ~/.ssh/config ]; then
        while IFS= read -r line; do
            if echo "$line" | grep -q "IdentityFile"; then
                f=$(echo "$line" | awk '{print $2}')
                base=$(basename "$f")
                cles_config+=("$base")
            fi
        done < ~/.ssh/config

        if [ ${#cles_config[@]} -eq 0 ]; then
            echo -e "${JAUNE}[!] Aucune IdentityFile trouvée dans ~/.ssh/config${RESET}"
        else
            echo -e "${BLEU}Clés référencées dans ~/.ssh/config :${RESET}"
            for c in "${cles_config[@]}"; do echo "  - $c"; done
        fi
    else
        echo -e "${JAUNE}[!] Fichier ~/.ssh/config absent${RESET}"
    fi

    echo ""
    echo -e "${JAUNE}5) Analyse de l'agent SSH${RESET}"

    if pgrep -u "$USER" ssh-agent >/dev/null; then
        echo -e "${VERT}[OK] ssh-agent en cours d'exécution${RESET}"
        cles_agent=$(ssh-add -l 2>/dev/null | awk '{print $3}')
        if [ -z "$cles_agent" ]; then
            echo -e "${JAUNE}[!] Aucune clé chargée dans l'agent${RESET}"
        else
            echo -e "${BLEU}Clés chargées dans l'agent :${RESET}"
            echo "$cles_agent"
        fi
    else
        echo -e "${JAUNE}[!] ssh-agent non lancé${RESET}"
    fi

    echo ""
    echo -e "${JAUNE}6) Fichiers parasites détectés${RESET}"

    if [ ${#parasites[@]} -eq 0 ]; then
        echo -e "${VERT}[OK] Aucun fichier parasite${RESET}"
    else
        echo -e "${ROUGE}Fichiers parasites :${RESET}"
        for p in "${parasites[@]}"; do echo "  - $p"; done
    fi

    echo ""
    echo -e "${BLEU}=== ACTIONS POSSIBLES ===${RESET}"
    echo "1) Corriger les permissions"
    echo "2) Charger les clés valides dans l'agent"
    echo "3) Supprimer les fichiers parasites"
    echo "4) Supprimer les clés HS"
    echo "5) Supprimer les clés non utilisées"
    echo "6) Recréer les clés publiques manquantes"
    echo "7) Retour au menu"
    read -p "Choix : " action

    case "$action" in
        1)
                        
            echo -e "${BLEU}--- Vérification des permissions actuelles ---${RESET}"
            echo ""
            echo -e "${JAUNE}Explication des permissions SSH :${RESET}"
            echo -e "${VERT}700${RESET} = rwx------  → Toi seul peux accéder au dossier ~/.ssh"
            echo -e "${VERT}600${RESET} = rw-------  → Clé privée : lecture/écriture pour toi uniquement"
            echo -e "${VERT}644${RESET} = rw-r--r--  → Clé publique : partageable, lecture pour tous"
            echo ""
            echo -e "${JAUNE}Permissions actuelles :${RESET}"
            echo ""
            echo "Dossier ~/.ssh :"
            stat -c "%a %n" ~/.ssh

            echo ""
            echo "Clés privées :"
            for c in "${cles_privees[@]}"; do
                stat -c "%a %n" "$HOME/.ssh/$c"
            done

            echo ""
            echo "Clés publiques :"
            for c in "${cles_publiques[@]}"; do
                stat -c "%a %n" "$HOME/.ssh/$c"
            done

            echo ""
            read -p "Corriger les permissions selon les règles SSH ? (o/N) : " rep
            if [[ "$rep" =~ ^[oO]$ ]]; then
                chmod 700 ~/.ssh
                chmod 600 ~/.ssh/id_ed25519_* 2>/dev/null
                chmod 644 ~/.ssh/id_ed25519_*.pub 2>/dev/null
                echo -e "${VERT}Permissions corrigées.${RESET}"
            else
                echo -e "${JAUNE}Permissions NON modifiées.${RESET}"
            fi
            ;;

        2)
            verifier_agent
            for c in "${cles_privees[@]}"; do ssh-add "$HOME/.ssh/$c" 2>/dev/null; done
            echo -e "${VERT}Clés chargées.${RESET}"
            ;;
        3)
            for p in "${parasites[@]}"; do rm -f "$HOME/.ssh/$p"; done
            echo -e "${VERT}Parasites supprimés.${RESET}"
            ;;
        4)
            for c in "${cles_hs[@]}"; do rm -f "$HOME/.ssh/$c"; done
            echo -e "${VERT}Clés HS supprimées.${RESET}"
            ;;
        5)
            for c in "${cles_privees[@]}"; do
                if ! printf '%s\n' "${cles_config[@]}" | grep -q "$c"; then
                    rm -f "$HOME/.ssh/$c" "$HOME/.ssh/$c.pub"
                fi
            done
            echo -e "${VERT}Clés non utilisées supprimées.${RESET}"
            ;;
        6)
            for c in "${cles_privees[@]}"; do
                if [ ! -f "$HOME/.ssh/$c.pub" ]; then
                    ssh-keygen -y -f "$HOME/.ssh/$c" > "$HOME/.ssh/$c.pub"
                fi
            done
            echo -e "${VERT}Clés publiques recréées.${RESET}"
            ;;
        *)
            echo "Retour au menu."
            ;;
    esac
}


# 10) Supprimer une clé SSH
supprimer_une_cle() {
    echo -e "${BLEU}--- Suppression d'une clé SSH ---${RESET}"

    echo "Clés disponibles :"
    ls -1 ~/.ssh/id_ed25519_* 2>/dev/null | sed 's/.pub//g'

    echo ""
    read -p "Nom EXACT de la clé à supprimer (ex: id_ed25519_perso) : " cle

    if [ -f ~/.ssh/$cle ]; then
        rm -f ~/.ssh/$cle ~/.ssh/$cle.pub
        echo -e "${VERT}Clé $cle supprimée.${RESET}"
    else
        echo -e "${ROUGE}Erreur : clé introuvable.${RESET}"
    fi

    read -p "Appuie sur ENTER pour revenir au menu..."
}

# 11) Supprimer TOUTES les clés SSH
supprimer_toutes_cles() {
    echo -e "${BLEU}--- Suppression de TOUTES les clés SSH ---${RESET}"

    rm -f ~/.ssh/id_ed25519_* ~/.ssh/*git* ~/.ssh/*.pub 2>/dev/null

    echo -e "${VERT}Toutes les clés SSH ont été supprimées.${RESET}"

    mkdir -p ~/.ssh
    chmod 700 ~/.ssh

    read -p "Appuie sur ENTER pour revenir au menu..."
}

# 12) Ajouter / Modifier le mot de passe d'une clé SSH
modifier_passphrase() {
    echo -e "${BLEU}--- Ajouter / Modifier le mot de passe d'une clé SSH ---${RESET}"

    echo "Clés disponibles :"
    ls -1 ~/.ssh/id_ed25519_* 2>/dev/null | sed 's/.pub//g'

    echo ""
    read -p "Nom EXACT de la clé (ex: id_ed25519_perso) : " cle

    if [ ! -f ~/.ssh/$cle ]; then
        echo -e "${ROUGE}Erreur : clé introuvable.${RESET}"
        return
    fi

    echo -e "${JAUNE}Si la clé n'a pas de mot de passe, appuie sur ENTER quand il demande l'ancien.${RESET}"
    ssh-keygen -p -f ~/.ssh/$cle

    echo -e "${VERT}Mot de passe mis à jour pour la clé : $cle${RESET}"
}

# 13) Backup du dossier ~/.ssh
backup_ssh() {
    verifier_dossier_ssh
    echo -e "${BLEU}--- Backup du dossier ~/.ssh ---${RESET}"
    ts=$(date +"%Y%m%d-%H%M%S")
    dest="$HOME/.ssh-backup-$ts.tar.gz"
    tar -czf "$dest" -C "$HOME" .ssh
    echo -e "${VERT}Backup créé : $dest${RESET}"
}

# 14) Restore d’un backup ~/.ssh
restore_ssh() {
    echo -e "${BLEU}--- Restore d'un backup ~/.ssh ---${RESET}"
    read -p "Chemin du fichier backup (.tar.gz) : " fichier

    if [ ! -f "$fichier" ]; then
        echo -e "${ROUGE}Erreur : fichier introuvable.${RESET}"
        return
    fi

    mkdir -p ~/.ssh
    tar -xzf "$fichier" -C "$HOME"
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/id_ed25519_* 2>/dev/null
    chmod 644 ~/.ssh/id_ed25519_*.pub 2>/dev/null

    echo -e "${VERT}Backup restauré et permissions corrigées.${RESET}"
}

# MENU PRINCIPAL
menu_principal() {
    clear
    echo -e "${JAUNE}==============================================${RESET}"
    echo -e "${JAUNE}   COCKPIT SSH + TOKEN – BERNARDOPS V9 PRO    ${RESET}"
    echo -e "${JAUNE}==============================================${RESET}"

    echo -e "${BLEU}1) Générer une nouvelle clé SSH${RESET}"
    echo -e "${BLEU}2) Ajouter une clé à l'agent SSH${RESET}"
    echo -e "${BLEU}3) Afficher une clé publique${RESET}"
    echo -e "${BLEU}4) Ajouter un bloc dans ~/.ssh/config${RESET}"
    echo -e "${BLEU}5) Tester une connexion SSH${RESET}"
    echo -e "${BLEU}6) Lister les clés disponibles${RESET}"
    echo -e "${BLEU}7) Initialiser le token GitHub${RESET}"
    echo -e "${BLEU}8) Corriger les permissions SSH${RESET}"
    echo -e "${BLEU}9) Diagnostic automatique SSH${RESET}"
    echo -e "${BLEU}10) Supprimer une clé SSH${RESET}"
    echo -e "${BLEU}11) Supprimer TOUTES les clés SSH${RESET}"
    echo -e "${BLEU}12) Ajouter / Modifier le mot de passe d'une clé SSH${RESET}"
    echo -e "${BLEU}13) Backup du dossier ~/.ssh${RESET}"
    echo -e "${BLEU}14) Restore d'un backup ~/.ssh${RESET}"
    echo -e "${BLEU}0) Quitter${RESET}"

    echo ""
    read -p "Choix : " choix

    case $choix in
        1) generer_cle ;;
        2) ajouter_agent ;;
        3) afficher_pub ;;
        4) configurer_ssh ;;
        5) tester_connexion ;;
        6) liste_cles ;;
        7) initialiser_token ;;
        8) corriger_permissions ;;
        9) diagnostic_ssh ;;
        10) supprimer_une_cle ;;
        11) supprimer_toutes_cles ;;
        12) modifier_passphrase ;;
        13) backup_ssh ;;
        14) restore_ssh ;;
        0) exit 0 ;;
        *) echo -e "${ROUGE}Choix invalide.${RESET}" ;;
    esac

    echo ""
    read -p "Appuie sur ENTER pour revenir au menu..."
    menu_principal
}

menu_principal
