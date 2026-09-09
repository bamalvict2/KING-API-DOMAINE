#!/bin/bash

#############################################
# BernardOps-Ultimate-V5
# - Sauvegarde projets → Nana5
# - Compression pigz
# - Rotation (5 dernières sauvegardes)
# - Logs détaillés
# - Restauration
# - Mode GUI (Zenity) + Mode CLI (--mode CLI)
#############################################

# ───────── CONFIG ─────────

MOUNT_POINT="/mnt/Nana5"
SHARE_NAME=".host:/Nana5"
LOG_FILE="$HOME/BernardOps.log"
MAX_BACKUPS=5

CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

step() { echo -e "${CYAN}➡️  $1${NC}"; }
ok()   { echo -e "${GREEN}✔️  $1${NC}"; }
err()  { echo -e "${RED}❌  $1${NC}"; echo "[$(date '+%F %T')] ERROR: $1" >> "$LOG_FILE"; exit 1; }
pause(){ echo -e "${YELLOW}⏸️  Appuie sur Entrée pour continuer...${NC}"; read; }

log_event() {
    # log_event "TYPE" "MESSAGE"
    echo "[$(date '+%F %T')] $1 | $2" >> "$LOG_FILE"
}

# ───────── DÉTECTION MODE ─────────

MODE="GUI"

if [[ "$1" == "--mode" ]]; then
    case "$2" in
        CLI|cli) MODE="CLI" ;;
        GUI|gui) MODE="GUI" ;;
    esac
fi

# Si Zenity absent → bascule en CLI
if [[ "$MODE" == "GUI" ]] && ! command -v zenity >/dev/null 2>&1; then
    step "Zenity non trouvé, bascule en mode CLI"
    MODE="CLI"
fi

# ───────── MONTAGE NANA5 ─────────

monter_windows() {
    step "Montage du partage Windows"
    sudo mkdir -p "$MOUNT_POINT"

    if mountpoint -q "$MOUNT_POINT"; then
        ok "Partage déjà monté"
        log_event "INFO" "Partage $MOUNT_POINT déjà monté"
    else
        sudo mount -t fuse.vmhgfs-fuse "$SHARE_NAME" "$MOUNT_POINT" \
            -o allow_other,uid=$(id -u),gid=$(id -g) \
            || err "Erreur montage Windows"
        ok "Partage Windows monté"
        log_event "INFO" "Partage $MOUNT_POINT monté"
    fi
}

# ───────── ROTATION DES SAUVEGARDES ─────────

rotation_sauvegardes() {
    step "Rotation des sauvegardes (max $MAX_BACKUPS)"
    local pattern="$MOUNT_POINT/Backup-*.tar.gz"
    local backups=($(ls -1t $pattern 2>/dev/null))

    if (( ${#backups[@]} > MAX_BACKUPS )); then
        local to_delete=("${backups[@]:MAX_BACKUPS}")
        for f in "${to_delete[@]}"; do
            rm -f "$f" && log_event "ROTATION" "Suppression ancienne sauvegarde: $f"
        done
        ok "Rotation effectuée"
    else
        ok "Aucune rotation nécessaire"
    fi
}

# ───────── CRÉATION ARCHIVE (pigz) ─────────

creer_archive() {
    local project="$1"
    shift
    local selected=("$@")

    local base
    base="$(basename "$project")"
    ARCHIVE_NAME="Backup-${base}-$(date '+%Y%m%d-%H%M').tar.gz"
    ARCHIVE_PATH="$HOME/$ARCHIVE_NAME"

    step "Création de l’archive (pigz) : $ARCHIVE_NAME"

    if ! command -v pigz >/dev/null 2>&1; then
        err "pigz non installé (sudo apt install pigz)"
    fi

    tar -cf - "${selected[@]}" 2>>"$LOG_FILE" | pigz -c > "$ARCHIVE_PATH" \
        || err "Erreur création archive"

    ok "Archive créée : $ARCHIVE_PATH"
    log_event "BACKUP" "Archive créée: $ARCHIVE_PATH | Projet: $project | Dossiers: ${selected[*]}"
}

# ───────── COPIE VERS NANA5 ─────────

copier_archive() {
    step "Copie de l’archive vers Windows"
    sudo cp "$ARCHIVE_PATH" "$MOUNT_POINT/" \
        || err "Erreur copie vers Windows"

    ok "Copie OK : $MOUNT_POINT/$ARCHIVE_NAME"
    log_event "COPY" "Copie vers $MOUNT_POINT/$ARCHIVE_NAME"
}

# ───────── RESTAURATION ─────────

restaurer_archive_GUI() {
    monter_windows

    local archive dest

    archive=$(zenity --file-selection \
        --title="Choisir une archive à restaurer" \
        --filename="$MOUNT_POINT/Backup-*.tar.gz") || return

    dest=$(zenity --file-selection --directory \
        --title="Choisir le dossier de destination") || return

    step "Restauration de $archive vers $dest"
    mkdir -p "$dest"

    if tar -xzf "$archive" -C "$dest" 2>>"$LOG_FILE"; then
        ok "Restauration terminée"
        log_event "RESTORE" "Archive: $archive -> $dest"
        zenity --info --title="Restauration" --text="Restauration terminée dans :\n$dest"
    else
        err "Erreur lors de la restauration"
    fi
}

restaurer_archive_CLI() {
    monter_windows

    echo "Archives disponibles dans $MOUNT_POINT :"
    mapfile -t archives < <(ls -1 "$MOUNT_POINT"/Backup-*.tar.gz 2>/dev/null)

    if (( ${#archives[@]} == 0 )); then
        err "Aucune archive trouvée dans $MOUNT_POINT"
    fi

    local i=1
    for a in "${archives[@]}"; do
        echo "  $i) $(basename "$a")"
        ((i++))
    done

    echo -n "Numéro de l’archive à restaurer : "
    read -r idx

    if ! [[ "$idx" =~ ^[0-9]+$ ]] || (( idx < 1 || idx > ${#archives[@]} )); then
        err "Choix invalide"
    fi

    local archive="${archives[$((idx-1))]}"

    echo -n "Dossier de destination (ex: /opt/KING-AO-Restored) : "
    read -r dest

    [[ -z "$dest" ]] && err "Destination vide"
    mkdir -p "$dest"

    step "Restauration de $archive vers $dest"

    if tar -xzf "$archive" -C "$dest" 2>>"$LOG_FILE"; then
        ok "Restauration terminée"
        log_event "RESTORE" "Archive: $archive -> $dest"
    else
        err "Erreur lors de la restauration"
    fi
}

# ───────── SÉLECTION PROJET + SOUS-DOSSIERS (GUI) ─────────

choisir_projet_GUI() {
    local project
    project=$(zenity --file-selection --directory \
        --title="Choisir le dossier du projet") || return 1

    [[ ! -d "$project" ]] && err "Dossier invalide"

    PROJECT="$project"
    return 0
}

choisir_sous_dossiers_GUI() {
    local list tmpfile
    tmpfile=$(mktemp)

    mapfile -t SUBDIRS < <(find "$PROJECT" -maxdepth 1 -mindepth 1 -type d | sort)

    (( ${#SUBDIRS[@]} == 0 )) && err "Aucun sous-dossier trouvé dans $PROJECT"

    list=()
    for d in "${SUBDIRS[@]}"; do
        list+=("FALSE" "$(basename "$d")" "$d")
    done

    zenity --list \
        --title="Sélection des sous-dossiers" \
        --text="Choisis les sous-dossiers à sauvegarder" \
        --checklist \
        --column="Choix" --column="Nom" --column="Chemin" \
        "${list[@]}" > "$tmpfile"

    [[ $? -ne 0 ]] && { rm -f "$tmpfile"; return 1; }

    IFS="|" read -r -a SELECTED <<< "$(cat "$tmpfile")"
    rm -f "$tmpfile"

    (( ${#SELECTED[@]} == 0 )) && err "Aucun sous-dossier sélectionné"
}

# ───────── SÉLECTION PROJET + SOUS-DOSSIERS (CLI) ─────────

choisir_projet_CLI() {
    step "Entre le chemin du projet (ex: /home/bamalvict/EPARVIER ou /opt/KING-AO)"
    read -r project

    [[ ! -d "$project" ]] && err "Dossier invalide"

    PROJECT="$project"
}

choisir_sous_dossiers_CLI() {
    mapfile -t SUBDIRS < <(find "$PROJECT" -maxdepth 1 -mindepth 1 -type d | sort)

    (( ${#SUBDIRS[@]} == 0 )) && err "Aucun sous-dossier trouvé dans $PROJECT"

    echo -e "${CYAN}📁 Sous-dossiers trouvés dans : $PROJECT${NC}"
    local i=1
    for d in "${SUBDIRS[@]}"; do
        echo "  $i) $(basename "$d")"
        ((i++))
    done

    echo "  a) Tous les dossiers"
    echo "  m) Sélection multiple (ex: 1 3 4)"
    echo
    echo -n "Ton choix : "
    read -r choice

    case "$choice" in
        a)
            SELECTED=("${SUBDIRS[@]}")
            ;;
        m)
            echo -n "Entre les numéros séparés par des espaces : "
            read -r multi
            for n in $multi; do
                if [[ "$n" =~ ^[0-9]+$ ]] && (( n>=1 && n<=${#SUBDIRS[@]} )); then
                    SELECTED+=("${SUBDIRS[$((n-1))]}")
                else
                    echo -e "${RED}❌ Numéro invalide : $n${NC}"
                fi
            done
            (( ${#SELECTED[@]} == 0 )) && err "Aucun dossier valide sélectionné"
            ;;
        *)
            if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice>=1 && choice<=${#SUBDIRS[@]} )); then
                SELECTED=("${SUBDIRS[$((choice-1))]}")
            else
                err "Choix invalide"
            fi
            ;;
    esac
}

# ───────── WORKFLOW SAUVEGARDE ─────────

workflow_sauvegarde_GUI() {
    if ! choisir_projet_GUI; then
        return
    fi

    choisir_sous_dossiers_GUI || return

    step "Projet sélectionné : $PROJECT"
    step "Dossiers sélectionnés :"
    for d in "${SELECTED[@]}"; do
        echo "  - $d"
    done

    creer_archive "$PROJECT" "${SELECTED[@]}"
    monter_windows
    copier_archive
    rotation_sauvegardes

    ok "🎉 Sauvegarde terminée"
    zenity --info --title="Sauvegarde" --text="Sauvegarde terminée.\nArchive : $ARCHIVE_NAME"
}

workflow_sauvegarde_CLI() {
    choisir_projet_CLI
    choisir_sous_dossiers_CLI

    step "Projet sélectionné : $PROJECT"
    step "Dossiers sélectionnés :"
    for d in "${SELECTED[@]}"; do
        echo "  - $d"
    done
    pause

    creer_archive "$PROJECT" "${SELECTED[@]}"
    pause

    monter_windows
    pause

    copier_archive
    rotation_sauvegardes

    ok "🎉 Sauvegarde terminée"
    pause
}

# ───────── MENUS PRINCIPAUX ─────────

menu_principal_GUI() {
    while true; do
        choice=$(zenity --list \
            --title="BernardOps-Ultimate-V5" \
            --text="Choisis une action" \
            --column="Action" --column="Description" \
            "Sauvegarde" "Créer une sauvegarde vers Nana5" \
            "Restauration" "Restaurer une archive depuis Nana5" \
            "Quitter" "Fermer BernardOps")

        case "$choice" in
            "Sauvegarde")   workflow_sauvegarde_GUI ;;
            "Restauration") restaurer_archive_GUI ;;
            "Quitter"|"" )  exit 0 ;;
        esac
    done
}

menu_principal_CLI() {
    while true; do
        echo -e "${CYAN}🧭 BernardOps-Ultimate-V5 (mode CLI)${NC}"
        echo
        echo "  1) Sauvegarde vers Nana5"
        echo "  2) Restauration depuis Nana5"
        echo "  3) Quitter"
        echo
        echo -n "Ton choix : "
        read -r c

        case "$c" in
            1) workflow_sauvegarde_CLI ;;
            2) restaurer_archive_CLI ;;
            3) exit 0 ;;
            *) echo -e "${RED}❌ Choix invalide${NC}" ;;
        esac
    done
}

# ───────── LANCEMENT ─────────

if [[ "$MODE" == "GUI" ]]; then
    menu_principal_GUI
else
    menu_principal_CLI
fi
