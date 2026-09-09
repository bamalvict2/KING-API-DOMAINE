#!/bin/bash

# ───────────────────────────────────────────────
# 🎨 Couleurs & fonctions UI
# ───────────────────────────────────────────────

CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

step() { echo -e "${CYAN}➡️  $1${NC}"; }
ok()   { echo -e "${GREEN}✔️  $1${NC}"; }
err()  { echo -e "${RED}❌  $1${NC}"; exit 1; }
pause(){ echo -e "${YELLOW}⏸️  Appuie sur Entrée pour continuer...${NC}"; read; }

# ───────────────────────────────────────────────
# 🔧 CONFIG
# ───────────────────────────────────────────────

MOUNT_POINT="/mnt/Nanav6"
SHARE_NAME=".host:/Nanav6"




# Fichiers système à inclure uniquement s'ils existent
SYSTEM_FILES=()

[[ -f "$HOME/.bashrc" ]] && SYSTEM_FILES+=("$HOME/.bashrc")
[[ -f "$HOME/.bash_aliases" ]] && SYSTEM_FILES+=("$HOME/.bash_aliases")
[[ -f "$HOME/.bash_profile" ]] && SYSTEM_FILES+=("$HOME/.bash_profile")


# ───────────────────────────────────────────────
# 📦 Création archive
# ───────────────────────────────────────────────

creer_archive() {
    ARCHIVE_NAME="Backup-$(basename "$PROJECT")-$(date '+%Y%m%d-%H%M').tar.gz"
    ARCHIVE_PATH="$HOME/$ARCHIVE_NAME"

    step "Création de l’archive : $ARCHIVE_NAME"

    sudo tar -czhf "$ARCHIVE_PATH" "${SELECTED[@]}" \
        || err "Erreur création archive"

    ok "Archive créée : $ARCHIVE_PATH"
}

# ───────────────────────────────────────────────
# 🪟 Montage Windows
# ───────────────────────────────────────────────

monter_windows() {
    step "Montage du partage Windows"

    sudo mkdir -p "$MOUNT_POINT"

    if mountpoint -q "$MOUNT_POINT"; then
        ok "Partage déjà monté"
    else
        sudo mount -t fuse.vmhgfs-fuse "$SHARE_NAME" "$MOUNT_POINT" \
            -o allow_other,uid=$(id -u),gid=$(id -g) \
            || err "Erreur montage Windows"
        ok "Partage Windows monté"
    fi
}

# ───────────────────────────────────────────────
# 📤 Copie vers Windows
# ───────────────────────────────────────────────

copier_archive() {
    step "Copie de l’archive vers Windows"
    sudo cp "$ARCHIVE_PATH" "$MOUNT_POINT/" \
        || err "Erreur copie vers Windows"

    ok "Copie OK : $MOUNT_POINT/$ARCHIVE_NAME"
}

# ───────────────────────────────────────────────
# 🧭 MENU PRINCIPAL
# ───────────────────────────────────────────────

menu_principal() {
    clear
    echo -e "${CYAN}🧭 BernardOps – Menu Principal${NC}"
    echo
    echo "  1) Choisir un projet (chemin libre)"
    echo "  2) Quitter"
    echo
    echo -n "Ton choix : "
    read -r CHOICE

    case "$CHOICE" in
        1) choisir_projet ;;
        2) exit 0 ;;
        *) echo -e "${RED}❌ Choix invalide${NC}"; menu_principal ;;
    esac
}

# ───────────────────────────────────────────────
# 📁 CHOIX DU PROJET
# ───────────────────────────────────────────────

choisir_projet() {
    clear
    step "Entre le chemin du projet (ex: /home/bamalvict/EPARVIER ou /opt/KING-AO)"
    read -r PROJECT_PATH

    [[ ! -d "$PROJECT_PATH" ]] && err "Dossier invalide"

    PROJECT="$PROJECT_PATH"
    detect_subdirs
}

# ───────────────────────────────────────────────
# 🔍 DÉTECTION DES SOUS-DOSSIERS & FICHIERS
# ───────────────────────────────────────────────

detect_subdirs() {
    SUBDIRS=($(find "$PROJECT" -maxdepth 1 -mindepth 1 -type d))
    FILES=($(find "$PROJECT" -maxdepth 1 -mindepth 1 -type f))

    select_subdirs
}

# ───────────────────────────────────────────────
# 📁 MENU DE SÉLECTION
# ───────────────────────────────────────────────

select_subdirs() {
    clear
    echo -e "${CYAN}📁 Contenu trouvé dans : $PROJECT${NC}"
    echo

    local i=1
    echo "📂 Dossiers :"
    for d in "${SUBDIRS[@]}"; do
        echo "  $i) $(basename "$d")"
        ((i++))
    done

    echo
    echo "📄 Fichiers :"
    local j=1
    for f in "${FILES[@]}"; do
        echo "  f$j) $(basename "$f")"
        ((j++))
    done

    echo
    echo "  a) Tous les dossiers"
    echo "  p) Projet complet + fichiers système"
    echo "  m) Sélection multiple (ex: 1 3 f2)"
    echo "  q) Retour menu principal"
    echo
    echo -n "Ton choix : "
    read -r choice

    case "$choice" in
        a)
            SELECTED=("${SUBDIRS[@]}")
            ;;
        p)
            SELECTED=("$PROJECT" "${SYSTEM_FILES[@]}")
            ;;
        m)
            echo -n "Entre les numéros séparés par des espaces : "
            read -r multi
            for n in $multi; do
                if [[ "$n" =~ ^[0-9]+$ ]] && (( n>=1 && n<=${#SUBDIRS[@]} )); then
                    SELECTED+=("${SUBDIRS[$((n-1))]}")
                elif [[ "$n" =~ ^f[0-9]+$ ]]; then
                    idx=${n:1}
                    if (( idx>=1 && idx<=${#FILES[@]} )); then
                        SELECTED+=("${FILES[$((idx-1))]}")
                    else
                        echo -e "${RED}❌ Numéro fichier invalide : $n${NC}"
                    fi
                else
                    echo -e "${RED}❌ Numéro invalide : $n${NC}"
                fi
            done
            ;;
        q)
            menu_principal
            ;;
        *)
            if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice>=1 && choice<=${#SUBDIRS[@]} )); then
                SELECTED=("${SUBDIRS[$((choice-1))]}")
            else
                echo -e "${RED}❌ Choix invalide${NC}"
                select_subdirs
            fi
            ;;
    esac

    workflow_complet
}

# ───────────────────────────────────────────────
# 🚀 WORKFLOW COMPLET
# ───────────────────────────────────────────────

workflow_complet() {
    clear
    step "Éléments sélectionnés :"
    printf "%s\n" "${SELECTED[@]}"
    pause

    creer_archive
    pause

    monter_windows
    pause

    copier_archive
    pause

    ok "🎉 Sauvegarde terminée avec succès !"
    pause

    menu_principal
}

# ───────────────────────────────────────────────
# 🚀 LANCEMENT
# ───────────────────────────────────────────────

menu_principal
