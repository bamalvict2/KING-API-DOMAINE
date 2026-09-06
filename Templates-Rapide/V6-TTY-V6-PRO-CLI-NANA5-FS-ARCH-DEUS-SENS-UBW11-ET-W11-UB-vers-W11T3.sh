#!/bin/bash

#############################################
# BernardOps-Ultimate-V6.2
# - Mode GUI / CLI auto
# - Mode secours TTY
# - Montage intelligent (VMware / WSL2 / SMB guest)
# - Sauvegarde / Restauration / Rotation / Logs
#############################################

# ───────── CONFIG ─────────

MOUNT_POINT="/mnt/NanaV6"
HGFS_SHARE=".host:/NanaV6"
SMB_SHARE="//192.168.1.178/NanaV6"   # SMB invité
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
    echo "[$(date '+%F %T')] $1 | $2" >> "$LOG_FILE"
}

# ───────── DÉTECTION MODE GUI/CLI ─────────

detect_mode() {
    if [[ -n "$DISPLAY" && -x /usr/bin/zenity ]]; then
        MODE="GUI"
    else
        MODE="CLI"
    fi
}

detect_mode

# ───────── DÉTECTION ENVIRONNEMENT ─────────

detect_env() {
    if grep -qi "microsoft" /proc/version 2>/dev/null; then
        echo "WSL2"
    elif command -v dmidecode >/dev/null 2>&1 && dmidecode | grep -qi "vmware"; then
        echo "VMWARE"
    else
        echo "PHYSICAL"
    fi
}

# ───────── MONTAGE NanaV6 ─────────

mount_nana() {
    step "Montage NanaV6"
    sudo mkdir -p "$MOUNT_POINT"

    if mountpoint -q "$MOUNT_POINT"; then
        ok "Déjà monté"
        return
    fi

    ENV=$(detect_env)

    case "$ENV" in
        WSL2)
            ok "WSL2 détecté → utilisation de /mnt/c/NanaV6"
            MOUNT_POINT="/mnt/c/NanaV6"
            return
            ;;

        VMWARE)
            step "VMware détecté → HGFS"
            sudo vmhgfs-fuse "$HGFS_SHARE" "$MOUNT_POINT" \
                -o allow_other,uid=$(id -u),gid=$(id -g) \
                || err "Erreur montage HGFS"
            ok "Monté via HGFS"
            return
            ;;

        PHYSICAL)
            step "Machine physique → SMB invité"
            sudo mount -t cifs "$SMB_SHARE" "$MOUNT_POINT" -o guest \
                || err "Erreur montage SMB invité"
            ok "Monté via SMB invité"
            return
            ;;
    esac
}

# ───────── ROTATION ─────────

rotation() {
    step "Rotation des sauvegardes"
    local backups=($(ls -1t "$MOUNT_POINT"/Backup-*.tar.gz 2>/dev/null))

    if (( ${#backups[@]} > MAX_BACKUPS )); then
        for f in "${backups[@]:MAX_BACKUPS}"; do
            rm -f "$f"
            log_event "ROTATION" "Suppression $f"
        done
        ok "Rotation effectuée"
    else
        ok "Aucune rotation nécessaire"
    fi
}

# ───────── ARCHIVE ─────────

create_archive() {
    local project="$1"
    shift
    local selected=("$@")

    local base="$(basename "$project")"
    ARCHIVE_NAME="Backup-${base}-$(date '+%Y%m%d-%H%M').tar.gz"
    ARCHIVE_PATH="$HOME/$ARCHIVE_NAME"

    step "Création archive : $ARCHIVE_NAME"

    tar -cf - "${selected[@]}" 2>>"$LOG_FILE" | pigz -c > "$ARCHIVE_PATH" \
        || err "Erreur création archive"

    ok "Archive créée"
}

copy_archive() {
    step "Copie vers NanaV6"
    sudo cp "$ARCHIVE_PATH" "$MOUNT_POINT/" || err "Erreur copie"
    ok "Copie OK"
}

# ───────── RESTAURATION ─────────

restore_generic() {
    local archive="$1"
    local dest="$2"

    [[ ! -f "$archive" ]] && err "Archive introuvable"
    mkdir -p "$dest"

    step "Restauration → $dest"
    tar -xzf "$archive" -C "$dest" || err "Erreur restauration"
    ok "Restauration terminée"
}

# ───────── LISTE ─────────

list_archives() {
    mount_nana
    ls -1 "$MOUNT_POINT"/Backup-*.tar.gz 2>/dev/null || echo "Aucune archive"
}

# ───────── CHECK ─────────

check_system() {
    echo "=== CHECK ==="
    echo "pigz : $(command -v pigz >/dev/null && echo OK || echo ABSENT)"
    echo "zenity : $(command -v zenity >/dev/null && echo OK || echo ABSENT)"
    echo "Environnement : $(detect_env)"
    echo "Montage : $(mountpoint -q "$MOUNT_POINT" && echo OK || echo NON)"
}

# ───────── SÉLECTION CLI ─────────

select_project_CLI() {
    echo -n "Chemin du projet : "
    read PROJECT
    [[ ! -d "$PROJECT" ]] && err "Projet invalide"
}

select_subdirs_CLI() {
    mapfile -t SUBDIRS < <(find "$PROJECT" -maxdepth 1 -mindepth 1 -type d)

    echo "Sous-dossiers :"
    local i=1
    for d in "${SUBDIRS[@]}"; do echo "$i) $d"; ((i++)); done

    echo -n "Choix (ex: 1 2 3) : "
    read choices

    SELECTED=()
    for n in $choices; do
        SELECTED+=("${SUBDIRS[$((n-1))]}")
    done
}

# ───────── WORKFLOW CLI ─────────

workflow_backup_CLI() {
    select_project_CLI
    select_subdirs_CLI
    create_archive "$PROJECT" "${SELECTED[@]}"
    mount_nana
    copy_archive
    rotation
}

workflow_restore_CLI() {
    mount_nana
    echo -n "Archive : "
    read archive
    echo -n "Destination : "
    read dest
    restore_generic "$archive" "$dest"
}

# ───────── MENUS ─────────

menu_CLI() {
    while true; do
        echo "1) Sauvegarde"
        echo "2) Restauration"
        echo "3) Lister"
        echo "4) Check"
        echo "5) Quitter"
        read c

        case "$c" in
            1) workflow_backup_CLI ;;
            2) workflow_restore_CLI ;;
            3) list_archives ;;
            4) check_system ;;
            5) exit 0 ;;
        esac
    done
}

menu_GUI() {
    choice=$(zenity --list --title="BernardOps V6.2" \
        --column="Action" "Sauvegarde" "Restauration" "Lister" "Check" "Quitter")

    case "$choice" in
        Sauvegarde) workflow_backup_CLI ;;
        Restauration) workflow_restore_CLI ;;
        Lister) list_archives ;;
        Check) check_system ;;
        Quitter) exit 0 ;;
    esac
}

# ───────── DISPATCH ─────────

case "$1" in
    --auto) PROJECT="$2"; mapfile -t SELECTED < <(find "$PROJECT" -maxdepth 1 -mindepth 1 -type d); create_archive "$PROJECT" "${SELECTED[@]}"; mount_nana; copy_archive; rotation; exit ;;
    --restore) restore_generic "$2" "$3"; exit ;;
    --list) list_archives; exit ;;
    --check) check_system; exit ;;
esac

# ───────── LANCEMENT ─────────

[[ "$MODE" == "GUI" ]] && menu_GUI || menu_CLI
