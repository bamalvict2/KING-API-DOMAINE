#!/bin/bash

#############################################
# BernardOps-Ultimate-V4
# - Sauvegarde projets (menu Zenity)
# - Compression pigz
# - Rotation des sauvegardes (5 dernières)
# - Logs détaillés
# - Restauration depuis Nana5
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

log_event() {
    # log_event "TYPE" "MESSAGE"
    echo "[$(date '+%F %T')] $1 | $2" >> "$LOG_FILE"
}

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

    local base="$(basename "$project")"
    ARCHIVE_NAME="Backup-${base}-$(date '+%Y%m%d-%H%M').tar.gz"
    ARCHIVE_PATH="$HOME/$ARCHIVE_NAME"

    step "Création de l’archive (pigz) : $ARCHIVE_NAME"

    # Vérifie pigz
    if ! command -v pigz >/dev/null 2>&1; then
        err "pigz non installé (sudo apt install pigz)"
    fi

    # tar + pigz
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

restaurer_archive() {
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

# ───────── SÉLECTION PROJET + SOUS-DOSSIERS (Zenity) ─────────

choisir_projet() {
    local project
    project=$(zenity --file-selection --directory \
        --title="Choisir le dossier du projet") || return 1

    [[ ! -d "$project" ]] && err "Dossier invalide"

    PROJECT="$project"
    return 0
}

choisir_sous_dossiers() {
    local list tmpfile
    tmpfile=$(mktemp)

    # Liste des sous-dossiers
    mapfile -t SUBDIRS < <(find "$PROJECT" -maxdepth 1 -mindepth 1 -type d | sort)

    if (( ${#SUBDIRS[@]} == 0 )); then
        err "Aucun sous-dossier trouvé dans $PROJECT"
    fi

    # Construire la liste pour Zenity checklist
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

    if [[ $? -ne 0 ]]; then
        rm -f "$tmpfile"
        return 1
    fi

    IFS="|" read -r -a SELECTED <<< "$(cat "$tmpfile")"
    rm -f "$tmpfile"

    if (( ${#SELECTED[@]} == 0 )); then
        err "Aucun sous-dossier sélectionné"
    fi
}

# ───────── WORKFLOW SAUVEGARDE ─────────

workflow_sauvegarde() {
    if ! choisir_projet; then
        return
    fi

    choisir_sous_dossiers || return

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

# ───────── MENU PRINCIPAL (Zenity) ─────────

menu_principal() {
    while true; do
        choice=$(zenity --list \
            --title="BernardOps-Ultimate-V4" \
            --text="Choisis une action" \
            --column="Action" --column="Description" \
            "Sauvegarde" "Créer une sauvegarde vers Nana5" \
            "Restauration" "Restaurer une archive depuis Nana5" \
            "Quitter" "Fermer BernardOps")

        case "$choice" in
            "Sauvegarde")  workflow_sauvegarde ;;
            "Restauration") restaurer_archive ;;
            "Quitter"|"")  exit 0 ;;
        esac
    done
}

# ───────── LANCEMENT ─────────

menu_principal
